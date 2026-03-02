import 'package:darkness_dungeon/menu.dart';
import 'package:darkness_dungeon/util/localization/my_localizations_delegate.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:darkness_dungeon/util/logger.dart';
import 'package:darkness_dungeon/services/ad_service.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// La constante tileSize ahora está en constants/game_constants.dart

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Mantener la splash screen nativa visible mientras se inicializa todo
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar AdMob
  await AdService().initialize();

  // Pre-cargar anuncios
  AdService().loadInterstitialAd();
  AdService().loadRewardedAd();

  // Inicializar sonidos (AudioPools)
  await Sounds.initialize();

  // Pre-cargar inventario para evitar lag al abrir UI
  await PlayerInventory().loadInventory();

  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }

  // Prueba
  MyLocalizationsDelegate myLocation = const MyLocalizationsDelegate();

  // Remover splash screen nativa - la app está lista
  FlutterNativeSplash.remove();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Normal',
        scaffoldBackgroundColor: const Color(0xFF0d0d1a),
      ),
      home: Menu(),
      // Forzar español en toda la aplicación (Android & iOS)
      locale: const Locale('es', 'ES'),
      supportedLocales: [const Locale('es', 'ES')], // Solo español
      localizationsDelegates: [
        myLocation,
        DefaultCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Siempre devolver español, sin importar el idioma del dispositivo
        GameLogger.info('Forzando idioma a español');
        return const Locale('es', 'ES');
      },
    ),
  );
}
