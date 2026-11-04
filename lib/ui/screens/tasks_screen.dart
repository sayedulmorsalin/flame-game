import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  final GameState gameState;

  const TasksScreen({super.key, required this.gameState});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');

    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final completedTasks = widget.gameState.dailyQuests.where((q) => q.isCompleted).length;
        final totalTasks = widget.gameState.dailyQuests.length;
        final hasClaimable = widget.gameState.dailyQuests.any((q) => q.isCompleted && !q.isClaimed);

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            // 1. TOP TASK HQ HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF22162B), Color(0xFF141A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.purpleQuantum, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purpleQuantum.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.purpleQuantum, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.purpleQuantum.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('📋', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TASK COMMAND HQ',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            if (hasClaimable) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.richRuby,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Complete daily bounties & missions to earn Satoshis',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.greenHash.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.greenHash.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$completedTasks/$totalTasks',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.greenHash,
                          ),
                        ),
                        Text(
                          'CLEARED',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.greenHash,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. DAILY BOUNTIES BOARD (Moved from Arcade Tab to Task Tab!)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cyberCardDecoration(
                borderColor: AppTheme.bitcoinGold,
                glowColor: AppTheme.bitcoinGold,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🎯 ', style: TextStyle(fontSize: 20)),
                          Text(
                            'DAILY BOUNTIES',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.bitcoinGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.bitcoinGold.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          'REFRESHES DAILY',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.bitcoinGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bounties Cards
                  ...widget.gameState.dailyQuests.take(3).map((quest) {
                    final canClaim = quest.isCompleted && !quest.isClaimed;
                    final isClaimed = quest.isClaimed;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: canClaim
                            ? AppTheme.bitcoinGold.withValues(alpha: 0.12)
                            : AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: canClaim ? AppTheme.bitcoinGold : AppTheme.surfaceBorderSubtle,
                          width: canClaim ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isClaimed
                                ? Icons.check_circle_rounded
                                : (quest.isCompleted ? Icons.stars_rounded : Icons.radio_button_unchecked),
                            size: 22,
                            color: isClaimed
                                ? AppTheme.greenHash
                                : (canClaim ? AppTheme.bitcoinGold : AppTheme.textMuted),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quest.title,
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  quest.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (canClaim)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.96 + (_pulseController.value * 0.08),
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.gameState.claimQuest(quest.id)) {
                                    AudioService.instance.playCoinPickup();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(milliseconds: 700),
                                        backgroundColor: AppTheme.surface,
                                        content: Text(
                                          'BOUNTY CLAIMED: +${quest.rewardSatoshis.toInt()} SATOSHIS! 🪙',
                                          style: GoogleFonts.chakraPetch(
                                            color: AppTheme.bitcoinGold,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: AppTheme.gameButtonDecoration(
                                    color: AppTheme.bitcoinGold,
                                    borderRadius: 8,
                                  ),
                                  child: Text(
                                    'CLAIM +${quest.rewardSatoshis.toInt()} 🪙',
                                    style: GoogleFonts.chakraPetch(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else if (isClaimed)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.greenHash.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CLAIMED ✓',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.greenHash,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.surfaceBorder),
                              ),
                              child: Text(
                                '+${quest.rewardSatoshis.toInt()} SAT',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.bitcoinGold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. 7-DAY LOGIN STREAK REWARDS
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
                      Row(
                        children: [
                          const Text('📅 ', style: TextStyle(fontSize: 18)),
                          Text(
                            'DAILY LOGIN STREAK',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: AppTheme.badgeDecoration(color: AppTheme.richRuby, borderRadius: 6),
                        child: Text(
                          'STREAK: DAY 1',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.richRuby,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [100, 250, 500, 1000, 2500, 5000, 15000].asMap().entries.map((entry) {
                        final day = entry.key + 1;
                        final reward = entry.value;
                        final isToday = day == 1;

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isToday
                                  ? [const Color(0xFF2E2218), const Color(0xFF1A1208)]
                                  : [AppTheme.surfaceLight, AppTheme.surfaceSecondary],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isToday ? AppTheme.bitcoinGold : AppTheme.surfaceBorder,
                              width: isToday ? 2.0 : 1.0,
                            ),
                            boxShadow: isToday
                                ? [
                                    BoxShadow(
                                      color: AppTheme.bitcoinGold.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'DAY $day',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 10.5,
                                  color: isToday ? AppTheme.bitcoinGold : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                day == 7 ? '🎁' : '🪙',
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                format.format(reward),
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isToday ? const Color(0xFFFFD54F) : AppTheme.textPrimary,
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

            const SizedBox(height: 16),

            // 4. QUANTUM TIME WARP QUICK BOOSTER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cyberCardDecoration(
                borderColor: AppTheme.cyanNeon,
                glowColor: AppTheme.cyanNeon,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceSecondary,
                      border: Border.all(color: AppTheme.cyanNeon.withValues(alpha: 0.6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cyanNeon.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('⌛', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUANTUM TIME WARP (1 HR)',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instantly accelerate 3,600s of idle hashrate mining',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final gained = widget.gameState.timeWarp(3600);
                      AudioService.instance.playFrenzyStart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Time Warp Complete! Mined ${format.format(gained.toInt())} SAT!',
                            style: GoogleFonts.chakraPetch(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          backgroundColor: AppTheme.cyanNeon,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: AppTheme.gameButtonDecoration(
                        color: AppTheme.cyanNeon,
                        borderRadius: 10,
                      ),
                      child: Text(
                        'WARP',
                        style: GoogleFonts.chakraPetch(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.black,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 5. ALL PROGRESSION TASKS HEADER
            Row(
              children: [
                const Text('⚡ ', style: TextStyle(fontSize: 18)),
                Text(
                  'ALL PROGRESSION TASKS',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: AppTheme.cyanNeon.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 6. TASKS LIST
            ...widget.gameState.dailyQuests.map((quest) {
              final isClaimable = quest.isCompleted && !quest.isClaimed;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                            style: GoogleFonts.chakraPetch(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            quest.description,
                            style: GoogleFonts.chakraPetch(
                              fontSize: 11.5,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar with neon border
                          Container(
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSecondary,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isClaimable
                                    ? AppTheme.greenHash.withValues(alpha: 0.6)
                                    : AppTheme.surfaceBorderSubtle,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
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
                            style: GoogleFonts.chakraPetch(
                              fontSize: 10.5,
                              color: isClaimable ? AppTheme.greenHash : AppTheme.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 3D Claim Push Button
                    GestureDetector(
                      onTap: isClaimable
                          ? () {
                              if (widget.gameState.claimQuest(quest.id)) {
                                AudioService.instance.playCoinPickup();
                              }
                            }
                          : null,
                      child: Container(
                        width: 94,
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                        decoration: isClaimable
                            ? AppTheme.gameButtonDecoration(
                                color: AppTheme.greenHash,
                                borderRadius: 10,
                              )
                            : BoxDecoration(
                                color: AppTheme.surfaceSecondary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.surfaceBorderSubtle),
                              ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              quest.isClaimed
                                  ? 'CLAIMED'
                                  : (quest.isCompleted ? 'CLAIM' : 'LOCKED'),
                              style: GoogleFonts.chakraPetch(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: isClaimable
                                    ? Colors.black
                                    : (quest.isClaimed ? AppTheme.greenHash : AppTheme.textMuted),
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (!quest.isClaimed) ...[
                              const SizedBox(height: 2),
                              Text(
                                '+${format.format(quest.rewardSatoshis.toInt())} SAT',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isClaimable ? Colors.black : AppTheme.textMuted,
                                ),
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
      },
    );
  }
}

