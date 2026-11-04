import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class MarketScreen extends StatefulWidget {
  final GameState gameState;

  const MarketScreen({super.key, required this.gameState});

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
          // Cash Portfolio Header (Flexible to prevent any overflow)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.greenHash,
              glowColor: AppTheme.greenHash,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL SIMULATED CASH',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(widget.gameState.virtualUsd),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.greenHash,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('TOTAL TRADES', style: TextStyle(fontSize: 8.5, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.gameState.totalTradesCount}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

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
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.richRuby : AppTheme.surfaceBorder,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.richRuby.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(asset.priceUsd),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
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

          const SizedBox(height: 14),

          // Live Price Candlestick / Line Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${selectedAsset.name} (${selectedAsset.symbol}) 24H TICKER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: selectedAsset.change24h >= 0
                            ? AppTheme.greenHash.withValues(alpha: 0.12)
                            : AppTheme.redOverheat.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LIVE MARKET',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: selectedAsset.change24h >= 0 ? AppTheme.greenHash : AppTheme.redOverheat,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Chart Canvas
                SizedBox(
                  height: 135,
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

          const SizedBox(height: 14),

          // Sell Mined Satoshis Interface Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cyberCardDecoration(
              borderColor: AppTheme.bitcoinGold.withValues(alpha: 0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('⚡ ', style: TextStyle(fontSize: 16)),
                    Text(
                      'SELL MINED SATOSHIS FOR USD',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Take profit when Bitcoin spikes! Sell Satoshis at live exchange rates.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),

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
                            backgroundColor: isChosen ? AppTheme.richRuby : Colors.transparent,
                            foregroundColor: isChosen ? Colors.white : AppTheme.textPrimary,
                            side: BorderSide(
                              color: isChosen ? AppTheme.richRuby : AppTheme.surfaceBorder,
                              width: isChosen ? 1.5 : 1,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            '${(pct * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isChosen ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.surfaceBorderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SELLING', style: TextStyle(fontSize: 9.5, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                            Text(
                              '${satoshiFormat.format(sellSatoshisAmount.toInt())} SAT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.bitcoinGold),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 18),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('RECEIVING', style: TextStyle(fontSize: 9.5, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                            Text(
                              currencyFormat.format(estimatedUsd),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.greenHash),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Sell Action Button
                GestureDetector(
                  onTap: widget.gameState.satoshis >= 10 && sellSatoshisAmount > 0
                      ? () {
                          final usd = widget.gameState.sellSatoshis(sellSatoshisAmount);
                          AudioService.instance.playCoinPickup();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sold Satoshis for ${currencyFormat.format(usd)} USD!',
                                style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900),
                              ),
                              backgroundColor: AppTheme.greenHash,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: (widget.gameState.satoshis >= 10 && sellSatoshisAmount > 0)
                        ? AppTheme.gameButtonDecoration(color: AppTheme.richRuby, borderRadius: 10)
                        : BoxDecoration(
                            color: AppTheme.surfaceSecondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.surfaceBorderSubtle),
                          ),
                    child: Center(
                      child: Text(
                        'EXECUTE TRADE ORDER',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: (widget.gameState.satoshis >= 10 && sellSatoshisAmount > 0)
                              ? Colors.white
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
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

    final chartColor = isPositive ? AppTheme.greenHash : AppTheme.redOverheat;

    // Gradient Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          chartColor.withValues(alpha: 0.22),
          chartColor.withValues(alpha: 0.0),
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
