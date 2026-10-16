import 'package:flutter/foundation.dart';

// ─── Rollout switches ───

/// Server-controlled feature switches for the signed-in student.
///
/// The backend resolves staged rollouts per student, so the app only reads
/// the final on/off value. A switch the server does not mention keeps the
/// default the caller passes to [isEnabled].
@immutable
class RolloutSwitches {
  final Map<String, bool> _switches;

  const RolloutSwitches([this._switches = const {}]);

  /// What the app uses before the first response and when the server is
  /// unreachable: every switch falls back to its caller's default.
  static const defaults = RolloutSwitches();

  factory RolloutSwitches.fromJson(Map<String, dynamic> json) {
    final raw = json['switches'];
    if (raw is! Map) {
      throw const FormatException('Rollout switches response has no switches.');
    }
    return RolloutSwitches({
      for (final entry in raw.entries)
        if (entry.key is String && entry.value is bool)
          entry.key as String: entry.value as bool,
    });
  }

  Map<String, dynamic> toJson() => {'switches': _switches};

  bool isEnabled(String name, {required bool defaultValue}) =>
      _switches[name] ?? defaultValue;

  @override
  bool operator ==(Object other) =>
      other is RolloutSwitches && mapEquals(other._switches, _switches);

  @override
  int get hashCode =>
      Object.hashAll(_switches.entries.map((e) => Object.hash(e.key, e.value)));
}
