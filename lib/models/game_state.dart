import 'dart:math';
import 'package:flutter/foundation.dart';
import 'mining_shaft.dart';
import 'super_miner.dart';
import 'crypto_asset.dart';
import 'quest.dart';

class GameState extends ChangeNotifier {
  // Currencies
  double satoshis = 0.0; // Start at 0 so player earns coins via games and activities!
  double virtualUsd = 0.0;
  int genesisCoins = 0; // Hard fork prestige points
  
  // Lifetime statistics
  double lifetimeSatoshisMined = 0.0;
  int totalTaps = 0;
  int totalDronesCaught = 0;
  int totalTradesCount = 0;
  int totalMiniGamesPlayed = 0;

  // Rig Power Grid System (0.0% to 100.0%)
  // Rigs ONLY auto-mine when rigPower > 0!
  // This prevents passive coin inflation when simply opening the app.
  double rigPower = 0.0;
  bool get isRigPowered => rigPower > 0.0;

  // Tap Frenzy system
  double frenzyMeter = 0.0; // 0.0 to 1.0
  bool isFrenzyActive = false;
  double frenzyDurationRemaining = 0.0;

  // Active Overclock Boost (e.g. 2x boost)
  double activeBoostMultiplier = 1.0;
  double boostDurationRemaining = 0.0;

  // Settings
  bool soundEnabled = true;
  bool hapticsEnabled = true;

  // Last update timestamp for offline calculation
  DateTime lastActiveTime = DateTime.now();

  // Mining Shafts (5 unique cyber floors)
  late List<MiningShaft> shafts;

  // Super Miners Roster
  late List<SuperMiner> superMiners;

  // Crypto Exchange Assets
  late List<CryptoAsset> marketAssets;

  // Daily Quests
  late List<Quest> dailyQuests;

  GameState() {
    _initShafts();
    _initMiners();
    _initMarket();
    _initQuests();
  }

  void _initShafts() {
    shafts = [
      MiningShaft(
        id: 0,
        name: 'Floor 1: GPU Cluster Alpha',
        subtitle: 'Custom liquid overclocked GTX rigs',
        icon: '🖥️',
        baseHashrate: 2.5, // 2.5 MH/s
        baseCost: 50.0,
        costMultiplier: 1.14,
        isUnlocked: true,
        level: 1,
      ),
      MiningShaft(
        id: 1,
        name: 'Floor 2: ASIC Antminer Grid',
        subtitle: 'High-density SHA-256 microchips',
        icon: '⚡',
        baseHashrate: 18.0, // 18 MH/s
        baseCost: 450.0,
        costMultiplier: 1.16,
        isUnlocked: false,
        level: 0,
      ),
      MiningShaft(
        id: 2,
        name: 'Floor 3: Cryo Immersion Vault',
        subtitle: 'Sub-zero fluorochemical coolant tank',
        icon: '❄️',
        baseHashrate: 120.0, // 120 MH/s
        baseCost: 3200.0,
        costMultiplier: 1.18,
        isUnlocked: false,
        level: 0,
      ),
      MiningShaft(
        id: 3,
        name: 'Floor 4: Quantum Hash Core',
        subtitle: 'Superconducting qubit accelerator',
        icon: '🔮',
        baseHashrate: 850.0, // 850 MH/s
        baseCost: 28000.0,
        costMultiplier: 1.20,
        isUnlocked: false,
        level: 0,
      ),
      MiningShaft(
        id: 4,
        name: 'Floor 5: Orbital Dyson Array',
        subtitle: 'Solar-pumped space relay miners',
        icon: '🛰️',
        baseHashrate: 6500.0, // 6.5 GH/s
        baseCost: 250000.0,
        costMultiplier: 1.24,
        isUnlocked: false,
        level: 0,
      ),
    ];
  }

