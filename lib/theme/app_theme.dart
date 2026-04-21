import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFF8F4ED);
  static const surface = Color(0xFFFDF9F2);
  static const primary = Color(0xFF1B3A5C);
  static const gold = Color(0xFFC9A84C);
  static const goldLight = Color(0xFFE8D5A3);
  static const text = Color(0xFF2C2416);
  static const textMuted = Color(0xFF8B7355);
  static const divider = Color(0xFFD4C9B0);

  static const moodHappy = Color(0xFFE8A838);
  static const moodNormal = Color(0xFF6B9EBF);
  static const moodSad = Color(0xFF7B8FA6);
  static const moodIdea = Color(0xFF5B9E6B);
  static const moodAlert = Color(0xFFBF5B5B);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = GoogleFonts.notoSansJpTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      textTheme: base.copyWith(
        titleLarge: GoogleFonts.notoSerifJp(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.notoSerifJp(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.notoSansJp(color: AppColors.text),
        bodyMedium: GoogleFonts.notoSansJp(color: AppColors.text),
        bodySmall: GoogleFonts.notoSansJp(color: AppColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerifJp(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      dividerColor: AppColors.divider,
      cardColor: AppColors.surface,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.divider),
      ),
    );
  }
}
