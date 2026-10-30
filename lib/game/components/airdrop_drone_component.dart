import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class AirdropDroneComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onDroneTapped;
  final double screenWidth;
  double hoverTimer = 0.0;
  final double flightSpeed = 90.0;
  bool isClaimed = false;

  AirdropDroneComponent({
    required this.screenWidth,
    required this.onDroneTapped,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(74, 52),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (isClaimed) {
      // Zoom upwards offscreen fast
      position.y -= 250.0 * dt;
      if (position.y < -100) removeFromParent();
      return;
    }

    // Fly to the right
    position.x += flightSpeed * dt;

    // Gentle hover bobbing
    hoverTimer += dt * 4.0;
    position.y += sin(hoverTimer) * 0.8;

    // Reset or remove when flew past screen
    if (position.x > screenWidth + 100) {
      removeFromParent();
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (isClaimed) return false;
    isClaimed = true;
    onDroneTapped();
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final dronePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = const Color(0xFF00F2FE)
      ..style = PaintingStyle.fill;

    final rotorPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Center body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(37, 20), width: 34, height: 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, dronePaint);

    // Glowing cockpit visor
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(42, 20), width: 14, height: 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(visorRect, accentPaint);

    // Left and right rotor arms
    final armPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 3.0;
    canvas.drawLine(const Offset(22, 20), const Offset(10, 10), armPaint);
    canvas.drawLine(const Offset(52, 20), const Offset(64, 10), armPaint);

    // Spinning rotors (ellipses that oscillate width)
    final rotorWidth = 22.0 + sin(hoverTimer * 8.0) * 8.0;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(10, 8), width: rotorWidth, height: 4),
      rotorPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(64, 8), width: rotorWidth, height: 4),
      rotorPaint,
    );

    // Suspension cables holding crate
    final cablePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(30, 26), const Offset(28, 36), cablePaint);
    canvas.drawLine(const Offset(44, 26), const Offset(46, 36), cablePaint);

    // Golden Bitcoin Mystery Crate
    final cratePaint = Paint()
      ..color = const Color(0xFFF7931A)
      ..style = PaintingStyle.fill;
    final crateBorder = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final crateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(37, 42), width: 22, height: 18),
      const Radius.circular(3),
    );
    canvas.drawRRect(crateRect, cratePaint);
    canvas.drawRRect(crateRect, crateBorder);

    // ₿ symbol on crate
    final btcTextPaint = TextPaint(
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    btcTextPaint.render(canvas, '₿', Vector2(33, 35));
  }
}
