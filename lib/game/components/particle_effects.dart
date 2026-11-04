import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ParticleEffects {
  static ParticleSystemComponent createTapBurst(Vector2 position, {bool isFrenzy = false}) {
    final rand = Random();
    final count = isFrenzy ? 24 : 12;

    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: count,
        lifespan: isFrenzy ? 0.65 : 0.45,
        generator: (i) {
          final speed = rand.nextDouble() * (isFrenzy ? 180.0 : 120.0) + 40.0;
          final angle = rand.nextDouble() * 2 * pi;
          final color = isFrenzy
              ? (rand.nextBool() ? const Color(0xFFFF5252) : const Color(0xFFFFD700))
              : (rand.nextBool() ? const Color(0xFFF7931A) : const Color(0xFF00F2FE));

          return AcceleratedParticle(
            acceleration: Vector2(0, 160.0), // slight gravity
            speed: Vector2(cos(angle) * speed, sin(angle) * speed),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = color.withValues(alpha: (1.0 - particle.progress).clamp(0.0, 1.0))
                  ..style = PaintingStyle.fill;
                canvas.drawCircle(
                  Offset.zero,
                  (isFrenzy ? 4.5 : 3.0) * (1.0 - particle.progress),
                  paint,
                );
              },
            ),
          );
        },
      ),
    );
  }

  static ParticleSystemComponent createMiningSpark(Vector2 position) {
    final rand = Random();
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 3,
        lifespan: 0.28,
        generator: (i) {
          final speed = rand.nextDouble() * 45.0 + 15.0;
          final angle = -pi / 2 + (rand.nextDouble() * 0.8 - 0.4);

          return AcceleratedParticle(
            acceleration: Vector2(0, 120.0),
            speed: Vector2(cos(angle) * speed, sin(angle) * speed),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = const Color(0xFFC78417).withValues(alpha: (1.0 - particle.progress).clamp(0.0, 1.0))
                  ..style = PaintingStyle.fill;
                canvas.drawCircle(
                  Offset.zero,
                  1.5 * (1.0 - particle.progress),
                  paint,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
