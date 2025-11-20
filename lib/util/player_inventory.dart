import 'package:shared_preferences/shared_preferences.dart';

class PlayerInventory {
  static const String _coinsKey = 'player_coins';
  static const String _itemsKey = 'player_items';
  static const String _upgradesKey = 'player_upgrades';
  
  // Singleton
  static final PlayerInventory _instance = PlayerInventory._internal();
  factory PlayerInventory() => _instance;
  PlayerInventory._internal();
  
  int _coins = 0;
  Map<String, int> _consumableItems = {}; // itemId -> cantidad
  List<String> _permanentUpgrades = []; // upgrades permanentes compradas
  
  int get coins => _coins;
  Map<String, int> get consumableItems => Map.unmodifiable(_consumableItems);
  List<String> get permanentUpgrades => List.unmodifiable(_permanentUpgrades);
  
  // Cargar datos guardados
  Future<void> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(_coinsKey) ?? 0;
    
    // Cargar items consumibles
    final itemsString = prefs.getStringList(_itemsKey) ?? [];
    _consumableItems.clear();
    for (String item in itemsString) {
      final parts = item.split(':');
      if (parts.length == 2) {
        _consumableItems[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }
    
    // Cargar upgrades permanentes
    _permanentUpgrades = prefs.getStringList(_upgradesKey) ?? [];
  }
  
  // Guardar datos
  Future<void> saveInventory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, _coins);
    
    // Guardar items consumibles
    final itemsString = _consumableItems.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
    await prefs.setStringList(_itemsKey, itemsString);
    
    // Guardar upgrades permanentes
    await prefs.setStringList(_upgradesKey, _permanentUpgrades);
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
    _consumableItems.clear();
    _permanentUpgrades.clear();
    await saveInventory();
  }
}

