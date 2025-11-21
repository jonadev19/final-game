import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darkness_dungeon/util/logger.dart';

class PlayerInventory {
  static const String _coinsKey = 'player_coins';
  static const String _itemsKey = 'player_items';
  static const String _upgradesKey = 'player_upgrades';
  static const String _levelKey = 'player_max_level';

  // Singleton
  static final PlayerInventory _instance = PlayerInventory._internal();
  factory PlayerInventory() => _instance;
  PlayerInventory._internal();

  int _coins = 0;
  int _maxLevelReached = 1;
  Map<String, int> _consumableItems = {}; // itemId -> cantidad
  List<String> _permanentUpgrades = []; // upgrades permanentes compradas

  int get coins => _coins;
  int get maxLevelReached => _maxLevelReached;
  Map<String, int> get consumableItems => Map.unmodifiable(_consumableItems);
  List<String> get permanentUpgrades => List.unmodifiable(_permanentUpgrades);

  // Cargar datos guardados (Local + Nube)
  Future<void> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Cargar localmente primero (para rapidez)
    _coins = prefs.getInt(_coinsKey) ?? 0;
    _maxLevelReached = prefs.getInt(_levelKey) ?? 1;

    final itemsString = prefs.getStringList(_itemsKey) ?? [];
    _consumableItems.clear();
    for (String item in itemsString) {
      final parts = item.split(':');
      if (parts.length == 2) {
        _consumableItems[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }
    _permanentUpgrades = prefs.getStringList(_upgradesKey) ?? [];

    // 2. Intentar sincronizar con la nube si hay usuario logueado
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final cloudLevel = data['maxLevel'] as int? ?? 1;
          final cloudCoins = data['coins'] as int? ?? 0;

          // Lógica de conflicto simple: Si la nube tiene mayor progreso, usar nube.
          // O si es igual, usar el que tenga más monedas (opcional, aquí priorizamos nivel)
          if (cloudLevel > _maxLevelReached) {
            _maxLevelReached = cloudLevel;
            _coins = cloudCoins; // Asumimos que las monedas van con el nivel

            // Cargar items de nube
            if (data['items'] != null) {
              _consumableItems = Map<String, int>.from(data['items']);
            }
            // Cargar upgrades de nube
            if (data['upgrades'] != null) {
              _permanentUpgrades = List<String>.from(data['upgrades']);
            }

            // Actualizar local con lo nuevo de la nube
            await saveInventory(onlyLocal: true);
            GameLogger.info('Datos sincronizados desde la nube');
          } else {
            // Si local es más avanzado, actualizar nube
            if (_maxLevelReached > cloudLevel) {
              await saveInventory();
            }
          }
        }
      } catch (e) {
        GameLogger.error('Error cargando de nube: $e');
      }
    }
  }

  // Guardar datos (Local + Nube)
  Future<void> saveInventory({bool onlyLocal = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, _coins);
    await prefs.setInt(_levelKey, _maxLevelReached);

    final itemsString =
        _consumableItems.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList(_itemsKey, itemsString);
    await prefs.setStringList(_upgradesKey, _permanentUpgrades);

    if (onlyLocal) return;

    // Guardar en nube si hay usuario
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'coins': _coins,
          'maxLevel': _maxLevelReached,
          'items': _consumableItems,
          'upgrades': _permanentUpgrades,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        GameLogger.info('Datos guardados en la nube');
      } catch (e) {
        GameLogger.error('Error guardando en nube: $e');
      }
    }
  }

  // Agregar monedas
  Future<void> addCoins(int amount) async {
    _coins += amount;
    await saveInventory();
  }

  // Gastar monedas
  Future<bool> spendCoins(int amount) async {
    if (_coins >= amount) {
      _coins -= amount;
      await saveInventory();
      return true;
    }
    return false;
  }

  // Agregar item consumible
  Future<void> addConsumableItem(String itemId, int quantity) async {
    _consumableItems[itemId] = (_consumableItems[itemId] ?? 0) + quantity;
    await saveInventory();
  }

  // Usar item consumible
  Future<bool> useConsumableItem(String itemId) async {
    final quantity = _consumableItems[itemId] ?? 0;
    if (quantity > 0) {
      _consumableItems[itemId] = quantity - 1;
      if (_consumableItems[itemId] == 0) {
        _consumableItems.remove(itemId);
      }
      await saveInventory();
      return true;
    }
    return false;
  }

  // Obtener cantidad de un item consumible
  int getConsumableQuantity(String itemId) {
    return _consumableItems[itemId] ?? 0;
  }

  // Agregar upgrade permanente
  Future<void> addPermanentUpgrade(String upgradeId) async {
    if (!_permanentUpgrades.contains(upgradeId)) {
      _permanentUpgrades.add(upgradeId);
      await saveInventory();
    }
  }

  // Verificar si tiene un upgrade permanente
  bool hasPermanentUpgrade(String upgradeId) {
    return _permanentUpgrades.contains(upgradeId);
  }

  // Resetear inventario (para testing)
  Future<void> resetInventory() async {
    _coins = 0;
    _maxLevelReached = 1;
    _consumableItems.clear();
    _permanentUpgrades.clear();
    await saveInventory();
  }

  // Desbloquear siguiente nivel
  Future<void> unlockNextLevel(int currentLevel) async {
    if (currentLevel >= _maxLevelReached) {
      _maxLevelReached = currentLevel + 1;
      await saveInventory();
    }
  }
}
