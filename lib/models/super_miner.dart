enum MinerRarity { common, rare, epic, legendary }

class SuperMiner {
  final String id;
  final String name;
  final String title;
  final String description;
  final MinerRarity rarity;
  final int targetShaftId; // -1 for global
  final double baseMultiplier;
  final double unlockCostSatoshis;
  int level;
  bool isUnlocked;

  SuperMiner({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.rarity,
    required this.targetShaftId,
    required this.baseMultiplier,
    required this.unlockCostSatoshis,
    this.level = 1,
    this.isUnlocked = false,
  });

  double get currentMultiplier => baseMultiplier * (1.0 + (level - 1) * 0.35);

  double get upgradeCost => unlockCostSatoshis * (level * 1.75);

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'isUnlocked': isUnlocked,
      };

  void loadJson(Map<String, dynamic> json) {
    level = json['level'] ?? level;
    isUnlocked = json['isUnlocked'] ?? isUnlocked;
  }
}
