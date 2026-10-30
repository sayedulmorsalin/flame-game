import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../theme/app_theme.dart';

class TopHud extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onBoostPressed;

  const TopHud({
    Key? key,
    required this.gameState,
    required this.onBoostPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final satoshiFormat = NumberFormat('#,###');
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: AppTheme.surfaceBorder, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Bitcoin Balance & Hashrate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bitcoin Balance
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB300), AppTheme.bitcoinGold],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.bitcoinGold.withOpacity(0.4),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gameState.btcBalance.toStringAsFixed(8)} BTC',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.bitcoinGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${satoshiFormat.format(gameState.satoshis.toInt())} SAT  •  ${usdFormat.format(gameState.portfolioUsdValue)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Hashrate, Battery & Boost
                Row(
                  children: [
                    // Rig Power Battery Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gameState.isRigPowered
                              ? AppTheme.greenHash.withValues(alpha: 0.6)
                              : AppTheme.orangeFrenzy.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            gameState.isRigPowered ? Icons.battery_charging_full : Icons.battery_alert,
                            size: 14,
                            color: gameState.isRigPowered ? AppTheme.greenHash : AppTheme.orangeFrenzy,
                          ),
                          const SizedBox(width: 3),
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
                    const SizedBox(width: 6),

                    // Hashrate Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gameState.isFrenzyActive
                              ? AppTheme.orangeFrenzy
                              : (gameState.isRigPowered
                                  ? AppTheme.greenHash.withValues(alpha: 0.5)
                                  : AppTheme.textMuted.withValues(alpha: 0.5)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 15,
                            color: gameState.isFrenzyActive
                                ? AppTheme.orangeFrenzy
                                : (gameState.isRigPowered ? AppTheme.greenHash : AppTheme.textMuted),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            gameState.isRigPowered ? gameState.formattedHashrate : 'STANDBY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: gameState.isFrenzyActive
                                  ? AppTheme.orangeFrenzy
                                  : (gameState.isRigPowered ? AppTheme.greenHash : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Boost Button
                    InkWell(
                      onTap: onBoostPressed,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gameState.boostDurationRemaining > 0
                                ? [AppTheme.orangeFrenzy, AppTheme.redOverheat]
                                : [AppTheme.surfaceLight, const Color(0xFF202A40)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: gameState.boostDurationRemaining > 0
                                ? AppTheme.orangeFrenzy
                                : AppTheme.cyanNeon.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🚀 ', style: TextStyle(fontSize: 11)),
                            Text(
                              gameState.boostDurationRemaining > 0
                                  ? '${gameState.boostDurationRemaining.toInt()}s'
                                  : '2X',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: gameState.boostDurationRemaining > 0
                                    ? Colors.white
                                    : AppTheme.cyanNeon,
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

            const SizedBox(height: 8),

            // Tap Frenzy Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      gameState.isFrenzyActive
                          ? '🔥 OVERCLOCK FRENZY (3X ACTIVE) 🔥'
                          : '⚡ TAP OVERCLOCK GAUGE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: gameState.isFrenzyActive
                            ? AppTheme.orangeFrenzy
                            : AppTheme.textMuted,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      gameState.isFrenzyActive
                          ? '${gameState.frenzyDurationRemaining.toStringAsFixed(1)}s'
                          : '${(gameState.frenzyMeter * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: gameState.isFrenzyActive
                            ? AppTheme.orangeFrenzy
                            : AppTheme.cyanNeon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 6,
                    color: AppTheme.surfaceLight,
                    child: LinearProgressIndicator(
                      value: gameState.frenzyMeter,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        gameState.isFrenzyActive
                            ? AppTheme.orangeFrenzy
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
