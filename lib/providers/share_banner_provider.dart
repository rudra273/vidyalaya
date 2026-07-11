import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

/// SharedPreferences key for the Home share-banner dismissal.
const _shareBannerDismissedKey = 'share_banner_dismissed';

/// Whether the "Share & Feedback" banner on Home has been dismissed.
/// Persisted locally; share/feedback stay reachable from Settings.
class ShareBannerDismissedNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_shareBannerDismissedKey) ?? false;
  }

  void dismiss() {
    state = true;
    ref.read(sharedPreferencesProvider).setBool(_shareBannerDismissedKey, true);
  }
}

final shareBannerDismissedProvider =
    NotifierProvider<ShareBannerDismissedNotifier, bool>(
  ShareBannerDismissedNotifier.new,
);
