import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colour Palette ─────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface = Color(0xFFF4F3EE);
  static const Color navy = Color(0xFF1A1F2E);

  // Accent (primary)
  static const Color teal = Color(0xFF1D9E75);
  static const Color tealLight = Color(0xFFE1F5EE);

  // Subject colour coding
  static const Color amberLight = Color(0xFFFAEEDA);
  static const Color amberDark = Color(0xFF854F0B);
  static const Color blueLight = Color(0xFFE6F1FB);
  static const Color blueDark = Color(0xFF185FA5);
  static const Color coralLight = Color(0xFFFAECE7);
  static const Color coralDark = Color(0xFF993C1D);
  static const Color greenLight = Color(0xFFEAF3DE);
  static const Color greenDark = Color(0xFF3B6D11);
  static const Color pinkLight = Color(0xFFFBEAF0);
  static const Color pinkDark = Color(0xFF993556);
  // Science gets a unique purple tone
  static const Color purpleLight = Color(0xFFF0EAFA);
  static const Color purpleDark = Color(0xFF5B3DAA);

  // Muted
  static const Color textMuted = Color(0xFF6B7080);
  static final Color border = const Color(0xFF1A1F2E).withValues(alpha: 0.09);

  // Subject colour map
  static const Map<String, (Color, Color)> subjectColors = {
    'odia': (amberLight, amberDark),
    'english': (blueLight, blueDark),
    'maths': (coralLight, coralDark),
    'social': (greenLight, greenDark),
    'hindi': (pinkLight, pinkDark),
    'sanskrit': (pinkLight, pinkDark),
    'science': (purpleLight, purpleDark),
  };

  static (Color bg, Color text) getSubjectColor(String subject) {
    return subjectColors[subject.toLowerCase()] ?? (surface, navy);
  }
}

// ─── Spacing ────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();
  static const double screenPadding = 20.0;
  static const double cardRadius = 16.0;
  static const double chipRadius = 20.0;
}

// ─── Theme ──────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme() {
    final displayFont = GoogleFonts.fraunces();
    final bodyFont = GoogleFonts.dmSans();

    return TextTheme(
      // Fraunces — headings & display
      displayLarge: displayFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      ),
      displayMedium: displayFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      ),
      displaySmall: displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.3,
      ),
      headlineLarge: displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
      headlineMedium: displayFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      headlineSmall: displayFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),

      // DM Sans — body & UI
      titleLarge: bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      titleMedium: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      titleSmall: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.navy,
      ),
      bodyLarge: bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.navy,
      ),
      bodyMedium: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.navy,
      ),
      bodySmall: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      labelLarge: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.navy,
      ),
      labelMedium: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
      labelSmall: bodyFont.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.teal,
        onPrimary: Colors.white,
        secondary: AppColors.tealLight,
        onSecondary: AppColors.teal,
        surface: AppColors.surface,
        onSurface: AppColors.navy,
        outline: AppColors.border,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge,
        iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.tealLight,
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        side: BorderSide(color: AppColors.border),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.teal;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: AppColors.textMuted, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
      ),
    );
  }
}
