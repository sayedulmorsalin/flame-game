import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BedrockBackgroundComponent extends PositionComponent {
  final double worldWidth;
  final double worldHeight;

  BedrockBackgroundComponent({
    required this.worldWidth,
    required this.worldHeight,
  }) : super(size: Vector2(worldWidth, worldHeight));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Deep Cyber Dark Gradient
    final rect = Rect.fromLTWH(0, 0, worldWidth, worldHeight);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF07090E),
          Color(0xFF0B0F19),
          Color(0xFF0F1523),
          Color(0xFF080B12),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Subtle Perspective Subterranean Cyber Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Horizontal grid lines
    for (double y = 0; y < worldHeight; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(worldWidth, y), gridPaint);
    }

    // Vertical grid lines
    for (double x = 0; x < worldWidth; x += 55) {
      canvas.drawLine(Offset(x, 0), Offset(x, worldHeight), gridPaint);
    }

    // Glowing Neon Vertical Cables on the sides
    final cablePaint = Paint()
      ..color = const Color(0xFF00F2FE).withOpacity(0.2)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(6, 0), Offset(6, worldHeight), cablePaint);
    canvas.drawLine(Offset(worldWidth - 6, 0), Offset(worldWidth - 6, worldHeight), cablePaint);
  }
}
