import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Calm Scholar palette ─────────────────────────────────────────────────
// Refined, academic, whitespace-led. Light + dark designed in parallel.

class AppColors {
  AppColors._();

  // ─── LIGHT ────────────────────────────────────────────────────────────
  static const Color paper = Color(0xFFECF1EC);
  static const Color paper2 = Color(0xFFE3EAE3);
  static const Color surface = Color(0xFFFBFCFA);
  static const Color surface2 = Color(0xFFF2F6F1);
  static const Color surface3 = Color(0xFFE7EEE7);

  static const Color ink = Color(0xFF16201B);
  static const Color ink2 = Color(0xFF4C564F);
  static const Color ink3 = Color(0xFF8A938C);

  static const Color hairline = Color(0xFFDCE6DC);
  static const Color hairline2 = Color(0xFFE6EDE5);

  // Claymorphism (light) — soft raised depth on accent surfaces
  static const Color clayShadow = Color(0xFFC9D4C9);
  static const Color clayHighlight = Color(0xFFFFFFFF);

  // Dark hero card (light theme)
  static const Color hero = Color(0xFF0F2A1F);
  static const Color hero2 = Color(0xFF143527);
  static const Color heroInk = Color(0xFFF2F6F2);
  static const Color heroInk2 = Color(0x9EF2F6F2);
  static const Color heroLine = Color(0x14FFFFFF);

  // Brand green
  static const Color green50 = Color(0xFFE9F4EE);
  static const Color green100 = Color(0xFFD3E8DC);
  static const Color green500 = Color(0xFF1F9F6A);
  static const Color green600 = Color(0xFF16855A);
  static const Color green700 = Color(0xFF0E6444);

  // Subject / tool hues (light)
  static const Color cAi = Color(0xFF16855A);
  static const Color cTutor = Color(0xFF6E56CF);
  static const Color cEnglish = Color(0xFF2F6FB5);
  static const Color cMaths = Color(0xFFC75B3F);
  static const Color cScience = Color(0xFF138B82);
  static const Color cOdia = Color(0xFFB9742B);
  static const Color cHindi = Color(0xFFC24D77);
  static const Color cSanskrit = Color(0xFF7A57C2);
  static const Color cSocial = Color(0xFFB5862B);
  static const Color cFormulas = Color(0xFF3D6CC9);
  static const Color cPeriodic = Color(0xFF9B4FB5);
  static const Color cDiagrams = Color(0xFF138B82);
  static const Color cTimeline = Color(0xFFB5862B);
  static const Color cCosmos = Color(0xFF3A66C9);
  static const Color cPython = Color(0xFF3E8E5A);

  // ─── DARK ─────────────────────────────────────────────────────────────
  static const Color paperDark = Color(0xFF0D1411);
  static const Color paper2Dark = Color(0xFF121A16);
  static const Color surfaceDark = Color(0xFF161F1A);
  static const Color surface2Dark = Color(0xFF1B2620);
  static const Color surface3Dark = Color(0xFF202D26);

  static const Color inkDark = Color(0xFFEBEEEA);
  static const Color ink2Dark = Color(0xFFA6B1AA);
  static const Color ink3Dark = Color(0xFF73807A);

  static const Color hairlineDark = Color(0xFF28342E);
  static const Color hairline2Dark = Color(0xFF202B25);

  // Claymorphism (dark)
  static const Color clayShadowDark = Color(0xFF070B09);
  static const Color clayHighlightDark = Color(0xFF1F2A23);

  static const Color heroDark = Color(0xFF14241C);
  static const Color hero2Dark = Color(0xFF102019);
  static const Color heroLineDark = Color(0x2978D2AA);

  static const Color green50Dark = Color(0xFF0F2A1F);
  static const Color green100Dark = Color(0xFF15392A);
  static const Color green500Dark = Color(0xFF36C188);
  static const Color green600Dark = Color(0xFF2BAE78);
  static const Color green700Dark = Color(0xFF239A69);
  static const Color onGreenDark = Color(0xFF06150D);

  // Subject hues (dark, brightened)
  static const Color cAiDark = Color(0xFF36C188);
  static const Color cTutorDark = Color(0xFF9D88EE);
  static const Color cEnglishDark = Color(0xFF5E9BDD);
  static const Color cMathsDark = Color(0xFFE8806A);
  static const Color cScienceDark = Color(0xFF3DB6AC);
  static const Color cOdiaDark = Color(0xFFDBA158);
  static const Color cHindiDark = Color(0xFFE27CA1);
  static const Color cSanskritDark = Color(0xFFA88DE8);
  static const Color cSocialDark = Color(0xFFD9B05B);
  static const Color cFormulasDark = Color(0xFF6E97E6);
  static const Color cPeriodicDark = Color(0xFFC684DA);
  static const Color cDiagramsDark = Color(0xFF3DB6AC);
  static const Color cTimelineDark = Color(0xFFD9B05B);
  static const Color cCosmosDark = Color(0xFF6E92E8);
  static const Color cPythonDark = Color(0xFF74C293);