  void _initMiners() {
    superMiners = [
      SuperMiner(
        id: 'miner_satoshi',
        name: 'Satoshi\'s Avatar',
        title: 'The Creator',
        description: '+150% Global Hashrate across all floors',
        rarity: MinerRarity.legendary,
        targetShaftId: -1,
        baseMultiplier: 2.5,
        unlockCostSatoshis: 15000.0,
      ),
      SuperMiner(
        id: 'miner_jax',
        name: 'Cyber Digger Jax',
        title: 'Floor 1 Specialist',
        description: '+120% GPU Cluster efficiency',
        rarity: MinerRarity.common,
        targetShaftId: 0,
        baseMultiplier: 2.2,
        unlockCostSatoshis: 300.0,
        isUnlocked: true,
      ),
      SuperMiner(
        id: 'miner_vesper',
        name: 'Overclock Queen Vesper',
        title: 'Floor 2 ASIC Guru',
        description: '+140% ASIC Antminer hashrate',
        rarity: MinerRarity.rare,
        targetShaftId: 1,
        baseMultiplier: 2.4,
        unlockCostSatoshis: 2500.0,
      ),
      SuperMiner(
        id: 'miner_frost',
        name: 'Dr. Cryo Frost',
        title: 'Floor 3 Thermals Master',
        description: '+160% Cryo Immersion power',
        rarity: MinerRarity.rare,
        targetShaftId: 2,
        baseMultiplier: 2.6,
        unlockCostSatoshis: 12000.0,
      ),
      SuperMiner(
        id: 'miner_ada',
        name: 'Quantum Ada',
        title: 'Floor 4 Theoretical Physicist',
        description: '+200% Quantum Core acceleration',
        rarity: MinerRarity.epic,
        targetShaftId: 3,
        baseMultiplier: 3.0,
        unlockCostSatoshis: 80000.0,
      ),
      SuperMiner(
        id: 'miner_neil',
        name: 'Cosmic Neil',
        title: 'Floor 5 Dyson Architect',
        description: '+300% Orbital Dyson hashrate',
        rarity: MinerRarity.legendary,
        targetShaftId: 4,
        baseMultiplier: 4.0,
        unlockCostSatoshis: 500000.0,
      ),
      SuperMiner(
        id: 'miner_bull',
        name: 'Gordon Bull',
        title: 'Market Arbitrageur',
        description: '+40% bonus USD on all crypto exchange trades',
        rarity: MinerRarity.epic,
        targetShaftId: -1,
        baseMultiplier: 1.4,
        unlockCostSatoshis: 35000.0,
      ),
      SuperMiner(
        id: 'miner_robo',
        name: 'Auto-Tapper Bot V2',
        title: 'Autonomous Digger',
        description: 'Automatically triggers manual mining taps every 1.5s',
        rarity: MinerRarity.rare,
        targetShaftId: -1,
        baseMultiplier: 1.5,
        unlockCostSatoshis: 5000.0,
      ),
    ];
  }

  void _initMarket() {
    marketAssets = [
      CryptoAsset(
        symbol: 'BTC',
        name: 'Bitcoin',
        icon: '₿',
        priceUsd: 68450.0,
        change24h: 4.2,
      ),
      CryptoAsset(
        symbol: 'ETH',
        name: 'Ethereum',
        icon: 'Ξ',
        priceUsd: 3480.0,
        change24h: 2.8,
      ),
      CryptoAsset(
        symbol: 'SOL',
        name: 'Solana',
        icon: '◎',
        priceUsd: 178.5,
        change24h: 8.5,
      ),
      CryptoAsset(
        symbol: 'DOGE',
        name: 'Dogecoin',
        icon: 'Ð',
        priceUsd: 0.165,
        change24h: -1.4,
      ),
    ];
  }

  void _initQuests() {
    dailyQuests = [
      Quest(
        id: 'quest_play_games_1',
        title: 'Arcade Rookie',
        description: 'Play 1 mini-game to earn your first coin reward',
        type: QuestType.miniGamePlayed,
        targetValue: 1,
        rewardSatoshis: 250.0,
      ),
      Quest(
        id: 'quest_taps_30',
        title: 'Rapid Dynamo Tapper',
        description: 'Crank the Dynamo or tap coins 30 times',
        type: QuestType.tapCount,
        targetValue: 30,
        rewardSatoshis: 200.0,
      ),
      Quest(
        id: 'quest_play_games_3',
        title: 'Arcade Master',
        description: 'Play 3 mini-games to score massive Satoshis',
        type: QuestType.miniGamePlayed,
        targetValue: 3,
        rewardSatoshis: 600.0,
      ),
      Quest(
        id: 'quest_frenzy',
        title: 'Frenzy Multiplier',
        description: 'Trigger 3X Coin Frenzy mode',
        type: QuestType.frenzyTrigger,
        targetValue: 1,
        rewardSatoshis: 350.0,
      ),
      Quest(
        id: 'quest_play_games_5',
        title: 'Arcade Champion',
        description: 'Play 5 mini-games for the grand daily jackpot',
        type: QuestType.miniGamePlayed,
        targetValue: 5,
        rewardSatoshis: 1200.0,
      ),
    ];
  }

