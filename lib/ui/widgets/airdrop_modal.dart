import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AirdropModal extends StatelessWidget {
  final Map<String, dynamic> airdropData;
  final VoidCallback onDismiss;

  const AirdropModal({
    Key? key,
    required this.airdropData,
    required this.onDismiss,
  }) : super(key: key);

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
      accentColor = AppTheme.orangeFrenzy;
    } else {
      contentText = '2.5X HASHRATE BOOST FOR 45s';
      emoji = '🚀';
      accentColor = AppTheme.cyanNeon;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cyberCardDecoration(
          borderColor: accentColor,
          glowColor: accentColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Airdrop drone intercepted successfully! You unlocked:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withOpacity(0.5)),
              ),
              child: Text(
                contentText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('CLAIM REWARD'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
