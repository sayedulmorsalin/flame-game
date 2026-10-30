import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/mining_shaft.dart';
import '../services/audio_service.dart';
import 'components/bedrock_background.dart';
import 'components/shaft_component.dart';
import 'components/airdrop_drone_component.dart';
import 'components/floating_text_component.dart';
import 'components/particle_effects.dart';

class BTMinerGame extends FlameGame with TapCallbacks, ScrollDetector {
  final GameState gameState;
  final Function(Map<String, dynamic>) onAirdropClaimed;

  late BedrockBackgroundComponent background;
  final List<ShaftComponent> shaftComponents = [];

  double droneTimer = 15.0; // Spawns first drone in 15s
  double ambientSparkTimer = 0.0;
  double cameraOffsetY = 0.0;
  final double shaftHeight = 110.0;
  final double shaftSpacing = 16.0;

  BTMinerGame({
    required this.gameState,
    required this.onAirdropClaimed,
  });

  @override
  Color backgroundColor() => const Color(0xFF07090E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final totalHeight = max(size.y, (shaftHeight + shaftSpacing) * gameState.shafts.length + 140);

    // 1. Bedrock Cavern Background
    background = BedrockBackgroundComponent(
      worldWidth: size.x,
      worldHeight: totalHeight,
    );
    add(background);

    // 2. Add Shaft Components for each floor
    _buildShafts();
  }

  void _buildShafts() {
    for (var shaftComp in shaftComponents) {
      shaftComp.removeFromParent();
    }
    shaftComponents.clear();

    double startY = 40.0;
    for (var shaft in gameState.shafts) {
      final comp = ShaftComponent(
        shaft: shaft,
        position: Vector2(0, startY),
        size: Vector2(size.x, shaftHeight),
        isFrenzyActive: gameState.isFrenzyActive,
        isPowered: gameState.isRigPowered,
        onShaftTapped: (s, pos) => _handleTap(pos, specificShaft: s),
      );
      shaftComponents.add(comp);
      add(comp);
      startY += shaftHeight + shaftSpacing;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _buildShafts();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Tick the game idle math and timers
    gameState.idleTick(dt);

    // Sync power status to shaft components
    for (var comp in shaftComponents) {
      comp.isPowered = gameState.isRigPowered;
    }

    // Airdrop Drone spawn countdown
    droneTimer -= dt;
    if (droneTimer <= 0) {
      _spawnAirdropDrone();
      droneTimer = 35.0 + Random().nextDouble() * 20.0; // Spawns every 35-55s
    }

    // Ambient random sparks on active shafts
    ambientSparkTimer += dt;
    if (ambientSparkTimer >= 0.75) {
      ambientSparkTimer = 0.0;
      if (gameState.isRigPowered) {
        _spawnAmbientMiningSpark();
      }
    }
  }

  void _spawnAirdropDrone() {
    final drone = AirdropDroneComponent(
      screenWidth: size.x,
      startPosition: Vector2(-80, 25.0 + Random().nextDouble() * 60.0),
      onDroneTapped: () {
        AudioService.instance.playAirdrop();
        final reward = gameState.claimAirdropCrate();
        onAirdropClaimed(reward);
        // Burst celebration particles
        add(ParticleEffects.createTapBurst(Vector2(size.x / 2, 70), isFrenzy: true));
      },
    );
    add(drone);
  }

  void _spawnAmbientMiningSpark() {
    for (var shaft in gameState.shafts) {
      if (shaft.isUnlocked && shaft.level > 0) {
        final compIndex = shaft.id;
        if (compIndex < shaftComponents.length) {
          final comp = shaftComponents[compIndex];
          final sparkPos = Vector2(
            comp.position.x + size.x - 45,
            comp.position.y + shaftHeight / 2,
          );
          add(ParticleEffects.createMiningSpark(sparkPos));
        }
      }
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    _handleTap(event.canvasPosition);
    return true;
  }

  void _handleTap(Vector2 tapPosition, {MiningShaft? specificShaft}) {
    // 1. Manual Tap in GameState
    final earned = gameState.manualTap();

    // 2. Play tactile audio
    AudioService.instance.playTap();

    // 3. Spawn Floating Score Text
    final isCrit = gameState.isFrenzyActive || Random().nextDouble() < 0.15;
    final text = isCrit ? '+${(earned * 1.5).toStringAsFixed(1)} CRIT! ⚡' : '+${earned.toStringAsFixed(1)} SAT';
    final textColor = isCrit
        ? const Color(0xFFFFD700)
        : (gameState.isFrenzyActive ? const Color(0xFFFF9100) : const Color(0xFF00F2FE));

    add(FloatingTextComponent(
      text: text,
      position: Vector2(tapPosition.x - 20, tapPosition.y - 10),
      color: textColor,
      isCrit: isCrit,
    ));

    // 4. Particle Burst
    add(ParticleEffects.createTapBurst(tapPosition, isFrenzy: gameState.isFrenzyActive));
  }

  // Allow vertical drag/scroll of camera across mining floors
  @override
  void onScroll(PointerScrollInfo info) {
    final scrollDelta = info.scrollDelta.global.y;
    camera.moveBy(Vector2(0, scrollDelta * 0.6));
  }

  void scrollShafts(double deltaY) {
    camera.moveBy(Vector2(0, deltaY));
  }
}
