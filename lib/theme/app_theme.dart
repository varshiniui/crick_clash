import 'package:flutter/material.dart';

class AppTheme {
  // ── CSK Brand Colors ──────────────────────────────────────
  static const Color cskYellow     = Color(0xFFFDB913);
  static const Color cskBlue       = Color(0xFF1A237E);
  static const Color cskLightBlue  = Color(0xFF3949AB);

  // ── Background & Surface ──────────────────────────────────
  static const Color darkBg        = Color(0xFF0D0D1A);
  static const Color cardBg        = Color(0xFF1C1C2E);
  static const Color cardBorder    = Color(0xFFFDB913);

  // ── Text ─────────────────────────────────────────────────
  static const Color textLight     = Color(0xFFFFFDE7);
  static const Color textGrey      = Color(0xFF9E9E9E);
  static const Color white         = Colors.white;

  // ── Feedback ─────────────────────────────────────────────
  static const Color correctGreen  = Color(0xFF00E676);
  static const Color wrongRed      = Color(0xFFFF1744);

  // ── Full Theme ────────────────────────────────────────────
  static ThemeData get cskTheme {
    return ThemeData(
      scaffoldBackgroundColor: darkBg,
      primaryColor: cskYellow,

      colorScheme: const ColorScheme.dark(
        primary:   cskYellow,
        secondary: cskLightBlue,
        surface:   cardBg,
      ),

      fontFamily: 'Roboto',

      // ── Text Theme ───────────────────────────────────────
      textTheme: const TextTheme(
        // Big title (Home screen headline)
        displayLarge: TextStyle(
          color:      cskYellow,
          fontSize:   36,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
        // Screen sub-titles
        titleLarge: TextStyle(
          color:      textLight,
          fontSize:   22,
          fontWeight: FontWeight.w700,
        ),
        // Card labels, difficulty titles
        titleMedium: TextStyle(
          color:      textLight,
          fontSize:   18,
          fontWeight: FontWeight.w600,
        ),
        // Body / question text
        bodyLarge: TextStyle(
          color:      textLight,
          fontSize:   16,
          fontWeight: FontWeight.w400,
          height:     1.5,
        ),
        // Hints, captions
        bodyMedium: TextStyle(
          color:      textGrey,
          fontSize:   14,
        ),
        // Button labels
        labelLarge: TextStyle(
          color:      cskBlue,
          fontSize:   18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),

      // ── Elevated Button ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cskYellow,
          foregroundColor: cskBlue,
          textStyle: const TextStyle(
            fontSize:      18,
            fontWeight:    FontWeight.bold,
            letterSpacing: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation:   6,
          shadowColor: Color(0xFFFDB913), // cskYellow glow
        ),
      ),

      // ── Input Field ───────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cskYellow, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x80FDB913), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cskYellow, width: 2.5),
        ),
        hintStyle:  const TextStyle(color: textGrey),
        labelStyle: const TextStyle(color: cskYellow),
      ),
    );
  }
}