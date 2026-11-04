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

  Timer? _sequenceTimer;
  Timer? _tapTimer;
  Timer? _nextRoundTimer;
  int _sequencePlaybackIndex = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _clearAllTimers();
    super.dispose();
  }

  void _clearAllTimers() {
    _sequenceTimer?.cancel();
    _sequenceTimer = null;
    _tapTimer?.cancel();
    _tapTimer = null;
    _nextRoundTimer?.cancel();
    _nextRoundTimer = null;
  }

  void _startRound() {
    _clearAllTimers();
    setState(() {
      _sequence.clear();
      _playerIndex = 0;
      _isPlayingSequence = true;
      _litNodeIndex = -1;
    });

    final rand = Random();
    final count = _currentRound + 2; // Round 1: 3 steps, Round 5: 7 steps
    for (int i = 0; i < count; i++) {
      _sequence.add(rand.nextInt(4));
    }

    _sequencePlaybackIndex = 0;
    _sequenceTimer = Timer(const Duration(milliseconds: 500), _playNextSequenceStep);
  }

  void _playNextSequenceStep() {
    if (!mounted) return;
    if (_sequencePlaybackIndex >= _sequence.length) {
      setState(() {
        _isPlayingSequence = false;
        _litNodeIndex = -1;
      });
      return;
    }

    final node = _sequence[_sequencePlaybackIndex];
    setState(() => _litNodeIndex = node);
    AudioService.instance.playTick();

    _sequenceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _litNodeIndex = -1);
      _sequencePlaybackIndex++;
      _sequenceTimer = Timer(const Duration(milliseconds: 180), _playNextSequenceStep);
    });
  }

  void _onNodeTap(int index) {
    if (_isPlayingSequence || _isGameOver) return;

    setState(() => _litNodeIndex = index);
    AudioService.instance.playTap();

    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 200), () {
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
          _nextRoundTimer?.cancel();
          _nextRoundTimer = Timer(const Duration(milliseconds: 800), () {
            if (mounted) _startRound();
          });
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
    _clearAllTimers();
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
      backgroundColor: AppTheme.background,
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
                // 1. Mission / Round Header
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
                          Text(
                            'BLOCK VALIDATION: ROUND $_currentRound/$_maxRounds',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.richRuby,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _isPlayingSequence
                                ? '👀 Observe the hash sequence...'
                                : '👆 Repeat the cryptographic hash!',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _isPlayingSequence ? AppTheme.goldLight : AppTheme.textPrimary,
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
                        color: isReached ? AppTheme.greenHash : AppTheme.surfaceSecondary,
                        border: Border.all(
                          color: isReached ? AppTheme.greenHash : AppTheme.surfaceBorder,
                          width: 2,
                        ),
                        boxShadow: isReached
                            ? [
                                BoxShadow(
                                  color: AppTheme.greenHash.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // 3. 2x2 Matrix of Quantum Cryptographic Nodes
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
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
                                      : color.withValues(alpha: 0.15),
                                  blurRadius: isLit ? 20 : 8,
                                  spreadRadius: isLit ? 3 : 0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _nodeIcons[index],
                                  style: TextStyle(
                                    fontSize: 36,
                                    shadows: isLit
                                        ? [Shadow(color: color, blurRadius: 16)]
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _nodeNames[index],
                                  style: TextStyle(
                                    fontSize: 10.5,
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

                const SizedBox(height: 20),

                // 4. Instructions
                Text(
                  _isPlayingSequence ? 'MEMORIZE CIPHER...' : 'TAP MATCHING NODES',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),

          // 5. Game Over / Victory Modal
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(22),
                    decoration: AppTheme.cyberCardDecoration(
                      borderColor: _wonGame ? AppTheme.greenHash : AppTheme.redOverheat,
                      glowColor: _wonGame ? AppTheme.greenHash : AppTheme.redOverheat,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _wonGame ? '🏆' : '⚠️',
                          style: const TextStyle(fontSize: 44),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _wonGame ? 'BLOCK MINED SUCCESSFULLY!' : 'HASH MISMATCH!',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _wonGame ? AppTheme.greenHash : AppTheme.redOverheat,
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
                                  const Text('Satoshis Mined:', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                  Text(
                                    '+$_totalSatoshisWon SAT',
                                    style: const TextStyle(
                                      fontSize: 17,
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
                                  const Text('Power Grid Bonus:', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                  Text(
                                    _wonGame ? '+50% ⚡' : '+25% ⚡',
                                    style: const TextStyle(
                                      fontSize: 14,
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
                                  const Text('Rounds Cleared:', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                  Text(
                                    '${_wonGame ? _maxRounds : _currentRound - 1} / $_maxRounds',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
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
                                  'COLLECT',
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
