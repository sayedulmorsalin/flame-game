import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../theme/app_theme.dart';

class TopHud extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onBoostPressed;

  const TopHud({
    super.key,
    required this.gameState,
    required this.onBoostPressed,
  });

  @override
  Widget build(BuildContext context) {
    final satoshiFormat = NumberFormat('#,###');
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          bottom: BorderSide(color: AppTheme.surfaceBorder, width: 1.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x103A1B28),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Bitcoin Balance (Left) & Status Badges (Right)
            Row(
              children: [
                // Bitcoin Balance Section (Expanded so it never overflows)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.bitcoinGold.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '₿',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${gameState.btcBalance.toStringAsFixed(8)} BTC',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              '${satoshiFormat.format(gameState.satoshis.toInt())} SAT • ${usdFormat.format(gameState.portfolioUsdValue)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right Status Badges: Battery, Hashrate & Boost (Flexible and compact)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rig Power Battery Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: gameState.isRigPowered
                              ? AppTheme.greenHash
                              : AppTheme.orangeFrenzy,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            gameState.isRigPowered ? Icons.battery_charging_full : Icons.battery_alert,
                            size: 14,
                            color: gameState.isRigPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${gameState.rigPower.toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: gameState.isRigPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Hashrate Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: gameState.isFrenzyActive
                              ? AppTheme.richRuby
                              : (gameState.isRigPowered
                                  ? AppTheme.cyanNeon
                                  : AppTheme.textMuted),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 14,
                            color: gameState.isFrenzyActive
                                ? AppTheme.richRuby
                                : (gameState.isRigPowered ? AppTheme.cyanNeon : AppTheme.textMuted),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            gameState.isRigPowered ? gameState.formattedHashrate : 'OFFLINE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: gameState.isFrenzyActive
                                  ? AppTheme.richRuby
                                  : (gameState.isRigPowered ? AppTheme.cyanNeon : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Boost Button
                    InkWell(
                      onTap: onBoostPressed,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: gameState.boostDurationRemaining > 0
                              ? AppTheme.rubyGradient
                              : const LinearGradient(
                                  colors: [Color(0xFFFFFFFF), Color(0xFFF3EDF1)],
                                ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: gameState.boostDurationRemaining > 0
                                ? AppTheme.richRuby
                                : AppTheme.surfaceBorder,
                            width: 1.2,
                          ),
                          boxShadow: gameState.boostDurationRemaining > 0
                              ? [
                                  BoxShadow(
                                    color: AppTheme.richRuby.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🚀', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 2),
                            Text(
                              gameState.boostDurationRemaining > 0
                                  ? '${gameState.boostDurationRemaining.toInt()}s'
                                  : '2X',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: gameState.boostDurationRemaining > 0
                                    ? Colors.white
                                    : AppTheme.richRuby,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 7),

            // Tap Frenzy Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      gameState.isFrenzyActive
                          ? '🔥 OVERCLOCK FRENZY (3X MULTIPLIER) 🔥'
                          : '⚡ OVERCLOCK GAUGE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: gameState.isFrenzyActive
                            ? AppTheme.richRuby
                            : AppTheme.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      gameState.isFrenzyActive
                          ? '${gameState.frenzyDurationRemaining.toStringAsFixed(1)}s'
                          : '${(gameState.frenzyMeter * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: gameState.isFrenzyActive
                            ? AppTheme.richRuby
                            : AppTheme.cyanNeon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    color: AppTheme.surfaceSecondary,
                    child: LinearProgressIndicator(
                      value: gameState.frenzyMeter,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        gameState.isFrenzyActive
                            ? AppTheme.richRuby
                            : AppTheme.cyanNeon,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
