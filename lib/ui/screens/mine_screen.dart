import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../game/btminer_game.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class MineScreen extends StatelessWidget {
  final BTMinerGame game;
  final GameState gameState;
  final VoidCallback onManualTap;
  final VoidCallback onOpenArcade;

  const MineScreen({
    super.key,
    required this.game,
    required this.gameState,
    required this.onManualTap,
    required this.onOpenArcade,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final isPowered = gameState.isRigPowered;
        final power = gameState.rigPower;

        return Stack(
          children: [
            // 1. Interactive Flame Game Canvas
            GameWidget(game: game),

            // 2. Power Grid & Quick Arcade Launch Banner (Top Center)
            Positioned(
              left: 14,
              right: 14,
              top: 10,
              child: GestureDetector(
                onTap: onOpenArcade,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPowered ? AppTheme.greenHash.withValues(alpha: 0.8) : AppTheme.orangeFrenzy,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy).withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPowered ? Icons.battery_charging_full : Icons.battery_alert,
                        color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isPowered ? '⚡ POWER GRID: ${power.toInt()}%' : '⚠️ RIGS OFFLINE (0%)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isPowered ? '• MINING ACTIVE' : '• NO PASSIVE COINS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPowered ? Colors.white : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPowered
                                  ? 'Play Arcade Games to top up battery & earn massive coin bags!'
                                  : 'Tap Dynamo or Play Mini-Games to energize rigs & earn coins!',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB300), AppTheme.bitcoinGold],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🕹️ ', style: TextStyle(fontSize: 11)),
                            Text(
                              'GAMES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Floor Quick-Jump Sidebar (Left)
            Positioned(
              left: 10,
              top: 75,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  children: List.generate(gameState.shafts.length, (index) {
                    final shaft = gameState.shafts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: InkWell(
                        onTap: () {
                          // Scroll camera to floor
                          game.camera.moveTo(Vector2(0, index * 126.0));
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: shaft.isUnlocked ? AppTheme.surfaceLight : Colors.black45,
                            border: Border.all(
                              color: shaft.isUnlocked
                                  ? AppTheme.cyanNeon.withValues(alpha: 0.6)
                                  : AppTheme.surfaceBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'F${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: shaft.isUnlocked ? Colors.white : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // 4. Floating Action Controls (Bottom Right)
            Positioned(
              right: 16,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Generator Dynamo Crank Button
                  GestureDetector(
                    onTapDown: (_) {
                      final earned = gameState.crankGenerator();
                      AudioService.instance.playTap();
                      // Show quick feedback
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 600),
                          backgroundColor: AppTheme.surface,
                          content: Text(
                            '+${earned.toStringAsFixed(1)} SAT • +4% Power Grid ⚡',
                            style: const TextStyle(
                              color: AppTheme.bitcoinGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surface,
                        border: Border.all(color: AppTheme.cyanNeon, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanNeon.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('⚡', style: TextStyle(fontSize: 18)),
                          Text(
                            '+4% CRANK',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.cyanNeon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quick Mine / Tap Overdrive Button
                  GestureDetector(
                    onTapDown: (_) => onManualTap(),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gameState.isFrenzyActive
                              ? [AppTheme.orangeFrenzy, AppTheme.redOverheat]
                              : [const Color(0xFFFFB300), AppTheme.bitcoinGold],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (gameState.isFrenzyActive
                                    ? AppTheme.orangeFrenzy
                                    : AppTheme.bitcoinGold)
                                .withValues(alpha: 0.5),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⛏️', style: TextStyle(fontSize: 22)),
                          Text(
                            gameState.isFrenzyActive ? '3X TAP!' : 'MINE',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 5. Offline / Unpowered Guiding Banner
            if (!isPowered)
              Positioned(
                bottom: 24,
                left: 16,
                right: 98,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.orangeFrenzy.withValues(alpha: 0.7)),
                  ),
                  child: Row(
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'COINS DON\'T GROW PASSIVELY!',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.orangeFrenzy,
                              ),
                            ),
                            const Text(
                              'Tap the ⚡ CRANK or play 🕹️ MINI-GAMES to earn coins & energize rigs.',
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
