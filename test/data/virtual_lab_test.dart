import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/models/virtual_lab.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/providers/lab_provider.dart';

void main() {
  test('lab is visible for Classes 7 through 12 on every board', () {
    expect(labAvailableForSelection({6}), isFalse);
    expect(labAvailableForSelection({7}), isTrue);
    expect(labAvailableForSelection({10}), isTrue);
    expect(labAvailableForSelection({12}), isTrue);
    expect(labAvailableForSelection({13}), isFalse);
    expect(labAvailableForSelection({6, 7}), isTrue);
  });

  test('circuit and indicator observations are deterministic', () {
    final open = evaluateLab('circuit', {
      'cells': 3,
      'resistance_ohms': 3,
      'closed': false,
    }, 'off');
    expect(open.values['current_a'], 0);
    expect(open.correct, isTrue);

    final acidic = evaluateLab('indicator', {'sample': 'lemon'}, 'red');
    expect(acidic.values['color'], 'red');
    expect(acidic.values['approx_ph'], 2);
    expect(acidic.correct, isTrue);
    final basic = evaluateLab('indicator', {'sample': 'soap'}, 'blue');
    expect(basic.values['nature'], 'basic');
    final weak = evaluateLab('circuit', {
      'cells': 1,
      'resistance_ohms': 9,
      'closed': true,
    }, 'dim');
    final stronger = evaluateLab('circuit', {
      'cells': 3,
      'resistance_ohms': 9,
      'closed': true,
    }, 'dim');
    expect(
      stronger.values['current_a'] as double,
      greaterThan(weak.values['current_a'] as double),
    );
  });

  test('device history preserves an attempt across restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = UserPrefsRepository(prefs);
    final attempt = LabAttempt.create(
      labId: 'indicator',
      prediction: 'blue',
      controls: {'sample': 'soap'},
      clientSessionId: newLabSessionId(),
    );
    expect(
      attempt.clientAttemptId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );

    await repository.saveLabAttempt(attempt);
    final restored = UserPrefsRepository(prefs).getLabAttempts().single;
    expect(restored.clientAttemptId, attempt.clientAttemptId);
    expect(restored.clientSessionId, attempt.clientSessionId);
    expect(repository.getLabAttempts(), hasLength(1));
  });
}
