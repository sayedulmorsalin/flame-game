import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../games/coin_catcher_game.dart';
import '../games/hash_cracker_game.dart';
import '../games/precision_drill_game.dart';
import '../games/lucky_wheel_game.dart';

class ArcadeScreen extends StatelessWidget {
  final GameState gameState;

  const ArcadeScreen({super.key, required this.gameState});

  void _launchGame(BuildContext context, Widget gameWidget) {
    AudioService.instance.playTap();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => gameWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final power = gameState.rigPower;
        final isPowered = gameState.isRigPowered;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            // 1. Power Grid & Status Banner (Zero overflow on any screen)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cyberCardDecoration(
                borderColor: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                glowColor: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              isPowered ? Icons.battery_charging_full : Icons.battery_alert,
                              color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                isPowered
                                    ? '⚡ RIG POWER: ${power.toInt()}% [MINING]'
                                    : '⚠️ RIG POWER: 0% [OFFLINE]',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${gameState.satoshis.toInt()} SAT',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.bitcoinGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 7,
                      color: AppTheme.surfaceSecondary,
                      child: LinearProgressIndicator(
                        value: (power / 100.0).clamp(0.0, 1.0),
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    isPowered
                        ? 'Your mining rigs are powered and mining Satoshis. Play games to top up energy & earn bonus coin bags!'
                        : 'Coins are not passively increasing because rigs require power! Play any mini-game below to get instant coins and recharge the power grid!',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Row(
              children: [
                Text('🕹️ ', style: TextStyle(fontSize: 18)),
                Text(
                  'INTERACTIVE ARCADE & GAMES',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Game 1: Satoshi Catcher
            _buildGameCard(
              context: context,
              title: 'SATOSHI CATCHER',
              subtitle: 'Catch falling Bitcoins & gems, build combo multipliers!',
              tag: 'ACTION ARCADE',
              tagColor: AppTheme.cyanNeon,
              icon: '🪙',
              rewardPreview: 'Earn 300 - 800+ SAT',
              powerBonus: '+40% Power Grid',
              gradientColors: [const Color(0xFFFFFFFF), const Color(0xFFF3F8FB)],
              borderColor: AppTheme.cyanNeon,
              onTap: () {
                _launchGame(
                  context,
                  CoinCatcherGame(
                    gameState: gameState,
                    onGameOver: () => Navigator.pop(context),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Game 2: Cipher Hash Cracker
            _buildGameCard(
              context: context,
              title: 'CIPHER HASH CRACKER',
              subtitle: 'Memorize & repeat the cryptographic node sequence to validate blocks!',
              tag: 'MEMORY & LOGIC',
              tagColor: AppTheme.purpleQuantum,
              icon: '🧠',
              rewardPreview: 'Earn up to 1,800+ SAT',
              powerBonus: '+50% Power Grid',
              gradientColors: [const Color(0xFFFFFFFF), const Color(0xFFFBF6FE)],
              borderColor: AppTheme.purpleQuantum,
              onTap: () {
                _launchGame(
                  context,
                  HashCrackerGame(
                    gameState: gameState,
                    onGameOver: () => Navigator.pop(context),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Game 3: Precision Laser Drill
            _buildGameCard(
              context: context,
              title: 'PRECISION LASER DRILL',
              subtitle: 'Time your strike inside the golden sweet spot for critical hash extractions!',
              tag: 'REFLEX & TIMING',
              tagColor: AppTheme.richRuby,
              icon: '🎯',
              rewardPreview: 'Earn up to 600+ SAT',
              powerBonus: '+35% Power Grid',
              gradientColors: [const Color(0xFFFFFFFF), const Color(0xFFFDF6F7)],
              borderColor: AppTheme.richRuby,
              onTap: () {
                _launchGame(
                  context,
                  PrecisionDrillGame(
                    gameState: gameState,
                    onGameOver: () => Navigator.pop(context),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Game 4: Quantum Lucky Wheel
            _buildGameCard(
              context: context,
              title: 'QUANTUM LUCKY WHEEL',
              subtitle: 'Spin the decentralized node wheel for instant Jackpots & 3X Frenzy!',
              tag: 'LUCKY SPINNER',
              tagColor: AppTheme.bitcoinGold,
              icon: '🎡',
              rewardPreview: 'Jackpots up to 1,500 SAT',
              powerBonus: 'Up to 100% Battery',
              gradientColors: [const Color(0xFFFFFFFF), const Color(0xFFFDF9F2)],
              borderColor: AppTheme.bitcoinGold,
              onTap: () {
                _launchGame(
                  context,
                  LuckyWheelGame(
                    gameState: gameState,
                    onGameOver: () => Navigator.pop(context),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 5. Interactive Manual Dynamo Generator Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cyberCardDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceLight,
                      border: Border.all(color: AppTheme.cyanNeon, width: 1.5),
                    ),
                    child: const Center(
                      child: Text('⚡', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANUAL DYNAMO CRANK',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap repeatedly on the Mine screen to crank the generator manually!',
                          style: TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final earned = gameState.crankGenerator();
                      AudioService.instance.playTap();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 700),
                          backgroundColor: AppTheme.surface,
                          content: Text(
                            '+${earned.toStringAsFixed(1)} SAT • +4% Rig Power ⚡',
                            style: const TextStyle(color: AppTheme.richRuby, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceLight,
                      foregroundColor: AppTheme.cyanNeon,
                      side: const BorderSide(color: AppTheme.cyanNeon),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('CRANK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        );
      },
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required String icon,
    required String rewardPreview,
    required String powerBonus,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.12),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: tagColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: tagColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, size: 14, color: AppTheme.greenHash),
                        const SizedBox(width: 2),
                        Text(
                          powerBonus,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.greenHash,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rewardPreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bitcoinGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [borderColor, borderColor.withValues(alpha: 0.85)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 15, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'PLAY',
                            style: TextStyle(
                              fontSize: 11.5,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
