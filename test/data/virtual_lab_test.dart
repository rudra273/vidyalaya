import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/models/virtual_lab.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/data/models/class_range.dart';
import 'package:vidyalaya/data/models/regional_language.dart';

void main() {
  test('lab is recommended from Class 6', () {
    final lab = exploreToolClassRanges['virtual-lab']!;
    expect(lab.fitsAny({5}), isFalse);
    expect(lab.fitsAny({6}), isTrue);
    expect(lab.fitsAny({10}), isTrue);
    expect(lab.fitsAny({4, 6}), isTrue);
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

  test('lab content is translated but saved values stay English keys', () {
    for (final sample in ['lemon', 'water', 'soap']) {
      final obs = evaluateLab('indicator', {'sample': sample}, 'red');
      expect(obs.values['color'], isIn(['red', 'green', 'blue']));
      expect(obs.explanation.or, isNot(obs.explanation.en));
      expect(obs.explanation.hi, isNot(obs.explanation.en));
      expect(
        obs.explanation.or,
        contains(labWord(sample, RegionalLanguage.odia)),
      );
    }
    for (final key in [
      'off',
      'dim',
      'bright',
      'red',
      'green',
      'blue',
      'acidic',
      'neutral',
      'basic',
      'lemon',
      'water',
      'soap',
    ]) {
      for (final lang in RegionalLanguage.values) {
        expect(labWord(key, lang), isNot(key), reason: '$key/$lang');
      }
    }
    for (final text in labInstructions.values) {
      expect({text.en, text.or, text.hi}, hasLength(3));
    }
  });
}
