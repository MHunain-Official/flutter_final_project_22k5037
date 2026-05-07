import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Design tokens — all colors and typography in one file
class AppColors {
  AppColors._();

  // Brand palette (from design spec)
  static const Color primary = Color(0xFF6C53FF);
  static const Color primaryLight = Color(0xFF8B75FF);
  static const Color accent = Color(0xFF2C9E5E);
  static const Color danger = Color(0xFFF95B5B);

  // Light theme surface colors
  static const Color bgLight = Color(0xFFF5F6FA);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;

  // Dark theme surface colors
  static const Color bgDark = Color(0xFF0D0D1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  // Text
  static const Color textDark = Color(0xFF1C1C2E);
  static const Color textLight = Color(0xFFF5F6FA);
  static const Color textMuted = Color(0xFF9E9EBF);

  // Favorites heart red
  static const Color heart = Color(0xFFF95B5B);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      cardColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textLight : AppColors.textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textLight : AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: isDark ? AppColors.textLight : AppColors.textDark,
        ),
        bodySmall: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textLight : AppColors.textDark,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textLight : AppColors.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.primary,
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
