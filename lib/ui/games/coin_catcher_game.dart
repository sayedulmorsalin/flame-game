import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

enum FallItemType { bitcoin, gem, star, malware }

class FallingItem {
  double x; // 0.0 to 1.0 (relative width)
  double y; // 0.0 to 1.0 (relative height)
  double speed;
  final FallItemType type;
  bool isCaught = false;

  FallingItem({
    required this.x,
    required this.y,
    required this.speed,
    required this.type,
  });

  String get icon {
    switch (type) {
      case FallItemType.bitcoin:
        return '₿';
      case FallItemType.gem:
        return '💎';
      case FallItemType.star:
        return '⭐';
      case FallItemType.malware:
        return '👾';
    }
  }

  Color get color {
    switch (type) {
      case FallItemType.bitcoin:
        return AppTheme.bitcoinGold;
      case FallItemType.gem:
        return AppTheme.cyanNeon;
      case FallItemType.star:
        return AppTheme.goldLight;
      case FallItemType.malware:
        return AppTheme.redOverheat;
    }
  }

  int get basePoints {
    switch (type) {
      case FallItemType.bitcoin:
        return 15;
      case FallItemType.gem:
        return 30;
      case FallItemType.star:
        return 50;
      case FallItemType.malware:
        return -20;
    }
  }
}

class CatchEffect {
  final double x;
  final double y;
  final String text;
  final Color color;
  double opacity = 1.0;

  CatchEffect({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
  });
}

class CoinCatcherGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CoinCatcherGame({
    super.key,
    required this.gameState,
    required this.onGameOver,
  });

  @override
  State<CoinCatcherGame> createState() => _CoinCatcherGameState();
}

