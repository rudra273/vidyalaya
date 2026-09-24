import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed/seed_data.dart';
import 'auth_provider.dart';
import 'core_providers.dart';
import 'user_selection_provider.dart';

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

/// The active content language for the Explore tools.
///
/// Resolves to, in order: an explicit switch the student made (persisted in
/// [UserPrefsRepository.getRegionalLanguage]); otherwise the profile's
/// preferred language; otherwise the locally-picked preferred language
/// (signed-out students save their Profile choice into `preferred_language`);
/// otherwise the selected board's default language; otherwise Odia.
class RegionalLanguageNotifier extends Notifier<RegionalLanguage> {
  @override
  RegionalLanguage build() {
    // Watch the board unconditionally so a board change always re-resolves
    // the language, even while an override is set (setBoard clears it).
    final boardId = ref.watch(userBoardProvider);

    final prefs = ref.read(userPrefsRepositoryProvider);

    final override = prefs.getRegionalLanguage();
    if (override != null) {
      return RegionalLanguage.fromCode(override);
    }

    final profile = ref
        .watch(backendAccountCacheProvider)
        .profile
        .maybeWhen(data: (p) => p, orElse: () => null);
    if (profile?.preferredLanguage != null) {
      return RegionalLanguage.fromCode(profile!.preferredLanguage);
    }

    // Locally-picked preferred language for signed-out students.
    final local = prefs.getPreferredLanguage();
    if (local != null) return RegionalLanguage.fromCode(local);

    // fromCode falls back to Odia for unknown/future board ids.
    return RegionalLanguage.fromCode(
      getBoardById(boardId)?.defaultLanguageCode,
    );
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
