import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

/// SharedPreferences key for the haptic feedback toggle.
const _hapticsEnabledKey = 'haptics_enabled';

/// Whether subtle haptic feedback is enabled. Persisted locally.
/// Defaults to ON; users who dislike vibrations can turn it off in Settings.
class HapticsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_hapticsEnabledKey) ?? true;
  }

  void set(bool enabled) {
    state = enabled;
    ref.read(sharedPreferencesProvider).setBool(_hapticsEnabledKey, enabled);
  }

  void toggle() => set(!state);
}

final hapticsEnabledProvider = NotifierProvider<HapticsEnabledNotifier, bool>(
  HapticsEnabledNotifier.new,
);
