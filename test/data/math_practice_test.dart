import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/math/line_graph.dart';
import 'package:vidyalaya/data/math/math_practice.dart';
import 'package:vidyalaya/data/math/math_tools_data.dart';
import 'package:vidyalaya/providers/regional_language_provider.dart';

void _checkRound(List<MathPracticeQuestion> round) {
  for (final q in round) {
    expect(q.options.length, 4, reason: q.prompt.en);
    expect(q.options.toSet().length, 4, reason: 'distinct: ${q.prompt.en}');
    expect(q.correctIndex, inInclusiveRange(0, 3));
    for (final lang in RegionalLanguage.values) {
      expect(q.prompt.of(lang).trim(), isNotEmpty);
      expect(q.explanation.of(lang).trim(), isNotEmpty);
    }
  }
}

void main() {
  group('clock & money', () {
    test('every class level builds valid rounds', () {
      for (var level = 1; level <= 8; level++) {
        for (var seed = 0; seed < 25; seed++) {
          _checkRound(
            buildClockMoneyRound(
              count: 10,
              classLevel: level,
              random: Random(seed),
            ),
          );
        }
      }
    });

    test('the clock answer matches the drawn time', () {
      for (var seed = 0; seed < 40; seed++) {
        for (final q in buildClockMoneyRound(random: Random(seed))) {
          final c = q.clock;
          if (c == null) continue;
          final shown = '${c.hour}:${c.minute.toString().padLeft(2, '0')}';
          expect(q.options[q.correctIndex], shown);
        }
      }
    });

    test('classes 1–2 only show o’clock and half past', () {
      for (var seed = 0; seed < 40; seed++) {
        for (final q in buildClockMoneyRound(
          classLevel: 1,
          random: Random(seed),
        )) {
          final c = q.clock;
          if (c != null) expect(c.minute, anyOf(0, 30));
        }
      }
    });
  });

  group('word problems', () {
    test('every class level builds valid rounds', () {
      for (var level = 1; level <= 8; level++) {
        for (var seed = 0; seed < 25; seed++) {
          _checkRound(
            buildWordProblemRound(
              count: 10,
              classLevel: level,
              random: Random(seed),
            ),
          );
        }
      }
    });

    test('the keyed answer equals the working in the explanation', () {
      for (var seed = 0; seed < 60; seed++) {
        for (final q in buildWordProblemRound(
          classLevel: 5,
          random: Random(seed),
        )) {
          final last = q.explanation.en.split('= ').last.replaceAll('₹', '');
          expect(q.options[q.correctIndex].replaceAll('₹', ''), last);
        }
      }
    });

    test('multiplication and shop problems wait for later classes', () {
      final early = [
        for (var s = 0; s < 30; s++)
          ...buildWordProblemRound(classLevel: 2, random: Random(s)),
      ];
      expect(early.map((q) => q.label).toSet(), {
        'Addition story',
        'Subtraction story',
      });
    });
  });

  group('graph plotter', () {
    test('equations read naturally', () {
      expect(const GraphLine(2, 3).equation, 'y = 2x + 3');
      expect(const GraphLine(-1, 0).equation, 'y = −x');
      expect(const GraphLine(1, -4).equation, 'y = x − 4');
      expect(const GraphLine(0, 5).equation, 'y = 5');
      expect(const GraphLine(0.5, 1.5).equation, 'y = 0.5x + 1.5');
    });

    test('intercepts', () {
      expect(const GraphLine(2, -6).xIntercept, 3);
      expect(const GraphLine(0, 4).xIntercept, isNull);
    });

    test('two lines cross, run parallel or coincide', () {
      final cross = meet(const GraphLine(1, 0), const GraphLine(-1, 4));
      expect(cross, isA<LinesCross>());
      expect((cross as LinesCross).x, 2);
      expect(cross.y, 2);
      expect(
        meet(const GraphLine(2, 1), const GraphLine(2, 5)),
        isA<LinesParallel>(),
      );
      expect(
        meet(const GraphLine(2, 1), const GraphLine(2, 1)),
        isA<LinesCoincide>(),
      );
    });
  });

  test('tool ids are unique and routed under /learn/math', () {
    final ids = mathTools.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final id in ['math-clock-money', 'math-word-problems', 'math-graph']) {
      expect(mathToolById(id), isNotNull, reason: id);
    }
  });
}
