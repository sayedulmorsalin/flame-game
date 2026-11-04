import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../games/mini_games_catalog.dart';

class ArcadeScreen extends StatefulWidget {
  final GameState gameState;

  const ArcadeScreen({super.key, required this.gameState});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final AnimationController _rotationController;

  String _selectedCategory = 'ALL';
  final List<String> _categories = const ['ALL', 'Action', 'Puzzle', 'Reflex', 'Retro', 'Casino', 'Physics'];

  @override
  void initState() {
    super.initState();
    // Continuous breathing pulse animation for buttons and reactor
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Shimmer light sweep across cards
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    // Slow rotation for halos & auras
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _launchGame(BuildContext context, Widget gameWidget) {
    AudioService.instance.playTap();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => gameWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');

    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final gamerLevel = (widget.gameState.totalMiniGamesPlayed ~/ 3) + 1;
        final gamesToDisplay = _selectedCategory == 'ALL'
            ? MiniGamesCatalog.allGames
            : MiniGamesCatalog.allGames.where((g) => g.category == _selectedCategory).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            // 1. HERO ARCADE STAGE BANNER (Visually Dominant, Animated, Less Text)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F2B48), Color(0xFF0F1426), Color(0xFF160D24)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cyanNeon, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyanNeon.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                  const BoxShadow(
                    color: Color(0x90000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: AppTheme.gameButtonDecoration(
                              color: AppTheme.richRuby,
                              borderRadius: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⭐ ', style: TextStyle(fontSize: 12)),
                                Text(
                                  'LVL $gamerLevel PRO',
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.gameState.isFrenzyActive)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.95 + (_pulseController.value * 0.1),
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: AppTheme.gameButtonDecoration(
                                  color: AppTheme.orangeFrenzy,
                                  borderRadius: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🔥 ', style: TextStyle(fontSize: 13)),
                                    Text(
                                      '3X FRENZY',
                                      style: GoogleFonts.chakraPetch(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Big Satoshi Counter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSecondary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.bitcoinGold, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.bitcoinGold.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙 ', style: TextStyle(fontSize: 14)),
                            Text(
                              '${format.format(widget.gameState.satoshis.toInt())} SAT',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.bitcoinGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Giant Game Headline (Visual, bold, high-contrast)
                  Row(
                    children: [
                      const Text('🕹️ ', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CYBER ARCADE ARENA',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.cyanNeon.withValues(alpha: 0.6),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'PLAY GAMES • WIN BITCOIN • LEVEL UP',
                              style: GoogleFonts.chakraPetch(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.cyanNeon,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Stats Row (Bold, punchy chips)
                  Row(
                    children: [
                      _buildQuickStat(
                        icon: '🎮',
                        label: 'GAMES WON',
                        value: '${widget.gameState.totalMiniGamesPlayed}',
                        accentColor: AppTheme.cyanNeon,
                      ),
                      const SizedBox(width: 8),
                      _buildQuickStat(
                        icon: '⚡',
                        label: 'SATOSHIS',
                        value: format.format(widget.gameState.lifetimeSatoshisMined.toInt()),
                        accentColor: AppTheme.bitcoinGold,
                      ),
                      const SizedBox(width: 8),
                      _buildQuickStat(
                        icon: '🎮',
                        label: 'MINI-GAMES',
                        value: '${MiniGamesCatalog.allGames.length} GAMES',
                        accentColor: AppTheme.greenHash,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. FEATURED ARCADE GAMES HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎮 ', style: TextStyle(fontSize: 22)),
                    Text(
                      '30 MINI-GAMES ARCADE',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: AppTheme.cyanNeon.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: AppTheme.badgeDecoration(color: AppTheme.richRuby, borderRadius: 6),
                  child: Text(
                    '🔥 PLAY TO EARN',
                    style: GoogleFonts.chakraPetch(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.richRuby,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final count = cat == 'ALL'
                      ? MiniGamesCatalog.allGames.length
                      : MiniGamesCatalog.allGames.where((g) => g.category == cat).length;
                  return GestureDetector(
                    onTap: () {
                      AudioService.instance.playTap();
                      setState(() => _selectedCategory = cat);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.cyanNeon.withValues(alpha: 0.2) : AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.cyanNeon : AppTheme.surfaceBorderSubtle,
                          width: isSelected ? 1.6 : 1.0,
                        ),
                      ),
                      child: Text(
                        '$cat ($count)',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? AppTheme.cyanNeon : AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 3. 30 MINI-GAMES LIST
            ...gamesToDisplay.map((game) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildAnimatedGameCard(
                  context: context,
                  title: game.title,
                  playTime: game.playTime,
                  imageAsset: game.imageAsset,
                  tag: game.tag,
                  tagColor: game.tagColor,
                  icon: game.icon,
                  rewardPill: game.rewardPill,
                  gradientColors: [
                    game.borderColor.withValues(alpha: 0.22),
                    const Color(0xFF0F1426),
                  ],
                  borderColor: game.borderColor,
                  buttonText: game.buttonText,
                  onTap: () {
                    _launchGame(
                      context,
                      game.builder(context, widget.gameState, () => Navigator.pop(context)),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildQuickStat({
    required String icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.chakraPetch(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.chakraPetch(
                fontSize: 9.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedGameCard({
    required BuildContext context,
    required String title,
    required String playTime,
    required String imageAsset,
    required String tag,
    required Color tagColor,
    required String icon,
    required String rewardPill,
    required List<Color> gradientColors,
    required Color borderColor,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Color(0x90000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Big Reward Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: AppTheme.badgeDecoration(color: tagColor, borderRadius: 8),
                      child: Text(
                        tag,
                        style: GoogleFonts.chakraPetch(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: tagColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bitcoinGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.bitcoinGold, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.bitcoinGold.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙 ', style: TextStyle(fontSize: 11)),
                          Text(
                            rewardPill,
                            style: GoogleFonts.chakraPetch(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.bitcoinGold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Center Game Image Cover and Details (NO description needed, ONLY time of the game)
                Row(
                  children: [
                    // High-Impact Game Cover Image (72x72)
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor.withValues(alpha: 0.45),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.surfaceSecondary,
                              child: Center(
                                child: Text(icon, style: const TextStyle(fontSize: 34)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.chakraPetch(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.8,
                              shadows: [
                                Shadow(
                                  color: borderColor.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Time of the game badge (ONLY time, no description)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.cyanNeon.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⏱️ ', style: TextStyle(fontSize: 12)),
                                Text(
                                  playTime,
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.cyanNeon,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bottom Row: Payout badge and Pulsing 3D Push Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on, size: 18, color: AppTheme.greenHash),
                        const SizedBox(width: 4),
                        Text(
                          'INSTANT REWARD',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.greenHash,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.97 + (_pulseController.value * 0.05),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: AppTheme.gameButtonDecoration(
                          color: borderColor,
                          borderRadius: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              buttonText,
                              style: GoogleFonts.chakraPetch(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
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
    );
  }
}
