import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class WheelReward {
  final String label;
  final String icon;
  final Color color;
  final double satoshis;
  final double power;
  final bool isFrenzy;

  const WheelReward({
    required this.label,
    required this.icon,
    required this.color,
    this.satoshis = 0.0,
    this.power = 0.0,
    this.isFrenzy = false,
  });
}

class LuckyWheelGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const LuckyWheelGame({
    super.key,
    required this.gameState,
    required this.onGameOver,
  });

  @override
  State<LuckyWheelGame> createState() => _LuckyWheelGameState();
}

class _LuckyWheelGameState extends State<LuckyWheelGame> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  late Animation<double> _spinAnimation;

  static const List<WheelReward> _rewards = [
    WheelReward(
      label: '150 SAT',
      icon: '🪙',
      color: Color(0xFF192B45),
      satoshis: 150.0,
      power: 20.0,
    ),
    WheelReward(
      label: '+100% POWER',
      icon: '⚡',
      color: Color(0xFF00B4D8),
      satoshis: 50.0,
      power: 100.0,
    ),
    WheelReward(
      label: '500 SAT',
      icon: '💰',
      color: Color(0xFFD97706),
      satoshis: 500.0,
      power: 35.0,
    ),
    WheelReward(
      label: '3X FRENZY',
      icon: '🚀',
      color: Color(0xFFDC2626),
      satoshis: 100.0,
      power: 40.0,
      isFrenzy: true,
    ),
    WheelReward(
      label: '300 SAT',
      icon: '🪙',
      color: Color(0xFF1E293B),
      satoshis: 300.0,
      power: 25.0,
    ),
    WheelReward(
      label: '1,500 SAT JACKPOT!',
      icon: '👑',
      color: Color(0xFFF59E0B),
      satoshis: 1500.0,
      power: 60.0,
    ),
    WheelReward(
      label: '+60% POWER',
      icon: '⚡',
      color: Color(0xFF0284C7),
      satoshis: 50.0,
      power: 60.0,
    ),
    WheelReward(
      label: '750 SAT',
      icon: '💎',
      color: Color(0xFF9333EA),
      satoshis: 750.0,
      power: 40.0,
    ),
  ];

  double _currentAngle = 0.0;
  bool _isSpinning = false;
  WheelReward? _wonReward;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _wonReward = null;
    });

    AudioService.instance.playSpin();

    final rand = Random();
    // Choose winning index
    final targetIndex = rand.nextInt(_rewards.length);
    
    // Each slice is 2 * pi / 8 = pi / 4 = 45 degrees
    const sliceAngle = (2 * pi) / 8;
    
    // Needle is at top (-pi / 2)
    // Extra full spins (5 to 8 rotations) + target slice offset
    final extraSpins = 5 + rand.nextInt(3);
    final targetSliceCenter = (targetIndex * sliceAngle) + (sliceAngle / 2);
    final finalAngle = _currentAngle + (extraSpins * 2 * pi) + (2 * pi - targetSliceCenter) + (3 * pi / 2);

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: finalAngle,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
      setState(() {
        _currentAngle = _spinAnimation.value;
      });
    });

    _spinController.forward(from: 0.0).then((_) {
      final won = _rewards[targetIndex];
      setState(() {
        _isSpinning = false;
        _wonReward = won;
      });

      // Award player
      widget.gameState.awardMiniGameReward(
        satoshisEarned: won.satoshis,
        powerBonus: won.power,
      );

      if (won.isFrenzy) {
        widget.gameState.applyBoost(multiplier: 3.0, durationSeconds: 20.0);
        AudioService.instance.playFrenzyStart();
      } else if (won.satoshis >= 500) {
        AudioService.instance.playCrit();
      } else {
        AudioService.instance.playSuccess();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onGameOver,
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎡 ', style: TextStyle(fontSize: 18)),
            Text(
              'QUANTUM LUCKY WHEEL',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppTheme.bitcoinGold),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cyberCardDecoration(
                    borderColor: AppTheme.bitcoinGold,
                    glowColor: AppTheme.bitcoinGold,
                  ),
                  child: const Row(
                    children: [
                      Text('🎁 ', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DECENTRALIZED NODE SPINNER',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.bitcoinGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Spin the wheel to win instant Satoshis, Power Battery & Frenzy Overdrive!',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Wheel Container with Needle
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // The Spinning Wheel
                        Transform.rotate(
                          angle: _currentAngle,
                          child: CustomPaint(
                            size: const Size(310, 310),
                            painter: _WheelPainter(rewards: _rewards),
                          ),
                        ),

                        // Center Hub
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.surface,
                            border: Border.all(color: AppTheme.bitcoinGold, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.bitcoinGold.withValues(alpha: 0.6),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('₿', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.bitcoinGold)),
                          ),
                        ),

                        // Top Pointer / Needle
                        Positioned(
                          top: -14,
                          child: Container(
                            width: 24,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.red, blurRadius: 8),
                              ],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: CustomPaint(painter: _NeedlePainter()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Spin Button
                GestureDetector(
                  onTap: _isSpinning ? null : _spin,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isSpinning
                            ? [AppTheme.surfaceLight, AppTheme.surface]
                            : [const Color(0xFFFFB300), AppTheme.bitcoinGold],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isSpinning
                          ? null
                          : [
                              BoxShadow(
                                color: AppTheme.bitcoinGold.withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSpinning ? Icons.refresh : Icons.play_arrow,
                            color: _isSpinning ? AppTheme.textMuted : Colors.black,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSpinning ? 'SPINNING NODE...' : 'SPIN THE WHEEL NOW!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: _isSpinning ? AppTheme.textMuted : Colors.black,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Victory / Reward Dialog
          if (_wonReward != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cyberCardDecoration(
                      borderColor: AppTheme.bitcoinGold,
                      glowColor: AppTheme.bitcoinGold,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_wonReward!.icon, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        const Text(
                          'CONGRATULATIONS!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _wonReward!.label,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.bitcoinGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Satoshis Won:', style: TextStyle(color: AppTheme.textMuted)),
                                  Text(
                                    '+${_wonReward!.satoshis.toInt()} SAT',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.bitcoinGold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Power Grid Refill:', style: TextStyle(color: AppTheme.textMuted)),
                                  Text(
                                    '+${_wonReward!.power.toInt()}% ⚡',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.cyanNeon,
                                    ),
                                  ),
                                ],
                              ),
                              if (_wonReward!.isFrenzy) ...[
                                const SizedBox(height: 6),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Bonus Mode:', style: TextStyle(color: AppTheme.textMuted)),
                                    Text(
                                      '3X FRENZY 🚀',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.redOverheat,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: widget.onGameOver,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bitcoinGold,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'CLAIM REWARD',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<WheelReward> rewards;

  _WheelPainter({required this.rewards});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sliceAngle = (2 * pi) / 8;

    for (int i = 0; i < rewards.length; i++) {
      final reward = rewards[i];
      final startAngle = i * sliceAngle;

      // Slice background
      final paint = Paint()
        ..color = reward.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        paint,
      );

      // Slice border
      final borderPaint = Paint()
        ..color = const Color(0xFF2A364F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        borderPaint,
      );

      // Render Text & Icon on slice
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + (sliceAngle / 2));

      final textSpan = TextSpan(
        text: '${reward.icon}\n${reward.label}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(radius * 0.52 - (textPainter.width / 2), -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Outer wheel border
    final outerRing = Paint()
      ..color = AppTheme.bitcoinGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, outerRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
