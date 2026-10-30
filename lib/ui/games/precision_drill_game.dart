import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class PrecisionDrillGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const PrecisionDrillGame({
    super.key,
    required this.gameState,
    required this.onGameOver,
  });

  @override
  State<PrecisionDrillGame> createState() => _PrecisionDrillGameState();
}

class _PrecisionDrillGameState extends State<PrecisionDrillGame> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  double _needlePos = 0.5; // 0.0 to 1.0
  bool _movingRight = true;

  int _attemptsRemaining = 5;
  int _totalScore = 0;
  String _lastHitResult = '';
  Color _lastHitColor = Colors.white;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(_tickNeedle)..repeat();
  }

  void _tickNeedle() {
    if (_isGameOver) return;
    setState(() {
      final speed = 0.032 + (5 - _attemptsRemaining) * 0.006;
      if (_movingRight) {
        _needlePos += speed;
        if (_needlePos >= 0.96) {
          _movingRight = false;
        }
      } else {
        _needlePos -= speed;
        if (_needlePos <= 0.04) {
          _movingRight = true;
        }
      }
    });
  }

  void _strike() {
    if (_attemptsRemaining <= 0 || _isGameOver) return;

    final distFromCenter = (_needlePos - 0.5).abs();
    int pointsEarned = 0;
    String feedback = '';
    Color feedbackColor = Colors.white;

    if (distFromCenter <= 0.06) {
      // Perfect Bullseye Crit!
      pointsEarned = 200;
      feedback = '⚡ CRITICAL STRIKE! +200 SAT';
      feedbackColor = AppTheme.bitcoinGold;
      AudioService.instance.playCrit();
    } else if (distFromCenter <= 0.16) {
      // Great hit!
      pointsEarned = 80;
      feedback = 'GREAT HIT! +80 SAT';
      feedbackColor = AppTheme.greenHash;
      AudioService.instance.playCoinPickup();
    } else if (distFromCenter <= 0.28) {
      // Normal hit
      pointsEarned = 35;
      feedback = 'GOOD HIT +35 SAT';
      feedbackColor = AppTheme.cyanNeon;
      AudioService.instance.playTap();
    } else {
      // Missed sweet spot
      pointsEarned = 0;
      feedback = 'DRILL MISS! 0 SAT';
      feedbackColor = AppTheme.redOverheat;
      AudioService.instance.playError();
    }

    setState(() {
      _totalScore += pointsEarned;
      _lastHitResult = feedback;
      _lastHitColor = feedbackColor;
      _attemptsRemaining--;

      if (_attemptsRemaining <= 0) {
        _endGame();
      }
    });
  }

  void _endGame() {
    _isGameOver = true;
    _animController.stop();

    widget.gameState.awardMiniGameReward(
      satoshisEarned: _totalScore.toDouble(),
      powerBonus: 35.0,
    );
    AudioService.instance.playSuccess();
  }

  void _restartGame() {
    setState(() {
      _attemptsRemaining = 5;
      _totalScore = 0;
      _lastHitResult = '';
      _isGameOver = false;
      _needlePos = 0.5;
      _movingRight = true;
    });
    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
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
          onPressed: () {
            if (_totalScore > 0 && !_isGameOver) {
              widget.gameState.awardMiniGameReward(
                satoshisEarned: _totalScore.toDouble(),
                powerBonus: 20.0,
              );
            }
            widget.onGameOver();
          },
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎯 ', style: TextStyle(fontSize: 18)),
            Text(
              'PRECISION LASER DRILL',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppTheme.orangeFrenzy),
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
                // 1. Attempts & Score Status Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cyberCardDecoration(
                    borderColor: AppTheme.orangeFrenzy,
                    glowColor: AppTheme.orangeFrenzy,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REFLEX TIMING DRILL',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orangeFrenzy,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Strikes Remaining: $_attemptsRemaining / 5',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.bitcoinGold),
                        ),
                        child: Text(
                          '+$_totalScore SAT',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bitcoinGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. Feedback Text Banner
                AnimatedOpacity(
                  opacity: _lastHitResult.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _lastHitColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _lastHitColor),
                    ),
                    child: Text(
                      _lastHitResult,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _lastHitColor,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 3. Precision Laser Meter
                Container(
                  width: double.infinity,
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surfaceBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Target labels
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('MISS', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          Text('GOOD', style: TextStyle(fontSize: 10, color: AppTheme.cyanNeon)),
                          Text('CRITICAL SWEET SPOT',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.bitcoinGold)),
                          Text('GOOD', style: TextStyle(fontSize: 10, color: AppTheme.cyanNeon)),
                          Text('MISS', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Laser Bar with target zones
                      LayoutBuilder(
                        builder: (context, gaugeBox) {
                          final barWidth = gaugeBox.maxWidth;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Background Track
                              Container(
                                width: barWidth,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF0E131F),
                                  border: Border.all(color: AppTheme.surfaceBorder),
                                ),
                              ),

                              // Good Zone (Cyan)
                              Positioned(
                                left: barWidth * 0.22,
                                width: barWidth * 0.56,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.cyanNeon.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),

                              // Great Zone (Green)
                              Positioned(
                                left: barWidth * 0.34,
                                width: barWidth * 0.32,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.greenHash.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),

                              // Critical Sweet Spot (Gold)
                              Positioned(
                                left: barWidth * 0.44,
                                width: barWidth * 0.12,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFB300), AppTheme.bitcoinGold],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.bitcoinGold.withValues(alpha: 0.8),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '⚡',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),

                              // Oscillating Laser Needle
                              Positioned(
                                left: (_needlePos * barWidth) - 4,
                                top: -6,
                                bottom: -6,
                                child: Container(
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.orangeFrenzy.withValues(alpha: 0.9),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 4. Strike Button
                GestureDetector(
                  onTap: _strike,
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.orangeFrenzy, AppTheme.redOverheat],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.orangeFrenzy.withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'STRIKE DRILL NOW!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
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

          // 5. Game Over / Session Complete Modal
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cyberCardDecoration(
                      borderColor: AppTheme.orangeFrenzy,
                      glowColor: AppTheme.orangeFrenzy,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        const Text(
                          'DRILL CYCLE COMPLETE!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
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
                                  const Text('Total Satoshis:', style: TextStyle(color: AppTheme.textMuted)),
                                  Text(
                                    '+$_totalScore SAT',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.bitcoinGold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Power Grid Recharged:', style: TextStyle(color: AppTheme.textMuted)),
                                  Text(
                                    '+35% ⚡',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.greenHash,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _restartGame,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: AppTheme.surfaceBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('RETRY', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onGameOver,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.bitcoinGold,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text(
                                  'CLAIM COINS',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
