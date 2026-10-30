import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/mining_shaft.dart';

class ShaftComponent extends PositionComponent with TapCallbacks {
  final MiningShaft shaft;
  final Function(MiningShaft, Vector2) onShaftTapped;
  final bool isFrenzyActive;
  bool isPowered;

  double animTimer = 0.0;
  double fanRotation = 0.0;
  double pickaxeSwing = 0.0;

  ShaftComponent({
    required this.shaft,
    required Vector2 position,
    required Vector2 size,
    required this.onShaftTapped,
    this.isFrenzyActive = false,
    this.isPowered = true,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void update(double dt) {
    super.update(dt);
    animTimer += dt;

    if (shaft.isUnlocked && shaft.level > 0 && isPowered) {
      // Fan speed accelerates with cooling level and frenzy
      final fanSpeed = (4.0 + shaft.coolingLevel * 3.0) * (isFrenzyActive ? 2.5 : 1.0);
      fanRotation += fanSpeed * dt;

      // Pickaxe / laser swing oscillation (1.5 Hz)
      pickaxeSwing = sin(animTimer * 6.0) * 0.45;
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    onShaftTapped(shaft, event.canvasPosition);
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;

    // 1. Cavern Chamber Background
    final chamberPaint = Paint()
      ..color = shaft.isUnlocked
          ? const Color(0xFF101726)
          : const Color(0xFF0A0D14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(8, 6, w - 16, h - 12), const Radius.circular(12)),
      chamberPaint,
    );

    // Chamber Border (glows when frenzy or high level)
    final borderPaint = Paint()
      ..color = shaft.isUnlocked
          ? (isFrenzyActive ? const Color(0xFFFF9100) : const Color(0xFF1E293B))
          : const Color(0xFF151D2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFrenzyActive ? 2.5 : 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(8, 6, w - 16, h - 12), const Radius.circular(12)),
      borderPaint,
    );

    // Cavern Support Girder Pillars
    final girderPaint = Paint()
      ..color = const Color(0xFF1E2638)
      ..strokeWidth = 3.0;
    canvas.drawLine(Offset(24, 6), Offset(24, h - 6), girderPaint);
    canvas.drawLine(Offset(w - 24, 6), Offset(w - 24, h - 6), girderPaint);

    if (!shaft.isUnlocked) {
      _renderLockedState(canvas, w, h);
      return;
    }

    // 2. High-Tech Server Rack / Rig Station
    _renderServerRack(canvas, 36, 18, 90, h - 36);

    // 3. Mining Ore Node & Animated Digger / Laser
    _renderMiningStation(canvas, w - 110, 20, 80, h - 40);

    // 4. Glowing Data Rail / Cables
    _renderDataRails(canvas, 130, h / 2 + 10, w - 245);

    // 5. Floor Info Header (Floor Name, Level, Hashrate)
    _renderHeader(canvas, 134, 16);
  }

  void _renderServerRack(Canvas canvas, double x, double y, double rw, double rh) {
    // Rack casing
    final rackPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final rackOutline = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, rw, rh),
      const Radius.circular(6),
    );
    canvas.drawRRect(rackRect, rackPaint);
    canvas.drawRRect(rackRect, rackOutline);