  // Calculated properties
  double get btcBalance => satoshis / 100000000.0;

  double get btcPrice => marketAssets.firstWhere((a) => a.symbol == 'BTC').priceUsd;

  double get portfolioUsdValue => (btcBalance * btcPrice) + virtualUsd;

  double get totalHashrate {
    double total = 0.0;

    for (var shaft in shafts) {
      if (shaft.isUnlocked && shaft.level > 0) {
        double shaftHr = shaft.currentHashrate;
        // Check if there is an assigned or targeting super miner
        for (var miner in superMiners) {
          if (miner.isUnlocked && miner.targetShaftId == shaft.id) {
            shaftHr *= miner.currentMultiplier;
          }
        }
        total += shaftHr;
      }
    }

    // Global super miners
    for (var miner in superMiners) {
      if (miner.isUnlocked && miner.targetShaftId == -1) {
        if (miner.id != 'miner_bull' && miner.id != 'miner_robo') {
          total *= miner.currentMultiplier;
        }
      }
    }

    // Hard fork genesis bonus (+50% per genesis coin)
    if (genesisCoins > 0) {
      total *= (1.0 + genesisCoins * 0.50);
    }

    // Frenzy multiplier (3x during frenzy)
    if (isFrenzyActive) {
      total *= 3.0;
    }

    // Active temporary boost
    if (boostDurationRemaining > 0) {
      total *= activeBoostMultiplier;
    }

    return total;
  }

  // Format hashrate into readable text (MH/s, GH/s, TH/s, etc.)
  String get formattedHashrate {
    final hr = totalHashrate;
    if (hr >= 1000000) {
      return '${(hr / 1000000).toStringAsFixed(2)} TH/s';
    } else if (hr >= 1000) {
      return '${(hr / 1000).toStringAsFixed(2)} GH/s';
    } else {
      return '${hr.toStringAsFixed(1)} MH/s';
    }
  }

  // Tap power (Satoshis per manual tap)
  double get tapPower {
    double base = 1.0;
    // Scaled with level of Floor 1 and total hashrate
    base += (shafts[0].level * 0.8) + (totalHashrate * 0.03);
    if (isFrenzyActive) base *= 3.0;
    if (boostDurationRemaining > 0) base *= activeBoostMultiplier;
    return base;
  }

  // --- ACTIONS ---

  double manualTap() {
    totalTaps++;
    final earned = tapPower;
    satoshis += earned;
    lifetimeSatoshisMined += earned;

    // Manual tap gently feeds small energy into the rig power grid (+0.3%)
    chargeRigPower(0.3);

    // Advance frenzy meter
    if (!isFrenzyActive) {
      frenzyMeter = (frenzyMeter + 0.04).clamp(0.0, 1.0);
      if (frenzyMeter >= 1.0) {
        _triggerFrenzy();
      }
    }

    // Update quest
    _updateQuest(QuestType.tapCount, 1);

    notifyListeners();
    return earned;
  }

  // Interactive Generator Crank Action
  double crankGenerator() {
    // Crank generates +4.0% power per turn
    chargeRigPower(4.0);
    final earned = max(1.0, tapPower * 0.6);
    satoshis += earned;
    lifetimeSatoshisMined += earned;
    _updateQuest(QuestType.tapCount, 1);
    notifyListeners();
    return earned;
  }

  void chargeRigPower(double percent) {
    rigPower = (rigPower + percent).clamp(0.0, 100.0);
    notifyListeners();
  }

  void awardMiniGameReward({required double satoshisEarned, double powerBonus = 35.0}) {
    satoshis += satoshisEarned;
    lifetimeSatoshisMined += satoshisEarned;
    chargeRigPower(powerBonus);
    totalMiniGamesPlayed++;
    _updateQuest(QuestType.miniGamePlayed, 1);
    notifyListeners();
  }

