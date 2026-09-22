import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/models/virtual_lab.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/providers/lab_provider.dart';

void main() {
  test('lab beta is visible only for its mapped board and class', () {
    expect(
      labAvailableForSelection(
        enabled: true,
        board: 'scert_odisha',
        selectedClasses: {7, 8},
      ),
      isTrue,
    );
    expect(
      labAvailableForSelection(
        enabled: true,
        board: 'scert_odisha',
        selectedClasses: {8},
      ),
      isFalse,
    );
    expect(
      labAvailableForSelection(
        enabled: false,
        board: 'scert_odisha',
        selectedClasses: {7},
      ),
      isFalse,
    );
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
  });

  test('device history preserves an attempt across restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = UserPrefsRepository(prefs);
    final attempt = LabAttempt.create(
      labId: 'indicator',
      prediction: 'blue',
      controls: {'sample': 'soap'},
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
    expect(restored.synced, isFalse);
    await repository.saveLabAttempt(restored.copyWith(synced: true));
    expect(repository.getLabAttempts(), hasLength(1));
    expect(repository.getLabAttempts().single.synced, isTrue);
  });
}
