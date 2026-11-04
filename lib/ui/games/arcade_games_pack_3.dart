import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

// ==========================================
// GAME 17: CRYPTO SIMON TAP (Simon Says)
// ==========================================
class CryptoSimonGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CryptoSimonGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CryptoSimonGame> createState() => _CryptoSimonGameState();
}

class _CryptoSimonGameState extends State<CryptoSimonGame> {
  final List<Color> _padColors = [AppTheme.greenHash, AppTheme.redOverheat, AppTheme.bitcoinGold, AppTheme.cyanNeon];
  final List<int> _sequence = [];
  int _playerStep = 0;
  int _litPad = -1;
  int _score = 0;
  bool _isPlayingSequence = false;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNextRound();
  }

  void _startNextRound() {
    _sequence.add(Random().nextInt(4));
    _playerStep = 0;
    _playSequence();
  }

  void _playSequence() async {
    setState(() => _isPlayingSequence = true);
    await Future.delayed(const Duration(milliseconds: 500));

    for (var pad in _sequence) {
      if (!mounted) return;
      setState(() => _litPad = pad);
      AudioService.instance.playTick();
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _litPad = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;
    setState(() => _isPlayingSequence = false);
  }

  void _padTap(int index) {
    if (_isPlayingSequence || _isGameOver) return;
    AudioService.instance.playTap();

    if (_sequence[_playerStep] == index) {
      _playerStep++;
      if (_playerStep >= _sequence.length) {
        _score += 50;
        AudioService.instance.playCoinPickup();
        Timer(const Duration(milliseconds: 600), _startNextRound);
      }
    } else {
      _isGameOver = true;
      AudioService.instance.playError();
      final reward = max(20, _score).toDouble();
      widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 25.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('SIMON HASH MEMORY', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ROUND: ${_sequence.length} • SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            SizedBox(
              width: 280,
              height: 280,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: List.generate(4, (i) {
                  final isLit = _litPad == i;
                  final color = _padColors[i];

                  return GestureDetector(
                    onTap: () => _padTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isLit ? color : color.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color, width: isLit ? 3.5 : 1.5),
                        boxShadow: isLit ? [BoxShadow(color: color, blurRadius: 20)] : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_isGameOver) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _sequence.clear();
                    _score = 0;
                    _isGameOver = false;
                  });
                  _startNextRound();
                },
                child: const Text('TRY AGAIN'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GAME 18: BALANCE THE RIG
// ==========================================
class BalanceTheRigGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const BalanceTheRigGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<BalanceTheRigGame> createState() => _BalanceTheRigGameState();
}

class _BalanceTheRigGameState extends State<BalanceTheRigGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _angle = 0.0; // in radians
  double _angularVelocity = 0.0;
  int _survivalSeconds = 0;
  Timer? _timer;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_loop)
      ..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _survivalSeconds++;
        // Add random slight wind / wobble
        _angularVelocity += (Random().nextDouble() - 0.5) * 0.005;
      });
    });
  }

  void _loop() {
    if (_isGameOver || !mounted) return;
    setState(() {
      _angle += _angularVelocity;
      // Gravity amplifies tilt
      _angularVelocity += _angle * 0.003;

      if (_angle.abs() > 0.65) {
        _isGameOver = true;
        _ticker.stop();
        _timer?.cancel();
        AudioService.instance.playError();
        final reward = (_survivalSeconds * 20.0 + 15.0);
        widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 20.0);
      }
    });
  }

  void _tilt(double force) {
    if (_isGameOver) return;
    setState(() {
      _angularVelocity += force;
      AudioService.instance.playTap();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('BALANCE THE MINING RIG', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('SURVIVED: ${_survivalSeconds}s', style: GoogleFonts.chakraPetch(fontSize: 22, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900)),
          const SizedBox(height: 40),
          Transform.rotate(
            angle: _angle,
            child: Container(
              width: 260,
              height: 24,
              decoration: BoxDecoration(color: AppTheme.bitcoinGold, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('🖥️', style: TextStyle(fontSize: 16)),
                  Text('⚡', style: TextStyle(fontSize: 16)),
                  Text('🖥️', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('▲ FULCRUM', style: TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _tilt(-0.015),
                icon: const Icon(Icons.rotate_left),
                label: const Text('TILT LEFT'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanNeon, foregroundColor: Colors.black),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => _tilt(0.015),
                icon: const Icon(Icons.rotate_right),
                label: const Text('TILT RIGHT'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanNeon, foregroundColor: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// GAME 19: MINECART GOLD RUSH
// ==========================================
class MinecartGoldRushGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const MinecartGoldRushGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<MinecartGoldRushGame> createState() => _MinecartGoldRushGameState();
}

class _MinecartGoldRushGameState extends State<MinecartGoldRushGame> {
  int _cartTrack = 1; // 0: Left, 1: Center, 2: Right
  final List<Point<int>> _goldNuggets = [];
  Timer? _tickTimer;
  int _score = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _score = 0;
    _isGameOver = false;
    _goldNuggets.clear();

    _tickTimer = Timer.periodic(const Duration(milliseconds: 400), (t) {
      if (!mounted) return;
      setState(() {
        // Move existing nuggets down
        for (int i = _goldNuggets.length - 1; i >= 0; i--) {
          final p = _goldNuggets[i];
          final nextY = p.y + 1;
          if (nextY >= 6) {
            if (p.x == _cartTrack) {
              _score += 40;
              AudioService.instance.playCoinPickup();
            }
            _goldNuggets.removeAt(i);
          } else {
            _goldNuggets[i] = Point(p.x, nextY);
          }
        }

        // Spawn new nugget at top
        if (Random().nextDouble() < 0.6) {
          _goldNuggets.add(Point(Random().nextInt(3), 0));
        }
      });
    });

    Timer(const Duration(seconds: 30), () {
      if (!mounted) return;
      _tickTimer?.cancel();
      setState(() => _isGameOver = true);
      widget.gameState.awardMiniGameReward(satoshisEarned: max(30, _score).toDouble(), powerBonus: 35.0);
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('MINECART GOLD RUSH', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _isGameOver ? 'MINING RUN COMPLETE! +$_score SAT' : 'SATOSHIS COLLECTED: $_score SAT',
              style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (trackIdx) {
                return Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSecondary,
                    border: Border.symmetric(vertical: BorderSide(color: AppTheme.surfaceBorder, width: 2)),
                  ),
                  child: Stack(
                    children: [
                      ..._goldNuggets.where((p) => p.x == trackIdx).map((p) {
                        return Positioned(
                          top: p.y * 65.0,
                          left: 20,
                          child: const Text('🪙', style: TextStyle(fontSize: 32)),
                        );
                      }),
                      if (_cartTrack == trackIdx)
                        const Positioned(
                          bottom: 20,
                          left: 14,
                          child: Text('🛒', style: TextStyle(fontSize: 48)),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 36, color: AppTheme.cyanNeon),
                  onPressed: () {
                    if (_cartTrack > 0) setState(() => _cartTrack--);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 36, color: AppTheme.cyanNeon),
                  onPressed: () {
                    if (_cartTrack < 2) setState(() => _cartTrack++);
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
// GAME 20: CRYPTO TIC-TAC-TOE PRO
// ==========================================
class CryptoTicTacToeGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const CryptoTicTacToeGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<CryptoTicTacToeGame> createState() => _CryptoTicTacToeGameState();
}

class _CryptoTicTacToeGameState extends State<CryptoTicTacToeGame> {
  final List<String> _board = List.filled(9, '');
  bool _playerTurn = true;
  String _winner = '';

  void _tapCell(int i) {
    if (_board[i].isNotEmpty || _winner.isNotEmpty || !_playerTurn) return;

    setState(() {
      _board[i] = '₿';
      AudioService.instance.playTap();
      _checkWinner();
      if (_winner.isEmpty) {
        _playerTurn = false;
        Timer(const Duration(milliseconds: 400), _aiMove);
      }
    });
  }

  void _aiMove() {
    if (!mounted || _winner.isNotEmpty) return;
    final empty = <int>[];
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) empty.add(i);
    }
    if (empty.isNotEmpty) {
      final pick = empty[Random().nextInt(empty.length)];
      setState(() {
        _board[pick] = '⚡';
        AudioService.instance.playTick();
        _checkWinner();
        _playerTurn = true;
      });
    }
  }

  void _checkWinner() {
    const wins = [
      [0,1,2], [3,4,5], [6,7,8],
      [0,3,6], [1,4,7], [2,5,8],
      [0,4,8], [2,4,6]
    ];
    for (var w in wins) {
      if (_board[w[0]].isNotEmpty && _board[w[0]] == _board[w[1]] && _board[w[0]] == _board[w[2]]) {
        _winner = _board[w[0]];
        if (_winner == '₿') {
          AudioService.instance.playSuccess();
          widget.gameState.awardMiniGameReward(satoshisEarned: 180.0, powerBonus: 30.0);
        } else {
          AudioService.instance.playError();
        }
        return;
      }
    }
    if (!_board.contains('') && _winner.isEmpty) {
      _winner = 'DRAW';
      widget.gameState.awardMiniGameReward(satoshisEarned: 40.0, powerBonus: 10.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('CRYPTO TIC-TAC-TOE', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _winner.isEmpty ? (_playerTurn ? 'YOUR TURN (₿)' : 'AI CALCULATING...') : (_winner == '₿' ? 'YOU WON! +180 SAT' : 'GAME OVER: $_winner'),
              style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.cyanNeon, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 280,
              height: 280,
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(9, (i) {
                  return GestureDetector(
                    onTap: () => _tapCell(i),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder, width: 1.5),
                      ),
                      child: Center(
                        child: Text(_board[i], style: TextStyle(fontSize: 34, color: _board[i] == '₿' ? AppTheme.bitcoinGold : AppTheme.cyanNeon)),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_winner.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _board.fillRange(0, 9, '');
                    _winner = '';
                    _playerTurn = true;
                  });
                },
                child: const Text('PLAY AGAIN'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GAME 21: SPACE MINER DEFENDER
// ==========================================
class SpaceMinerDefenderGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const SpaceMinerDefenderGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<SpaceMinerDefenderGame> createState() => _SpaceMinerDefenderGameState();
}

class _SpaceMinerDefenderGameState extends State<SpaceMinerDefenderGame> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  double _shipX = 0.5;
  final List<Point<double>> _lasers = [];
  final List<Point<double>> _aliens = [];
  int _score = 0;
  double _spawnTimer = 0.0;
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

    _spawnTimer += 0.016;
    if (_spawnTimer >= 0.7) {
      _spawnTimer = 0.0;
      _aliens.add(Point(0.1 + Random().nextDouble() * 0.8, 0.0));
    }

    setState(() {
      // Lasers move up
      for (int i = _lasers.length - 1; i >= 0; i--) {
        _lasers[i] = Point(_lasers[i].x, _lasers[i].y - 0.03);
        if (_lasers[i].y < 0.0) _lasers.removeAt(i);
      }

      // Aliens move down
      for (int i = _aliens.length - 1; i >= 0; i--) {
        _aliens[i] = Point(_aliens[i].x, _aliens[i].y + 0.007);
        if (_aliens[i].y > 0.9) {
          _isGameOver = true;
          _ticker.stop();
          AudioService.instance.playError();
          widget.gameState.awardMiniGameReward(satoshisEarned: max(20, _score).toDouble(), powerBonus: 25.0);
        }
      }

      // Hit detection
      for (int l = _lasers.length - 1; l >= 0; l--) {
        for (int a = _aliens.length - 1; a >= 0; a--) {
          if ((_lasers[l].x - _aliens[a].x).abs() < 0.08 && (_lasers[l].y - _aliens[a].y).abs() < 0.06) {
            _score += 50;
            AudioService.instance.playCrit();
            _lasers.removeAt(l);
            _aliens.removeAt(a);
            break;
          }
        }
      }
    });
  }

  void _fire() {
    if (_isGameOver) return;
    setState(() {
      _lasers.add(Point(_shipX, 0.85));
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
        title: Text('SPACE MINER INVADERS', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            setState(() {
              _shipX = (_shipX + (d.delta.dx / constraints.maxWidth)).clamp(0.1, 0.9);
            });
          },
          onTap: _fire,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(top: 14, left: 20, child: Text('SCORE: $_score SAT', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900))),
                ..._aliens.map((a) => Positioned(left: a.x * constraints.maxWidth - 16, top: a.y * constraints.maxHeight, child: const Text('👾', style: TextStyle(fontSize: 28)))),
                ..._lasers.map((l) => Positioned(left: l.x * constraints.maxWidth - 2, top: l.y * constraints.maxHeight, width: 4, height: 16, child: Container(color: AppTheme.cyanNeon))),
                Positioned(left: _shipX * constraints.maxWidth - 20, top: 0.86 * constraints.maxHeight, child: const Text('🚀', style: TextStyle(fontSize: 36))),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ==========================================
// GAME 22: REACTION SPEED GAUGE
// ==========================================
class ReactionSpeedGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const ReactionSpeedGame({super.key, required this.gameState, required this.onGameOver});

  @override
  State<ReactionSpeedGame> createState() => _ReactionSpeedGameState();
}

class _ReactionSpeedGameState extends State<ReactionSpeedGame> {
  String _state = 'WAIT'; // WAIT, READY, CLICK, RESULT
  int? _startTime;
  int? _reactionMs;
  Timer? _triggerTimer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    setState(() {
      _state = 'READY';
      _reactionMs = null;
    });

    final delay = 1500 + Random().nextInt(2500);
    _triggerTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _state = 'CLICK';
        _startTime = DateTime.now().millisecondsSinceEpoch;
      });
      AudioService.instance.playTick();
    });
  }

  void _tapScreen() {
    if (_state == 'READY') {
      _triggerTimer?.cancel();
      setState(() => _state = 'EARLY');
      AudioService.instance.playError();
    } else if (_state == 'CLICK') {
      final ms = DateTime.now().millisecondsSinceEpoch - _startTime!;
      setState(() {
        _reactionMs = ms;
        _state = 'RESULT';
      });
      AudioService.instance.playSuccess();
      final reward = max(20, 500 - ms).toDouble();
      widget.gameState.awardMiniGameReward(satoshisEarned: reward, powerBonus: 30.0);
    }
  }

  @override
  void dispose() {
    _triggerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg = AppTheme.background;
    if (_state == 'READY') bg = AppTheme.redOverheat.withValues(alpha: 0.3);
    if (_state == 'CLICK') bg = AppTheme.greenHash.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('REACTION SPEED GAUGE', style: GoogleFonts.chakraPetch(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onGameOver),
      ),
      body: GestureDetector(
        onTap: _tapScreen,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_state == 'READY') const Text('WAIT FOR GREEN...', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                if (_state == 'CLICK') const Text('TAP NOW!! ⚡⚡', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
                if (_state == 'EARLY') ...[
                  const Text('TOO EARLY! ⚠️', style: TextStyle(fontSize: 26, color: AppTheme.redOverheat, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _startRound, child: const Text('RETRY')),
                ],
                if (_state == 'RESULT') ...[
                  Text('$_reactionMs ms!', style: GoogleFonts.chakraPetch(fontSize: 36, color: AppTheme.bitcoinGold, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text('REWARD: +${max(20, 500 - _reactionMs!)} SAT 🪙', style: GoogleFonts.chakraPetch(fontSize: 18, color: AppTheme.greenHash)),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _startRound, child: const Text('TEST AGAIN')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
