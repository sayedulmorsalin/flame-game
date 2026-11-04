import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../../services/audio_service.dart';
import '../theme/app_theme.dart';

class MinerRankEntry {
  final String id;
  final String name;
  final String title;
  final double coins;
  final String avatarEmoji;
  final String? profilePicUrl;
  final Color badgeColor;
  final String location;
  final int rankChange; // +1, 0, -1
  final bool isPlayer;

  const MinerRankEntry({
    required this.id,
    required this.name,
    required this.title,
    required this.coins,
    required this.avatarEmoji,
    this.profilePicUrl,
    required this.badgeColor,
    required this.location,
    this.rankChange = 0,
    this.isPlayer = false,
  });
}

class MinersScreen extends StatefulWidget {
  final GameState gameState;

  const MinersScreen({super.key, required this.gameState});

  @override
  State<MinersScreen> createState() => _MinersScreenState();
}

class _MinersScreenState extends State<MinersScreen> {
  int _selectedFilterIndex = 0; // 0: All-Time, 1: Weekly League, 2: Arcade Champs

  // Baseline NPC miners in the crypto universe
  final List<MinerRankEntry> _staticMiners = const [
    MinerRankEntry(
      id: 'satoshi',
      name: 'Satoshi Nakamoto',
      title: '👑 GENESIS ARCHITECT',
      coins: 21000000.0,
      avatarEmoji: '👑',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Satoshi',
      badgeColor: AppTheme.bitcoinGold,
      location: '🌐 Global Node',
      rankChange: 0,
    ),
    MinerRankEntry(
      id: 'whale',
      name: 'Quantum Whale',
      title: '🐋 MEGA LIQUIDITY',
      coins: 14850000.0,
      avatarEmoji: '🐋',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Whale',
      badgeColor: AppTheme.cyanNeon,
      location: '🇸🇬 Singapore',
      rankChange: 1,
    ),
    MinerRankEntry(
      id: 'viper',
      name: 'Cyber Viper',
      title: '⚡ OVERCLOCK GOD',
      coins: 8920000.0,
      avatarEmoji: '⚡',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Viper',
      badgeColor: AppTheme.purpleQuantum,
      location: '🇩🇪 Frankfurt',
      rankChange: 2,
    ),
    MinerRankEntry(
      id: 'ada',
      name: 'Ada Lovelace',
      title: '🔬 LOGIC MASTER',
      coins: 4780000.0,
      avatarEmoji: '🔬',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Ada',
      badgeColor: AppTheme.cyanNeon,
      location: '🇬🇧 London',
      rankChange: -1,
    ),
    MinerRankEntry(
      id: 'ninja',
      name: 'Crypto Ninja',
      title: '🥷 STEALTH MINER',
      coins: 2650000.0,
      avatarEmoji: '🥷',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Ninja',
      badgeColor: AppTheme.greenHash,
      location: '🇯🇵 Tokyo',
      rankChange: 0,
    ),
    MinerRankEntry(
      id: 'megahash',
      name: 'MegaHash 99',
      title: '🦾 ASIC OVERLORD',
      coins: 1380000.0,
      avatarEmoji: '🦾',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=MegaHash',
      badgeColor: AppTheme.richRuby,
      location: '🇺🇸 Texas',
      rankChange: 1,
    ),
    MinerRankEntry(
      id: 'neon',
      name: 'Neon Striker',
      title: '🦊 SPEED DEMON',
      coins: 640000.0,
      avatarEmoji: '🦊',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Neon',
      badgeColor: AppTheme.orangeFrenzy,
      location: '🇰🇷 Seoul',
      rankChange: -1,
    ),
    MinerRankEntry(
      id: 'moon',
      name: 'Moon Walker',
      title: '👨‍🚀 HODL CAPTAIN',
      coins: 290000.0,
      avatarEmoji: '👨‍🚀',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Moon',
      badgeColor: AppTheme.cyanNeon,
      location: '🇦🇺 Sydney',
      rankChange: 3,
    ),
    MinerRankEntry(
      id: 'zerocool',
      name: 'Zero Cool',
      title: '💻 CYBER RUNNER',
      coins: 95000.0,
      avatarEmoji: '💻',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=ZeroCool',
      badgeColor: AppTheme.silverMetallic,
      location: '🇨🇦 Toronto',
      rankChange: 0,
    ),
    MinerRankEntry(
      id: 'drillmaster',
      name: 'Drill Master',
      title: '⛏️ CORE EXCAVATOR',
      coins: 32000.0,
      avatarEmoji: '⛏️',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Drill',
      badgeColor: AppTheme.bronzeAccent,
      location: '🇳🇴 Oslo',
      rankChange: 1,
    ),
    MinerRankEntry(
      id: 'pixelminer',
      name: 'Pixel Miner',
      title: '👾 ARCADE ROOKIE',
      coins: 8500.0,
      avatarEmoji: '👾',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Pixel',
      badgeColor: AppTheme.purpleQuantum,
      location: '🇧🇷 São Paulo',
      rankChange: -2,
    ),
    MinerRankEntry(
      id: 'bitnovice',
      name: 'Bit Novice',
      title: '🪙 FRESH EXPLORER',
      coins: 1200.0,
      avatarEmoji: '🪙',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=Novice',
      badgeColor: AppTheme.textMuted,
      location: '🇮🇳 Bangalore',
      rankChange: 0,
    ),
  ];

