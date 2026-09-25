import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/lab/lab_catalog.dart';
import 'package:vidyalaya/data/lab/lab_rules.dart';
import 'package:vidyalaya/data/lab/lab_words.dart';
import 'package:vidyalaya/data/models/class_range.dart';
import 'package:vidyalaya/data/models/regional_language.dart';
import 'package:vidyalaya/data/models/virtual_lab.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';

LabObservation run(String lab, Map<String, Object> controls) =>
    evaluateLab(lab, controls);

void main() {
  test('lab is recommended from Class 5', () {
    final lab = exploreToolClassRanges['virtual-lab']!;
    expect(lab.fitsAny({4}), isFalse);
    expect(lab.fitsAny({5}), isTrue);
    expect(lab.fitsAny({10}), isTrue);
    expect(lab.fitsAny({4, 6}), isTrue);
  });

  test('catalog has four physics and two chemistry experiments', () {
    expect(labExperiments.map((l) => l.id).toSet(), hasLength(6));
    expect(
      labExperiments.where((l) => l.subject == LabSubject.physics),
      hasLength(4),
    );
    expect(
      labExperiments.where((l) => l.subject == LabSubject.chemistry),
      hasLength(2),
    );
  });

  group('every experiment', () {
    for (final lab in labExperiments) {
      test('${lab.id}: deterministic, valid and fully reachable', () {
        for (final entry in lab.defaultControls.entries) {
          expect(lab.controls[entry.key], contains(entry.value));
        }
        expect(lab.defaultControls.keys.toSet(), lab.controls.keys.toSet());

        final reached = <String>{};
        for (final controls in lab.allControlSets) {
          final a = run(lab.id, controls);
          final b = run(lab.id, Map.of(controls));
          expect(a.values, b.values, reason: '$controls');
          expect(a.outcome, b.outcome);
          expect(lab.outcomes, contains(a.outcome), reason: '$controls');
          expect(a.matches(a.outcome), isTrue);
          final e = a.explanation;
          expect({e.en, e.or, e.hi}, hasLength(3), reason: '$controls');
          reached.add(a.outcome);
        }
        // Every prediction on offer can actually happen.
        expect(reached, lab.outcomes.toSet());
      });
    }
  });

  test('circuit: open switch is off, more cells push more current', () {
    final open = run('circuit', {
      'cells': 3,
      'resistance_ohms': 3,
      'closed': false,
    });
    expect(open.values['current_a'], 0);
    expect(open.outcome, 'off');
    final weak = run('circuit', {
      'cells': 1,
      'resistance_ohms': 9,
      'closed': true,
    });
    final strong = run('circuit', {
      'cells': 3,
      'resistance_ohms': 9,
      'closed': true,
    });
    expect(weak.outcome, 'dim');
    expect(strong.outcome, 'bright');
    expect(
      strong.values['current_a'] as double,
      greaterThan(weak.values['current_a'] as double),
    );
  });

  test('pendulum: length sets the pace, mass does not', () {
    Map<String, Object> at(int length, int mass) =>
        run('pendulum', {'length_cm': length, 'mass_g': mass}).values;
    expect(at(25, 50)['speed'], 'fast');
    expect(at(50, 50)['speed'], 'medium');
    expect(at(100, 50)['speed'], 'slow');
    expect(at(100, 50)['period_s'], closeTo(2.01, 0.01));
    for (final length in [25, 50, 100]) {
      expect(at(length, 50), at(length, 200));
    }
  });

  test('mirror: angle of reflection equals angle of incidence', () {
    for (final angle in [30, 45, 60]) {
      final obs = run('mirror', {'angle_deg': angle});
      expect(obs.values['reflection_deg'], angle);
    }
    expect(run('mirror', {'angle_deg': 30}).outcome, 'high');
    expect(run('mirror', {'angle_deg': 60}).outcome, 'low');
  });

  test('float: an egg sinks in water but floats in salt water', () {
    expect(run('float', {'object': 'egg', 'liquid': 'water'}).outcome, 'sink');
    expect(
      run('float', {'object': 'egg', 'liquid': 'salt_water'}).outcome,
      'float',
    );
    expect(
      run('float', {'object': 'iron', 'liquid': 'salt_water'}).outcome,
      'sink',
    );
    final wood = run('float', {'object': 'wood', 'liquid': 'water'});
    expect(wood.outcome, 'float');
    expect(wood.values['underwater_pct'], 60);
  });

  test('indicator: colour and nature follow pH', () {
    final lemon = run('indicator', {'sample': 'lemon'}).values;
    expect(lemon, {'color': 'red', 'approx_ph': 2, 'nature': 'acidic'});
    final water = run('indicator', {'sample': 'water'}).values;
    expect(water['color'], 'green');
    expect(water['nature'], 'neutral');
    final lime = run('indicator', {'sample': 'limewater'}).values;
    expect(lime['color'], 'violet');
    expect(lime['nature'], 'basic');
  });

  test('fizz: the ingredient that runs out first limits the gas', () {
    final obs = run('fizz', {'soda_spoons': 3, 'vinegar_cups': 1});
    expect(obs.values['gas_units'], 1);
    expect(obs.values['leftover'], 'baking_soda');
    expect(obs.outcome, 'small');
    final even = run('fizz', {'soda_spoons': 3, 'vinegar_cups': 3});
    expect(even.values['leftover'], 'none');
    expect(even.outcome, 'big');
  });

  test('every key shown on screen has Odia and Hindi words', () {
    final keys = <String>{
      for (final lab in labExperiments) ...[
        ...lab.outcomes,
        for (final values in lab.controls.values) ...values.whereType<String>(),
        for (final controls in lab.allControlSets)
          ...evaluateLab(lab.id, controls).values.values.whereType<String>(),
      ],
    };
    for (final key in keys) {
      final word = labWords[key];
      expect(word, isNotNull, reason: key);
      expect(word!.or, isNot(word.en), reason: key);
      expect(word.hi, isNot(word.en), reason: key);
      for (final lang in RegionalLanguage.values) {
        expect(labWord(key, lang), isNotEmpty);
      }
    }
    for (final lab in labExperiments) {
      final q = lab.question;
      expect({q.en, q.or, q.hi}, hasLength(3), reason: lab.id);
    }
  });

  test('odia explanation uses the odia sample word', () {
    for (final sample in ['lemon', 'water', 'soap']) {
      final obs = run('indicator', {'sample': sample});
      expect(
        obs.explanation.or,
        contains(labWord(sample, RegionalLanguage.odia)),
      );
    }
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
    expect(attempt.labVersion, kLabVersion);
    expect(attempt.correct, isTrue);
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
    expect(restored.correct, isTrue);
    expect(repository.getLabAttempts(), hasLength(1));
  });

  test('attempts saved by the version 1 lab still load', () {
    final old = LabAttempt.fromJson({
      'client_attempt_id': '00000000-0000-4000-8000-000000000000',
      'lab_id': 'circuit',
      'lab_version': 1,
      'prediction': 'dim',
      'controls': {'cells': 1, 'resistance_ohms': 9, 'closed': true},
      'observation': {'voltage_v': 1.5, 'current_a': 0.17, 'brightness': 'dim'},
      'correct': true,
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    expect(old.labVersion, 1);
    expect(old.correct, isTrue);
  });
}
