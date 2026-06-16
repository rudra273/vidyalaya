import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'core_providers.dart';

/// The second language shown alongside English in the Explore tools
/// (diagrams, timeline, math formulas).
enum RegionalLanguage {
  odia('or', 'Odia', 'ଓଡ଼ିଆ'),
  hindi('hi', 'Hindi', 'हिंदी');

  const RegionalLanguage(this.code, this.labelEn, this.labelNative);

  /// Persisted code: `'or'` or `'hi'`.
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

/// The active regional language for the Explore tools.
///
/// Resolves to, in order: an explicit switch the student made (persisted in
/// [UserPrefsRepository.getRegionalLanguage]); otherwise the profile's
/// preferred language (`hi` → Hindi, anything else → Odia, since English is
/// always shown anyway); otherwise Odia.
class RegionalLanguageNotifier extends Notifier<RegionalLanguage> {
  @override
  RegionalLanguage build() {
    final override = ref.read(userPrefsRepositoryProvider).getRegionalLanguage();
    if (override != null) {
      return RegionalLanguage.fromCode(override);
    }

    final profile = ref
        .watch(backendAccountCacheProvider)
        .profile
        .maybeWhen(data: (p) => p, orElse: () => null);
    if (profile?.preferredLanguage == 'hi') return RegionalLanguage.hindi;
    return RegionalLanguage.odia;
  }

  /// Switches the regional language and remembers the choice across sessions.
  void set(RegionalLanguage lang) {
    ref.read(userPrefsRepositoryProvider).setRegionalLanguage(lang.code);
    state = lang;
  }
}

final regionalLanguageProvider =
    NotifierProvider<RegionalLanguageNotifier, RegionalLanguage>(
      RegionalLanguageNotifier.new,
    );
