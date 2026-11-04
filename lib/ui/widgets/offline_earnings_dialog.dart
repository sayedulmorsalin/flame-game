import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OfflineEarningsDialog extends StatelessWidget {
  final double satoshisEarned;
  final Duration timeAway;
  final VoidCallback onClaimNormal;
  final VoidCallback onClaimDoubled;

  const OfflineEarningsDialog({
    super.key,
    required this.satoshisEarned,
    required this.timeAway,
    required this.onClaimNormal,
    required this.onClaimDoubled,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');
    final hours = timeAway.inHours;
    final minutes = timeAway.inMinutes.remainder(60);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cyberCardDecoration(
          borderColor: AppTheme.bitcoinGold,
          glowColor: AppTheme.bitcoinGold,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Miner Icon Ring
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.goldGradient,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.bitcoinGold.withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                  const BoxShadow(
                    color: Color(0xFF8D5300),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Text('⛏️', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'WELCOME BACK MINER!',
              textAlign: TextAlign.center,
              style: GoogleFonts.chakraPetch(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: AppTheme.bitcoinGold.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your automated rigs kept mining 24/7 while you were away (${hours}h ${minutes}m):',
              textAlign: TextAlign.center,
              style: GoogleFonts.chakraPetch(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Amount
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.bitcoinGold.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.bitcoinGold.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙 ', style: TextStyle(fontSize: 24)),
                  Text(
                    '+${format.format(satoshisEarned.toInt())} SAT',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.bitcoinGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 3D Game Push Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onClaimNormal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.surfaceBorder, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF0A0E1A),
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'CLAIM 1X',
                          style: GoogleFonts.chakraPetch(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onClaimDoubled,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: AppTheme.gameButtonDecoration(
                        color: AppTheme.richRuby,
                        borderRadius: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⚡ ', style: TextStyle(fontSize: 14)),
                          Text(
                            'CLAIM 2X',
                            style: GoogleFonts.chakraPetch(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
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
