import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GarnishColors {
  static const cream = Color(0xFFF5EFE6);
  static const creamDark = Color(0xFFEDE5D8);
  static const orange = Color(0xFFE88A2D);
  static const orangeLight = Color(0xFFF0A84E);
  static const green = Color(0xFF3A7D44);
  static const greenLight = Color(0xFF5A9E65);
  static const textDark = Color(0xFF1A1A1A);
  static const textMid = Color(0xFF555555);
  static const textLight = Color(0xFF888888);
  static const white = Color(0xFFFFFFFF);
  static const cardBg = Color(0xFFFFFFFF);
  static const border = Color(0xFFDDD5C8);
  static const tagBg = Color(0xFFFFF0DC);
  static const tagText = Color(0xFFB86A10);
  static const greenTagBg = Color(0xFFE6F4E9);
  static const greenTagText = Color(0xFF2D6B38);
}

class GarnishTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: GarnishColors.cream,
      colorScheme: const ColorScheme.light(
        primary: GarnishColors.orange,
        secondary: GarnishColors.green,
        surface: GarnishColors.cardBg,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: GarnishColors.textDark,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: GarnishColors.textDark,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GarnishColors.textDark,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          color: GarnishColors.textMid,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: GarnishColors.textMid,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: GarnishColors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GarnishColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: GarnishColors.textDark,
        ),
        iconTheme: const IconThemeData(color: GarnishColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: GarnishColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GarnishColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GarnishColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GarnishColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GarnishColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GarnishColors.orange, width: 2),
        ),
        labelStyle: GoogleFonts.dmSans(color: GarnishColors.textLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      useMaterial3: true,
    );
  }
}