class _CoinCatcherGameState extends State<CoinCatcherGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _catcherX = 0.5; // normalized 0.0 to 1.0
  final double _catcherWidth = 0.22; // normalized basket width
  
  final List<FallingItem> _items = [];
  final List<CatchEffect> _effects = [];
  
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _itemsCaught = 0;
  int _secondsLeft = 30;
  Timer? _countdownTimer;
  double _spawnTimer = 0.0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();

    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_gameLoop)
      ..repeat();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _gameLoop() {
    if (_isGameOver) return;

    final dt = 0.016; // approximate delta time per frame

    // 1. Spawn items
    _spawnTimer += dt;
    if (_spawnTimer >= 0.45) {
      _spawnTimer = 0.0;
      _spawnItem();
    }

    // 2. Move items & check collisions
    setState(() {
      for (int i = _items.length - 1; i >= 0; i--) {
        final item = _items[i];
        item.y += item.speed * dt;

        // Collision detection near bottom (y ~ 0.85 to 0.92)
        if (!item.isCaught && item.y >= 0.82 && item.y <= 0.90) {
          final basketLeft = _catcherX - (_catcherWidth / 2);
          final basketRight = _catcherX + (_catcherWidth / 2);

          if (item.x >= basketLeft - 0.04 && item.x <= basketRight + 0.04) {
            item.isCaught = true;
            _handleCatch(item);
          }
        }

        // Remove item if fallen off bottom
        if (item.y > 1.05) {
          if (!item.isCaught && item.type != FallItemType.malware) {
            // Dropped a coin
            _combo = 0;
          }
          _items.removeAt(i);
        }
      }

      // Update catch effects
      for (int i = _effects.length - 1; i >= 0; i--) {
        final ef = _effects[i];
        ef.opacity -= dt * 1.5;
        if (ef.opacity <= 0) {
          _effects.removeAt(i);
        }
      }
    });
  }

  void _spawnItem() {
    final rand = Random();
    final x = 0.08 + rand.nextDouble() * 0.84;
    final roll = rand.nextDouble();

    FallItemType type;
    if (roll < 0.50) {
      type = FallItemType.bitcoin;
    } else if (roll < 0.75) {
      type = FallItemType.gem;
    } else if (roll < 0.88) {
      type = FallItemType.star;
    } else {
      type = FallItemType.malware;
    }

    final speed = 0.35 + rand.nextDouble() * 0.25;

    _items.add(FallingItem(
      x: x,
      y: 0.0,
      speed: speed,
      type: type,
    ));
  }

  void _handleCatch(FallingItem item) {
    if (item.type == FallItemType.malware) {
      AudioService.instance.playError();
      _combo = 0;
      _score = max(0, _score + item.basePoints);
      _effects.add(CatchEffect(
        x: item.x,
        y: 0.82,
        text: '${item.basePoints} SAT ⚠️',
        color: AppTheme.redOverheat,
      ));
    } else {
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;
      _itemsCaught++;

      final comboMultiplier = _combo >= 10 ? 3.0 : (_combo >= 5 ? 2.0 : (_combo >= 3 ? 1.5 : 1.0));
      final earned = (item.basePoints * comboMultiplier).round();
      _score += earned;

      if (_combo >= 5) {
        AudioService.instance.playCrit();
      } else {
        AudioService.instance.playCoinPickup();
      }

      _effects.add(CatchEffect(
        x: item.x,
        y: 0.82,
        text: '+$earned ${comboMultiplier > 1.0 ? '(${comboMultiplier}x)' : ''}',
        color: item.color,
      ));
    }
  }

  void _endGame() {
    if (_isGameOver) return;
    _isGameOver = true;
    _ticker.stop();
    _countdownTimer?.cancel();

    // Reward player: score satoshis + 40% battery recharge
    widget.gameState.awardMiniGameReward(
      satoshisEarned: _score.toDouble(),
      powerBonus: 40.0,
    );
    AudioService.instance.playSuccess();
  }

  void _restartGame() {
    setState(() {
      _items.clear();
      _effects.clear();
      _score = 0;
      _combo = 0;
      _itemsCaught = 0;
      _secondsLeft = 30;
      _isGameOver = false;
      _catcherX = 0.5;
    });
    _ticker.repeat();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _countdownTimer?.cancel();
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
            if (!_isGameOver && _score > 0) {
              widget.gameState.awardMiniGameReward(
                satoshisEarned: _score.toDouble(),
                powerBonus: 20.0,
              );
            }
            widget.onGameOver();
          },
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪙 ', style: TextStyle(fontSize: 18)),
            Text(
              'SATOSHI CATCHER',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppTheme.bitcoinGold),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              // 1. Cyber Grid Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _CyberGridPainter(),
                ),
              ),

              // 2. Interactive Falling Items
              ..._items.map((item) {
                return Positioned(
                  left: item.x * width - 18,
                  top: item.y * height,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        item.icon,
                        style: TextStyle(
                          fontSize: 24,
                          color: item.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 3. Catch Floating Text Effects
              ..._effects.map((ef) {
                return Positioned(
                  left: ef.x * width - 30,
                  top: ef.y * height - 20,
                  child: Opacity(
                    opacity: ef.opacity.clamp(0.0, 1.0),
                    child: Text(
                      ef.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: ef.color,
                        shadows: [
                          Shadow(color: ef.color, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // 4. Cyber Catcher Basket / Cart
              Positioned(
                left: (_catcherX * width) - (width * _catcherWidth / 2),
                top: height * 0.84,
                child: Container(
                  width: width * _catcherWidth,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.cyanNeon,
                        AppTheme.cyanNeon.withValues(alpha: 0.6),
                        const Color(0xFF0072FF),
                      ],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cyanNeon.withValues(alpha: 0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt, size: 16, color: Colors.white),
                        Text(
                          'CATCHER',
                          style: TextStyle(
                            fontSize: 10,
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

              // 5. Touch Drag Detection Area
              Positioned.fill(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _catcherX = (details.localPosition.dx / width).clamp(0.12, 0.88);
                    });
                  },
                  onTapDown: (details) {
                    setState(() {
                      _catcherX = (details.localPosition.dx / width).clamp(0.12, 0.88);
                    });
                  },
                ),
              ),

              // 6. Top HUD Overlay: Timer, Score, Combo
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _secondsLeft <= 5 ? AppTheme.redOverheat : AppTheme.surfaceBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: _secondsLeft <= 5 ? AppTheme.redOverheat : AppTheme.cyanNeon,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_secondsLeft}s',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _secondsLeft <= 5 ? AppTheme.redOverheat : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Combo Counter
                    if (_combo >= 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.orangeFrenzy, AppTheme.redOverheat],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.orangeFrenzy.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          '${_combo}X COMBO 🔥',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Current Score Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.bitcoinGold, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('🪙 ', style: TextStyle(fontSize: 13)),
                          Text(
                            '$_score SAT',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.bitcoinGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 7. Left / Right Touch Arrow Controls (Bottom)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _catcherX = (_catcherX - 0.15).clamp(0.12, 0.88);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceLight,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.surfaceBorder),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_ios, size: 14, color: AppTheme.cyanNeon),
                      label: const Text('LEFT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _catcherX = (_catcherX + 0.15).clamp(0.12, 0.88);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceLight,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.surfaceBorder),
                        ),
                      ),
                      icon: const Text('RIGHT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      label: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.cyanNeon),
                    ),
                  ],
                ),
              ),

              // 8. Game Over Summary Modal
              if (_isGameOver)
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
                            const Text('🎉', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            const Text(
                              'SESSION COMPLETE!',
                              style: TextStyle(
                                fontSize: 20,
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
                                      const Text('Satoshis Earned:', style: TextStyle(color: AppTheme.textMuted)),
                                      Text(
                                        '+$_score SAT',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.bitcoinGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Power Grid Recharged:', style: TextStyle(color: AppTheme.textMuted)),
                                      const Text(
                                        '+40% ⚡',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.greenHash,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Highest Combo:', style: TextStyle(color: AppTheme.textMuted)),
                                      Text(
                                        '${_maxCombo}X',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.orangeFrenzy,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Coins Caught:', style: TextStyle(color: AppTheme.textMuted)),
                                      Text(
                                        '$_itemsCaught',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                                    child: const Text('PLAY AGAIN', style: TextStyle(color: Colors.white)),
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
          );
        },
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF131D2F).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