  // ─── Subject color mapping ───────────────────────────────────────────
  static Color subjectColor(String subject, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    switch (subject.toLowerCase()) {
      case 'odia':
        return dark ? cOdiaDark : cOdia;
      case 'english':
        return dark ? cEnglishDark : cEnglish;
      case 'maths':
      case 'math':
        return dark ? cMathsDark : cMaths;
      case 'hindi':
        return dark ? cHindiDark : cHindi;
      case 'sanskrit':
        return dark ? cSanskritDark : cSanskrit;
      case 'science':
        return dark ? cScienceDark : cScience;
      case 'social':
      case 'social_science':
        return dark ? cSocialDark : cSocial;
      case 'skill':
        return dark ? cDiagramsDark : cDiagrams;
      case 'work':
        return dark ? cOdiaDark : cOdia;
      default:
        return dark ? green500Dark : green600;
    }
  }

  // ─── Back-compat shims (legacy code still references these) ──────────
  static const Color background = paper;
  static const Color navy = ink;
  static const Color teal = green600;
  static const Color tealLight = green50;
  static const Color textMuted = ink3;
  static final Color border = hairline;

  static const Color darkBackground = paperDark;
  static const Color darkSurface = surfaceDark;
  static const Color darkSurfaceElevated = surface2Dark;
  static const Color darkTextPrimary = inkDark;
  static const Color darkTextSecondary = ink2Dark;
  static const Color darkTeal = green500Dark;
  static const Color darkTealSurface = green50Dark;
  static final Color darkBorder = hairlineDark;

  static (Color bg, Color text) getSubjectColor(String subject) {
    final fg = subjectColor(subject, Brightness.light);
    return (Color.alphaBlend(fg.withValues(alpha: 0.14), surface), fg);
  }

  static (Color bg, Color text) getDarkSubjectColor(String subject) {
    final fg = subjectColor(subject, Brightness.dark);
    return (Color.alphaBlend(fg.withValues(alpha: 0.18), surfaceDark), fg);
  }

  static (Color bg, Color text) getSubjectColorFor(
    String subject,
    Brightness brightness,
  ) {
    final fg = subjectColor(subject, brightness);
    final surf = brightness == Brightness.dark ? surfaceDark : surface;
    return (Color.alphaBlend(fg.withValues(alpha: 0.15), surf), fg);
  }
}

// ─── Spacing & radii ──────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();
  static const double screenPadding = 20.0;
  static const double sectionGap = 26.0;
  static const double cardPad = 18.0;
  static const double stackGap = 12.0;
  static const double tilePad = 16.0;

  static const double cardRadius = 20.0;
  static const double tileRadius = 15.0;
  static const double chipRadius = 999.0;
  static const double inputRadius = 14.0;
}

// ─── Theme ────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color muted,
  }) {
    final serif = GoogleFonts.spectral();
    final body = GoogleFonts.hankenGrotesk();

    return TextTheme(
      // Spectral — serif display
      displayLarge: serif.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.3,
        height: 1.05,
      ),
      displayMedium: serif.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.3,
        height: 1.05,
      ),
      displaySmall: serif.copyWith(
        fontSize: 27,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.3,
        height: 1.1,
      ),
      headlineLarge: serif.copyWith(
        fontSize: 25,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.15,
      ),
      headlineMedium: serif.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      ),
      headlineSmall: serif.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      ),

      // Hanken Grotesk — body & UI
      titleLarge: body.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: body.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.45,
      ),
      bodyMedium: body.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.45,
      ),
      bodySmall: body.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.45,
      ),
      labelLarge: body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: body.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelSmall: body.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: muted,
        letterSpacing: 1.4,
      ),
    );
  }

  // ── Light ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      primary: AppColors.ink,
      muted: AppColors.ink3,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: const ColorScheme.light(
        primary: AppColors.green600,
        onPrimary: Colors.white,
        secondary: AppColors.green50,
        onSecondary: AppColors.green700,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.surface3,
        outline: AppColors.hairline,
        outlineVariant: AppColors.hairline2,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.green600,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        side: const BorderSide(color: AppColors.hairline),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.green600,
        unselectedItemColor: AppColors.ink3,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.green600;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.ink3, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green600,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.green600,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline2,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.hairline2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.hairline2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.green600, width: 1.4),
        ),
      ),
    );
  }

  // ── Dark ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(
      primary: AppColors.inkDark,
      muted: AppColors.ink3Dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.paperDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.green500Dark,
        onPrimary: AppColors.onGreenDark,
        secondary: AppColors.green50Dark,
        onSecondary: AppColors.green500Dark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.inkDark,
        surfaceContainerHighest: AppColors.surface3Dark,
        outline: AppColors.hairlineDark,
        outlineVariant: AppColors.hairline2Dark,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paperDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.inkDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.hairlineDark),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.green500Dark,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge
            ?.copyWith(color: AppColors.onGreenDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        side: const BorderSide(color: AppColors.hairlineDark),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.green500Dark,
        unselectedItemColor: AppColors.ink3Dark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.green500Dark;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onGreenDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.ink3Dark, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green500Dark,
          foregroundColor: AppColors.onGreenDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.onGreenDark,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.green500Dark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline2Dark,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface3Dark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.hairline2Dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.hairline2Dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.green500Dark,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
