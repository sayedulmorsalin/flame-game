import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                ? AppTheme.surfaceBorder
                : AppTheme.surfaceBorder.withValues(alpha: 0.6),
            glowColor: shaft.isUnlocked ? AppTheme.richRuby : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Name, Subtitle, Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: shaft.isUnlocked ? AppTheme.richRuby : AppTheme.surfaceBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(shaft.icon, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shaft.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          shaft.subtitle,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              shaft.isUnlocked
                                  ? 'LVL ${shaft.level}'
                                  : 'LOCKED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: shaft.isUnlocked
                                    ? AppTheme.richRuby
                                    : AppTheme.textMuted,
                              ),
                            ),
                            if (shaft.isUnlocked) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '• ⚡ ${shaft.currentHashrate >= 1000 ? "${(shaft.currentHashrate / 1000).toStringAsFixed(2)} GH/s" : "${shaft.currentHashrate.toStringAsFixed(1)} MH/s"}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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

              // Upgrade Actions Row (Compact, responsive, zero-overflow)
              Row(
                children: [
                  // Main Level Upgrade Button
                  Expanded(
                    flex: 5,
                    child: ElevatedButton(
                      onPressed: canAffordLevel
                          ? () {
                              if (gameState.upgradeShaft(shaft.id)) {
                                AudioService.instance.playUpgrade();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAffordLevel ? AppTheme.richRuby : AppTheme.surfaceSecondary,
                        foregroundColor: canAffordLevel ? Colors.white : AppTheme.textMuted,
                        disabledBackgroundColor: AppTheme.surfaceSecondary,
                        disabledForegroundColor: AppTheme.textMuted,
                        elevation: canAffordLevel ? 2 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            shaft.isUnlocked ? 'UPGRADE' : 'UNLOCK',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '🪙 ${format.format(shaft.currentCost.toInt())}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (shaft.isUnlocked) ...[
                    const SizedBox(width: 6),
                    // Cooling Fan Upgrade
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: canAffordCooling
                            ? () {
                                if (gameState.upgradeShaftCooling(shaft.id)) {
                                  AudioService.instance.playUpgrade();
                                }
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: canAffordCooling
                              ? AppTheme.cyanNeon.withValues(alpha: 0.08)
                              : Colors.transparent,
                          side: BorderSide(
                            color: canAffordCooling ? AppTheme.cyanNeon : AppTheme.surfaceBorder,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '❄️ FAN L.${shaft.coolingLevel}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: canAffordCooling ? AppTheme.cyanNeon : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${format.format(coolingCost.toInt())} SAT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Overclock Upgrade
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: canAffordOverclock
                            ? () {
                                if (gameState.upgradeShaftOverclock(shaft.id)) {
                                  AudioService.instance.playUpgrade();
                                }
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: canAffordOverclock
                              ? AppTheme.orangeFrenzy.withValues(alpha: 0.08)
                              : Colors.transparent,
                          side: BorderSide(
                            color: canAffordOverclock ? AppTheme.orangeFrenzy : AppTheme.surfaceBorder,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🔥 BOOST L.${shaft.overclockLevel}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: canAffordOverclock ? AppTheme.orangeFrenzy : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${format.format(overclockCost.toInt())} SAT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          ],
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
