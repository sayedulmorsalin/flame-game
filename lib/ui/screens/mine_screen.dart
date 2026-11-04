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
    required this.onOpenArcade,
    required this.onManualTap,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy).withValues(alpha: 0.18),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
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
                                Flexible(
                                  child: Text(
                                    isPowered ? '⚡ POWER GRID: ${power.toInt()}%' : '⚠️ RIGS OFFLINE (0%)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPowered ? '• ACTIVE' : '• STANDBY',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: isPowered ? AppTheme.greenHash : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPowered
                                  ? 'Play Arcade Games to top up battery & earn massive coin bags!'
                                  : 'Tap Dynamo or Play Mini-Games to energize rigs & earn coins!',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.rubyGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.richRuby.withValues(alpha: 0.28),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🕹️', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 3),
                            Text(
                              'GAMES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
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

            // 3. Floor Quick-Jump Sidebar (Left) - constrained & scrollable to prevent overlap
            Positioned(
              left: 10,
              top: 68,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.46,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x103A1B28),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(gameState.shafts.length, (index) {
                        final shaft = gameState.shafts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: InkWell(
                            onTap: () {
                              game.camera.moveTo(Vector2(0, index * 126.0));
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: shaft.isUnlocked ? AppTheme.surfaceLight : AppTheme.surfaceSecondary,
                                border: Border.all(
                                  color: shaft.isUnlocked
                                      ? AppTheme.cyanNeon
                                      : AppTheme.surfaceBorder,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'F${index + 1}',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: shaft.isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted,
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
              ),
            ),

            // 4. Floating Action Controls (Bottom Right)
            Positioned(
              right: 16,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Generator Dynamo Crank Button
                  GestureDetector(
                    onTapDown: (_) {
                      final earned = gameState.crankGenerator();
                      AudioService.instance.playTap();
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 600),
                          backgroundColor: AppTheme.surface,
                          content: Text(
                            '+${earned.toStringAsFixed(1)} SAT • +4% Power Grid ⚡',
                            style: const TextStyle(
                              color: AppTheme.richRuby,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surface,
                        border: Border.all(color: AppTheme.cyanNeon, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanNeon.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('⚡', style: TextStyle(fontSize: 17)),
                          Text(
                            '+4% CRANK',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.cyanNeon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Quick Mine / Tap Overdrive Button
                  GestureDetector(
                    onTapDown: (_) => onManualTap(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gameState.isFrenzyActive
                            ? AppTheme.rubyGradient
                            : AppTheme.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: (gameState.isFrenzyActive
                                    ? AppTheme.richRuby
                                    : AppTheme.bitcoinGold)
                                .withValues(alpha: 0.4),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2.5),
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
                bottom: 20,
                left: 14,
                right: 98,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.orangeFrenzy, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x123A1B28),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'COINS DON\'T GROW PASSIVELY!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.orangeFrenzy,
                              ),
                            ),
                            const Text(
                              'Tap ⚡ CRANK or play 🕹️ MINI-GAMES to energize rigs.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9.5, color: AppTheme.textSecondary),
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
