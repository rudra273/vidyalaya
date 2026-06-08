import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

/// SharedPreferences key for the claymorphism toggle.
const _clayEnabledKey = 'clay_enabled';

/// Whether the soft "claymorphism" depth is enabled. Persisted locally.
/// Defaults to ON; older students can turn it off for a flat, plain look.
class ClayEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_clayEnabledKey) ?? true;
  }

  void set(bool enabled) {
    state = enabled;
    ref.read(sharedPreferencesProvider).setBool(_clayEnabledKey, enabled);
  }

  void toggle() => set(!state);
}

final clayEnabledProvider = NotifierProvider<ClayEnabledNotifier, bool>(
  ClayEnabledNotifier.new,
);
