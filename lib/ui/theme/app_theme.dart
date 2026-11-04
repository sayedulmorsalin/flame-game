import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Light Reddish Gray Silver Palette ---
  /// Main app canvas: a light, luxurious silver with a subtle warm reddish-rose undertone
  static const Color background = Color(0xFFF4EFF2);

  /// Elevated card surface: crisp white for high contrast and modern luxury
  static const Color surface = Color(0xFFFFFFFF);

  /// Inner container / card chip / pill background: warm silver-rose tint
  static const Color surfaceLight = Color(0xFFF9F5F7);

  /// Secondary surface for tracks, inactive tabs, and chips
  static const Color surfaceSecondary = Color(0xFFEBE3E8);

  /// Polished silver-reddish border
  static const Color surfaceBorder = Color(0xFFDCD2D8);

  /// Subtle divider border
  static const Color surfaceBorderSubtle = Color(0xFFEFE8ED);

  /// Polished silver/platinum metallic accents
  static const Color silverMetallic = Color(0xFF7B727A);
  static const Color silverLight = Color(0xFFE4DCE2);

  // --- Rich Metallic & Accent Colors ---
  /// Deep rich ruby crimson - represents luxury, prestige, and power
  static const Color richRuby = Color(0xFFB81D36);
  static const Color crimsonRose = Color(0xFFC92A42);
  static const Color roseGold = Color(0xFFBD7B89);

  /// Pure bullion gold - high contrast on light theme
  static const Color bitcoinGold = Color(0xFFC78417);
  static const Color goldLight = Color(0xFFDF9820);

  /// Deep tech sapphire / cyan - crisp and readable on light backgrounds
  static const Color cyanNeon = Color(0xFF0284C7);

  /// Rich emerald green for mining yield, positive changes, active status
  static const Color greenHash = Color(0xFF098A55);

  /// Regal royal amethyst purple for epic miners and prestige
  static const Color purpleQuantum = Color(0xFF7C3AED);

  /// Vibrant flame orange for frenzy and power alerts
  static const Color orangeFrenzy = Color(0xFFDE5500);

  /// Crimson alert red for overheat and critical warnings
  static const Color redOverheat = Color(0xFFD32F2F);

  // --- Professional Typography Hierarchy ---
  /// Crisp deep charcoal with warm undertones for maximum readability
  static const Color textPrimary = Color(0xFF1E161C);

  /// Rich slate reddish-gray for descriptions and secondary text
  static const Color textSecondary = Color(0xFF5A4F57);

  /// Warm silver-gray for subtle hints, timestamps, and muted labels
  static const Color textMuted = Color(0xFF887D85);

  // --- Gradients ---
  static const LinearGradient silverMetallicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0EAEF)],
  );

  static const LinearGradient rubyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC92A42), Color(0xFFA5142C)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE4A22E), Color(0xFFB8750E)],
  );

  static const LinearGradient frenzyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE65100), Color(0xFFC92A42)],
  );

  // --- ThemeData ---
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final rajdhaniTextTheme = GoogleFonts.rajdhaniTextTheme(baseTextTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: richRuby,
      cardColor: surface,
      dividerColor: surfaceBorder,
      textTheme: rajdhaniTextTheme,
      colorScheme: const ColorScheme.light(
        primary: richRuby,
        secondary: bitcoinGold,
        surface: surface,
        error: redOverheat,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: richRuby,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Alias darkTheme to lightTheme to ensure unified light reddish gray silver theme
  static ThemeData get darkTheme => lightTheme;

  // --- Rich Professional Card Decoration ---
  static BoxDecoration cyberCardDecoration({
    Color? borderColor,
    Color? glowColor,
    Color? backgroundColor,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? surfaceBorder,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor != null
              ? glowColor.withValues(alpha: 0.18)
              : const Color(0x103A1C28),
          blurRadius: glowColor != null ? 14 : 10,
          spreadRadius: glowColor != null ? 1 : 0,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