    // Server Blades (3 shelves)
    final bladeH = (rh - 16) / 3;
    for (int i = 0; i < 3; i++) {
      final by = y + 8 + i * bladeH;
      final bladeRect = Rect.fromLTWH(x + 6, by, rw - 12, bladeH - 4);
      canvas.drawRect(
        bladeRect,
        Paint()..color = const Color(0xFF1E293B),
      );

      // Blinking RGB LEDs
      for (int led = 0; led < 4; led++) {
        final ledX = x + 12 + led * 8;
        final ledY = by + bladeH / 2 - 2;
        final isLedOn = sin(animTimer * (led + 2) * 3) > -0.2;
        final ledColor = isFrenzyActive
            ? const Color(0xFFFF5252)
            : (led % 2 == 0 ? const Color(0xFF00E676) : const Color(0xFF00F2FE));

        canvas.drawCircle(
          Offset(ledX, ledY),
          2.0,
          Paint()..color = isLedOn ? ledColor : const Color(0xFF334155),
        );
      }

      // Cooling Fan on right side of blade
      final fanCenter = Offset(x + rw - 18, by + bladeH / 2 - 2);
      _renderFan(canvas, fanCenter, 8.0);
    }
  }

  void _renderFan(Canvas canvas, Offset center, double radius) {
    // Fan ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Spinning Blades
    final bladePaint = Paint()
      ..color = isFrenzyActive ? const Color(0xFFFF9100) : const Color(0xFF38BDF8)
      ..strokeWidth = 1.5;

    for (int b = 0; b < 3; b++) {
      final angle = fanRotation + (b * (2 * pi / 3));
      final tip = Offset(
        center.dx + cos(angle) * (radius - 2),
        center.dy + sin(angle) * (radius - 2),
      );
      canvas.drawLine(center, tip, bladePaint);
    }
  }

  void _renderMiningStation(Canvas canvas, double x, double y, double mw, double mh) {
    // Crypto Crystal Ore Vein
    final oreCenter = Offset(x + mw - 20, y + mh / 2);
    final oreRadius = 16.0;

    // Glowing aura
    final glowPaint = Paint()
      ..color = (isFrenzyActive ? const Color(0xFFFF9100) : const Color(0xFFF7931A)).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(oreCenter, oreRadius + 4, glowPaint);

    // Ore polygon
    final orePath = Path();
    for (int p = 0; p < 6; p++) {
      final a = p * (2 * pi / 6);
      final r = oreRadius + (p % 2 == 0 ? 3 : -2);
      final pt = Offset(oreCenter.dx + cos(a) * r, oreCenter.dy + sin(a) * r);
      if (p == 0) {
        orePath.moveTo(pt.dx, pt.dy);
      } else {
        orePath.lineTo(pt.dx, pt.dy);
      }
    }
    orePath.close();

    final orePaint = Paint()
      ..color = isFrenzyActive ? const Color(0xFFFFD54F) : const Color(0xFFF7931A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(orePath, orePaint);

    // ₿ insignia in crystal
    final btcPaint = TextPaint(
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
    btcPaint.render(canvas, '₿', Vector2(oreCenter.dx - 4, oreCenter.dy - 8));

    // Animated Miner with Pickaxe / Laser
    final minerX = x + 15;
    final minerY = y + mh / 2;

    // Miner Body (Cyber Digger in Neon Suit)
    canvas.drawCircle(
      Offset(minerX, minerY - 10),
      7, // Head with helmet
      Paint()..color = const Color(0xFF38BDF8),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(minerX, minerY + 6), width: 12, height: 16),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Swinging Pickaxe Arm
    canvas.save();
    canvas.translate(minerX + 4, minerY - 4);
    canvas.rotate(pickaxeSwing);

    // Pickaxe handle
    final handlePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset.zero, const Offset(18, -4), handlePaint);

    // Pickaxe Head
    final headPaint = Paint()
      ..color = const Color(0xFFF7931A)
      ..strokeWidth = 3.5;
    canvas.drawLine(const Offset(18, -12), const Offset(18, 4), headPaint);

    canvas.restore();
  }

  void _renderDataRails(Canvas canvas, double x, double y, double rw) {
    // Rail line
    final railPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(x, y), Offset(x + rw, y), railPaint);

    // Animated pulse packet traveling on rail
    final pulsePos = (animTimer * 120.0) % rw;
    final pulsePaint = Paint()
      ..color = const Color(0xFF00F2FE)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(x + pulsePos, y), 3.0, pulsePaint);
  }

  void _renderHeader(Canvas canvas, double x, double y) {
    // Shaft Title
    final titlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    titlePaint.render(canvas, shaft.name, Vector2(x, y));

    // Level Badge & Hashrate
    final statsPaint = TextPaint(
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: !isPowered
            ? const Color(0xFFFF9100)
            : (isFrenzyActive ? const Color(0xFFFF9100) : const Color(0xFF00E676)),
      ),
    );
    final hrText = shaft.currentHashrate >= 1000
        ? '${(shaft.currentHashrate / 1000).toStringAsFixed(2)} GH/s'
        : '${shaft.currentHashrate.toStringAsFixed(1)} MH/s';
    final statusText = !isPowered ? ' • ⚠️ STANDBY' : '';

    statsPaint.render(
      canvas,
      'LVL ${shaft.level}  •  ⚡ $hrText$statusText',
      Vector2(x, y + 17),
    );

    // Cooling & Overclock indicators
    final modPaint = TextPaint(
      style: const TextStyle(
        fontSize: 9.5,
        color: Color(0xFF94A3B8),
      ),
    );
    modPaint.render(
      canvas,
      '❄️ Fan Lv.${shaft.coolingLevel}  🔥 Boost Lv.${shaft.overclockLevel}',
      Vector2(x, y + 33),
    );
  }

  void _renderLockedState(Canvas canvas, double w, double h) {
    // Dimmed Locked Floor with Lock Icon
    final lockPaint = TextPaint(
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
      ),
    );
    lockPaint.render(canvas, '🔒 ${shaft.name}', Vector2(w / 2 - 75, h / 2 - 16));

    final unlockPaint = TextPaint(
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF00F2FE),
        fontWeight: FontWeight.w600,
      ),
    );
    unlockPaint.render(
      canvas,
      'Tap or Visit Hardware to Unlock (${shaft.baseCost.toInt()} SAT)',
      Vector2(w / 2 - 110, h / 2 + 6),
    );
  }
}
