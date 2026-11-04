import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class VaultScreen extends StatefulWidget {
  final GameState gameState;

  const VaultScreen({super.key, required this.gameState});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool isProcessingPayout = false;

  void _simulatePayout() {
    setState(() => isProcessingPayout = true);
    AudioService.instance.playCoinPickup();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => isProcessingPayout = false);
      final txHash = '0x${List.generate(16, (i) => Random().nextInt(16).toRadixString(16)).join()}...';

      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.greenHash,
              glowColor: AppTheme.greenHash,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 10),
                const Text(
                  'SIMULATED PAYOUT CONFIRMED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.greenHash,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simulated blockchain transaction broadcasted to the demo network:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.surfaceBorderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Text('TRANSACTION HASH', style: TextStyle(fontSize: 8.5, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          txHash,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cyanNeon,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Status: 12/12 Confirmations (Virtual Simulation)',
                        style: TextStyle(fontSize: 10, color: AppTheme.greenHash, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenHash,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('GREAT!', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final satoshiFormat = NumberFormat('#,###');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hardware Cold Wallet Display Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.cyanNeon.withValues(alpha: 0.5),
              glowColor: AppTheme.cyanNeon,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Text('🛡️ ', style: TextStyle(fontSize: 18)),
                          Flexible(
                            child: Text(
                              'HARDWARE VAULT SECURED',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.cyanNeon,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.greenHash.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AIR-GAPPED',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.greenHash),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Vault Display Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B161A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF382F36)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VAULT PUBLIC KEY',
                        style: TextStyle(fontSize: 8.5, color: Color(0xFFAFA4AC), letterSpacing: 0.8, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'bc1q8df749a2c918e74f0a234f9a0c71a39fbc8120e',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.cyanNeon.withValues(alpha: 0.9),
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TOTAL SATOSHIS', style: TextStyle(fontSize: 8.5, color: Color(0xFFAFA4AC), fontWeight: FontWeight.bold)),
                                Text(
                                  '${satoshiFormat.format(widget.gameState.satoshis.toInt())} SAT',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.bitcoinGold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('EST. VALUE', style: TextStyle(fontSize: 8.5, color: Color(0xFFAFA4AC), fontWeight: FontWeight.bold)),
                                Text(
                                  currencyFormat.format(widget.gameState.portfolioUsdValue),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.greenHash),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Simulated Payout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessingPayout ? null : _simulatePayout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenHash,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.surfaceSecondary,
                      disabledForegroundColor: AppTheme.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isProcessingPayout)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else ...[
                          const Text('📤 '),
                          const Text(
                            'SIMULATE DEMO PAYOUT',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Hard Fork / Genesis Prestige Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.purpleQuantum.withValues(alpha: 0.5),
              glowColor: AppTheme.purpleQuantum,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Text('🔮 ', style: TextStyle(fontSize: 18)),
                          Flexible(
                            child: Text(
                              'HARD FORK / PRESTIGE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.purpleQuantum,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.purpleQuantum.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.gameState.genesisCoins} GENESIS COINS',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.purpleQuantum,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fork the blockchain to start fresh with permanent Genesis Hash power! Each Genesis Coin grants +50% global production forever.',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.gameState.lifetimeSatoshisMined >= 50000
                        ? () {
                            if (widget.gameState.triggerHardFork()) {
                              AudioService.instance.playFrenzyStart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hard Fork Executed! Genesis Hash bonus applied!'),
                                  backgroundColor: AppTheme.purpleQuantum,
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purpleQuantum,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.surfaceSecondary,
                      disabledForegroundColor: AppTheme.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    child: Text(
                      widget.gameState.lifetimeSatoshisMined >= 50000
                          ? 'TRIGGER HARD FORK (+${max(1, (sqrt(widget.gameState.lifetimeSatoshisMined / 25000)).floor())} COINS)'
                          : 'REQUIRES 50,000 LIFETIME SAT (HAVE: ${satoshiFormat.format(widget.gameState.lifetimeSatoshisMined.toInt())})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Lifetime Stats Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIFETIME MINING STATISTICS',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildStatRow('Total Satoshis Mined', '${satoshiFormat.format(widget.gameState.lifetimeSatoshisMined.toInt())} SAT'),
                _buildStatRow('Total Manual Taps', satoshiFormat.format(widget.gameState.totalTaps)),
                _buildStatRow('Airdrop Drones Intercepted', '${widget.gameState.totalDronesCaught}'),
                _buildStatRow('Exchange Trades Completed', '${widget.gameState.totalTradesCount}'),
                _buildStatRow('Genesis Multiplier', '+${(widget.gameState.genesisCoins * 50)}% Hashpower'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Settings Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SETTINGS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sound Effects & Chimes', style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                  value: widget.gameState.soundEnabled,
                  activeTrackColor: AppTheme.richRuby,
                  onChanged: (val) {
                    widget.gameState.toggleSound();
                    AudioService.instance.soundEnabled = val;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Haptic Vibration Feedback', style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                  value: widget.gameState.hapticsEnabled,
                  activeTrackColor: AppTheme.cyanNeon,
                  onChanged: (val) {
                    widget.gameState.toggleHaptics();
                    AudioService.instance.hapticsEnabled = val;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
