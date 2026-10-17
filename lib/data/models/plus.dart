import 'package:flutter/foundation.dart';

// ─── Plus status ───

/// Where a student's Plus request stands, as the server reports it.
enum PlusState { none, pending, declined, active, expired }

/// The screens a student can ask for Plus from. The server records which one,
/// and nothing else, so no free text ever leaves the device.
class PlusSource {
  const PlusSource._();

  static const profile = 'profile';
  static const aiQuestions = 'ai_questions';
  static const tests = 'tests';
  static const tutor = 'tutor';
  static const speaking = 'speaking';
}

/// The student's Plus card: whether they can ask, and where a request stands.
@immutable
class PlusStatus {
  final PlusState state;
  final String planKey;

  /// False when the server has switched Plus requests off.
  final bool available;
  final bool canRequest;
  final DateTime? requestedAt;
  final DateTime? decidedAt;

  /// When a declined student may ask again.
  final DateTime? canRequestAgainAt;

  /// When active Plus ends; null for no end date.
  final DateTime? plusExpiresAt;

  const PlusStatus({
    required this.state,
    required this.planKey,
    required this.available,
    required this.canRequest,
    this.requestedAt,
    this.decidedAt,
    this.canRequestAgainAt,
    this.plusExpiresAt,
  });

  factory PlusStatus.fromJson(Map<String, dynamic> json) {
    return PlusStatus(
      // A state this app does not know yet reads as "not asked", never a crash.
      state: PlusState.values.asNameMap()[json['state']] ?? PlusState.none,
      planKey: json['plan_key'] as String? ?? 'free',
      available: json['available'] as bool? ?? false,
      canRequest: json['can_request'] as bool? ?? false,
      requestedAt: _date(json['requested_at']),
      decidedAt: _date(json['decided_at']),
      canRequestAgainAt: _date(json['can_request_again_at']),
      plusExpiresAt: _date(json['plus_expires_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'state': state.name,
    'plan_key': planKey,
    'available': available,
    'can_request': canRequest,
    if (requestedAt != null) 'requested_at': requestedAt!.toIso8601String(),
    if (decidedAt != null) 'decided_at': decidedAt!.toIso8601String(),
    if (canRequestAgainAt != null)
      'can_request_again_at': canRequestAgainAt!.toIso8601String(),
    if (plusExpiresAt != null)
      'plus_expires_at': plusExpiresAt!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is PlusStatus && mapEquals(other.toJson(), toJson());

  @override
  int get hashCode => Object.hashAll(
    toJson().entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
