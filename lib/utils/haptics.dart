import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/haptic_provider.dart';

/// Central gate for haptic feedback. Every call reads [hapticsEnabledProvider]
/// and no-ops when the user has turned haptics off in Settings — so the toggle
/// is honoured everywhere from a single place. Call sites use these named
/// intents (e.g. `Haptics.selection(ref)`) rather than [HapticFeedback]
/// directly.
class Haptics {
  Haptics._();

  static bool _on(WidgetRef ref) => ref.read(hapticsEnabledProvider);

  /// Light tap — buttons, card taps, minor confirmations.
  static void light(WidgetRef ref) {
    if (_on(ref)) HapticFeedback.lightImpact();
  }

  /// Selection change — tab switches, chips, segmented controls.
  static void selection(WidgetRef ref) {
    if (_on(ref)) HapticFeedback.selectionClick();
  }

  /// Medium impact — meaningful state changes (bookmark, progress, save).
  static void medium(WidgetRef ref) {
    if (_on(ref)) HapticFeedback.mediumImpact();
  }

  /// Heavy impact — errors and failures.
  static void error(WidgetRef ref) {
    if (_on(ref)) HapticFeedback.heavyImpact();
  }
}