  void _triggerFrenzy() {
    isFrenzyActive = true;
    frenzyDurationRemaining = 12.0; // 12 seconds frenzy
    _updateQuest(QuestType.frenzyTrigger, 1);
    notifyListeners();
  }

  void idleTick(double dt) {
    lastActiveTime = DateTime.now();

    // Rigs ONLY auto-mine if power grid has battery!
    // When opened with 0% battery, coins will NOT auto-increase until user plays or cranks!
    if (isRigPowered && totalHashrate > 0) {
      // Drain battery smoothly: 0.5% per second (lasts 200 seconds / ~3.3 mins per full 100% charge)
      rigPower = (rigPower - 0.5 * dt).clamp(0.0, 100.0);

      // 1 MH/s produces ~ 0.25 Satoshis per second
      final produced = (totalHashrate * 0.25) * dt;
      satoshis += produced;
      lifetimeSatoshisMined += produced;
    }

    // Auto-tapper robot manager only runs when rigs have power
    final roboMatches = superMiners.where((m) => m.id == 'miner_robo');
    if (roboMatches.isNotEmpty && roboMatches.first.isUnlocked && isRigPowered) {
      final autoEarned = tapPower * 0.6 * dt;
      satoshis += autoEarned;
      lifetimeSatoshisMined += autoEarned;
    }

    // Frenzy decay or active countdown
    if (isFrenzyActive) {
      frenzyDurationRemaining -= dt;
      frenzyMeter = (frenzyDurationRemaining / 12.0).clamp(0.0, 1.0);
      if (frenzyDurationRemaining <= 0) {
        isFrenzyActive = false;
        frenzyMeter = 0.0;
      }
    } else if (frenzyMeter > 0) {
      frenzyMeter = (frenzyMeter - 0.02 * dt).clamp(0.0, 1.0);
    }

    // Boost timer
    if (boostDurationRemaining > 0) {
      boostDurationRemaining -= dt;
      if (boostDurationRemaining <= 0) {
        activeBoostMultiplier = 1.0;
      }
    }

    // Check hashrate quest
    _setQuestProgress(QuestType.hashrateTarget, totalHashrate);

    // Throttle UI notification to ~5 FPS to keep Flutter UI buttery smooth
    _uiNotificationTimer += dt;
    if (_uiNotificationTimer >= 0.2) {
      _uiNotificationTimer = 0.0;
      notifyListeners();
    }
  }

  double _uiNotificationTimer = 0.0;

  // Market tick (fluctuates crypto prices)
  void tickMarket() {
    for (var asset in marketAssets) {
      asset.tickFluctuation();
    }
    // Random market event (5% chance per 15s)
    if (Random().nextDouble() < 0.05) {
      final events = ['BULL_RUN', 'HALVING', 'DIP'];
      final pickedEvent = events[Random().nextInt(events.length)];
      marketAssets[0].triggerMarketEvent(pickedEvent);
    }
    notifyListeners();
  }

