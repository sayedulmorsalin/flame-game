import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AirdropModal extends StatelessWidget {
  final Map<String, dynamic> airdropData;
  final VoidCallback onDismiss;

  const AirdropModal({
    super.key,
    required this.airdropData,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');
    final title = airdropData['title'] ?? 'AIRDROP CRATE!';
    final type = airdropData['type'] ?? 'SATOSHIS';
    final value = airdropData['value'] ?? 0;

    String contentText = '';
    String emoji = '📦';
    Color accentColor = AppTheme.bitcoinGold;

    if (type == 'SATOSHIS') {
      contentText = '+${format.format((value as num).toInt())} SATOSHIS';
      emoji = '💰';
      accentColor = AppTheme.bitcoinGold;
    } else if (type == 'FRENZY') {
      contentText = '12s INSTANT OVERCLOCK FRENZY 3X';
      emoji = '⚡';
      accentColor = AppTheme.richRuby;
    } else {
      contentText = '2.5X HASHRATE BOOST FOR 45s';
      emoji = '🚀';
      accentColor = AppTheme.cyanNeon;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: AppTheme.cyberCardDecoration(
          borderColor: accentColor,
          glowColor: accentColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceSecondary,
                border: Border.all(color: accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.chakraPetch(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: accentColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Airdrop drone intercepted successfully! You unlocked:',
              textAlign: TextAlign.center,
              style: GoogleFonts.chakraPetch(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                contentText,
                textAlign: TextAlign.center,
                style: GoogleFonts.chakraPetch(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: AppTheme.gameButtonDecoration(
                  color: accentColor,
                  borderRadius: 10,
                ),
                child: Center(
                  child: Text(
                    'CLAIM REWARD',
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
    );
  }
}
