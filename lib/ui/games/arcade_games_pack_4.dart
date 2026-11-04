import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

// ==========================================
// GAME 23: HIGHER OR LOWER CRYPTO
// ==========================================
class HigherLowerCryptoGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const HigherLowerCryptoGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<HigherLowerCryptoGame> createState() => _HigherLowerCryptoGameState();
}

class _HigherLowerCryptoGameState extends State<HigherLowerCryptoGame> {
  int _currentPrice = 64000;
  int _nextPrice = 0;
  int _streak = 0;
  String _message = 'WILL THE NEXT PRICE BE HIGHER OR LOWER?';
  bool _isGameOver = false;

  void _guess(bool isHigher) {
    if (_isGameOver) return;
    final delta = (Random().nextInt(4000) - 2000);
    _nextPrice = max(10000, _currentPrice + (delta == 0 ? 500 : delta));

    final won = isHigher ? (_nextPrice >= _currentPrice) : (_nextPrice <= _currentPrice);

    setState(() {
      if (won) {
        _streak++;
        _message = 'CORRECT! PRICE: \$$_nextPrice';
        AudioService.instance.playCoinPickup();
        _currentPrice = _nextPrice;
      } else {
        _isGameOver = true;
        _message = 'WRONG! PRICE WAS \$$_nextPrice';
        AudioService.instance.playError();
        final reward = (_streak * 50.0 + 10.0);
        widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 20.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('HIGHER OR LOWER BTC', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('WIN STREAK: $_streak 🔥', style: GoogleFonts.chakraPetch(fontSize: 22, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.cyanNeon),
                child: Column(
                  children: [
                    const Text('CURRENT BTC PRICE:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('\$$_currentPrice', style: GoogleFonts.chakraPetch(fontSize: 38, fontWeight: FontWeight.w900, color: AppTheme.cyanNeon)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(_message, textAlign: TextAlign.center, style: GoogleFonts.chakraPetch(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w700)),
              const SizedBox(height: 40),
              if (!_isGameOver)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _guess(true),
                      icon: const Icon(Icons.trending_up, color: Colors.black),
                      label: const Text('HIGHER ▲', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenHash, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () => _guess(false),
                      icon: const Icon(Icons.trending_down, color: Colors.white),
                      label: const Text('LOWER ▼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redOverheat, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPrice = 64000;
                      _streak = 0;
                      _isGameOver = false;
                      _message = 'GUESS HIGHER OR LOWER!';
                    });
                  },
                  child: const Text('PLAY AGAIN'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// GAME 24: MERGE 2048 SAT
// ==========================================
class Merge2048SatGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const Merge2048SatGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<Merge2048SatGame> createState() => _Merge2048SatGameState();
}

class _Merge2048SatGameState extends State<Merge2048SatGame> {
  final List<int> _grid = List.filled(16, 0);
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _spawnTile();
    _spawnTile();
  }

  void _spawnTile() {
    final empty = <int>[];
    for (int i = 0; i < 16; i++) {
      if (_grid[i] == 0) empty.add(i);
    }
    if (empty.isNotEmpty) {
      _grid[empty[Random().nextInt(empty.length)]] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  void _swipe(int dx, int dy) {
    bool moved = false;
    // simplified 2048 row/col shift logic
    setState(() {
      for (int i = 0; i < 16; i++) {
        if (_grid[i] != 0) {
          final target = (i + dx + dy * 4).clamp(0, 15);
          if (target != i) {
            if (_grid[target] == 0) {
              _grid[target] = _grid[i];
              _grid[i] = 0;
              moved = true;
            } else if (_grid[target] == _grid[i]) {
              _grid[target] *= 2;
              _score += _grid[target];
              _grid[i] = 0;
              moved = true;
              AudioService.instance.playCoinPickup();
            }
          }
        }
      }
      if (moved) {
        _spawnTile();
        widget.gameState.awardMiniGameReward(satoshisEarned: 15.0, powerBonus: 5.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('2048 SAT MERGE', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (d) => _swipe(d.primaryVelocity! > 0 ? 1 : -1, 0),
        onVerticalDragEnd: (d) => _swipe(0, d.primaryVelocity! > 0 ? 1 : -1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MERGED VALUE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 20, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: _grid.map((val) {
                    return Container(
                      decoration: BoxDecoration(
                        color: val == 0 ? AppTheme.surfaceSecondary : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: val > 0 ? AppTheme.bitcoinGold : AppTheme.surfaceBorder),
                      ),
                      child: Center(
                        child: Text(val == 0 ? '' : '$val', style: GoogleFonts.chakraPetch(fontSize: 18, fontWeight: FontWeight.w900, color: val >= 64 ? AppTheme.bitcoinGold : Colors.white)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('SWIPE TO SLIDE & MERGE TILES', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GAME 25: CYBER ROPE SWING
// ==========================================
class CyberRopeSwingGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CyberRopeSwingGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CyberRopeSwingGame> createState() => _CyberRopeSwingGameState();
}

class _CyberRopeSwingGameState extends State<CyberRopeSwingGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _heroX = 0.2;
  double _heroY = 0.5;
  final double _vx = 0.006;
  double _angle = 0.0;
  bool _isAttached = false;
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
      if (_isAttached) {
        _angle += 0.04;
        _heroX = 0.5 + sin(_angle) * 0.3;
        _heroY = 0.2 + cos(_angle) * 0.4;
      } else {
        _heroX += _vx;
        _heroY += 0.012; // gravity
      }

      if (_heroY > 1.0) {
        _isGameOver = true;
        _ticker.stop();
        AudioService.instance.playError();
        widget.gameState.awardMiniGameReward(satoshisEarned: max(20, _score).toDouble(), powerBonus: 20.0);
      }
    });
  }

  void _tap() {
    if (_isGameOver) return;
    setState(() {
      _isAttached = !_isAttached;
      if (_isAttached) {
        _score += 40;
        AudioService.instance.playTap();
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
        title: Text('CYBER ROPE GRAPPLE', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: GestureDetector(
        onTap: _tap,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(top: 14, left: 20, child: Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900))),
              if (_isAttached)
                CustomPaint(
                  size: Size.infinite,
                  painter: _RopePainter(anchor: const Offset(0.5, 0.1), hero: Offset(_heroX, _heroY)),
                ),
              LayoutBuilder(builder: (context, constraints) {
                return Positioned(
                  left: _heroX * constraints.maxWidth - 16,
                  top: _heroY * constraints.maxHeight - 16,
                  child: const Text('🥷', style: TextStyle(fontSize: 32)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _RopePainter extends CustomPainter {
  final Offset anchor;
  final Offset hero;
  _RopePainter({required this.anchor, required this.hero});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppTheme.cyanNeon
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(anchor.dx * size.width, anchor.dy * size.height), Offset(hero.dx * size.width, hero.dy * size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// GAME 26: ROCK PAPER SCISSORS BOT
// ==========================================
class RockPaperScissorsBotGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const RockPaperScissorsBotGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<RockPaperScissorsBotGame> createState() => _RockPaperScissorsBotGameState();
}

class _RockPaperScissorsBotGameState extends State<RockPaperScissorsBotGame> {
  final List<String> _choices = ['🪨 ROCK', '📄 PAPER', '✂️ SCISSORS'];
  String _playerChoice = '';
  String _botChoice = '';
  String _result = 'CHOOSE YOUR WEAPON';
  int _score = 0;

  void _play(int pIndex) {
    final bIndex = Random().nextInt(3);
    final p = _choices[pIndex];
    final b = _choices[bIndex];

    String res;
    if (pIndex == bIndex) {
      res = 'TIE GAME!';
    } else if ((pIndex == 0 && bIndex == 2) || (pIndex == 1 && bIndex == 0) || (pIndex == 2 && bIndex == 1)) {
      res = 'YOU WON! +60 SAT';
      _score += 60;
      AudioService.instance.playSuccess();
      widget.gameState.awardMiniGameReward(satoshisEarned: 60.0, powerBonus: 15.0);
    } else {
      res = 'BOT WON!';
      AudioService.instance.playError();
    }

    setState(() {
      _playerChoice = p;
      _botChoice = b;
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('CYBER RPS SHOWDOWN', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TOTAL SAT EARNED: $_score', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
            const SizedBox(height: 30),
            Text('BOT CHOSE: $_botChoice', style: GoogleFonts.chakraPetch(fontSize: 20, color: AppTheme.redOverheat, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text('YOU CHOSE: $_playerChoice', style: GoogleFonts.chakraPetch(fontSize: 20, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Text(_result, style: GoogleFonts.chakraPetch(fontSize: 22, color: AppTheme.greenHash, fontWeight: FontWeight.w900)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                return ElevatedButton(
                  onPressed: () => _play(i),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceSecondary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  child: Text(_choices[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GAME 27: TARGET ARCHERY
// ==========================================
class TargetArcheryGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const TargetArcheryGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<TargetArcheryGame> createState() => _TargetArcheryGameState();
}

class _TargetArcheryGameState extends State<TargetArcheryGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _targetX = 0.5;
  double _arrowY = 0.85;
  bool _isShooting = false;
  int _score = 0;
  int _arrowsLeft = 5;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_loop)
      ..repeat();
  }

  void _loop() {
    if (!mounted) return;
    setState(() {
      _targetX = 0.5 + sin(DateTime.now().millisecondsSinceEpoch / 400) * 0.35;

      if (_isShooting) {
        _arrowY -= 0.04;
        if (_arrowY <= 0.22) {
          _isShooting = false;
          _arrowY = 0.85;
          final dist = (_targetX - 0.5).abs();
          if (dist < 0.1) {
            _score += 100;
            AudioService.instance.playCrit();
          } else {
            AudioService.instance.playError();
          }
          _arrowsLeft--;
          if (_arrowsLeft <= 0) {
            _ticker.stop();
            widget.gameState.awardMiniGameReward(satoshisEarned: max(20, _score).toDouble(), powerBonus: 30.0);
          }
        }
      }
    });
  }

  void _shoot() {
    if (_isShooting || _arrowsLeft <= 0) return;
    setState(() {
      _isShooting = true;
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
        title: Text('TARGET BULLSEYE ARCHERY', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onTap: _shoot,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(top: 14, left: 20, child: Text('ARROWS: $_arrowsLeft • SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900))),
                // Target
                Positioned(
                  left: _targetX * constraints.maxWidth - 25,
                  top: 0.18 * constraints.maxHeight,
                  child: const Text('🎯', style: TextStyle(fontSize: 48)),
                ),
                // Arrow
                Positioned(
                  left: constraints.maxWidth * 0.5 - 12,
                  top: _arrowY * constraints.maxHeight,
                  child: const Text('🏹', style: TextStyle(fontSize: 32)),
                ),
                if (_arrowsLeft <= 0)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.bitcoinGold),
                      child: Text('FINAL SCORE: $_score SAT!', style: GoogleFonts.chakraPetch(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
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
// GAME 28: CRYPTO RUNNER 2D (Side-scroller)
// ==========================================
class CryptoRunner2DGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CryptoRunner2DGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CryptoRunner2DGame> createState() => _CryptoRunner2DGameState();
}

class _CryptoRunner2DGameState extends State<CryptoRunner2DGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _playerY = 0.75;
  double _vy = 0.0;
  double _obstacleX = 1.2;
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
      _vy += 0.0016; // gravity
      _playerY += _vy;
      if (_playerY >= 0.75) {
        _playerY = 0.75;
        _vy = 0.0;
      }

      _obstacleX -= 0.015;
      if (_obstacleX < -0.1) {
        _obstacleX = 1.2;
        _score += 30;
        AudioService.instance.playCoinPickup();
      }

      // Collision
      if (_obstacleX >= 0.18 && _obstacleX <= 0.28 && _playerY > 0.68) {
        _isGameOver = true;
        _ticker.stop();
        AudioService.instance.playError();
        widget.gameState.awardMiniGameReward(satoshisEarned: max(20, _score).toDouble(), powerBonus: 20.0);
      }
    });
  }

  void _jump() {
    if (_playerY >= 0.74 && !_isGameOver) {
      setState(() => _vy = -0.026);
      AudioService.instance.playTap();
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
        title: Text('CYBER RUNNER 2D', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onTap: _jump,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(top: 14, left: 20, child: Text('DISTANCE: $_score METERS', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900))),
                // Floor
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: (1.0 - 0.75) * constraints.maxHeight - 30,
                  height: 4,
                  child: Container(color: AppTheme.cyanNeon),
                ),
                // Player
                Positioned(
                  left: 0.2 * constraints.maxWidth - 16,
                  top: _playerY * constraints.maxHeight - 20,
                  child: const Text('🏃', style: TextStyle(fontSize: 36)),
                ),
                // Obstacle
                Positioned(
                  left: _obstacleX * constraints.maxWidth,
                  top: 0.75 * constraints.maxHeight - 16,
                  child: const Text('⚡', style: TextStyle(fontSize: 28)),
                ),
                if (_isGameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.redOverheat),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('TRIPPED!', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold)),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _playerY = 0.75;
                                _obstacleX = 1.2;
                                _score = 0;
                                _isGameOver = false;
                              });
                              _ticker.repeat();
                            },
                            child: const Text('RUN AGAIN'),
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
// GAME 29: QUANTUM SLOTS 777
// ==========================================
class QuantumSlotsGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const QuantumSlotsGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<QuantumSlotsGame> createState() => _QuantumSlotsGameState();
}

class _QuantumSlotsGameState extends State<QuantumSlotsGame> {
  final List<String> _symbols = ['₿', '⚡', '💎', '7', '🚀'];
  String _reel1 = '₿';
  String _reel2 = '₿';
  String _reel3 = '₿';
  bool _spinning = false;
  int _lastPayout = 0;

  void _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    AudioService.instance.playTick();

    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _reel1 = _symbols[Random().nextInt(_symbols.length)];
        _reel2 = _symbols[Random().nextInt(_symbols.length)];
        _reel3 = _symbols[Random().nextInt(_symbols.length)];
      });
    }

    int win = 0;
    if (_reel1 == _reel2 && _reel2 == _reel3) {
      win = 500;
      AudioService.instance.playSuccess();
    } else if (_reel1 == _reel2 || _reel2 == _reel3 || _reel1 == _reel3) {
      win = 100;
      AudioService.instance.playCoinPickup();
    } else {
      AudioService.instance.playError();
    }

    if (win > 0) {
      widget.gameState.awardMiniGameReward(satoshisEarned: win.toDouble(), powerBonus: 30.0);
    }

    setState(() {
      _spinning = false;
      _lastPayout = win;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('QUANTUM SLOTS 777', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PAYOUT: +$_lastPayout SAT', style: GoogleFonts.chakraPetch(fontSize: 22, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_reel1, _reel2, _reel3].map((s) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cyberCardDecoration(borderColor: AppTheme.bitcoinGold),
                  child: Text(s, style: const TextStyle(fontSize: 44)),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _spinning ? null : _spin,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanNeon, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
              child: Text(_spinning ? 'SPINNING...' : 'SPIN REELS (FREE)', style: GoogleFonts.chakraPetch(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GAME 30: CIRCUIT CROSSER (Crossy road)
// ==========================================
class CircuitCrosserGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CircuitCrosserGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CircuitCrosserGame> createState() => _CircuitCrosserGameState();
}

class _CircuitCrosserGameState extends State<CircuitCrosserGame> {
  int _playerLane = 0; // 0 (start) to 5 (finish)
  int _score = 0;

  void _hop() {
    setState(() {
      _playerLane++;
      AudioService.instance.playTap();
      if (_playerLane >= 5) {
        _score += 150;
        _playerLane = 0;
        AudioService.instance.playSuccess();
        widget.gameState.awardMiniGameReward(satoshisEarned: 150.0, powerBonus: 35.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('CIRCUIT HIGHWAY CROSSER', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('SATOSHIS EARNED: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.greenHash, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Column(
              children: List.generate(6, (lane) {
                final isCurrent = (5 - lane) == _playerLane;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppTheme.cyanNeon.withValues(alpha: 0.25) : AppTheme.surfaceSecondary,
                      border: Border.all(color: isCurrent ? AppTheme.cyanNeon : AppTheme.surfaceBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isCurrent ? const Text('🤖 DRONE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)) : Text(lane == 0 ? '🏁 FINISH NODE' : '⚡ DATA HIGHWAY', style: const TextStyle(color: Colors.white30)),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _hop,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenHash, minimumSize: const Size(double.infinity, 50)),
              child: Text('HOP FORWARD ⬆', style: GoogleFonts.chakraPetch(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