  // Upgrade shaft level
  bool upgradeShaft(int shaftId) {
    final shaft = shafts.firstWhere((s) => s.id == shaftId);
    final cost = shaft.currentCost;
    if (satoshis >= cost) {
      satoshis -= cost;
      if (!shaft.isUnlocked) {
        shaft.isUnlocked = true;
        shaft.level = 1;
      } else {
        shaft.level += 1;
      }
      _updateQuest(QuestType.floorUpgrade, 1);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Upgrade cooling system
  bool upgradeShaftCooling(int shaftId) {
    final shaft = shafts.firstWhere((s) => s.id == shaftId);
    final cost = shaft.baseCost * (shaft.coolingLevel * 1.6);
    if (satoshis >= cost) {
      satoshis -= cost;
      shaft.coolingLevel += 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Upgrade overclock level
  bool upgradeShaftOverclock(int shaftId) {
    final shaft = shafts.firstWhere((s) => s.id == shaftId);
    final cost = shaft.baseCost * (shaft.overclockLevel * 2.2);
    if (satoshis >= cost) {
      satoshis -= cost;
      shaft.overclockLevel += 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Unlock or upgrade Super Miner
  bool hireOrUpgradeMiner(String minerId) {
    final miner = superMiners.firstWhere((m) => m.id == minerId);
    final cost = miner.isUnlocked ? miner.upgradeCost : miner.unlockCostSatoshis;
    if (satoshis >= cost) {
      satoshis -= cost;
      if (!miner.isUnlocked) {
        miner.isUnlocked = true;
        miner.level = 1;
      } else {
        miner.level += 1;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Trade Satoshis for simulated USD at live BTC rate
  double sellSatoshis(double amountSatoshis) {
    if (satoshis < amountSatoshis || amountSatoshis <= 0) return 0.0;
    satoshis -= amountSatoshis;
    final btcAmount = amountSatoshis / 100000000.0;
    double usdGained = btcAmount * btcPrice;

    // Check Bull miner bonus
    final bullMatches = superMiners.where((m) => m.id == 'miner_bull');
    if (bullMatches.isNotEmpty && bullMatches.first.isUnlocked) {
      usdGained *= bullMatches.first.currentMultiplier;
    }

    virtualUsd += usdGained;
    totalTradesCount++;
    _updateQuest(QuestType.marketTrade, 1);
    notifyListeners();
    return usdGained;
  }

  // Apply Overclock Boost (e.g., from Airdrop or Booster button)
  void applyBoost({double multiplier = 2.0, double durationSeconds = 60.0}) {
    activeBoostMultiplier = multiplier;
    boostDurationRemaining = durationSeconds;
    notifyListeners();
  }

  // Time Warp (instantly mine N seconds of idle hashrate)
  double timeWarp(double seconds) {
    final produced = (totalHashrate * 0.25) * seconds;
    satoshis += produced;
    lifetimeSatoshisMined += produced;
    notifyListeners();
    return produced;
  }

  // Claim Airdrop Drone crate
  Map<String, dynamic> claimAirdropCrate() {
    totalDronesCaught++;
    final rand = Random();
    final type = rand.nextInt(3); // 0: satoshis, 1: frenzy, 2: 2x boost

    if (type == 0) {
      final bonusSatoshis = (tapPower * 40.0) + (totalHashrate * 15.0);
      satoshis += bonusSatoshis;
      lifetimeSatoshisMined += bonusSatoshis;
      notifyListeners();
      return {'type': 'SATOSHIS', 'value': bonusSatoshis, 'title': 'Satoshi Airdrop!'};
    } else if (type == 1) {
      _triggerFrenzy();
      return {'type': 'FRENZY', 'value': 12.0, 'title': 'Instant Frenzy Surge!'};
    } else {
      applyBoost(multiplier: 2.5, durationSeconds: 45.0);
      return {'type': 'BOOST', 'value': 45.0, 'title': 'Overclock Overdrive 2.5x!'};
    }
  }

  // Hard Fork Prestige Reset
  bool triggerHardFork() {
    // Requires at least 1,000,000 Satoshis or high progress
    if (lifetimeSatoshisMined < 50000) return false;

    // Calculate genesis coins gained
    final gainedCoins = max(1, (sqrt(lifetimeSatoshisMined / 25000)).floor());
    genesisCoins += gainedCoins;

    // Reset shafts & satoshis
    satoshis = 100.0;
    frenzyMeter = 0.0;
    isFrenzyActive = false;
    boostDurationRemaining = 0.0;

    _initShafts();
    // Keep Super Miners unlocked, but can reset floor levels
    notifyListeners();
    return true;
  }

  // Claim Quest reward
  bool claimQuest(String questId) {
    final quest = dailyQuests.firstWhere((q) => q.id == questId);
    if (quest.isCompleted && !quest.isClaimed) {
      quest.isClaimed = true;
      satoshis += quest.rewardSatoshis;
      lifetimeSatoshisMined += quest.rewardSatoshis;
      notifyListeners();
      return true;
    }
    return false;
  }

  void _updateQuest(QuestType type, double increment) {
    for (var quest in dailyQuests) {
      if (quest.type == type && !quest.isCompleted) {
        quest.currentValue += increment;
        if (quest.currentValue >= quest.targetValue) {
          quest.currentValue = quest.targetValue;
          quest.isCompleted = true;
        }
      }
    }
  }

  void _setQuestProgress(QuestType type, double value) {
    for (var quest in dailyQuests) {
      if (quest.type == type && !quest.isCompleted) {
        if (value >= quest.currentValue) {
          quest.currentValue = value;
        }
        if (quest.currentValue >= quest.targetValue) {
          quest.currentValue = quest.targetValue;
          quest.isCompleted = true;
        }
      }
    }
  }

  // Offline earnings calculation: only earned if power battery had charge when closed!
  double calculateOfflineEarnings(DateTime lastTime) {
    if (rigPower <= 0.0) return 0.0;
    final now = DateTime.now();
    final differenceSeconds = now.difference(lastTime).inSeconds;
    if (differenceSeconds <= 10) return 0.0;

    // Battery lasts (rigPower / 0.5) seconds
    final powerSecondsRemaining = rigPower / 0.5;
    final activeSeconds = min(differenceSeconds.toDouble(), powerSecondsRemaining);

    // Max 12 hours of offline earnings
    final cappedSeconds = min(activeSeconds, 12 * 3600);
    final offlineEarned = (totalHashrate * 0.25) * cappedSeconds;
    
    // Battery was drained
    rigPower = 0.0;
    notifyListeners();
    return offlineEarned;
  }

  void claimOfflineEarnings(double amount, {bool doubled = false}) {
    final finalAmount = doubled ? amount * 2.0 : amount;
    satoshis += finalAmount;
    lifetimeSatoshisMined += finalAmount;
    notifyListeners();
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
    notifyListeners();
  }

  void toggleHaptics() {
    hapticsEnabled = !hapticsEnabled;
    notifyListeners();
  }

  // Serialization for persistent save
  Map<String, dynamic> toJson() => {
        'satoshis': satoshis,
        'virtualUsd': virtualUsd,
        'genesisCoins': genesisCoins,
        'lifetimeSatoshisMined': lifetimeSatoshisMined,
        'totalTaps': totalTaps,
        'totalDronesCaught': totalDronesCaught,
        'totalTradesCount': totalTradesCount,
        'totalMiniGamesPlayed': totalMiniGamesPlayed,
        'rigPower': rigPower,
        'lastActiveTime': DateTime.now().toIso8601String(),
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'shafts': shafts.map((s) => s.toJson()).toList(),
        'superMiners': superMiners.map((m) => m.toJson()).toList(),
        'dailyQuests': dailyQuests.map((q) => q.toJson()).toList(),
      };

  void loadFromJson(Map<String, dynamic> json) {
    satoshis = (json['satoshis'] as num?)?.toDouble() ?? satoshis;
    virtualUsd = (json['virtualUsd'] as num?)?.toDouble() ?? virtualUsd;
    genesisCoins = json['genesisCoins'] ?? genesisCoins;
    lifetimeSatoshisMined = (json['lifetimeSatoshisMined'] as num?)?.toDouble() ?? lifetimeSatoshisMined;
    totalTaps = json['totalTaps'] ?? totalTaps;
    totalDronesCaught = json['totalDronesCaught'] ?? totalDronesCaught;
    totalTradesCount = json['totalTradesCount'] ?? totalTradesCount;
    totalMiniGamesPlayed = json['totalMiniGamesPlayed'] ?? totalMiniGamesPlayed;
    rigPower = (json['rigPower'] as num?)?.toDouble() ?? rigPower;
    soundEnabled = json['soundEnabled'] ?? soundEnabled;
    hapticsEnabled = json['hapticsEnabled'] ?? hapticsEnabled;

    if (json['lastActiveTime'] != null) {
      lastActiveTime = DateTime.tryParse(json['lastActiveTime']) ?? DateTime.now();
    }

    if (json['shafts'] != null) {
      final shaftsList = json['shafts'] as List;
      for (var sData in shaftsList) {
        final id = sData['id'];
        final shaft = shafts.firstWhere((s) => s.id == id, orElse: () => shafts[0]);
        shaft.loadJson(sData);
      }
    }

    if (json['superMiners'] != null) {
      final minersList = json['superMiners'] as List;
      for (var mData in minersList) {
        final id = mData['id'];
        final miner = superMiners.firstWhere((m) => m.id == id, orElse: () => superMiners[0]);
        miner.loadJson(mData);
      }
    }

    if (json['dailyQuests'] != null) {
      final qList = json['dailyQuests'] as List;
      for (var qData in qList) {
        final id = qData['id'];
        final quest = dailyQuests.firstWhere((q) => q.id == id, orElse: () => dailyQuests[0]);
        quest.loadJson(qData);
      }
    }
    notifyListeners();
  }
}
