import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Duolingo-style "3D Palette" - Chunky Tactile aesthetic
/// Each color has a Base and Shade for the 3D button effect
class AppColors {
  // Primary (Blue) - Brand, Path Nodes, Info
  static const Color primary = Color(0xFF1CB0F6);
  static const Color primaryShade = Color(0xFF1899D6);

  // Success (Green) - Correct, Continue, Progress
  static const Color success = Color(0xFF58CC02);
  static const Color successShade = Color(0xFF46A302);

  // Attention (Yellow) - Review, Gold Levels, Stars
  static const Color attention = Color(0xFFFFC800);
  static const Color attentionShade = Color(0xFFE5A400);

  // Energy (Orange) - Streaks, Special Nodes
  static const Color energy = Color(0xFFFF9600);
  static const Color energyShade = Color(0xFFE58700);

  // Error (Red) - Mistakes, Try Again
  static const Color error = Color(0xFFFF4B4B);
  static const Color errorShade = Color(0xFFD33131);

  // Neutral (Gray) - Locked Levels, Troughs
  static const Color neutral = Color(0xFFE5E5E5);
  static const Color neutralShade = Color(0xFFAFB4BD);

  // Background & Surface
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors (Duolingo style)
  static const Color textPrimary = Color(0xFF4B4B4B);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textMuted = Color(0xFFAFAFAF);

  // Legacy compatibility aliases
  static const Color secondary = primary;
  static const Color accent1 = attention;
  static const Color accent2 = success;
  static const Color warning = attention;
  static const Color info = primary;
  static const Color disabled = neutral;

  // Game tile colors with their shades (for 3D effect)
  static const List<Color> tileColors = [
    Color(0xFF1CB0F6),  // Blue
    Color(0xFF58CC02),  // Green
    Color(0xFFFFC800),  // Yellow
    Color(0xFFFF9600),  // Orange
    Color(0xFFFF4B4B),  // Red
    Color(0xFFCE82FF),  // Purple
    Color(0xFF1CB0F6),  // Blue (repeat)
    Color(0xFF58CC02),  // Green (repeat)
    Color(0xFFFFC800),  // Yellow (repeat)
    Color(0xFFFF9600),  // Orange (repeat)
    Color(0xFFFF4B4B),  // Red (repeat)
    Color(0xFFCE82FF),  // Purple (repeat)
    Color(0xFF1CB0F6),  // Blue (repeat)
    Color(0xFF58CC02),  // Green (repeat)
  ];

  static const List<Color> tileShadeColors = [
    Color(0xFF1899D6),  // Blue shade
    Color(0xFF46A302),  // Green shade
    Color(0xFFE5A400),  // Yellow shade
    Color(0xFFE58700),  // Orange shade
    Color(0xFFD33131),  // Red shade
    Color(0xFFB066E0),  // Purple shade
    Color(0xFF1899D6),  // Blue shade (repeat)
    Color(0xFF46A302),  // Green shade (repeat)
    Color(0xFFE5A400),  // Yellow shade (repeat)
    Color(0xFFE58700),  // Orange shade (repeat)
    Color(0xFFD33131),  // Red shade (repeat)
    Color(0xFFB066E0),  // Purple shade (repeat)
    Color(0xFF1899D6),  // Blue shade (repeat)
    Color(0xFF46A302),  // Green shade (repeat)
  ];
}

/// Typography using Nunito (Duolingo-style)
class AppTypography {
  // Heading L - Unit Titles, Success Screen
  static TextStyle headingL = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // Body M - Instructions, Dialogues
  static TextStyle bodyM = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  // Button Text - "CONTINUE", "START"
  static TextStyle button = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  // Micro Text - Progress labels, tooltips
  static TextStyle micro = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );

  // Game-specific larger sizes
  static TextStyle gameTitle = GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle gamePrompt = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle gameLetter = GoogleFonts.nunito(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle answerOption = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: TextTheme(
      headlineLarge: AppTypography.headingL,
      headlineMedium: AppTypography.gameTitle,
      titleLarge: AppTypography.gamePrompt,
      bodyLarge: AppTypography.bodyM,
      labelLarge: AppTypography.button,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: AppTypography.button,
      ),
    ),
  );
}
