import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class HashCrackerGame extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onGameOver;

  const HashCrackerGame({
    super.key,
    required this.gameState,
    required this.onGameOver,
  });

  @override
  State<HashCrackerGame> createState() => _HashCrackerGameState();
}

class _HashCrackerGameState extends State<HashCrackerGame> {
  static const List<Color> _nodeColors = [
    AppTheme.cyanNeon,
    AppTheme.bitcoinGold,
    AppTheme.greenHash,
    AppTheme.purpleQuantum,
  ];

  static const List<String> _nodeIcons = ['⚡', '₿', '💻', '🔮'];
  static const List<String> _nodeNames = ['CYAN CORE', 'GOLD SAT', 'HASH LOGIC', 'QUANTUM'];

  final List<int> _sequence = [];
  int _playerIndex = 0;
  int _currentRound = 1;
  static const int _maxRounds = 5;

  int _litNodeIndex = -1;
  bool _isPlayingSequence = false;
  bool _isGameOver = false;
  bool _wonGame = false;
  int _totalSatoshisWon = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    setState(() {
      _sequence.clear();
      _playerIndex = 0;
      _isPlayingSequence = true;
    });

    final rand = Random();
    final count = _currentRound + 2; // Round 1: 3 steps, Round 5: 7 steps
    for (int i = 0; i < count; i++) {
      _sequence.add(rand.nextInt(4));
    }

    _playSequence();
  }

  Future<void> _playSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (int node in _sequence) {
      if (!mounted) return;
      setState(() => _litNodeIndex = node);
      AudioService.instance.playTick();
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _litNodeIndex = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (mounted) {
      setState(() {
        _isPlayingSequence = false;
      });
    }
  }

  void _onNodeTap(int index) {
    if (_isPlayingSequence || _isGameOver) return;

    setState(() => _litNodeIndex = index);
    AudioService.instance.playTap();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _litNodeIndex = -1);
    });

    // Verify player step
    if (_sequence[_playerIndex] == index) {
      _playerIndex++;

      if (_playerIndex >= _sequence.length) {
        // Round completed successfully!
        final roundReward = _getRoundReward(_currentRound);
        _totalSatoshisWon += roundReward;
        AudioService.instance.playSuccess();

        if (_currentRound >= _maxRounds) {
          // Completed all 5 rounds!
          _wonGame = true;
          _isGameOver = true;
          widget.gameState.awardMiniGameReward(
            satoshisEarned: _totalSatoshisWon.toDouble(),
            powerBonus: 50.0,
          );
        } else {
          // Advance to next round
          setState(() {
            _currentRound++;
          });
          Future.delayed(const Duration(milliseconds: 800), _startRound);
        }
      }
    } else {
      // Mistake / Hash verification failed!
      AudioService.instance.playError();
      _isGameOver = true;
      _wonGame = false;

      if (_totalSatoshisWon > 0) {
        widget.gameState.awardMiniGameReward(
          satoshisEarned: _totalSatoshisWon.toDouble(),
          powerBonus: 25.0,
        );
      }
    }
  }

  int _getRoundReward(int round) {
    switch (round) {
      case 1:
        return 60;
      case 2:
        return 120;
      case 3:
        return 250;
      case 4:
        return 500;
      case 5:
        return 1000;
      default:
        return 50;
    }
  }

  void _restartGame() {
    setState(() {
      _sequence.clear();
      _playerIndex = 0;
      _currentRound = 1;
      _totalSatoshisWon = 0;
      _isGameOver = false;
      _wonGame = false;
      _litNodeIndex = -1;
    });
    _startRound();
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
            if (_totalSatoshisWon > 0 && !_isGameOver) {
              widget.gameState.awardMiniGameReward(
                satoshisEarned: _totalSatoshisWon.toDouble(),
                powerBonus: 20.0,
              );
            }
            widget.onGameOver();
          },
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🧠 ', style: TextStyle(fontSize: 18)),
            Text(
              'CIPHER HASH CRACKER',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppTheme.cyanNeon),
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
                // 1. Mission / Round Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cyberCardDecoration(
                    borderColor: AppTheme.cyanNeon,
                    glowColor: AppTheme.cyanNeon,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BLOCK VALIDATION: ROUND $_currentRound/$_maxRounds',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.cyanNeon,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isPlayingSequence
                                ? '👀 Observe the hash sequence...'
                                : '👆 Repeat the cryptographic hash!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isPlayingSequence ? AppTheme.goldLight : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.bitcoinGold),
                        ),
                        child: Text(
                          '+$_totalSatoshisWon SAT',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bitcoinGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Sequence Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_sequence.length, (index) {
                    final isReached = index < _playerIndex;
                    return Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReached ? AppTheme.greenHash : AppTheme.surfaceLight,
                        border: Border.all(
                          color: isReached ? AppTheme.greenHash : AppTheme.surfaceBorder,
                          width: 2,
                        ),
                        boxShadow: isReached
                            ? [
                                BoxShadow(
                                  color: AppTheme.greenHash.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                const Spacer(),

                // 3. 2x2 Matrix of Quantum Cryptographic Nodes
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: List.generate(4, (index) {
                        final isLit = _litNodeIndex == index;
                        final color = _nodeColors[index];

                        return GestureDetector(
                          onTap: () => _onNodeTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isLit
                                    ? [color, Colors.white]
                                    : [AppTheme.surfaceLight, AppTheme.surface],
                              ),
                              border: Border.all(
                                color: isLit ? Colors.white : color.withValues(alpha: 0.6),
                                width: isLit ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isLit
                                      ? color.withValues(alpha: 0.8)
                                      : color.withValues(alpha: 0.2),
                                  blurRadius: isLit ? 24 : 10,
                                  spreadRadius: isLit ? 4 : 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _nodeIcons[index],
                                  style: TextStyle(
                                    fontSize: 38,
                                    shadows: isLit
                                        ? [Shadow(color: color, blurRadius: 16)]
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _nodeNames[index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: isLit ? Colors.white : color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const Spacer(),

                // 4. Instructions
                Text(
                  _isPlayingSequence ? 'MEMORIZE CIPHER...' : 'TAP MATCHING NODES',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 5. Game Over / Victory Modal
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cyberCardDecoration(
                      borderColor: _wonGame ? AppTheme.greenHash : AppTheme.redOverheat,
                      glowColor: _wonGame ? AppTheme.greenHash : AppTheme.redOverheat,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _wonGame ? '🏆' : '⚠️',
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _wonGame ? 'BLOCK MINED SUCCESSFULLY!' : 'HASH MISMATCH!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _wonGame ? AppTheme.greenHash : AppTheme.redOverheat,
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
                                  const Text('Satoshis Mined:', style: TextStyle(color: AppTheme.textMuted)),
                                  Text(
                                    '+$_totalSatoshisWon SAT',
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
                                  const Text('Power Grid Bonus:', style: TextStyle(color: AppTheme.textMuted)),
                                  Text(
                                    _wonGame ? '+50% ⚡' : '+25% ⚡',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.cyanNeon,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Rounds Cleared:', style: TextStyle(color: AppTheme.textMuted)),
                                  Text(
                                    '${_wonGame ? _maxRounds : _currentRound - 1} / $_maxRounds',
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
                                  'COLLECT',
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
