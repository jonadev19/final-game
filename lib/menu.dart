import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/screens/level_selection_screen.dart';
import 'package:darkness_dungeon/screens/login_screen.dart';
import 'package:darkness_dungeon/screens/levels/level2.dart';
import 'package:darkness_dungeon/screens/levels/level3.dart';
import 'package:darkness_dungeon/shop/shop_screen.dart';
import 'package:darkness_dungeon/util/custom_sprite_animation_widget.dart';
import 'package:darkness_dungeon/util/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/util/localization/strings_location.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:darkness_dungeon/services/ad_service.dart';

import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  // OPTIMIZADO: Usar ValueNotifier para evitar rebuilds completos
  final ValueNotifier<int> _currentPositionNotifier = ValueNotifier<int>(0);
  late async.Timer _timer;
  late AnimationController _animController;

  List<Future<SpriteAnimation>> sprites = [
    PlayerSpriteSheet.idleRight(),
    EnemySpriteSheet.goblinIdleRight(),
    EnemySpriteSheet.impIdleRight(),
    EnemySpriteSheet.miniBossIdleRight(),
    EnemySpriteSheet.bossIdleRight(),
  ];

  @override
  void initState() {
    super.initState();
    Sounds.playBackgroundSound();
    startTimer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    _currentPositionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isSmallScreen = size.height < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF2D1B4E), // Morado oscuro centro
              Colors.black, // Negro bordes
            ],
            radius: 1.3,
            center: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: isSmallScreen ? 15 : 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // TÍTULO (Responsive)
                    _buildTitleResponsive(
                      isLandscape ? 22.0 : (isSmallScreen ? 26.0 : 32.0),
                      isLandscape ? 36.0 : (isSmallScreen ? 42.0 : 56.0),
                    ),

                    SizedBox(
                        height: isLandscape ? 8 : (isSmallScreen ? 15 : 25)),

                    // PERSONAJE ANIMADO (Responsive)
                    if (sprites.isNotEmpty)
                      _buildAnimatedCharacterResponsive(
                        isLandscape ? 60.0 : (isSmallScreen ? 70.0 : 100.0),
                      ),

                    SizedBox(
                        height: isLandscape ? 15 : (isSmallScreen ? 20 : 30)),

                    // BOTÓN JUGAR (Principal)
                    _buildMainButton(
                      label: getString('play_cap'),
                      icon: Icons.play_arrow_rounded,
                      color: Colors.deepPurple,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LevelSelectionScreen()),
                        );
                      },
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 18),

                    // BOTONES SECUNDARIOS (Responsive)
                    _buildSecondaryButtonsRow(isSmallScreen),

                    SizedBox(height: isSmallScreen ? 12 : 20),

                    // BOTONES DEV (Discretos)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.bug_report,
                              color: Colors.white24, size: 14),
                          label: Text(
                            'DEV: Nivel 2',
                            style: TextStyle(
                              fontFamily: 'Normal',
                              color: Colors.white24,
                              fontSize: 11,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Level2()),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        TextButton.icon(
                          icon: Icon(Icons.whatshot,
                              color: Colors.orange.withOpacity(0.4), size: 14),
                          label: Text(
                            'DEV: Nivel 3',
                            style: TextStyle(
                              fontFamily: 'Normal',
                              color: Colors.orange.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Level3()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // OPTIMIZADO: Título responsive sin ScrollView
  Widget _buildTitleResponsive(double size1, double size2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "FINAL",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Normal',
            fontSize: size1,
            letterSpacing: size1 * 0.25,
            shadows: [
              Shadow(
                color: Colors.deepPurpleAccent.withOpacity(0.5),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        Text(
          "RELIC",
          style: TextStyle(
            color: Colors.amber,
            fontFamily: 'Normal',
            fontSize: size2,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.orange.withOpacity(0.5),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // OPTIMIZADO: Personaje responsive
  Widget _buildAnimatedCharacterResponsive(double size) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPositionNotifier,
      builder: (context, currentPosition, child) {
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animController.value * 8),
              child: Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: CustomSpriteAnimationWidget(
                  animation: sprites[currentPosition],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // OPTIMIZADO: Botones secundarios responsive
  Widget _buildSecondaryButtonsRow(bool isSmallScreen) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSecondaryButtonCompact(
          label: 'Tienda',
          icon: Icons.shopping_cart,
          color: Colors.amber[800]!,
          isSmall: isSmallScreen,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShopScreen()),
            );
          },
        ),
        _buildSecondaryButtonCompact(
          label: 'Cloud',
          icon: Icons.cloud,
          color: Colors.blue[700]!,
          isSmall: isSmallScreen,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        _buildSecondaryButtonCompact(
          label: '+100 💰',
          icon: Icons.video_library,
          color: Colors.green[700]!,
          isSmall: isSmallScreen,
          onPressed: _showRewardAd,
        ),
      ],
    );
  }

  // OPTIMIZADO: Botón principal responsive
  Widget _buildMainButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = MediaQuery.of(context).size.height < 600;
        final width = isSmallScreen ? 200.0 : 220.0;
        final height = isSmallScreen ? 52.0 : 58.0;
        final iconSize = isSmallScreen ? 24.0 : 28.0;
        final fontSize = isSmallScreen ? 19.0 : 22.0;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize),
                SizedBox(width: 10),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Normal',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // OPTIMIZADO: Botón secundario compacto y responsive
  Widget _buildSecondaryButtonCompact({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSmall,
    required VoidCallback onPressed,
  }) {
    final height = isSmall ? 38.0 : 42.0;
    final iconSize = isSmall ? 16.0 : 18.0;
    final fontSize = isSmall ? 13.0 : 15.0;
    final horizontalPadding = isSmall ? 14.0 : 18.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Normal',
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardAd() {
    if (AdService().isRewardedLoaded) {
      AdService().showRewardedAd(
        onRewardEarned: (amount) async {
          // Dar 100 monedas al usuario
          await PlayerInventory().addCoins(100);

          // Mostrar mensaje de éxito
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      '¡Has ganado 100 monedas! 💰',
                      style: TextStyle(
                        fontFamily: 'Normal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anuncio no disponible, intenta más tarde',
            style: TextStyle(fontFamily: 'Normal'),
          ),
          backgroundColor: Colors.orange[900],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void startTimer() {
    // OPTIMIZADO: Actualizar solo el ValueNotifier en lugar de setState
    _timer = async.Timer.periodic(Duration(seconds: 2), (timer) {
      _currentPositionNotifier.value++;
      if (_currentPositionNotifier.value > sprites.length - 1) {
        _currentPositionNotifier.value = 0;
      }
    });
  }
}
