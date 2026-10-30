import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../../models/super_miner.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class MinersScreen extends StatelessWidget {
  final GameState gameState;

  const MinersScreen({Key? key, required this.gameState}) : super(key: key);

  Color _getRarityColor(MinerRarity rarity) {
    switch (rarity) {
      case MinerRarity.common:
        return const Color(0xFF94A3B8);
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
            borderColor: miner.isUnlocked ? rarityColor.withOpacity(0.5) : AppTheme.surfaceBorder,
            glowColor: miner.isUnlocked ? rarityColor : null,
          ),
          child: Row(
            children: [
              // Avatar with Rarity Ring
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceLight,
                  border: Border.all(color: rarityColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getMinerAvatar(miner.id),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Miner Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          miner.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: rarityColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            _getRarityLabel(miner.rarity),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: rarityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      miner.title,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      miner.description,
                      style: TextStyle(
                        fontSize: 11,
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
                width: 95,
                child: ElevatedButton(
                  onPressed: canAfford
                      ? () {
                          if (gameState.hireOrUpgradeMiner(miner.id)) {
                            AudioService.instance.playUpgrade();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? rarityColor : AppTheme.surfaceLight,
                    foregroundColor: canAfford ? Colors.black : AppTheme.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        miner.isUnlocked ? 'LEVEL UP' : 'HIRE',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${format.format(cost.toInt())} SAT',
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
