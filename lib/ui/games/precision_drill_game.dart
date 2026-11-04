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
    if (_isGameOver || !mounted) return;
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
      backgroundColor: AppTheme.background,
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
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppTheme.richRuby),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                // 1. Attempts & Score Status Header
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.cyberCardDecoration(
                    borderColor: AppTheme.richRuby,
                    glowColor: AppTheme.richRuby,
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
                              color: AppTheme.richRuby,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Strikes Remaining: $_attemptsRemaining / 5',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bitcoinGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Feedback Text Banner
                AnimatedOpacity(
                  opacity: _lastHitResult.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _lastHitColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _lastHitColor),
                    ),
                    child: Text(
                      _lastHitResult,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: _lastHitColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 3. Precision Laser Meter
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: AppTheme.cyberCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Target labels (Zero overflow)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('MISS', style: TextStyle(fontSize: 9.5, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                          Text('GOOD', style: TextStyle(fontSize: 9.5, color: AppTheme.cyanNeon, fontWeight: FontWeight.bold)),
                          Text(
                            '⚡ CRIT ZONE ⚡',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppTheme.richRuby),
                          ),
                          Text('GOOD', style: TextStyle(fontSize: 9.5, color: AppTheme.cyanNeon, fontWeight: FontWeight.bold)),
                          Text('MISS', style: TextStyle(fontSize: 9.5, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
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
                                  color: AppTheme.surfaceSecondary,
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
                                    color: AppTheme.cyanNeon.withValues(alpha: 0.18),
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
                                    color: AppTheme.greenHash.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),

                              // Critical Sweet Spot (Ruby)
                              Positioned(
                                left: barWidth * 0.44,
                                width: barWidth * 0.12,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.rubyGradient,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.richRuby.withValues(alpha: 0.5),
                                        blurRadius: 8,
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
                                    color: AppTheme.richRuby,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.richRuby.withValues(alpha: 0.6),
                                        blurRadius: 10,
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

                const SizedBox(height: 32),

                // 4. Strike Button
                GestureDetector(
                  onTap: _strike,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.rubyGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.richRuby.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, color: Colors.white, size: 26),
                          SizedBox(width: 8),
                          Text(
                            'STRIKE DRILL NOW!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 5. Game Over / Session Complete Modal
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(22),
                    decoration: AppTheme.cyberCardDecoration(
                      borderColor: AppTheme.richRuby,
                      glowColor: AppTheme.richRuby,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 44)),
                        const SizedBox(height: 8),
                        const Text(
                          'DRILL CYCLE COMPLETE!',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.surfaceBorderSubtle),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Satoshis:', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                  Text(
                                    '+$_totalScore SAT',
                                    style: const TextStyle(
                                      fontSize: 16,
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
                                  Text('Power Grid Recharged:', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
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
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _restartGame,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppTheme.surfaceBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('RETRY', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onGameOver,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.richRuby,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'CLAIM COINS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
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
