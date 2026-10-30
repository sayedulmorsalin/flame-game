import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class VaultScreen extends StatefulWidget {
  final GameState gameState;

  const VaultScreen({Key? key, required this.gameState}) : super(key: key);

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
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                const Text(
                  'SIMULATED PAYOUT CONFIRMED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.greenHash,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simulated blockchain transaction broadcasted to the demo network:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('TRANSACTION HASH', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                      Text(
                        txHash,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.cyanNeon,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Status: 12/12 Confirmations (Virtual Simulation)',
                        style: TextStyle(fontSize: 10, color: AppTheme.greenHash),
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
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('GREAT!'),
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
          // Hardware Cold Wallet Display
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.cyanNeon.withOpacity(0.5),
              glowColor: AppTheme.cyanNeon,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🛡️ ', style: TextStyle(fontSize: 18)),
                        Text(
                          'HARDWARE VAULT SECURED',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cyanNeon,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.greenHash.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AIR-GAPPED',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.greenHash),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Vault OLED Screen
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VAULT PUBLIC KEY',
                        style: TextStyle(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'bc1q8df749a2c918e74f0a234f9a0c71a39fbc8120e',
                        style: TextStyle(fontSize: 11, color: AppTheme.cyanNeon, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL SATOSHIS', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                              Text(
                                '${satoshiFormat.format(widget.gameState.satoshis.toInt())} SAT',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.bitcoinGold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('EST. VALUE', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                              Text(
                                currencyFormat.format(widget.gameState.portfolioUsdValue),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.greenHash),
                              ),
                            ],
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
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isProcessingPayout)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        else ...[
                          const Text('📤 '),
                          const Text('SIMULATE DEMO PAYOUT'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hard Fork / Genesis Prestige
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.purpleQuantum.withOpacity(0.6),
              glowColor: AppTheme.purpleQuantum,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🔮 ', style: TextStyle(fontSize: 18)),
                        Text(
                          'HARD FORK / PRESTIGE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.purpleQuantum,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.purpleQuantum.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.gameState.genesisCoins} GENESIS COINS',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.purpleQuantum,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fork the blockchain to start fresh with permanent Genesis Hash power! Each Genesis Coin grants +50% global production forever.',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: Text(
                      widget.gameState.lifetimeSatoshisMined >= 50000
                          ? 'TRIGGER HARD FORK (+${max(1, (sqrt(widget.gameState.lifetimeSatoshisMined / 25000)).floor())} COINS)'
                          : 'REQUIRES 50,000 LIFETIME SAT (HAVE: ${satoshiFormat.format(widget.gameState.lifetimeSatoshisMined.toInt())})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lifetime Stats Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.surfaceBorder),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIFETIME MINING STATISTICS',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
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

          const SizedBox(height: 16),

          // Settings (Audio & Haptics)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.surfaceBorder),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SETTINGS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sound Effects & Chimes', style: TextStyle(fontSize: 13)),
                  value: widget.gameState.soundEnabled,
                  activeTrackColor: AppTheme.bitcoinGold,
                  onChanged: (val) {
                    widget.gameState.toggleSound();
                    AudioService.instance.soundEnabled = val;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Haptic Vibration Feedback', style: TextStyle(fontSize: 13)),
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
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