  List<MinerRankEntry> _getRankedList() {
    final playerCoins = widget.gameState.satoshis;
    final totalGames = widget.gameState.totalMiniGamesPlayed;

    String playerTitle = '🎮 ARCADE CONTENDER';
    if (playerCoins >= 1000000) {
      playerTitle = '💎 CRYPTO TITAN';
    } else if (playerCoins >= 100000) {
      playerTitle = '⚡ POWER MINER';
    } else if (totalGames >= 10) {
      playerTitle = '🔥 ARCADE VETERAN';
    }

    final playerEntry = MinerRankEntry(
      id: 'player_user',
      name: 'You (Player)',
      title: playerTitle,
      coins: playerCoins,
      avatarEmoji: '⚡',
      profilePicUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=PlayerOne',
      badgeColor: AppTheme.bitcoinGold,
      location: '📍 Local Rig',
      isPlayer: true,
      rankChange: 1,
    );

    final list = List<MinerRankEntry>.from(_staticMiners)..add(playerEntry);
    list.sort((a, b) => b.coins.compareTo(a.coins));
    return list;
  }

  void _showMinerDetails(MinerRankEntry miner, int rank) {
    AudioService.instance.playTap();
    final format = NumberFormat('#,###');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: miner.badgeColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rank Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: AppTheme.badgeDecoration(color: miner.badgeColor, borderRadius: 8),
                child: Text(
                  'GLOBAL RANK #$rank',
                  style: GoogleFonts.chakraPetch(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: miner.badgeColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Profile Picture
              _buildAvatarWidget(miner, size: 76, showBorderGlow: true),
              const SizedBox(height: 14),
              // Miner Name & Title
              Text(
                miner.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.chakraPetch(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                miner.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.chakraPetch(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: miner.badgeColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Coin Balance Stat Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 18)),
                        Text(
                          'COIN BALANCE:',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${format.format(miner.coins.toInt())} SAT',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.bitcoinGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Location info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppTheme.cyanNeon),
                  const SizedBox(width: 4),
                  Text(
                    miner.location,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Send Respect Button
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AudioService.instance.playCoinPickup();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(milliseconds: 900),
                            backgroundColor: AppTheme.surface,
                            content: Text(
                              '👍 Respect sent to ${miner.name}!',
                              style: GoogleFonts.chakraPetch(
                                color: AppTheme.cyanNeon,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: AppTheme.gameButtonDecoration(
                          color: miner.badgeColor,
                          borderRadius: 12,
                        ),
                        child: Center(
                          child: Text(
                            miner.isPlayer ? 'YOU ARE AWESOME ⚡' : 'SEND RESPECT 👍',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.8,
                            ),
                          ),
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
    );
  }

  Widget _buildAvatarWidget(MinerRankEntry miner, {double size = 48, bool showBorderGlow = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceSecondary,
        border: Border.all(color: miner.badgeColor, width: size > 60 ? 2.5 : 2.0),
        boxShadow: showBorderGlow
            ? [
                BoxShadow(
                  color: miner.badgeColor.withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: miner.profilePicUrl != null
            ? Image.network(
                miner.profilePicUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackEmoji(miner, size),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildFallbackEmoji(miner, size);
                },
              )
            : _buildFallbackEmoji(miner, size),
      ),
    );
  }

  Widget _buildFallbackEmoji(MinerRankEntry miner, double size) {
    return Container(
      color: AppTheme.surfaceSecondary,
      child: Center(
        child: Text(
          miner.avatarEmoji,
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');

    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final rankedMiners = _getRankedList();
        final playerIndex = rankedMiners.indexWhere((m) => m.isPlayer);
        final playerRank = playerIndex >= 0 ? playerIndex + 1 : rankedMiners.length;
        final playerEntry = playerIndex >= 0 ? rankedMiners[playerIndex] : null;

        final top1 = rankedMiners.isNotEmpty ? rankedMiners[0] : null;
        final top2 = rankedMiners.length > 1 ? rankedMiners[1] : null;
        final top3 = rankedMiners.length > 2 ? rankedMiners[2] : null;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            // 1. LEADERBOARD HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A1C16), Color(0xFF141A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.bitcoinGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.bitcoinGold.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bitcoinGold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.bitcoinGold.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GLOBAL MINERS RANKING',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Live hashrate and Satoshi leaderboard',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.bitcoinGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.bitcoinGold.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '#$playerRank',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.bitcoinGold,
                          ),
                        ),
                        Text(
                          'YOUR RANK',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.bitcoinGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. FILTER PILLS
            Row(
              children: [
                _buildFilterPill(0, '🌍 ALL-TIME'),
                const SizedBox(width: 8),
                _buildFilterPill(1, '⚡ WEEKLY LEAGUE'),
                const SizedBox(width: 8),
                _buildFilterPill(2, '🔥 ARCADE TOP'),
              ],
            ),

            const SizedBox(height: 18),

            // 3. TOP 3 PODIUM DISPLAY
            if (top1 != null && top2 != null && top3 != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                decoration: AppTheme.cyberCardDecoration(
                  borderColor: AppTheme.bitcoinGold,
                  glowColor: AppTheme.bitcoinGold,
                ),
                child: Column(
                  children: [
                    Text(
                      '👑 TOP CRYPTO KINGS',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.bitcoinGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // #2 Rank (Silver - Left)
                        Expanded(
                          child: _buildPodiumStep(
                            miner: top2,
                            rank: 2,
                            pedestalHeight: 80,
                            pedestalColor: AppTheme.silverMetallic,
                            avatarSize: 52,
                            crownOrMedal: '🥈',
                          ),
                        ),
                        // #1 Rank (Gold - Center, Tallest)
                        Expanded(
                          child: _buildPodiumStep(
                            miner: top1,
                            rank: 1,
                            pedestalHeight: 110,
                            pedestalColor: AppTheme.bitcoinGold,
                            avatarSize: 66,
                            crownOrMedal: '👑',
                          ),
                        ),
                        // #3 Rank (Bronze - Right)
                        Expanded(
                          child: _buildPodiumStep(
                            miner: top3,
                            rank: 3,
                            pedestalHeight: 65,
                            pedestalColor: AppTheme.bronzeAccent,
                            avatarSize: 48,
                            crownOrMedal: '🥉',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 4. PLAYER'S LIVE STANDING STICKY CARD
            if (playerEntry != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E2218), Color(0xFF1B1622)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.bitcoinGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.bitcoinGold.withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.goldGradient,
                      ),
                      child: Center(
                        child: Text(
                          '#$playerRank',
                          style: GoogleFonts.chakraPetch(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildAvatarWidget(playerEntry, size: 44, showBorderGlow: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                playerEntry.name,
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.bitcoinGold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.bitcoinGold,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'YOU',
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            playerEntry.title,
                            style: GoogleFonts.chakraPetch(
                              fontSize: 10.5,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${format.format(playerEntry.coins.toInt())} SAT',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.bitcoinGold,
                          ),
                        ),
                        Text(
                          'YOUR COINS',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.greenHash,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            // 5. ALL MINERS RANK LIST HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('📊 ', style: TextStyle(fontSize: 18)),
                    Text(
                      'RANKINGS TABLE',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: AppTheme.cyanNeon.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  '${rankedMiners.length} MINERS',
                  style: GoogleFonts.chakraPetch(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 6. RANKED MINERS LIST
            ...rankedMiners.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final miner = entry.value;
              final isTop3 = rank <= 3;

              Color rankColor = AppTheme.textSecondary;
              if (rank == 1) rankColor = AppTheme.bitcoinGold;
              if (rank == 2) rankColor = AppTheme.silverMetallic;
              if (rank == 3) rankColor = AppTheme.bronzeAccent;
              if (miner.isPlayer) rankColor = AppTheme.cyanNeon;

              return GestureDetector(
                onTap: () => _showMinerDetails(miner, rank),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: miner.isPlayer
                        ? AppTheme.bitcoinGold.withValues(alpha: 0.12)
                        : AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: miner.isPlayer
                          ? AppTheme.bitcoinGold
                          : (isTop3 ? rankColor.withValues(alpha: 0.6) : AppTheme.surfaceBorderSubtle),
                      width: miner.isPlayer ? 1.8 : 1.0,
                    ),
                    boxShadow: miner.isPlayer
                        ? [
                            BoxShadow(
                              color: AppTheme.bitcoinGold.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Rank position
                      SizedBox(
                        width: 32,
                        child: Text(
                          '#$rank',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.chakraPetch(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: rankColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Profile Picture with live avatar
                      _buildAvatarWidget(miner, size: 42, showBorderGlow: isTop3 || miner.isPlayer),
                      const SizedBox(width: 10),
                      // Name & Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    miner.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.chakraPetch(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: miner.isPlayer ? AppTheme.bitcoinGold : AppTheme.textPrimary,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                if (miner.isPlayer) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bitcoinGold,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'YOU',
                                      style: GoogleFonts.chakraPetch(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              miner.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.chakraPetch(
                                fontSize: 10.5,
                                color: miner.isPlayer ? AppTheme.cyanNeon : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Coins Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙 ', style: TextStyle(fontSize: 12)),
                              Text(
                                format.format(miner.coins.toInt()),
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: miner.isPlayer ? AppTheme.bitcoinGold : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SAT',
                            style: GoogleFonts.chakraPetch(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildFilterPill(int index, String label) {
    final isSelected = _selectedFilterIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioService.instance.playTap();
          setState(() => _selectedFilterIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.cyanNeon.withValues(alpha: 0.15)
                : AppTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.cyanNeon : AppTheme.surfaceBorderSubtle,
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.chakraPetch(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: isSelected ? AppTheme.cyanNeon : AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumStep({
    required MinerRankEntry miner,
    required int rank,
    required double pedestalHeight,
    required Color pedestalColor,
    required double avatarSize,
    required String crownOrMedal,
  }) {
    final format = NumberFormat('#,###');

    return GestureDetector(
      onTap: () => _showMinerDetails(miner, rank),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown / Medal Icon
          Text(crownOrMedal, style: TextStyle(fontSize: rank == 1 ? 24 : 18)),
          const SizedBox(height: 4),
          // Profile Picture with glowing border
          _buildAvatarWidget(miner, size: avatarSize, showBorderGlow: true),
          const SizedBox(height: 6),
          // Miner Name
          Text(
            miner.name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.chakraPetch(
              fontSize: rank == 1 ? 13 : 11.5,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          // Coin count
          Text(
            '${format.format(miner.coins.toInt())} SAT',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.chakraPetch(
              fontSize: rank == 1 ? 11 : 9.5,
              fontWeight: FontWeight.w900,
              color: pedestalColor,
            ),
          ),
          const SizedBox(height: 8),
          // 3D Pedestal
          Container(
            height: pedestalHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  pedestalColor.withValues(alpha: 0.35),
                  pedestalColor.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: pedestalColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: pedestalColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: GoogleFonts.chakraPetch(
                    fontSize: rank == 1 ? 26 : 20,
                    fontWeight: FontWeight.w900,
                    color: pedestalColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
