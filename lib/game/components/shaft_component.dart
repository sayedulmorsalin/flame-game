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
    if (shaft.isUnlocked && shaft.level > 0 && isPowered) {
      animTimer += dt;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!shaft.isUnlocked) {
      // Locked floors are strictly NOT clickable
      return;
    }
    onShaftTapped(shaft, event.canvasPosition);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;

    // 1. Cavern Chamber Card (Polished light silver & white card)
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 4, w - 16, h - 8),
      const Radius.circular(12),
    );

    final chamberPaint = Paint()
      ..color = shaft.isUnlocked
          ? const Color(0xFFFFFFFF)
          : const Color(0xFFEDE6EB);
    canvas.drawRRect(cardRect, chamberPaint);

    // Chamber Border (Crisp silver, glows Rich Ruby when frenzy)
    final borderPaint = Paint()
      ..color = shaft.isUnlocked
          ? (isFrenzyActive ? const Color(0xFFB81D36) : const Color(0xFFDCD2D8))
          : const Color(0xFFD5CBD2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFrenzyActive ? 2.0 : 1.2;
    canvas.drawRRect(cardRect, borderPaint);

    // Structural Girder Pillars on sides
    final girderPaint = Paint()
      ..color = const Color(0xFFDDD3DB)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(18, 4), Offset(18, h - 4), girderPaint);
    canvas.drawLine(Offset(w - 18, 4), Offset(w - 18, h - 4), girderPaint);

    if (!shaft.isUnlocked) {
      _renderLockedState(canvas, w, h);
      return;
    }

    // 2. Hardware Server Rig Unit (Left section: w ~ 64px)
    _renderServerRack(canvas, 24, 14, 64, h - 28);

    // 3. Center Section: Floor Metrics & Name (Zero overlap with graphics)
    _renderHeader(canvas, 96, 14);

    // 4. Mining Extraction Node (Right section: contained within w - 80)
    _renderMiningStation(canvas, w - 80, 14, 64, h - 28);

    // 5. Bottom Guide Rail (Runs along floor baseboard, never cutting through text)
    _renderDataRails(canvas, h - 14, w);
  }

  void _renderServerRack(Canvas canvas, double x, double y, double rw, double rh) {
    // Rack casing
    final rackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, rw, rh),
      const Radius.circular(6),
    );
    canvas.drawRRect(rackRect, Paint()..color = const Color(0xFFF7F2F5));
    canvas.drawRRect(
      rackRect,
      Paint()
        ..color = const Color(0xFFD6CBD3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 2 Clean Server Blade Bays
    final bayH = (rh - 10) / 2;
    for (int i = 0; i < 2; i++) {
      final by = y + 3.5 + i * (bayH + 3);
      final bayRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 4, by, rw - 8, bayH),
        const Radius.circular(4),
      );
      canvas.drawRRect(bayRect, Paint()..color = const Color(0xFFEBE3E8));

      // Calm status LEDs
      final isTop = i == 0;
      final led1Color = isTop ? const Color(0xFF0284C7) : const Color(0xFFC78417);
      final led2Color = isFrenzyActive
          ? const Color(0xFFB81D36)
          : (isTop ? const Color(0xFF098A55) : const Color(0xFF0284C7));

      // LED 1: Steady
      canvas.drawCircle(
        Offset(x + 10, by + bayH / 2),
        2.2,
        Paint()..color = isPowered ? led1Color : const Color(0xFFB8ADB6),
      );

      // LED 2: Smooth calm breathing pulse (no chaotic flickering)
      final breathAlpha = isPowered ? (0.4 + 0.6 * ((sin(animTimer * 2.5 + i) + 1) / 2)) : 0.2;
      canvas.drawCircle(
        Offset(x + 17, by + bayH / 2),
        2.2,
        Paint()..color = led2Color.withValues(alpha: breathAlpha),
      );

      // Slat Vent Grills
      final ventX = x + rw - 22;
      final ventY = by + 6;
      final ventW = 14.0;
      final ventH = bayH - 12;

      final slatPaint = Paint()
        ..color = const Color(0xFFC2B6C0)
        ..strokeWidth = 1.5;
      for (int s = 0; s < 3; s++) {
        final sy = ventY + (s + 0.5) * (ventH / 3);
        canvas.drawLine(Offset(ventX, sy), Offset(ventX + ventW, sy), slatPaint);
      }
    }
  }

  void _renderHeader(Canvas canvas, double x, double y) {
    // Floor Title
    final cleanName = shaft.name.replaceFirst(RegExp(r'^Floor \d+:\s*'), '');
    final titlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E161C),
        letterSpacing: 0.3,
      ),
    );
    titlePaint.render(
      canvas,
      'F${shaft.id + 1}: $cleanName',
      Vector2(x, y),
    );

    // Level & Hashrate Capsule Badge
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y + 18, 128, 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(pillRect, Paint()..color = const Color(0xFFF5EFF3));
    canvas.drawRRect(
      pillRect,
      Paint()
        ..color = const Color(0xFFDDD4DC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final hrText = shaft.currentHashrate >= 1000
        ? '${(shaft.currentHashrate / 1000).toStringAsFixed(1)} GH/s'
        : '${shaft.currentHashrate.toStringAsFixed(1)} MH/s';

    final levelTextPaint = TextPaint(
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFFB81D36),
      ),
    );
    levelTextPaint.render(canvas, 'LVL ${shaft.level}', Vector2(x + 6, y + 21));

    final dotPaint = TextPaint(
      style: const TextStyle(fontSize: 10, color: Color(0xFFA89CA6)),
    );
    dotPaint.render(canvas, '•', Vector2(x + 46, y + 21));

    final hrTextPaint = TextPaint(
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFF098A55),
      ),
    );
    hrTextPaint.render(canvas, '⚡ $hrText', Vector2(x + 56, y + 21));

    // Status or Upgrade Mods
    if (!isPowered) {
      final standbyPaint = TextPaint(
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFFDE5500),
        ),
      );
      standbyPaint.render(canvas, '⚠️ STANDBY (0% POWER)', Vector2(x, y + 42));
    } else {
      final modPaint = TextPaint(
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B5F69),
        ),
      );
      modPaint.render(
        canvas,
        '❄️ Fan L.${shaft.coolingLevel}  •  🔥 Boost L.${shaft.overclockLevel}',
        Vector2(x, y + 42),
      );
    }
  }

  void _renderMiningStation(Canvas canvas, double x, double y, double mw, double mh) {
    final centerY = y + mh / 2 - 2;
    final crystalCenter = Offset(x + mw - 22, centerY);
    final oreRadius = 13.0;

    // Soft aura glow
    final glowColor = isFrenzyActive
        ? const Color(0xFFB81D36)
        : (isPowered ? const Color(0xFFC78417) : const Color(0xFF9E929C));
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: isPowered ? 0.22 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(crystalCenter, oreRadius + 3, glowPaint);

    // Faceted Hexagon Crystal
    final orePath = Path();
    for (int p = 0; p < 6; p++) {
      final a = p * (2 * pi / 6);
      final r = oreRadius + (p % 2 == 0 ? 1.5 : -1.0);
      final pt = Offset(crystalCenter.dx + cos(a) * r, crystalCenter.dy + sin(a) * r);
      if (p == 0) {
        orePath.moveTo(pt.dx, pt.dy);
      } else {
        orePath.lineTo(pt.dx, pt.dy);
      }
    }
    orePath.close();

    final orePaint = Paint()
      ..color = isFrenzyActive
          ? const Color(0xFFE29A26)
          : (isPowered ? const Color(0xFFC78417) : const Color(0xFFB0A4AE))
      ..style = PaintingStyle.fill;
    canvas.drawPath(orePath, orePaint);

    // ₿ insignia in crystal center
    final btcPaint = TextPaint(
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
    btcPaint.render(canvas, '₿', Vector2(crystalCenter.dx - 4, crystalCenter.dy - 7));

    // High-Tech Focused Laser Diode
    final emitterX = x + 8;
    final emitterRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(emitterX, centerY), width: 10, height: 16),
      const Radius.circular(3),
    );
    canvas.drawRRect(emitterRect, Paint()..color = const Color(0xFF42373F));
    canvas.drawRRect(
      emitterRect,
      Paint()
        ..color = const Color(0xFF756772)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Focused Laser Extraction Beam (active only when powered)
    if (isPowered) {
      final beamColor = isFrenzyActive ? const Color(0xFFB81D36) : const Color(0xFF0284C7);
      final beamAlpha = 0.35 + 0.35 * ((sin(animTimer * 3.5) + 1) / 2);

      final beamPaint = Paint()
        ..color = beamColor.withValues(alpha: beamAlpha)
        ..strokeWidth = 2.0;
      canvas.drawLine(
        Offset(emitterX + 5, centerY),
        Offset(crystalCenter.dx - oreRadius, centerY),
        beamPaint,
      );

      // Subtle emitter flare
      canvas.drawCircle(
        Offset(emitterX + 5, centerY),
        2.5,
        Paint()..color = beamColor.withValues(alpha: beamAlpha + 0.2),
      );
    }
  }

  void _renderDataRails(Canvas canvas, double y, double w) {
    final startX = 26.0;
    final endX = w - 26.0;
    final railLen = endX - startX;

    // Slim bottom track line
    final trackPaint = Paint()
      ..color = const Color(0xFFE5DDE3)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(startX, y), Offset(endX, y), trackPaint);

    if (isPowered && railLen > 0) {
      // Gentle calm data packet along bottom baseboard (35 px/s)
      final pulsePos = (animTimer * 35.0) % railLen;
      final pulsePaint = Paint()
        ..color = (isFrenzyActive ? const Color(0xFFB81D36) : const Color(0xFF0284C7)).withValues(alpha: 0.7);
      canvas.drawCircle(Offset(startX + pulsePos, y), 2.0, pulsePaint);
    }
  }

  void _renderLockedState(Canvas canvas, double w, double h) {
    // Center lock container
    final lockBadgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h / 2 - 12), width: 34, height: 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      lockBadgeRect,
      Paint()..color = const Color(0xFFE2D9E0),
    );
    canvas.drawRRect(
      lockBadgeRect,
      Paint()
        ..color = const Color(0xFFCDC2CB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Lock emoji icon in badge
    final iconPaint = TextPaint(
      style: const TextStyle(fontSize: 15),
    );
    iconPaint.render(canvas, '🔒', Vector2(w / 2 - 8, h / 2 - 21));

    // Floor Name Locked Text
    final cleanName = shaft.name.replaceFirst(RegExp(r'^Floor \d+:\s*'), '').toUpperCase();
    final lockTitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF7A6F78),
        letterSpacing: 0.5,
      ),
    );
    lockTitlePaint.render(
      canvas,
      'FLOOR ${shaft.id + 1}: $cleanName (LOCKED)',
      Vector2(w / 2 - 95, h / 2 + 10),
    );

    // Unlock instruction (non-clickable, indicates to visit Rigs tab)
    final unlockSubPaint = TextPaint(
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF9E3B4B),
      ),
    );
    unlockSubPaint.render(
      canvas,
      'Unlock in Rigs tab  •  🪙 ${shaft.baseCost.toInt()} SAT',
      Vector2(w / 2 - 82, h / 2 + 25),
    );
  }
}
