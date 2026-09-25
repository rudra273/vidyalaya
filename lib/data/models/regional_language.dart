// Plain Dart so pure-data code (math generators, models) can use it without
// pulling in Flutter or Riverpod. Re-exported by regional_language_provider.

/// The selected content language in the Explore tools.
enum RegionalLanguage {
  english('en', 'English', 'English'),
  odia('or', 'Odia', 'ଓଡ଼ିଆ'),
  hindi('hi', 'Hindi', 'हिंदी');

  const RegionalLanguage(this.code, this.labelEn, this.labelNative);

  /// Persisted code: `'en'`, `'or'`, or `'hi'`.
  final String code;

  /// English name, e.g. for accessibility.
  final String labelEn;

  /// Native-script label shown in the switcher chip.
  final String labelNative;

  static RegionalLanguage fromCode(String? code) {
    return RegionalLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => RegionalLanguage.odia,
    );
  }
}
