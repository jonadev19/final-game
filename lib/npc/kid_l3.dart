import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/enemies/boss_l3.dart';
import 'package:darkness_dungeon/menu.dart';
import 'package:darkness_dungeon/util/custom_sprite_animation_widget.dart';
import 'package:darkness_dungeon/util/player_inventory.dart';
import 'package:darkness_dungeon/util/dialogs.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/localization/strings_location.dart';
import 'package:darkness_dungeon/util/npc_sprite_sheet.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// NPC Kid para el Nivel 3
/// Detecta cuando el BossL3 muere y muestra la victoria final
class KidL3 extends GameDecoration {
  bool conversationWithHero = false;

  KidL3(
    Vector2 position,
  ) : super.withAnimation(
          animation: NpcSpriteSheet.kidL3IdleLeft(), // Usando nuevos sprites full
          position: position,
          size: Vector2(valueByTileSize(4), valueByTileSize(4)), // 128x128 aprox para sprite de 138x126
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!conversationWithHero && checkInterval('checkBossDead', 1000, dt)) {
      try {
        // Buscar si existe el BossL3 en el juego
        gameRef.enemies().firstWhere((e) => e is BossL3);
      } catch (e) {
        // Si no existe, significa que fue derrotado
        conversationWithHero = true;
        gameRef.camera.moveToTargetAnimated(
          target: this,
          onComplete: () {
            _startConversation();
          },
        );
      }
    }
  }

  void _startConversation() {
    Sounds.interaction();
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [
            const TextSpan(
              text: '¡Gracias por salvarme! Has completado la mazmorra y salvado a la princesa hija del rey.',
            )
          ],
          person: CustomSpriteAnimationWidget(
            animation: NpcSpriteSheet.kidL3IdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_4'))],
          person: CustomSpriteAnimationWidget(
            animation: PlayerSpriteSheet.idleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onFinish: () {
        Sounds.interaction();
        gameRef.camera.moveToPlayerAnimated(onComplete: () {
          Dialogs.showVictoryDialog(
            gameRef.context,
            () async {
              // Guardamos el progreso
              await PlayerInventory().unlockNextLevel(3);

              // Regresar al Menú Principal
              Navigator.of(gameRef.context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Menu()),
                (Route<dynamic> route) => false,
              );
            },
          );
        });
      },
      onChangeTalk: (index) {
        Sounds.interaction();
      },
      logicalKeyboardKeysToNext: [
        LogicalKeyboardKey.space,
      ],
    );
  }
}
