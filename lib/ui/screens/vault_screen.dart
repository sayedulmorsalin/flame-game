import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Timer? _payoutTimer;

  @override
  void dispose() {
    _payoutTimer?.cancel();
    super.dispose();
  }

  void _simulatePayout() {
    setState(() => isProcessingPayout = true);
    AudioService.instance.playCoinPickup();

    _payoutTimer?.cancel();
    _payoutTimer = Timer(const Duration(seconds: 2), () {
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
                Text(
                  'SIMULATED PAYOUT CONFIRMED',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.greenHash,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Simulated blockchain transaction broadcasted to the demo network:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.surfaceBorderSubtle),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TRANSACTION HASH',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 9,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          txHash,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cyanNeon,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: 12/12 Confirmations (Virtual Simulation)',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 10.5,
                          color: AppTheme.greenHash,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: AppTheme.gameButtonDecoration(
                      color: AppTheme.greenHash,
                      borderRadius: 10,
                    ),
                    child: Center(
                      child: Text(
                        'GREAT!',
                        style: GoogleFonts.chakraPetch(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
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
              borderColor: AppTheme.cyanNeon,
              glowColor: AppTheme.cyanNeon,
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
                          const Text('🛡️ ', style: TextStyle(fontSize: 20)),
                          Flexible(
                            child: Text(
                              'HARDWARE VAULT SECURED',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.chakraPetch(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.cyanNeon,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: AppTheme.badgeDecoration(color: AppTheme.greenHash, borderRadius: 6),
                      child: Text(
                        'AIR-GAPPED',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.greenHash,
                          letterSpacing: 0.5,
                        ),
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
                    color: AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x60000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VAULT PUBLIC KEY',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 9,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'bc1q8df749a2c918e74f0a234f9a0c71a39fbc8120e',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.cyanNeon,
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
                                Text(
                                  'TOTAL SATOSHIS',
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 9,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  '${satoshiFormat.format(widget.gameState.satoshis.toInt())} SAT',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.bitcoinGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'EST. VALUE',
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 9,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(widget.gameState.portfolioUsdValue),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.greenHash,
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

                const SizedBox(height: 14),

                // Simulated Payout 3D Push Button
                GestureDetector(
                  onTap: isProcessingPayout ? null : _simulatePayout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: isProcessingPayout
                        ? BoxDecoration(
                            color: AppTheme.surfaceSecondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.surfaceBorderSubtle),
                          )
                        : AppTheme.gameButtonDecoration(
                            color: AppTheme.greenHash,
                            borderRadius: 10,
                          ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isProcessingPayout)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else ...[
                          const Text('📤 '),
                          Text(
                            'SIMULATE DEMO PAYOUT',
                            style: GoogleFonts.chakraPetch(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: Colors.black,
                              letterSpacing: 0.8,
                            ),
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
              borderColor: AppTheme.purpleQuantum,
              glowColor: AppTheme.purpleQuantum,
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
                          const Text('🔮 ', style: TextStyle(fontSize: 20)),
                          Flexible(
                            child: Text(
                              'HARD FORK / PRESTIGE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.chakraPetch(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.purpleQuantum,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: AppTheme.badgeDecoration(color: AppTheme.purpleQuantum, borderRadius: 6),
                      child: Text(
                        '${widget.gameState.genesisCoins} GENESIS COINS',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.purpleQuantum,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fork the blockchain to start fresh with permanent Genesis Hash power! Each Genesis Coin grants +50% global production forever.',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: widget.gameState.lifetimeSatoshisMined >= 50000
                      ? () {
                          if (widget.gameState.triggerHardFork()) {
                            AudioService.instance.playFrenzyStart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Hard Fork Executed! Genesis Hash bonus applied!',
                                  style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900),
                                ),
                                backgroundColor: AppTheme.purpleQuantum,
                              ),
                            );
                          }
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: widget.gameState.lifetimeSatoshisMined >= 50000
                        ? AppTheme.gameButtonDecoration(
                            color: AppTheme.purpleQuantum,
                            borderRadius: 10,
                          )
                        : BoxDecoration(
                            color: AppTheme.surfaceSecondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.surfaceBorderSubtle),
                          ),
                    child: Text(
                      widget.gameState.lifetimeSatoshisMined >= 50000
                          ? 'TRIGGER HARD FORK (+${max(1, (sqrt(widget.gameState.lifetimeSatoshisMined / 25000)).floor())} COINS)'
                          : 'REQUIRES 50,000 LIFETIME SAT (HAVE: ${satoshiFormat.format(widget.gameState.lifetimeSatoshisMined.toInt())})',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.chakraPetch(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: widget.gameState.lifetimeSatoshisMined >= 50000 ? Colors.white : AppTheme.textMuted,
                        letterSpacing: 0.6,
                      ),
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
                Text(
                  'LIFETIME MINING STATISTICS',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.8,
                  ),
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
                Text(
                  'SETTINGS',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Sound Effects & Chimes',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  value: widget.gameState.soundEnabled,
                  activeTrackColor: AppTheme.richRuby,
                  onChanged: (val) {
                    widget.gameState.toggleSound();
                    AudioService.instance.soundEnabled = val;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Haptic Vibration Feedback',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.chakraPetch(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.chakraPetch(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
