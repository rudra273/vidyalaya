import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/models/plus.dart';

void main() {
  test('reads everything the server sends', () {
    final status = PlusStatus.fromJson({
      'state': 'declined',
      'plan_key': 'free',
      'available': true,
      'can_request': false,
      'requested_at': '2026-11-02T10:00:00Z',
      'decided_at': '2026-11-03T10:00:00Z',
      'can_request_again_at': '2026-12-03T10:00:00Z',
      'plus_expires_at': '2026-12-10T10:00:00Z',
    });

    expect(status.state, PlusState.declined);
    expect(status.planKey, 'free');
    expect(status.available, isTrue);
    expect(status.canRequest, isFalse);
    expect(status.requestedAt, DateTime.parse('2026-11-02T10:00:00Z'));
    expect(status.canRequestAgainAt, DateTime.parse('2026-12-03T10:00:00Z'));
    expect(status.plusExpiresAt, DateTime.parse('2026-12-10T10:00:00Z'));
  });

  test('every state the server can send is understood', () {
    for (final state in PlusState.values) {
      expect(PlusStatus.fromJson({'state': state.name}).state, state);
    }
  });

  test('a state this app does not know reads as not asked, without crashing', () {
    final status = PlusStatus.fromJson({
      'state': 'suspended_by_aliens',
      'can_request': true,
      'available': true,
    });

    expect(status.state, PlusState.none);
  });

  test('missing fields fall back to the cautious answer', () {
    final status = PlusStatus.fromJson({});

    expect(status.state, PlusState.none);
    expect(status.planKey, 'free');
    expect(status.available, isFalse, reason: 'unknown means closed');
    expect(status.canRequest, isFalse);
    expect(status.requestedAt, isNull);
  });

  test('survives the cache: JSON round trip keeps equality', () {
    final status = PlusStatus.fromJson({
      'state': 'active',
      'plan_key': 'plus',
      'available': true,
      'can_request': false,
      'plus_expires_at': '2026-12-10T10:00:00Z',
    });

    expect(PlusStatus.fromJson(status.toJson()), status);
    expect(PlusStatus.fromJson(status.toJson()).hashCode, status.hashCode);
    expect(status.toJson().containsKey('requested_at'), isFalse);
  });

  test('different statuses are not equal', () {
    const a = PlusStatus(
      state: PlusState.none,
      planKey: 'free',
      available: true,
      canRequest: true,
    );
    const b = PlusStatus(
      state: PlusState.pending,
      planKey: 'free',
      available: true,
      canRequest: false,
    );

    expect(a, isNot(b));
  });

  test('a request names a screen and nothing else a student could type', () {
    expect(PlusSource.profile, 'profile');
    expect(PlusSource.aiQuestions, 'ai_questions');
    expect(PlusSource.tests, 'tests');
    expect(PlusSource.tutor, 'tutor');
    expect(PlusSource.speaking, 'speaking');
  });
}
