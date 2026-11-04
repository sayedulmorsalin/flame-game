import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class QuestsScreen extends StatelessWidget {
  final GameState gameState;

  const QuestsScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      children: [
        // 7-Day Daily Login Streak Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cyberCardDecoration(
            borderColor: AppTheme.bitcoinGold,
            glowColor: AppTheme.bitcoinGold,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('📅 ', style: TextStyle(fontSize: 16)),
                      Text(
                        'DAILY LOGIN REWARDS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'STREAK: DAY 1',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.richRuby),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [100, 250, 500, 1000, 2500, 5000, 15000].asMap().entries.map((entry) {
                    final day = entry.key + 1;
                    final reward = entry.value;
                    final isToday = day == 1;

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: isToday ? AppTheme.surfaceLight : AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isToday ? AppTheme.richRuby : AppTheme.surfaceBorder,
                          width: isToday ? 2 : 1,
                        ),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: AppTheme.richRuby.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text('DAY $day', style: const TextStyle(fontSize: 9.5, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 3),
                          Text(
                            day == 7 ? '🎁' : '🪙',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            format.format(reward),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isToday ? AppTheme.richRuby : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Time Warp Quick Booster Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cyberCardDecoration(
            borderColor: AppTheme.cyanNeon.withValues(alpha: 0.5),
          ),
          child: Row(
            children: [
              const Text('⌛', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUANTUM TIME WARP (1 HR)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Instantly accelerate 3,600s of idle hashrate mining',
                      style: TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final gained = gameState.timeWarp(3600);
                  AudioService.instance.playFrenzyStart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Time Warp Complete! Mined ${format.format(gained.toInt())} SAT!'),
                      backgroundColor: AppTheme.cyanNeon,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyanNeon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                child: const Text('WARP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Daily Quests Header
        const Text(
          'DAILY MISSIONS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        // Quests List
        ...gameState.dailyQuests.map((quest) {
          final isClaimable = quest.isCompleted && !quest.isClaimed;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: isClaimable ? AppTheme.greenHash : AppTheme.surfaceBorder,
              glowColor: isClaimable ? AppTheme.greenHash : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        quest.description,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 5,
                          color: AppTheme.surfaceSecondary,
                          child: LinearProgressIndicator(
                            value: quest.progress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              quest.isCompleted ? AppTheme.greenHash : AppTheme.cyanNeon,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quest.currentValue.toInt()} / ${quest.targetValue.toInt()} (${(quest.progress * 100).toInt()}%)',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Claim Button
                SizedBox(
                  width: 88,
                  child: ElevatedButton(
                    onPressed: isClaimable
                        ? () {
                            if (gameState.claimQuest(quest.id)) {
                              AudioService.instance.playCoinPickup();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isClaimable
                          ? AppTheme.greenHash
                          : AppTheme.surfaceSecondary,
                      foregroundColor: isClaimable ? Colors.white : AppTheme.textMuted,
                      disabledBackgroundColor: AppTheme.surfaceSecondary,
                      disabledForegroundColor: AppTheme.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: isClaimable ? 2 : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          quest.isClaimed
                              ? 'CLAIMED'
                              : (quest.isCompleted ? 'CLAIM' : 'LOCKED'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        if (!quest.isClaimed) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+${format.format(quest.rewardSatoshis.toInt())} SAT',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
