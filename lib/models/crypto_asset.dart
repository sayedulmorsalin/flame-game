import 'dart:math';

class CryptoAsset {
  final String symbol;
  final String name;
  final String icon;
  double priceUsd;
  double change24h;
  List<double> priceHistory;

  CryptoAsset({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.priceUsd,
    this.change24h = 0.0,
    List<double>? history,
  }) : priceHistory = history ?? List.generate(12, (index) => priceUsd * (0.95 + Random().nextDouble() * 0.10));

  void tickFluctuation() {
    final rand = Random();
    // Volatility between -3.5% and +3.8%
    final deltaPercent = (rand.nextDouble() * 7.5 - 3.6) / 100.0;
    priceUsd = (priceUsd * (1.0 + deltaPercent)).clamp(0.001, 10000000.0);
    change24h = (change24h * 0.85) + (deltaPercent * 100.0);
    
    priceHistory.add(priceUsd);
    if (priceHistory.length > 20) {
      priceHistory.removeAt(0);
    }
  }

  void triggerMarketEvent(String eventType) {
    if (eventType == 'BULL_RUN') {
      priceUsd *= 1.35;
      change24h += 35.0;
    } else if (eventType == 'HALVING') {
      priceUsd *= 1.75;
      change24h += 75.0;
    } else if (eventType == 'DIP') {
      priceUsd *= 0.80;
      change24h -= 20.0;
    }
    priceHistory.add(priceUsd);
    if (priceHistory.length > 20) {
      priceHistory.removeAt(0);
    }
  }
}
