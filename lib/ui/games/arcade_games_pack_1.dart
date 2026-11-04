import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

// ==========================================
// GAME 5: FLAPPY MINER (Fly through firewalls)
// ==========================================
class FlappyMinerGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const FlappyMinerGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<FlappyMinerGame> createState() => _FlappyMinerGameState();
}

class _FlappyMinerGameState extends State<FlappyMinerGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _birdY = 0.5; // 0.0 top to 1.0 bottom
  double _velocity = 0.0;
  final double _gravity = 0.0016;
  final double _jumpForce = -0.024;

  final List<double> _pipeX = [1.2, 1.8, 2.4];
  final List<double> _pipeGapY = [0.4, 0.6, 0.35];
  final double _gapHeight = 0.28;

  int _score = 0;
  bool _isGameOver = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_gameLoop)
      ..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _gameLoop() {
    if (!_hasStarted || _isGameOver || !mounted) return;

    setState(() {
      _velocity += _gravity;
      _birdY += _velocity;

      // Floor / ceiling collision
      if (_birdY <= 0.02 || _birdY >= 0.94) {
        _endGame();
        return;
      }

      // Move pipes
      for (int i = 0; i < _pipeX.length; i++) {
        _pipeX[i] -= 0.009;

        // Check if passed bird (bird X is 0.25)
        if (_pipeX[i] < 0.25 && _pipeX[i] + 0.009 >= 0.25) {
          _score++;
          AudioService.instance.playTick();
        }

        // Pipe collision
        if (_pipeX[i] >= 0.16 && _pipeX[i] <= 0.34) {
          final topLimit = _pipeGapY[i] - (_gapHeight / 2);
          final bottomLimit = _pipeGapY[i] + (_gapHeight / 2);
          if (_birdY - 0.04 < topLimit || _birdY + 0.04 > bottomLimit) {
            _endGame();
            return;
          }
        }

        // Reset pipe offscreen
        if (_pipeX[i] < -0.2) {
          _pipeX[i] = 1.6;
          _pipeGapY[i] = 0.25 + Random().nextDouble() * 0.50;
        }
      }
    });
  }

  void _flap() {
    if (_isGameOver) return;
    if (!_hasStarted) {
      setState(() => _hasStarted = true);
    }
    setState(() {
      _velocity = _jumpForce;
    });
    AudioService.instance.playTap();
  }

  void _endGame() {
    _isGameOver = true;
    _ticker.stop();
    AudioService.instance.playError();
    final reward = _score * 25.0 + 10.0;
    widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 20.0);
  }

  void _restart() {
    setState(() {
      _birdY = 0.5;
      _velocity = 0.0;
      _score = 0;
      _isGameOver = false;
      _hasStarted = false;
      _pipeX[0] = 1.2;
      _pipeX[1] = 1.8;
      _pipeX[2] = 2.4;
    });
    _ticker.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('FLAPPY CRYPTO DRONE', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        return GestureDetector(
          onTap: _flap,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Background grid
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CyberGridPainter(),
                  ),
                ),

                // Pipes
                ..._pipeX.asMap().entries.expand((entry) {
                  final i = entry.key;
                  final px = entry.value;
                  final gapY = _pipeGapY[i];
                  final pipeLeft = px * screenW;
                  const pipeWidth = 54.0;
                  final gapCenterPx = gapY * screenH;
                  final gapH = _gapHeight * screenH;

                  return [
                    // Top Pipe
                    Positioned(
                      left: pipeLeft,
                      top: 0,
                      width: pipeWidth,
                      height: max(0, gapCenterPx - (gapH / 2)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2236),
                          border: Border.all(color: AppTheme.cyanNeon, width: 2),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        ),
                      ),
                    ),
                    // Bottom Pipe
                    Positioned(
                      left: pipeLeft,
                      top: gapCenterPx + (gapH / 2),
                      width: pipeWidth,
                      height: max(0, screenH - (gapCenterPx + (gapH / 2))),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2236),
                          border: Border.all(color: AppTheme.cyanNeon, width: 2),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ),
                    ),
                  ];
                }),

                // Bird Drone (X = 0.25)
                Positioned(
                  left: 0.25 * screenW - 22,
                  top: _birdY * screenH - 22,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bitcoinGold,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.bitcoinGold.withValues(alpha: 0.6),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🛸', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ),

              // Score HUD
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSecondary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cyanNeon),
                    ),
                    child: Text(
                      'SCORE: $_score',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.cyanNeon,
                      ),
                    ),
                  ),
                ),
              ),

              // Tap to Start / Game Over Overlay
              if (!_hasStarted && !_isGameOver)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.cyanNeon),
                    child: Text(
                      'TAP ANYWHERE TO FLY!',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.cyanNeon,
                      ),
                    ),
                  ),
                ),

              if (_isGameOver)
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.redOverheat),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💥 CRASH!', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          'FINAL SCORE: $_score',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'REWARD: +${(_score * 25 + 10)} SAT 🪙',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.bitcoinGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _restart,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanNeon),
                          child: Text('PLAY AGAIN', style: GoogleFonts.chakraPetch(color: Colors.black, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }),
  );
}
}

