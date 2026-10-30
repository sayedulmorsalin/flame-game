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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // 1. Power Grid & Status Banner
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
                      Row(
                        children: [
                          Icon(
                            isPowered ? Icons.battery_charging_full : Icons.battery_alert,
                            color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPowered
                                ? '⚡ RIG POWER: ${power.toInt()}% [MINING ACTIVE]'
                                : '⚠️ RIG POWER: 0% [STANDBY / OFFLINE]',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${gameState.satoshis.toInt()} SAT',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.bitcoinGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (power / 100.0).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: const Color(0xFF0C1220),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isPowered
                        ? 'Your mining rigs are powered and mining Satoshis. Play games to top up energy & earn bonus coin bags!'
                        : 'Coins are not passively increasing because rigs require power! Play any mini-game below to get instant coins and recharge the power grid!',
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
              gradientColors: [const Color(0xFF0F2B48), AppTheme.surface],
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

            const SizedBox(height: 14),

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
              gradientColors: [const Color(0xFF281448), AppTheme.surface],
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

            const SizedBox(height: 14),

            // Game 3: Precision Laser Drill
            _buildGameCard(
              context: context,
              title: 'PRECISION LASER DRILL',
              subtitle: 'Time your strike inside the golden sweet spot for critical hash extractions!',
              tag: 'REFLEX & TIMING',
              tagColor: AppTheme.orangeFrenzy,
              icon: '🎯',
              rewardPreview: 'Earn up to 600+ SAT',
              powerBonus: '+35% Power Grid',
              gradientColors: [const Color(0xFF452010), AppTheme.surface],
              borderColor: AppTheme.orangeFrenzy,
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

            const SizedBox(height: 14),

            // Game 4: Quantum Lucky Wheel
            _buildGameCard(
              context: context,
              title: 'QUANTUM LUCKY WHEEL',
              subtitle: 'Spin the decentralized node wheel for instant Jackpots & 3X Frenzy!',
              tag: 'LUCKY SPINNER',
              tagColor: AppTheme.bitcoinGold,
              icon: '🎡',
              rewardPreview: 'Jackpots up to 1,500 SAT',
              powerBonus: 'Up to 100% Power Battery',
              gradientColors: [const Color(0xFF42280A), AppTheme.surface],
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

            const SizedBox(height: 14),

            // 5. Interactive Manual Dynamo Generator Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.cyanNeon),
                    ),
                    child: const Center(
                      child: Text('⚡', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANUAL DYNAMO CRANK',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap repeatedly on the Mine screen to crank the generator manually!',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
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
                            style: const TextStyle(color: AppTheme.bitcoinGold, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.cyanNeon,
                      side: const BorderSide(color: AppTheme.cyanNeon),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('CRANK', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
        border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tagColor.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: tagColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bolt, size: 14, color: AppTheme.greenHash),
                        const SizedBox(width: 2),
                        Text(
                          powerBonus,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.greenHash,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rewardPreview,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.bitcoinGold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [borderColor, borderColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow, size: 16, color: Colors.black),
                          SizedBox(width: 4),
                          Text(
                            'PLAY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
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
