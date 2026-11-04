import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

// ==========================================
// GAME 11: MINING BRICK BREAKER (Breakout)
// ==========================================
class BrickItem {
  final Rect rect;
  final Color color;
  final int points;
  bool isDestroyed;

  BrickItem({required this.rect, required this.color, required this.points, this.isDestroyed = false});
}

class MiningBrickBreakerGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const MiningBrickBreakerGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<MiningBrickBreakerGame> createState() => _MiningBrickBreakerGameState();
}

class _MiningBrickBreakerGameState extends State<MiningBrickBreakerGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _paddleX = 0.5;
  final double _paddleW = 0.28;
  double _ballX = 0.5;
  double _ballY = 0.7;
  double _vx = 0.010;
  double _vy = -0.012;

  final List<BrickItem> _bricks = [];
  int _score = 0;
  int _lives = 3;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initBricks();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_tick)
      ..repeat();
  }

  void _initBricks() {
    _bricks.clear();
    const rows = 4;
    const cols = 6;
    const colors = [AppTheme.richRuby, AppTheme.orangeFrenzy, AppTheme.bitcoinGold, AppTheme.greenHash];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final left = 0.06 + c * 0.15;
        final top = 0.12 + r * 0.05;
        _bricks.add(BrickItem(
          rect: Rect.fromLTWH(left, top, 0.13, 0.038),
          color: colors[r],
          points: (rows - r) * 20,
        ));
      }
    }
  }

  void _tick() {
    if (_isGameOver || !mounted) return;

    setState(() {
      _ballX += _vx;
      _ballY += _vy;

      // Wall bounce
      if (_ballX <= 0.03 || _ballX >= 0.97) {
        _vx = -_vx;
        AudioService.instance.playTick();
      }
      if (_ballY <= 0.05) {
        _vy = -_vy;
      }

      // Paddle hit
      if (_ballY >= 0.88 && _ballY <= 0.92) {
        if ((_ballX - _paddleX).abs() <= _paddleW / 2) {
          _vy = -_vy.abs();
          _vx += (_ballX - _paddleX) * 0.02;
          AudioService.instance.playTap();
        }
      }

      // Brick collisions
      for (var b in _bricks) {
        if (!b.isDestroyed && b.rect.contains(Offset(_ballX, _ballY))) {
          b.isDestroyed = true;
          _score += b.points;
          _vy = -_vy;
          AudioService.instance.playCrit();
          break;
        }
      }

      // Check win
      if (_bricks.every((b) => b.isDestroyed)) {
        _endGame(true);
        return;
      }

      // Bottom fall
      if (_ballY > 1.0) {
        _lives--;
        if (_lives <= 0) {
          _endGame(false);
        } else {
          _ballX = 0.5;
          _ballY = 0.7;
          _vy = -0.012;
        }
      }
    });
  }

  void _endGame(bool won) {
    _isGameOver = true;
    _ticker.stop();
    final reward = (_score + (won ? 200 : 0)).toDouble();
    widget.gameState.awardMiniGameReward(satoshisEarned: max(20, reward), powerBonus: 30.0);
    if (won) AudioService.instance.playSuccess();
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
        title: Text('MINING BRICK BREAKER', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            setState(() {
              _paddleX = (_paddleX + (d.delta.dx / constraints.maxWidth)).clamp(0.15, 0.85);
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SCORE: $_score', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
                      Row(children: List.generate(3, (i) => Icon(i < _lives ? Icons.favorite : Icons.favorite_border, color: AppTheme.richRuby))),
                    ],
                  ),
                ),
                // Bricks
                ..._bricks.where((b) => !b.isDestroyed).map((b) {
                  return Positioned(
                    left: b.rect.left * constraints.maxWidth,
                    top: b.rect.top * constraints.maxHeight,
                    width: b.rect.width * constraints.maxWidth,
                    height: b.rect.height * constraints.maxHeight,
                    child: Container(
                      decoration: BoxDecoration(color: b.color, borderRadius: BorderRadius.circular(4)),
                    ),
                  );
                }),
                // Paddle
                Positioned(
                  left: (_paddleX - _paddleW / 2) * constraints.maxWidth,
                  top: 0.90 * constraints.maxHeight,
                  width: _paddleW * constraints.maxWidth,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(color: AppTheme.cyanNeon, borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                // Ball
                Positioned(
                  left: _ballX * constraints.maxWidth - 8,
                  top: _ballY * constraints.maxHeight - 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                ),
                if (_isGameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.bitcoinGold),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('GAME OVER! +$_score SAT', style: GoogleFonts.chakraPetch(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _initBricks();
                                _score = 0;
                                _lives = 3;
                                _isGameOver = false;
                                _ballX = 0.5;
                                _ballY = 0.7;
                              });
                              _ticker.repeat();
                            },
                            child: const Text('PLAY AGAIN'),
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
// GAME 12: FALLING MATRIX (Binary decoder)
// ==========================================
class FallingMatrixGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const FallingMatrixGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<FallingMatrixGame> createState() => _FallingMatrixGameState();
}

class _FallingMatrixGameState extends State<FallingMatrixGame> {
  final List<String> _codes = ['01', '10', '11', '00', '7F', 'AA', 'FF', 'C4'];
  late String _targetCode;
  late List<String> _options;
  int _score = 0;
  int _timeLeft = 25;
  Timer? _timer;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _end();
        }
      });
    });
  }

  void _nextRound() {
    final rand = Random();
    _targetCode = _codes[rand.nextInt(_codes.length)];
    _options = List<String>.from(_codes)..shuffle(rand);
    _options = _options.take(4).toList();
    if (!_options.contains(_targetCode)) _options[0] = _targetCode;
    _options.shuffle();
  }

  void _selectCode(String code) {
    if (_isGameOver) return;
    if (code == _targetCode) {
      AudioService.instance.playCrit();
      setState(() {
        _score += 40;
        _nextRound();
      });
    } else {
      AudioService.instance.playError();
      setState(() {
        _score = max(0, _score - 10);
      });
    }
  }

  void _end() {
    _isGameOver = true;
    _timer?.cancel();
    final earned = max(20, _score).toDouble();
    widget.gameState.awardMiniGameReward(satoshisEarned: earned, powerBonus: 25.0);
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
        title: Text('MATRIX HASH DECODER', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TIME: ${_timeLeft}s', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900)),
                Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 30),
            Text('MATCH THE TARGET HASH KEY:', style: GoogleFonts.chakraPetch(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.greenHash),
              child: Text(
                '0x$_targetCode',
                style: GoogleFonts.chakraPetch(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.greenHash, letterSpacing: 3),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: _options.map((opt) {
                  return GestureDetector(
                    onTap: () => _selectCode(opt),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cyanNeon, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '0x$opt',
                          style: GoogleFonts.chakraPetch(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GAME 13: CRYPTO JUMP (Tower climber)
// ==========================================
class PlatformNode {
  double x;
  double y;
  PlatformNode(this.x, this.y);
}

class CryptoJumpGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CryptoJumpGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CryptoJumpGame> createState() => _CryptoJumpGameState();
}

class _CryptoJumpGameState extends State<CryptoJumpGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _playerX = 0.5;
  double _playerY = 0.8;
  double _vy = -0.016;
  final List<PlatformNode> _platforms = [];
  int _score = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initPlatforms();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_loop)
      ..repeat();
  }

  void _initPlatforms() {
    _platforms.clear();
    for (int i = 0; i < 7; i++) {
      _platforms.add(PlatformNode(0.15 + Random().nextDouble() * 0.7, 0.9 - i * 0.15));
    }
  }

  void _loop() {
    if (_isGameOver || !mounted) return;

    setState(() {
      _vy += 0.0008; // gravity
      _playerY += _vy;

      // Screen scrolling when jumping high
      if (_playerY < 0.4) {
        final delta = 0.4 - _playerY;
        _playerY = 0.4;
        _score += (delta * 100).toInt();

        for (var p in _platforms) {
          p.y += delta;
        }

        // Recycle platforms that scroll down
        for (var p in _platforms) {
          if (p.y > 1.05) {
            p.y = 0.0;
            p.x = 0.15 + Random().nextDouble() * 0.7;
          }
        }
      }

      // Check collision with platform when falling
      if (_vy > 0) {
        for (var p in _platforms) {
          if ((_playerY - p.y).abs() <= 0.03 && (_playerX - p.x).abs() <= 0.14) {
            _vy = -0.018; // bounce!
            AudioService.instance.playTap();
            break;
          }
        }
      }

      // Fall off bottom
      if (_playerY > 1.05) {
        _isGameOver = true;
        _ticker.stop();
        AudioService.instance.playError();
        final earned = max(15, _score * 2).toDouble();
        widget.gameState.awardMiniGameReward(satoshisEarned: earned, powerBonus: 20.0);
      }
    });
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
        title: Text('CRYPTO JUMP CLIMBER', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            setState(() {
              _playerX = (_playerX + (d.delta.dx / constraints.maxWidth)).clamp(0.08, 0.92);
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: 14,
                  left: 20,
                  child: Text('HEIGHT SCORE: $_score', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900)),
                ),
                // Platforms
                ..._platforms.map((p) {
                  return Positioned(
                    left: (p.x - 0.12) * constraints.maxWidth,
                    top: p.y * constraints.maxHeight,
                    width: 0.24 * constraints.maxWidth,
                    height: 12,
                    child: Container(
                      decoration: BoxDecoration(color: AppTheme.greenHash, borderRadius: BorderRadius.circular(6)),
                    ),
                  );
                }),
                // Player Drone
                Positioned(
                  left: _playerX * constraints.maxWidth - 20,
                  top: _playerY * constraints.maxHeight - 20,
                  child: const Text('🚀', style: TextStyle(fontSize: 32)),
                ),
                if (_isGameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.redOverheat),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('FALLEN!', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          Text('SCORE: $_score', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold)),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _playerX = 0.5;
                                _playerY = 0.8;
                                _vy = -0.016;
                                _score = 0;
                                _isGameOver = false;
                                _initPlatforms();
                              });
                              _ticker.repeat();
                            },
                            child: const Text('RETRY'),
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
// GAME 14: LASER DEFENSE (Turret shooter)
// ==========================================
class Missile {
  double x;
  double y;
  double speed;
  bool isDestroyed;
  Missile({required this.x, required this.y, required this.speed, this.isDestroyed = false});
}

class LaserDefenseGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const LaserDefenseGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<LaserDefenseGame> createState() => _LaserDefenseGameState();
}

class _LaserDefenseGameState extends State<LaserDefenseGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final List<Missile> _missiles = [];
  int _score = 0;
  int _vaultHealth = 100;
  double _spawnTimer = 0.0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    if (_isGameOver || !mounted) return;
    _spawnTimer += 0.016;
    if (_spawnTimer >= 0.75) {
      _spawnTimer = 0.0;
      _missiles.add(Missile(
        x: 0.1 + Random().nextDouble() * 0.8,
        y: 0.0,
        speed: 0.006 + Random().nextDouble() * 0.006,
      ));
    }

    setState(() {
      for (int i = _missiles.length - 1; i >= 0; i--) {
        final m = _missiles[i];
        m.y += m.speed;

        if (m.y >= 0.88 && !m.isDestroyed) {
          _vaultHealth -= 20;
          AudioService.instance.playError();
          _missiles.removeAt(i);
          if (_vaultHealth <= 0) {
            _isGameOver = true;
            _ticker.stop();
            final reward = max(20, _score).toDouble();
            widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 25.0);
          }
        }
      }
    });
  }

  void _shootMissile(int index) {
    if (_isGameOver) return;
    setState(() {
      _missiles[index].isDestroyed = true;
      _score += 35;
      AudioService.instance.playCrit();
      _missiles.removeAt(index);
    });
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
        title: Text('CYBER VAULT LASER DEFENSE', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              top: 14,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('VAULT HP: $_vaultHealth%', style: GoogleFonts.chakraPetch(fontSize: 16, color: _vaultHealth > 40 ? AppTheme.greenHash : AppTheme.redOverheat, fontWeight: FontWeight.w900)),
                  Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 16, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            // Incoming Missiles (Tap to shoot)
            ..._missiles.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;

              return Positioned(
                left: m.x * constraints.maxWidth - 20,
                top: m.y * constraints.maxHeight - 20,
                child: GestureDetector(
                  onTap: () => _shootMissile(i),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.redOverheat.withValues(alpha: 0.25),
                      border: Border.all(color: AppTheme.redOverheat, width: 2),
                    ),
                    child: const Center(child: Text('👾', style: TextStyle(fontSize: 22))),
                  ),
                ),
              );
            }),
            // Bottom defense laser bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 48,
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFF141F36), border: Border(top: BorderSide(color: AppTheme.cyanNeon, width: 2))),
                child: const Center(child: Text('🛡️ DEFENSE GRID ONLINE - TAP INCOMING VIRUSES!', style: TextStyle(color: AppTheme.cyanNeon, fontSize: 11, fontWeight: FontWeight.w900))),
              ),
            ),
            if (_isGameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.redOverheat),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('VAULT BREACHED!', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold)),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _missiles.clear();
                            _score = 0;
                            _vaultHealth = 100;
                            _isGameOver = false;
                          });
                          _ticker.repeat();
                        },
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ==========================================
// GAME 15: PIPE CONNECTION PUZZLE
// ==========================================
class PipeTile {
  int rotation; // 0, 1, 2, 3 (* 90 deg)
  final int correctRotation;
  PipeTile(this.rotation, this.correctRotation);
}

class PipeConnectionGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const PipeConnectionGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<PipeConnectionGame> createState() => _PipeConnectionGameState();
}

class _PipeConnectionGameState extends State<PipeConnectionGame> {
  final List<PipeTile> _tiles = [
    PipeTile(1, 0), PipeTile(2, 1), PipeTile(0, 2),
    PipeTile(3, 1), PipeTile(0, 0), PipeTile(2, 3),
    PipeTile(1, 3), PipeTile(3, 2), PipeTile(0, 1),
  ];
  bool _isSolved = false;

  void _rotate(int index) {
    if (_isSolved) return;
    setState(() {
      _tiles[index].rotation = (_tiles[index].rotation + 1) % 4;
      AudioService.instance.playTick();

      if (_tiles.every((t) => t.rotation == t.correctRotation)) {
        _isSolved = true;
        AudioService.instance.playSuccess();
        widget.gameState.awardMiniGameReward(satoshisEarned: 220.0, powerBonus: 40.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('GPU COOLANT PIPE MATRIX', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _isSolved ? '⚡ CIRCUIT FLOW ESTABLISHED! +220 SAT' : 'ROTATE PIPES TO CONNECT POWER GRID',
              style: GoogleFonts.chakraPetch(
                fontSize: 14,
                color: _isSolved ? AppTheme.greenHash : AppTheme.cyanNeon,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemBuilder: (context, i) {
                  final tile = _tiles[i];
                  final isAligned = tile.rotation == tile.correctRotation;

                  return GestureDetector(
                    onTap: () => _rotate(i),
                    child: Transform.rotate(
                      angle: tile.rotation * (pi / 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isAligned ? AppTheme.greenHash : AppTheme.surfaceBorder, width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.cable, color: isAligned ? AppTheme.cyanNeon : Colors.white60, size: 36),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// GAME 16: COLOR SWITCH ORBIT
// ==========================================
class ColorSwitchOrbitGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const ColorSwitchOrbitGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<ColorSwitchOrbitGame> createState() => _ColorSwitchOrbitGameState();
}

class _ColorSwitchOrbitGameState extends State<ColorSwitchOrbitGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _ballY = 0.7;
  double _ballVy = 0.0;
  final List<Color> _colors = [AppTheme.richRuby, AppTheme.cyanNeon, AppTheme.bitcoinGold, AppTheme.purpleQuantum];
  int _currentColorIndex = 0;
  double _wheelRotation = 0.0;
  int _score = 0;
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
      _ballVy += 0.0010;
      _ballY += _ballVy;
      _wheelRotation += 0.02;

      // Obstacle pass near y ~ 0.45
      if (_ballY <= 0.45 && _ballY >= 0.40) {
        _score += 50;
        _currentColorIndex = (_currentColorIndex + 1) % _colors.length;
        AudioService.instance.playCoinPickup();
        _ballY = 0.8;
        _ballVy = 0.0;
        if (_score >= 300) {
          _isGameOver = true;
          _ticker.stop();
          AudioService.instance.playSuccess();
          widget.gameState.awardMiniGameReward(satoshisEarned: 300.0, powerBonus: 30.0);
        }
      }

      if (_ballY > 0.95) {
        _ballY = 0.95;
        _ballVy = 0.0;
      }
    });
  }

  void _tap() {
    if (_isGameOver) return;
    setState(() {
      _ballVy = -0.016;
      AudioService.instance.playTap();
    });
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
        title: Text('COLOR SWITCH ORBIT', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: GestureDetector(
        onTap: _tap,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 22, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
                ),
              ),
              // Rotating color wheel
              Positioned(
                top: 200,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: _wheelRotation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _colors[_currentColorIndex], width: 12),
                      ),
                      child: const Center(child: Text('🪙', style: TextStyle(fontSize: 28))),
                    ),
                  ),
                ),
              ),
              // Pulsing color ball
              Positioned(
                top: 450 * _ballY,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _colors[_currentColorIndex]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