// ==========================================
// GAME 6: BLOCK SLICER (Ninja style swipe)
// ==========================================
class SlicerTarget {
  double x;
  double y;
  double vx;
  double vy;
  final bool isMalware;
  final String icon;
  final int points;
  bool isSliced;

  SlicerTarget({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.isMalware,
    required this.icon,
    required this.points,
    this.isSliced = false,
  });
}

class BlockSlicerGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const BlockSlicerGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<BlockSlicerGame> createState() => _BlockSlicerGameState();
}

class _BlockSlicerGameState extends State<BlockSlicerGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final List<SlicerTarget> _targets = [];
  final List<Offset> _slicePoints = [];
  int _score = 0;
  int _lives = 3;
  double _spawnTimer = 0.0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_gameLoop)
      ..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _gameLoop() {
    if (_isGameOver || !mounted) return;

    final dt = 0.016;
    _spawnTimer += dt;
    if (_spawnTimer >= 0.8) {
      _spawnTimer = 0.0;
      _spawnTarget();
    }

    setState(() {
      for (int i = _targets.length - 1; i >= 0; i--) {
        final t = _targets[i];
        t.x += t.vx * dt;
        t.y += t.vy * dt;
        t.vy += 0.8 * dt; // gravity

        if (t.y > 1.1) {
          if (!t.isSliced && !t.isMalware) {
            _lives--;
            if (_lives <= 0) _endGame();
          }
          _targets.removeAt(i);
        }
      }

      if (_slicePoints.length > 8) {
        _slicePoints.removeAt(0);
      }
    });
  }

  void _spawnTarget() {
    final rand = Random();
    final isMalware = rand.nextDouble() < 0.25;
    final x = 0.2 + rand.nextDouble() * 0.6;
    final vx = (rand.nextDouble() - 0.5) * 0.3;
    final vy = -(0.9 + rand.nextDouble() * 0.4);

    _targets.add(SlicerTarget(
      x: x,
      y: 1.05,
      vx: vx,
      vy: vy,
      isMalware: isMalware,
      icon: isMalware ? '💣' : (rand.nextBool() ? '₿' : '💎'),
      points: isMalware ? -100 : 50,
    ));
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isGameOver) return;
    final pos = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    setState(() {
      _slicePoints.add(details.localPosition);
      for (var t in _targets) {
        if (!t.isSliced) {
          final dist = (Offset(t.x, t.y) - pos).distance;
          if (dist < 0.08) {
            t.isSliced = true;
            if (t.isMalware) {
              AudioService.instance.playError();
              _lives--;
              if (_lives <= 0) _endGame();
            } else {
              AudioService.instance.playCrit();
              _score += t.points;
            }
          }
        }
      }
    });
  }

  void _endGame() {
    _isGameOver = true;
    _ticker.stop();
    final earned = max(10, _score).toDouble();
    widget.gameState.awardMiniGameReward(satoshisEarned: earned, powerBonus: 25.0);
  }

  void _restart() {
    setState(() {
      _targets.clear();
      _slicePoints.clear();
      _score = 0;
      _lives = 3;
      _isGameOver = false;
    });
    _ticker.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('BLOCK SLICER 3000', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: (_) => setState(() => _slicePoints.clear()),
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Top HUD
                Positioned(
                  top: 14,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SCORE: $_score', style: GoogleFonts.chakraPetch(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.bitcoinGold)),
                      Row(
                        children: List.generate(3, (index) => Icon(index < _lives ? Icons.favorite : Icons.favorite_border, color: AppTheme.richRuby)),
                      ),
                    ],
                  ),
                ),

                // Flying targets
                ..._targets.map((t) {
                  return Positioned(
                    left: t.x * constraints.maxWidth - 25,
                    top: t.y * constraints.maxHeight - 25,
                    child: Opacity(
                      opacity: t.isSliced ? 0.3 : 1.0,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.isMalware ? AppTheme.redOverheat.withValues(alpha: 0.2) : AppTheme.surfaceSecondary,
                          border: Border.all(color: t.isMalware ? AppTheme.redOverheat : AppTheme.cyanNeon, width: 2),
                        ),
                        child: Center(child: Text(t.icon, style: const TextStyle(fontSize: 26))),
                      ),
                    ),
                  );
                }),

                if (_isGameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.redOverheat),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('SLASH TERMINATED!', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _restart, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanNeon), child: const Text('RETRY', style: TextStyle(color: Colors.black))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ==========================================
