class MiningShaft {
  final int id;
  final String name;
  final String subtitle;
  final String icon;
  final double baseHashrate; // in MH/s
  final double baseCost; // in Satoshis
  final double costMultiplier;
  int level;
  int coolingLevel;
  int overclockLevel;
  bool isUnlocked;
  String? assignedMinerId;

  MiningShaft({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.baseHashrate,
    required this.baseCost,
    this.costMultiplier = 1.15,
    this.level = 0,
    this.coolingLevel = 1,
    this.overclockLevel = 1,
    this.isUnlocked = false,
    this.assignedMinerId,
  });

  double get currentCost {
    if (level == 0) return baseCost;
    return baseCost * (costMultiplier * (level + 1) * 1.08);
  }

  double get currentHashrate {
    if (!isUnlocked || level == 0) return 0.0;
    // Base hashrate scaled by level, cooling, and overclocking
    double hr = baseHashrate * level;
    hr *= (1.0 + (coolingLevel - 1) * 0.25);
    hr *= (1.0 + (overclockLevel - 1) * 0.40);
    return hr;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'coolingLevel': coolingLevel,
        'overclockLevel': overclockLevel,
        'isUnlocked': isUnlocked,
        'assignedMinerId': assignedMinerId,
      };

  void loadJson(Map<String, dynamic> json) {
    level = json['level'] ?? level;
    coolingLevel = json['coolingLevel'] ?? coolingLevel;
    overclockLevel = json['overclockLevel'] ?? overclockLevel;
    isUnlocked = json['isUnlocked'] ?? isUnlocked;
    assignedMinerId = json['assignedMinerId'];
  }
}
