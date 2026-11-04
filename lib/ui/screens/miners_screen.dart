import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../../models/super_miner.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class MinersScreen extends StatelessWidget {
  final GameState gameState;

  const MinersScreen({super.key, required this.gameState});

  Color _getRarityColor(MinerRarity rarity) {
    switch (rarity) {
      case MinerRarity.common:
        return AppTheme.silverMetallic;
      case MinerRarity.rare:
        return AppTheme.cyanNeon;
      case MinerRarity.epic:
        return AppTheme.purpleQuantum;
      case MinerRarity.legendary:
        return AppTheme.bitcoinGold;
    }
  }

  String _getRarityLabel(MinerRarity rarity) {
    switch (rarity) {
      case MinerRarity.common:
        return 'COMMON';
      case MinerRarity.rare:
        return 'RARE';
      case MinerRarity.epic:
        return 'EPIC';
      case MinerRarity.legendary:
        return 'LEGENDARY';
    }
  }

  String _getMinerAvatar(String id) {
    switch (id) {
      case 'miner_satoshi':
        return '👑';
      case 'miner_jax':
        return '🦾';
      case 'miner_vesper':
        return '⚡';
      case 'miner_frost':
        return '❄️';
      case 'miner_ada':
        return '🔬';
      case 'miner_neil':
        return '👨‍🚀';
      case 'miner_bull':
        return '📈';
      case 'miner_robo':
        return '🤖';
      default:
        return '👷';
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: gameState.superMiners.length,
      itemBuilder: (context, index) {
        final miner = gameState.superMiners[index];
        final rarityColor = _getRarityColor(miner.rarity);
        final cost = miner.isUnlocked ? miner.upgradeCost : miner.unlockCostSatoshis;
        final canAfford = gameState.satoshis >= cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.cyberCardDecoration(
            borderColor: miner.isUnlocked ? rarityColor.withValues(alpha: 0.5) : AppTheme.surfaceBorder,
            glowColor: miner.isUnlocked ? rarityColor : null,
          ),
          child: Row(
            children: [
              // Avatar with Rarity Ring
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceLight,
                  border: Border.all(color: rarityColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getMinerAvatar(miner.id),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Miner Info (Flexible to prevent any header overlap)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            miner.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: rarityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: rarityColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            _getRarityLabel(miner.rarity),
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: rarityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      miner.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      miner.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: rarityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      miner.isUnlocked
                          ? 'LVL ${miner.level}  •  Multiplier: ${miner.currentMultiplier.toStringAsFixed(2)}x'
                          : 'NOT HIRED',
                      style: TextStyle(
                        fontSize: 10,
                        color: miner.isUnlocked ? AppTheme.greenHash : AppTheme.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action Button (Hire or Level Up)
              SizedBox(
                width: 90,
                child: ElevatedButton(
                  onPressed: canAfford
                      ? () {
                          if (gameState.hireOrUpgradeMiner(miner.id)) {
                            AudioService.instance.playUpgrade();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? rarityColor : AppTheme.surfaceSecondary,
                    foregroundColor: canAfford ? Colors.white : AppTheme.textMuted,
                    disabledBackgroundColor: AppTheme.surfaceSecondary,
                    disabledForegroundColor: AppTheme.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: canAfford ? 2 : 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        miner.isUnlocked ? 'LEVEL UP' : 'HIRE',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${format.format(cost.toInt())} SAT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
