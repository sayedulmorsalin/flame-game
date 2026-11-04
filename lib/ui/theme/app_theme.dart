import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- High-Voltage Arcade Game Palette ---
  /// Deep space cyber void background
  static const Color background = Color(0xFF07090E);

  /// High-tech cyber panel surface
  static const Color surface = Color(0xFF0F1424);

  /// Elevated arcade card surface with subtle glow
  static const Color surfaceLight = Color(0xFF171E36);

  /// Secondary surface for recessed trays, meters, inactive items
  static const Color surfaceSecondary = Color(0xFF11172A);

  /// Neon cyber border
  static const Color surfaceBorder = Color(0xFF263558);

  /// Subtle inner border
  static const Color surfaceBorderSubtle = Color(0xFF1C2642);

  /// Metallic chrome / armor accent
  static const Color silverMetallic = Color(0xFF90A4CE);
  static const Color silverLight = Color(0xFF384870);

  // --- Ultra-Vibrant Game Neon Accents ---
  /// Arcade Crimson Laser (Attack, Alert, Boost)
  static const Color richRuby = Color(0xFFFF1E56);
  static const Color crimsonRose = Color(0xFFFF4071);
  static const Color roseGold = Color(0xFFFF6E91);
  static const Color rubyDark = Color(0xFF9E0B2F);

  /// Blazing Bitcoin Gold (Currency, Jackpots, Treasures)
  static const Color bitcoinGold = Color(0xFFFFB300);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color goldDark = Color(0xFFC67C00);
  static const Color bronzeAccent = Color(0xFFCD7F32);

  /// Cyber Cyan (Action, Technology, Electricity)
  static const Color cyanNeon = Color(0xFF00F0FF);
  static const Color cyanDark = Color(0xFF00838F);

  /// Matrix Emerald Green (Satoshis Mined, Upgrades, Success)
  static const Color greenHash = Color(0xFF00FF88);
  static const Color greenDark = Color(0xFF00897B);

  /// Hyper Plasma Purple (Epic Rarity, Special Abilities)
  static const Color purpleQuantum = Color(0xFFD500F9);
  static const Color purpleDark = Color(0xFF7B1FA2);

  /// Overdrive Flame Orange (Frenzy, Turbo, Combos)
  static const Color orangeFrenzy = Color(0xFFFF6D00);
  static const Color orangeDark = Color(0xFFB23C00);

  /// Critical Core Warning Red
  static const Color redOverheat = Color(0xFFFF1744);

  // --- High-Contrast Game Typography Colors ---
  /// Pure stark white for titles, numbers, and primary labels
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Cyber ice blue for secondary game info and stats
  static const Color textSecondary = Color(0xFF9AB2DC);

  /// Dark tech muted hint text
  static const Color textMuted = Color(0xFF52668E);

  // --- 3D Game Gradients (with top-light highlights) ---
  static const LinearGradient silverMetallicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF25304E), Color(0xFF131A2D)],
  );

  static const LinearGradient rubyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF4071), Color(0xFFB71C1C)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
  );

  static const LinearGradient frenzyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF9100), Color(0xFFFF1744)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF64FFDA), Color(0xFF00B0FF)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B233D), Color(0xFF0D1222)],
  );

  static const LinearGradient plasmaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF69F0AE), Color(0xFF00C853)],
  );

  // --- High-Energy Game Typography ---
  static TextStyle get gameFontHeading => GoogleFonts.chakraPetch(
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    color: textPrimary,
  );

  static TextStyle get gameFontBody => GoogleFonts.chakraPetch(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textSecondary,
  );

  static TextStyle get gameFontNumber => GoogleFonts.chakraPetch(
    fontWeight: FontWeight.w900,
    letterSpacing: 0.8,
  );

  // --- ThemeData ---
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    final gameTextTheme = GoogleFonts.chakraPetchTextTheme(baseTextTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: cyanNeon,
      cardColor: surface,
      dividerColor: surfaceBorder,
      textTheme: gameTextTheme,
      colorScheme: const ColorScheme.dark(
        primary: cyanNeon,
        secondary: bitcoinGold,
        surface: surface,
        error: redOverheat,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.chakraPetch(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: cyanNeon,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }

  // Unified game theme alias
  static ThemeData get darkTheme => lightTheme;

  // --- 3D Arcade Push Button Decoration ---
  /// Creates an authentic 3D beveled game button with tactile press-depth
  static BoxDecoration gameButtonDecoration({
    required Color color,
    Color? shadowColor,
    Color? borderColor,
    double borderRadius = 12,
    bool isPressed = false,
  }) {
    final bottomBevelColor = shadowColor ?? _darkenColor(color, 0.4);
    final highlightBorder = borderColor ?? color.withValues(alpha: 0.8);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.95),
          color,
          _darkenColor(color, 0.15),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: highlightBorder,
        width: 1.5,
      ),
      boxShadow: isPressed
          ? [
              BoxShadow(
                color: bottomBevelColor,
                offset: const Offset(0, 1),
                blurRadius: 0,
              ),
            ]
          : [
              // 3D Bottom Bevel Edge
              BoxShadow(
                color: bottomBevelColor,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
              // Vibrant Ambient Glow
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                offset: const Offset(0, 6),
                blurRadius: 12,
              ),
            ],
    );
  }

  // --- Sci-Fi Cyber Card Decoration ---
  static BoxDecoration cyberCardDecoration({
    Color? borderColor,
    Color? glowColor,
    Color? backgroundColor,
    double borderRadius = 16,
  }) {
    final activeBorder = borderColor ?? surfaceBorder;
    final activeGlow = glowColor ?? activeBorder;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          backgroundColor ?? const Color(0xFF161E34),
          backgroundColor != null ? _darkenColor(backgroundColor, 0.1) : const Color(0xFF0E1324),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: activeBorder.withValues(alpha: 0.8),
        width: 1.8,
      ),
      boxShadow: [
        // Inner rim shadow effect
        BoxShadow(
          color: activeGlow.withValues(alpha: 0.22),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x60000000),
          blurRadius: 10,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  // --- Game Badge / Tag Decoration ---
  static BoxDecoration badgeDecoration({
    required Color color,
    double borderRadius = 8,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.10),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withValues(alpha: 0.7),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 6,
        ),
      ],
    );
  }

  static Color _darkenColor(Color c, double factor) {
    assert(factor >= 0 && factor <= 1);
    final hsl = HSLColor.fromColor(c);
    final darkenedHsl = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return darkenedHsl.toColor();
  }
}
