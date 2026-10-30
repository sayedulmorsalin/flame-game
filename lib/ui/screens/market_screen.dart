import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class MarketScreen extends StatefulWidget {
  final GameState gameState;

  const MarketScreen({Key? key, required this.gameState}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int selectedAssetIndex = 0;
  double sellPercentage = 0.50; // default 50%

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final satoshiFormat = NumberFormat('#,###');
    final selectedAsset = widget.gameState.marketAssets[selectedAssetIndex];

    final sellSatoshisAmount = widget.gameState.satoshis * sellPercentage;
    final estimatedUsd = (sellSatoshisAmount / 100000000.0) * widget.gameState.btcPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cash Portfolio Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.greenHash,
              glowColor: AppTheme.greenHash,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL SIMULATED CASH',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(widget.gameState.virtualUsd),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.greenHash,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      const Text('TOTAL TRADES', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                      Text(
                        '${widget.gameState.totalTradesCount}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Crypto Asset Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.gameState.marketAssets.length, (idx) {
                final asset = widget.gameState.marketAssets[idx];
                final isSelected = idx == selectedAssetIndex;
                final isPositive = asset.change24h >= 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => selectedAssetIndex = idx),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.cyanNeon : AppTheme.surfaceBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(asset.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                asset.symbol,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(asset.priceUsd),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          Text(
                            '${isPositive ? '+' : ''}${asset.change24h.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? AppTheme.greenHash : AppTheme.redOverheat,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Live Price Candlestick / Line Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.surfaceBorder,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedAsset.name} (${selectedAsset.symbol}) 24H TICKER',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: selectedAsset.change24h >= 0
                            ? AppTheme.greenHash.withOpacity(0.15)
                            : AppTheme.redOverheat.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LIVE MARKET',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: selectedAsset.change24h >= 0 ? AppTheme.greenHash : AppTheme.redOverheat,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Chart Canvas
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _MarketChartPainter(
                      prices: selectedAsset.priceHistory,
                      isPositive: selectedAsset.change24h >= 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sell Mined Satoshis Interface
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.bitcoinGold.withOpacity(0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('⚡ ', style: TextStyle(fontSize: 16)),
                    Text(
                      'SELL MINED SATOSHIS FOR USD',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Take profit when Bitcoin spikes! Sell Satoshis at live exchange rates.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),

                // Percentage Buttons (25%, 50%, 100%)
                Row(
                  children: [0.25, 0.50, 1.0].map((pct) {
                    final isChosen = sellPercentage == pct;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          onPressed: () => setState(() => sellPercentage = pct),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isChosen ? AppTheme.bitcoinGold : Colors.transparent,
                            foregroundColor: isChosen ? Colors.black : Colors.white,
                            side: BorderSide(
                              color: isChosen ? AppTheme.bitcoinGold : AppTheme.surfaceBorder,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            '${(pct * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isChosen ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SELLING', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          Text(
                            '${satoshiFormat.format(sellSatoshisAmount.toInt())} SAT',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.bitcoinGold),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('RECEIVING', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          Text(
                            currencyFormat.format(estimatedUsd),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.greenHash),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Sell Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.gameState.satoshis >= 10 && sellSatoshisAmount > 0
                        ? () {
                            final usd = widget.gameState.sellSatoshis(sellSatoshisAmount);
                            AudioService.instance.playCoinPickup();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sold Satoshis for ${currencyFormat.format(usd)} USD!'),
                                backgroundColor: AppTheme.greenHash,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bitcoinGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: const Text('EXECUTE TRADE ORDER'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  final List<double> prices;
  final bool isPositive;

  _MarketChartPainter({required this.prices, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    final range = (maxPrice - minPrice).abs() < 0.001 ? 1.0 : (maxPrice - minPrice);

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (prices.length - 1);

    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final normalizedY = (prices[i] - minPrice) / range;
      final y = size.height - (normalizedY * (size.height - 20) + 10);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final chartColor = isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);

    // Gradient Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          chartColor.withOpacity(0.35),
          chartColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Stroke Line
    final strokePaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);

    // Last point dot
    final lastNormalizedY = (prices.last - minPrice) / range;
    final lastY = size.height - (lastNormalizedY * (size.height - 20) + 10);
    canvas.drawCircle(Offset(size.width, lastY), 4.5, Paint()..color = chartColor);
    canvas.drawCircle(Offset(size.width, lastY), 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MarketChartPainter oldDelegate) => true;
}
