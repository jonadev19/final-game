import 'package:bonfire/bonfire.dart';

class NpcSpriteSheet {
  static Future<SpriteAnimation> kidIdleLeft() => SpriteAnimation.load(
        'npc/kid_idle_left.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(16, 22),
        ),
      );

  static Future<SpriteAnimation> wizardIdleLeft() => SpriteAnimation.load(
        'npc/wizard_idle_left.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(16, 22),
        ),
      );

  // Kid Level 3 (Full PNG 138x252 - 2 frames verticales de 138x126)
  static Future<SpriteAnimation> kidL3IdleLeft() => SpriteAnimation.load(
        'npc/kidL3/kidL3_full.png',
        SpriteAnimationData.sequenced(
          amount: 1, // Estático
          stepTime: 0.1,
          textureSize: Vector2(138, 126), // Mitad de 252
          texturePosition: Vector2(0, 0), // Arriba (Asumiendo Left)
        ),
      );

  static Future<SpriteAnimation> kidL3IdleRight() => SpriteAnimation.load(
        'npc/kidL3/kidL3_full.png',
        SpriteAnimationData.sequenced(
          amount: 1, // Estático
          stepTime: 0.1,
          textureSize: Vector2(138, 126),
          texturePosition: Vector2(0, 126), // Abajo (Asumiendo Right)
        ),
      );
}
