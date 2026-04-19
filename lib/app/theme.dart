import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colour Palette ─────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ─── Light Mode ─────────────────────────────────────────────────────────

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
  // Science — purple
  static const Color purpleLight = Color(0xFFF0EAFA);
  static const Color purpleDark = Color(0xFF5B3DAA);
  // Skill — cyan
  static const Color cyanLight = Color(0xFFE0F7FA);
  static const Color cyanDark = Color(0xFF006D7A);
  // Work — orange
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color orangeDark = Color(0xFFB45309);

  // Muted
  static const Color textMuted = Color(0xFF6B7080);
  static final Color border = const Color(0xFF1A1F2E).withValues(alpha: 0.09);

  // ─── Dark Mode ──────────────────────────────────────────────────────────

  // Background — deep charcoal with a subtle warm undertone
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkSurfaceElevated = Color(0xFF232835);

  // Text
  static const Color darkTextPrimary = Color(0xFFF0F1F5);
  static const Color darkTextSecondary = Color(0xFF9EA3B5);

  // Accent — vibrant teal, slightly brighter for dark mode contrast
  static const Color darkTeal = Color(0xFF2BD89E);
  static const Color darkTealSurface = Color(0xFF142E24);

  // Border
  static final Color darkBorder = Colors.white.withValues(alpha: 0.08);

  // Subject colours — vibrant neon-ish tones for dark backgrounds
  static const Color darkAmberBg = Color(0xFF2B2114);
  static const Color darkAmberText = Color(0xFFF5B756);
  static const Color darkBlueBg = Color(0xFF14202E);
  static const Color darkBlueText = Color(0xFF5AA8F2);
  static const Color darkCoralBg = Color(0xFF2B1A14);
  static const Color darkCoralText = Color(0xFFFF8A65);
  static const Color darkGreenBg = Color(0xFF172514);
  static const Color darkGreenText = Color(0xFF7BCF4A);
  static const Color darkPinkBg = Color(0xFF2B1420);
  static const Color darkPinkText = Color(0xFFF06EA0);
  static const Color darkPurpleBg = Color(0xFF1F1630);
  static const Color darkPurpleText = Color(0xFFA78BFA);

  // Dark skill/work tones
  static const Color darkCyanBg = Color(0xFF0E2428);
  static const Color darkCyanText = Color(0xFF4DD9E8);
  static const Color darkOrangeBg = Color(0xFF2B1E10);
  static const Color darkOrangeText = Color(0xFFFBBA43);

  // Subject colour map (light)
  static const Map<String, (Color, Color)> subjectColors = {
    'odia': (amberLight, amberDark),
    'english': (blueLight, blueDark),
    'maths': (coralLight, coralDark),
    'social': (greenLight, greenDark),
    'social_science': (greenLight, greenDark),
    'hindi': (pinkLight, pinkDark),
    'sanskrit': (pinkLight, pinkDark),
    'science': (purpleLight, purpleDark),
    'skill': (cyanLight, cyanDark),
    'work': (orangeLight, orangeDark),
  };

  // Subject colour map (dark)
  static const Map<String, (Color, Color)> darkSubjectColors = {
    'odia': (darkAmberBg, darkAmberText),
    'english': (darkBlueBg, darkBlueText),
    'maths': (darkCoralBg, darkCoralText),
    'social': (darkGreenBg, darkGreenText),
    'social_science': (darkGreenBg, darkGreenText),
    'hindi': (darkPinkBg, darkPinkText),
    'sanskrit': (darkPinkBg, darkPinkText),
    'science': (darkPurpleBg, darkPurpleText),
    'skill': (darkCyanBg, darkCyanText),
    'work': (darkOrangeBg, darkOrangeText),
  };

  static (Color bg, Color text) getSubjectColor(String subject) {
    return subjectColors[subject.toLowerCase()] ?? (surface, navy);
  }

  static (Color bg, Color text) getDarkSubjectColor(String subject) {
    return darkSubjectColors[subject.toLowerCase()] ??
        (darkSurface, darkTextPrimary);
  }

  /// Returns subject colors appropriate for the current brightness.
  static (Color bg, Color text) getSubjectColorFor(
    String subject,
    Brightness brightness,
  ) {
    if (brightness == Brightness.dark) {
      return getDarkSubjectColor(subject);
    }
    return getSubjectColor(subject);
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

  // ─── Light TextTheme ─────────────────────────────────────────────────

  static TextTheme _buildTextTheme({required Color primary, required Color muted}) {
    final displayFont = GoogleFonts.fraunces();
    final bodyFont = GoogleFonts.dmSans();

    return TextTheme(
      // Fraunces — headings & display
      displayLarge: displayFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      ),
      displayMedium: displayFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      ),
      displaySmall: displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.3,
      ),
      headlineLarge: displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: displayFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: displayFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),

      // DM Sans — body & UI
      titleLarge: bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      labelMedium: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelSmall: bodyFont.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Light Theme
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      primary: AppColors.navy,
      muted: AppColors.textMuted,
    );

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
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Dark Theme — Vibrant & Premium
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(
      primary: AppColors.darkTextPrimary,
      muted: AppColors.darkTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkTeal,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.darkTealSurface,
        onSecondary: AppColors.darkTeal,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.darkTealSurface,
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        side: BorderSide(color: AppColors.darkBorder),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkTeal,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.darkTeal;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.darkBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: AppColors.darkTextSecondary, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.darkBackground,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkTeal,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
    );
  }
}
