import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF07090E);
  static const Color surface = Color(0xFF101726);
  static const Color surfaceLight = Color(0xFF192237);
  static const Color surfaceBorder = Color(0xFF243048);

  static const Color bitcoinGold = Color(0xFFF7931A);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color cyanNeon = Color(0xFF00F2FE);
  static const Color greenHash = Color(0xFF00E676);
  static const Color purpleQuantum = Color(0xFFA855F7);
  static const Color orangeFrenzy = Color(0xFFFF9100);
  static const Color redOverheat = Color(0xFFFF5252);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: bitcoinGold,
      cardColor: surface,
      textTheme: GoogleFonts.rajdhaniTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: bitcoinGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static BoxDecoration cyberCardDecoration({Color? borderColor, Color? glowColor}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: borderColor ?? surfaceBorder,
        width: 1.5,
      ),
      boxShadow: glowColor != null
          ? [
              BoxShadow(
                color: glowColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }
}
