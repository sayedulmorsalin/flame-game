import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class RigsScreen extends StatelessWidget {
  final GameState gameState;

  const RigsScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: gameState.shafts.length,
      itemBuilder: (context, index) {
        final shaft = gameState.shafts[index];
        final canAffordLevel = gameState.satoshis >= shaft.currentCost;
        final coolingCost = shaft.baseCost * (shaft.coolingLevel * 1.6);
        final canAffordCooling = gameState.satoshis >= coolingCost;
        final overclockCost = shaft.baseCost * (shaft.overclockLevel * 2.2);
        final canAffordOverclock = gameState.satoshis >= overclockCost;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cyberCardDecoration(
            borderColor: shaft.isUnlocked
                ? AppTheme.cyanNeon
                : AppTheme.surfaceBorder,
            glowColor: shaft.isUnlocked ? AppTheme.cyanNeon : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Name, Subtitle, Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: shaft.isUnlocked ? AppTheme.cyanNeon : AppTheme.surfaceBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (shaft.isUnlocked ? AppTheme.cyanNeon : Colors.transparent).withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(shaft.icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shaft.name,
                          style: GoogleFonts.chakraPetch(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          shaft.subtitle,
                          style: GoogleFonts.chakraPetch(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: AppTheme.badgeDecoration(
                                color: shaft.isUnlocked ? AppTheme.greenHash : AppTheme.textMuted,
                                borderRadius: 4,
                              ),
                              child: Text(
                                shaft.isUnlocked
                                    ? 'LVL ${shaft.level}'
                                    : 'LOCKED',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: shaft.isUnlocked
                                      ? AppTheme.greenHash
                                      : AppTheme.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (shaft.isUnlocked) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '• ⚡ ${shaft.currentHashrate >= 1000 ? "${(shaft.currentHashrate / 1000).toStringAsFixed(2)} GH/s" : "${shaft.currentHashrate.toStringAsFixed(1)} MH/s"}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.greenHash,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: AppTheme.surfaceBorderSubtle, height: 1),
              const SizedBox(height: 12),

              // Upgrade Actions Row
              Row(
                children: [
                  // Main Level Upgrade Button
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: canAffordLevel
                          ? () {
                              if (gameState.upgradeShaft(shaft.id)) {
                                AudioService.instance.playUpgrade();
                              }
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: canAffordLevel
                            ? AppTheme.gameButtonDecoration(
                                color: AppTheme.richRuby,
                                borderRadius: 8,
                              )
                            : BoxDecoration(
                                color: AppTheme.surfaceSecondary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.surfaceBorderSubtle),
                              ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              shaft.isUnlocked ? 'UPGRADE' : 'UNLOCK',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: canAffordLevel ? Colors.white : AppTheme.textMuted,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '🪙 ${format.format(shaft.currentCost.toInt())}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.chakraPetch(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: canAffordLevel ? const Color(0xFFFFE082) : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (shaft.isUnlocked) ...[
                    const SizedBox(width: 6),
                    // Cooling Fan Upgrade
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: canAffordCooling
                            ? () {
                                if (gameState.upgradeShaftCooling(shaft.id)) {
                                  AudioService.instance.playUpgrade();
                                }
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: canAffordCooling
                              ? AppTheme.gameButtonDecoration(
                                  color: AppTheme.cyanNeon,
                                  borderRadius: 8,
                                )
                              : BoxDecoration(
                                  color: AppTheme.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.surfaceBorderSubtle),
                                ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '❄️ FAN L.${shaft.coolingLevel}',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: canAffordCooling ? Colors.black : AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${format.format(coolingCost.toInt())} SAT',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: canAffordCooling ? Colors.black87 : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Overclock Upgrade
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: canAffordOverclock
                            ? () {
                                if (gameState.upgradeShaftOverclock(shaft.id)) {
                                  AudioService.instance.playUpgrade();
                                }
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: canAffordOverclock
                              ? AppTheme.gameButtonDecoration(
                                  color: AppTheme.orangeFrenzy,
                                  borderRadius: 8,
                                )
                              : BoxDecoration(
                                  color: AppTheme.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.surfaceBorderSubtle),
                                ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '🔥 BOOST L.${shaft.overclockLevel}',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: canAffordOverclock ? Colors.white : AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${format.format(overclockCost.toInt())} SAT',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: canAffordOverclock ? const Color(0xFFFFE082) : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
