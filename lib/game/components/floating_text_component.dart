import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FloatingTextComponent extends PositionComponent {
  final String text;
  final Color color;
  final bool isCrit;
  double lifeTime = 0.0;
  static const double maxLife = 0.85;

  late TextPaint _textPaint;

  FloatingTextComponent({
    required this.text,
    required Vector2 position,
    this.color = const Color(0xFFF7931A), // Bitcoin Gold
    this.isCrit = false,
  }) : super(position: position) {
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: isCrit ? 22.0 : 16.0,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.8),
            blurRadius: isCrit ? 10.0 : 6.0,
          ),
          const Shadow(
            color: Colors.black,
            blurRadius: 4.0,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime += dt;
    // Float upward and slowly drift
    position.y -= (60.0 + (isCrit ? 30.0 : 0.0)) * dt;
    
    if (lifeTime >= maxLife) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final opacity = (1.0 - (lifeTime / maxLife)).clamp(0.0, 1.0);
    final currentPaint = TextPaint(
      style: _textPaint.style.copyWith(
        color: color.withValues(alpha: opacity),
      ),
    );
    currentPaint.render(canvas, text, Vector2.zero());
  }
}
