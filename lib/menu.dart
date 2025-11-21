import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/screens/level_selection_screen.dart';
import 'package:darkness_dungeon/screens/login_screen.dart';
import 'package:darkness_dungeon/screens/levels/level2.dart';
import 'package:darkness_dungeon/shop/shop_screen.dart';
import 'package:darkness_dungeon/util/custom_sprite_animation_widget.dart';
import 'package:darkness_dungeon/util/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/util/localization/strings_location.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:darkness_dungeon/services/ad_service.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  int currentPosition = 0;
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
    startTimer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Container(
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // TÍTULO (Más pequeño en landscape)
                  _buildTitle(isLandscape),

                  SizedBox(height: isLandscape ? 10 : 30),

                  // PERSONAJE ANIMADO (Ocultar o reducir en landscape si es muy bajo)
                  if (sprites.isNotEmpty) _buildAnimatedCharacter(isLandscape),

                  SizedBox(height: isLandscape ? 20 : 50),

                  // BOTÓN JUGAR (Principal)
                  _buildMainButton(
                    label: getString('play_cap'),
                    icon: Icons.play_arrow_rounded,
                    color: Colors.deepPurple,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LevelSelectionScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // BOTONES SECUNDARIOS (Fila)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSecondaryButton(
                        label: 'Tienda',
                        icon: Icons.shopping_cart,
                        color: Colors.amber[800]!,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShopScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 15),
                      _buildSecondaryButton(
                        label: 'Cloud',
                        icon: Icons.cloud,
                        color: Colors.blue[700]!,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 15),
                      _buildSecondaryButton(
                        label: '+100 💰',
                        icon: Icons.video_library,
                        color: Colors.green[700]!,
                        onPressed: _showRewardAd,
                      ),
                    ],
                  ),

                  SizedBox(height: isLandscape ? 10 : 40),

                  // BOTÓN DEV (Discreto)
                  TextButton.icon(
                    icon:
                        Icon(Icons.bug_report, color: Colors.white24, size: 16),
                    label: Text(
                      'DEV: Nivel 2',
                      style: TextStyle(
                        fontFamily: 'Normal',
                        color: Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Level2()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isLandscape) {
    return Column(
      children: [
        Text(
          "FINAL",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Normal',
            fontSize: isLandscape ? 24.0 : 32.0,
            letterSpacing: 8,
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
            fontSize: isLandscape ? 40.0 : 56.0,
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

  Widget _buildAnimatedCharacter(bool isLandscape) {
    double size = isLandscape ? 80 : 120;
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animController.value * 10), // Flotar suavemente
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
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
  }

  Widget _buildMainButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 220,
      height: 60,
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
            Icon(icon, size: 28),
            SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Normal',
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, size: 18),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Normal',
                fontSize: 16.0,
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
    _timer = async.Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        currentPosition++;
        if (currentPosition > sprites.length - 1) {
          currentPosition = 0;
        }
      });
    });
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
