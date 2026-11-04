import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_state.dart';
import '../theme/app_theme.dart';

class TopHud extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onBoostPressed;

  const TopHud({
    super.key,
    required this.gameState,
    required this.onBoostPressed,
  });

  @override
  State<TopHud> createState() => _TopHudState();
}

class _TopHudState extends State<TopHud> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final satoshiFormat = NumberFormat('#,###');
    final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isFrenzy = widget.gameState.isFrenzyActive;
    final isBoosted = widget.gameState.boostDurationRemaining > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF161E36), Color(0xFF0C101E)],
        ),
        border: const Border(
          bottom: BorderSide(color: AppTheme.surfaceBorder, width: 2.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x90000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Bitcoin Balance & Arcade Status Chips
            Row(
              children: [
                // Bitcoin Satoshi Bank
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 3D Embossed Golden Coin with Animated Pulse
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.96 + (_pulseController.value * 0.08),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.goldGradient,
                            border: Border.all(color: const Color(0xFFFFE082), width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.bitcoinGold.withValues(alpha: 0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                              const BoxShadow(
                                color: Color(0xFF8D5300),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '₿',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${satoshiFormat.format(widget.gameState.satoshis.toInt())} SAT',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.chakraPetch(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.bitcoinGold,
                                      letterSpacing: 0.8,
                                      shadows: [
                                        Shadow(
                                          color: AppTheme.bitcoinGold.withValues(alpha: 0.6),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${widget.gameState.btcBalance.toStringAsFixed(8)} BTC • ${usdFormat.format(widget.gameState.portfolioUsdValue)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Right Status Badges: Battery, Hashrate & Animated 3D Boost Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Power Cell Battery Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.gameState.isRigPowered
                              ? AppTheme.greenHash
                              : AppTheme.orangeFrenzy,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.gameState.isRigPowered
                                    ? AppTheme.greenHash
                                    : AppTheme.orangeFrenzy)
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.gameState.isRigPowered
                                ? Icons.battery_charging_full
                                : Icons.battery_alert,
                            size: 15,
                            color: widget.gameState.isRigPowered
                                ? AppTheme.greenHash
                                : AppTheme.orangeFrenzy,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.gameState.rigPower.toInt()}%',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: widget.gameState.isRigPowered
                                  ? AppTheme.greenHash
                                  : AppTheme.orangeFrenzy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Hashrate Speedometer Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isFrenzy
                              ? AppTheme.richRuby
                              : (widget.gameState.isRigPowered
                                  ? AppTheme.cyanNeon
                                  : AppTheme.textMuted),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isFrenzy
                                    ? AppTheme.richRuby
                                    : (widget.gameState.isRigPowered
                                        ? AppTheme.cyanNeon
                                        : Colors.transparent))
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 15,
                            color: isFrenzy
                                ? AppTheme.richRuby
                                : (widget.gameState.isRigPowered
                                    ? AppTheme.cyanNeon
                                    : AppTheme.textMuted),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.gameState.isRigPowered
                                ? widget.gameState.formattedHashrate
                                : 'OFFLINE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isFrenzy
                                  ? AppTheme.richRuby
                                  : (widget.gameState.isRigPowered
                                      ? AppTheme.cyanNeon
                                      : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),

                    // 3D Animated Game Boost Push Button
                    GestureDetector(
                      onTap: widget.onBoostPressed,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isBoosted
                                ? 0.95 + (_pulseController.value * 0.1)
                                : 1.0,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: isBoosted
                              ? AppTheme.gameButtonDecoration(
                                  color: AppTheme.richRuby,
                                  borderRadius: 10,
                                )
                              : BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF24304D), Color(0xFF141B2D)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.surfaceBorder, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF0B0E19),
                                      offset: Offset(0, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🚀', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 3),
                              Text(
                                isBoosted
                                    ? '${widget.gameState.boostDurationRemaining.toInt()}s'
                                    : '2X',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: isBoosted
                                      ? Colors.white
                                      : AppTheme.cyanNeon,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 7),

            // Tap Frenzy Arcade Meter with Animated Pulse
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          isFrenzy ? '🔥' : '⚡',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFrenzy
                              ? 'OVERCLOCK FRENZY • 3X MULTIPLIER'
                              : 'OVERCLOCK COMBO METER',
                          style: GoogleFonts.chakraPetch(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: isFrenzy
                                ? AppTheme.richRuby
                                : AppTheme.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isFrenzy
                          ? '${widget.gameState.frenzyDurationRemaining.toStringAsFixed(1)}s'
                          : '${(widget.gameState.frenzyMeter * 100).toInt()}%',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isFrenzy
                            ? AppTheme.richRuby
                            : AppTheme.cyanNeon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isFrenzy
                          ? AppTheme.richRuby
                          : AppTheme.surfaceBorderSubtle,
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: widget.gameState.frenzyMeter,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFrenzy
                            ? AppTheme.richRuby
                            : AppTheme.cyanNeon,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