// GAME 7: WHACK-A-BUG (Server bug hunter)
// ==========================================
class WhackABugGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const WhackABugGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<WhackABugGame> createState() => _WhackABugGameState();
}

class _WhackABugGameState extends State<WhackABugGame> {
  int _activeHole = -1;
  bool _isBug = true; // bug vs golden coin
  int _score = 0;
  int _secondsLeft = 25;
  Timer? _gameTimer;
  Timer? _moleTimer;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _score = 0;
    _secondsLeft = 25;
    _isGameOver = false;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _endGame();
        }
      });
    });

    _moleTimer = Timer.periodic(const Duration(milliseconds: 650), (t) {
      if (!mounted) return;
      setState(() {
        _activeHole = Random().nextInt(9);
        _isBug = Random().nextDouble() < 0.70;
      });
    });
  }

  void _tapHole(int index) {
    if (_isGameOver || index != _activeHole) return;

    if (_isBug) {
      AudioService.instance.playCrit();
      _score += 40;
    } else {
      AudioService.instance.playCoinPickup();
      _score += 100;
    }

    setState(() {
      _activeHole = -1;
    });
  }

  void _endGame() {
    _isGameOver = true;
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    final earned = max(20, _score).toDouble();
    widget.gameState.awardMiniGameReward(satoshisEarned: earned, powerBonus: 30.0);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('SERVER WHACK-A-BUG', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TIME: ${_secondsLeft}s', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900)),
                Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: 9,
              itemBuilder: (context, i) {
                final isActive = i == _activeHole;

                return GestureDetector(
                  onTap: () => _tapHole(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? (_isBug ? AppTheme.redOverheat : AppTheme.bitcoinGold) : AppTheme.surfaceBorder,
                        width: isActive ? 2.5 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: (_isBug ? AppTheme.redOverheat : AppTheme.bitcoinGold).withValues(alpha: 0.5),
                                blurRadius: 16,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? Text(
                              _isBug ? '👾' : '🪙',
                              style: const TextStyle(fontSize: 44),
                            )
                          : Text('🖥️', style: TextStyle(fontSize: 28, color: Colors.white.withValues(alpha: 0.4))),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isGameOver)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _gameTimer?.cancel();
                  _moleTimer?.cancel();
                  _start();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenHash),
                child: Text('PLAY AGAIN (+$_score SAT EARNED)', style: GoogleFonts.chakraPetch(color: Colors.black, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// GAME 8: CRYPTO SNAKE (Retro snake 15x15)
// ==========================================
class CryptoSnakeGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CryptoSnakeGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CryptoSnakeGame> createState() => _CryptoSnakeGameState();
}

class _CryptoSnakeGameState extends State<CryptoSnakeGame> {
  static const int _gridSize = 14;
  final List<Point<int>> _snake = [const Point(7, 7), const Point(7, 8)];
  Point<int> _food = const Point(3, 3);
  Point<int> _direction = const Point(0, -1);
  Timer? _timer;
  int _score = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _snake.clear();
    _snake.addAll([const Point(7, 7), const Point(7, 8)]);
    _direction = const Point(0, -1);
    _score = 0;
    _isGameOver = false;
    _spawnFood();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 220), (_) => _tick());
  }

  void _spawnFood() {
    final rand = Random();
    Point<int> p;
    do {
      p = Point(rand.nextInt(_gridSize), rand.nextInt(_gridSize));
    } while (_snake.contains(p));
    _food = p;
  }

  void _tick() {
    if (_isGameOver || !mounted) return;

    setState(() {
      final head = _snake.first;
      final newHead = Point(head.x + _direction.x, head.y + _direction.y);

      // Wall collision
      if (newHead.x < 0 || newHead.x >= _gridSize || newHead.y < 0 || newHead.y >= _gridSize) {
        _end();
        return;
      }

      // Self collision
      if (_snake.contains(newHead)) {
        _end();
        return;
      }

      _snake.insert(0, newHead);

      if (newHead == _food) {
        _score += 30;
        AudioService.instance.playCoinPickup();
        _spawnFood();
      } else {
        _snake.removeLast();
      }
    });
  }

  void _end() {
    _isGameOver = true;
    _timer?.cancel();
    AudioService.instance.playError();
    final reward = max(15, _score).toDouble();
    widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 25.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('CRYPTO SNAKE CLASSIC', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SATOSHIS EATEN: $_score', style: GoogleFonts.chakraPetch(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.greenHash)),
                if (_isGameOver)
                  ElevatedButton(onPressed: _start, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanNeon), child: const Text('RESTART', style: TextStyle(color: Colors.black))),
              ],
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.greenHash, width: 2),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _gridSize * _gridSize,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _gridSize),
                  itemBuilder: (context, i) {
                    final x = i % _gridSize;
                    final y = i ~/ _gridSize;
                    final p = Point(x, y);

                    final isHead = _snake.isNotEmpty && _snake.first == p;
                    final isBody = _snake.contains(p) && !isHead;
                    final isFood = _food == p;

                    Color? cellColor;
                    if (isHead) cellColor = AppTheme.bitcoinGold;
                    if (isBody) cellColor = AppTheme.greenHash;
                    if (isFood) cellColor = AppTheme.cyanNeon;

                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: cellColor ?? Colors.black26,
                        borderRadius: BorderRadius.circular(isFood ? 8 : 2),
                      ),
                      child: isFood ? const Center(child: Text('🪙', style: TextStyle(fontSize: 12))) : null,
                    );
                  },
                ),
              ),
            ),
          ),
          // D-PAD CONTROLLER
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 40, color: AppTheme.cyanNeon),
                  onPressed: () {
                    if (_direction.y != 1) _direction = const Point(0, -1);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left, size: 40, color: AppTheme.cyanNeon),
                      onPressed: () {
                        if (_direction.x != 1) _direction = const Point(-1, 0);
                      },
                    ),
                    const SizedBox(width: 48),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_right, size: 40, color: AppTheme.cyanNeon),
                      onPressed: () {
                        if (_direction.x != -1) _direction = const Point(1, 0);
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 40, color: AppTheme.cyanNeon),
                  onPressed: () {
                    if (_direction.y != -1) _direction = const Point(0, 1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// GAME 9: CYBER PONG (Retro paddle vs AI)
// ==========================================
class CyberPongGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CyberPongGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CyberPongGame> createState() => _CyberPongGameState();
}

class _CyberPongGameState extends State<CyberPongGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _ballX = 0.5;
  double _ballY = 0.5;
  double _vx = 0.008;
  double _vy = 0.012;

  double _playerX = 0.5;
  double _aiX = 0.5;
  final double _paddleW = 0.26;

  int _playerScore = 0;
  int _aiScore = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_loop)
      ..repeat();
  }

  void _loop() {
    if (_isGameOver || !mounted) return;

    setState(() {
      _ballX += _vx;
      _ballY += _vy;

      // Wall bounce
      if (_ballX <= 0.04 || _ballX >= 0.96) {
        _vx = -_vx;
        AudioService.instance.playTick();
      }

      // AI paddle tracking
      if (_aiX < _ballX - 0.02) _aiX += 0.006;
      if (_aiX > _ballX + 0.02) _aiX -= 0.006;

      // Bottom paddle (Player at y ~ 0.92)
      if (_ballY >= 0.88 && _ballY <= 0.93) {
        if ((_ballX - _playerX).abs() <= _paddleW / 2) {
          _vy = -_vy.abs();
          _vx += (_ballX - _playerX) * 0.02;
          AudioService.instance.playTap();
        }
      }

      // Top paddle (AI at y ~ 0.08)
      if (_ballY <= 0.12 && _ballY >= 0.07) {
        if ((_ballX - _aiX).abs() <= _paddleW / 2) {
          _vy = _vy.abs();
        }
      }

      // Out of bounds
      if (_ballY > 1.0) {
        _aiScore++;
        _resetBall();
        if (_aiScore >= 3) _finish(false);
      } else if (_ballY < 0.0) {
        _playerScore++;
        _resetBall();
        if (_playerScore >= 3) _finish(true);
      }
    });
  }

  void _resetBall() {
    _ballX = 0.5;
    _ballY = 0.5;
    _vy = -_vy;
  }

  void _finish(bool playerWon) {
    _isGameOver = true;
    _ticker.stop();
    if (playerWon) {
      AudioService.instance.playSuccess();
      widget.gameState.awardMiniGameReward(satoshisEarned: 250.0, powerBonus: 35.0);
    } else {
      AudioService.instance.playError();
      widget.gameState.awardMiniGameReward(satoshisEarned: 40.0, powerBonus: 10.0);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('CYBER PONG 2088', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            setState(() {
              _playerX = (_playerX + (d.delta.dx / constraints.maxWidth)).clamp(0.14, 0.86);
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Middle dotted net
                Center(
                  child: Container(height: 2, color: AppTheme.surfaceBorder),
                ),
                // Scores
                Positioned(
                  top: 20,
                  left: 20,
                  child: Text('AI: $_aiScore', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.redOverheat, fontWeight: FontWeight.w900)),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text('YOU: $_playerScore', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900)),
                ),
                // Top AI paddle
                Positioned(
                  left: (_aiX - _paddleW / 2) * constraints.maxWidth,
                  top: 0.08 * constraints.maxHeight,
                  width: _paddleW * constraints.maxWidth,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(color: AppTheme.redOverheat, borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                // Bottom Player paddle
                Positioned(
                  left: (_playerX - _paddleW / 2) * constraints.maxWidth,
                  top: 0.90 * constraints.maxHeight,
                  width: _paddleW * constraints.maxWidth,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(color: AppTheme.cyanNeon, borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                // Ball
                Positioned(
                  left: _ballX * constraints.maxWidth - 10,
                  top: _ballY * constraints.maxHeight - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.bitcoinGold),
                  ),
                ),
                if (_isGameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cyberCardDecoration(borderColor: _playerScore >= 3 ? AppTheme.greenHash : AppTheme.redOverheat),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_playerScore >= 3 ? 'VICTORY! +250 SAT' : 'DEFEATED!', style: GoogleFonts.chakraPetch(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _playerScore = 0;
                                _aiScore = 0;
                                _isGameOver = false;
                                _ballX = 0.5;
                                _ballY = 0.5;
                              });
                              _ticker.repeat();
                            },
                            child: const Text('REMATCH'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ==========================================
// GAME 10: MEMORY CARD MATCH (4x4 Grid)
// ==========================================
class MemoryCardGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const MemoryCardGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<MemoryCardGame> createState() => _MemoryCardGameState();
}

class _MemoryCardGameState extends State<MemoryCardGame> {
  final List<String> _symbols = ['₿', '⚡', '💎', '🚀', '🛡️', '👑', '⛏️', '🤖'];
  late List<String> _deck;
  late List<bool> _revealed;
  late List<bool> _matched;
  int? _firstSelectedIndex;
  int _moves = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initCards();
  }

  void _initCards() {
    _deck = [..._symbols, ..._symbols]..shuffle(Random());
    _revealed = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstSelectedIndex = null;
    _moves = 0;
    _isGameOver = false;
  }

  void _onCardTap(int index) {
    if (_revealed[index] || _matched[index] || _isGameOver) return;

    setState(() {
      _revealed[index] = true;
      AudioService.instance.playTap();

      if (_firstSelectedIndex == null) {
        _firstSelectedIndex = index;
      } else {
        _moves++;
        final first = _firstSelectedIndex!;
        if (_deck[first] == _deck[index]) {
          _matched[first] = true;
          _matched[index] = true;
          _firstSelectedIndex = null;
          AudioService.instance.playCoinPickup();

          if (_matched.every((m) => m)) {
            _isGameOver = true;
            final reward = max(50, 300 - _moves * 10).toDouble();
            widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 30.0);
          }
        } else {
          _firstSelectedIndex = null;
          Timer(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            setState(() {
              _revealed[first] = false;
              _revealed[index] = false;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('NODE MEMORY MATRIX', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MOVES: $_moves', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900)),
                if (_isGameOver)
                  ElevatedButton(
                    onPressed: () => setState(() => _initCards()),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenHash),
                    child: const Text('PLAY AGAIN', style: TextStyle(color: Colors.black)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 16,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, i) {
                final isShown = _revealed[i] || _matched[i];

                return GestureDetector(
                  onTap: () => _onCardTap(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isShown ? AppTheme.surfaceLight : AppTheme.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _matched[i] ? AppTheme.greenHash : AppTheme.surfaceBorder, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        isShown ? _deck[i] : '❓',
                        style: TextStyle(fontSize: isShown ? 30 : 22),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF142036).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
