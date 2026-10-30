enum QuestType { tapCount, hashrateTarget, floorUpgrade, marketTrade, frenzyTrigger, miniGamePlayed }

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final double targetValue;
  final double rewardSatoshis;
  double currentValue;
  bool isCompleted;
  bool isClaimed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.rewardSatoshis,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'currentValue': currentValue,
        'isCompleted': isCompleted,
        'isClaimed': isClaimed,
      };

  void loadJson(Map<String, dynamic> json) {
    currentValue = (json['currentValue'] as num?)?.toDouble() ?? currentValue;
    isCompleted = json['isCompleted'] ?? isCompleted;
    isClaimed = json['isClaimed'] ?? isClaimed;
  }
}
