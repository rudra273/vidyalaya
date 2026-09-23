import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/math/math_generators.dart';
import 'package:vidyalaya/data/math/math_models.dart';

// ─── Math generator invariants ────────────────────────────────────────────────
//
// The load-bearing property: a Flash Math chain must never show a student a
// fractional or negative intermediate value. Everything is seeded so a failure
// reproduces exactly.

/// Enough seeds to shake out rare operand choices without slowing the suite.
const _seeds = 400;

void main() {
  group('buildFlashChain', () {
    for (final preset in mathFlashPresets) {
      test('${preset.label}: every intermediate value is a clean integer', () {
        for (var seed = 0; seed < _seeds; seed++) {
          final chain = buildFlashChain(preset, random: Random(seed));

          expect(chain.start, greaterThan(0), reason: 'seed $seed');
          expect(chain.steps, hasLength(preset.steps), reason: 'seed $seed');

          var running = chain.start;
          for (var i = 0; i < chain.steps.length; i++) {
            final step = chain.steps[i];

            expect(step.operand, greaterThanOrEqualTo(1),
                reason: 'seed $seed step $i operand must be positive');

            // Division must be exact — this is the invariant that would bite a
            // student with a fractional running total.
            if (step.op == MathOp.div) {
              expect(running % step.operand, 0,
                  reason: 'seed $seed step $i: $running ÷ ${step.operand} '
                      'is not a whole number');
            }

            final expected = step.op.apply(running, step.operand);
            expect(step.runningValue, expected,
                reason: 'seed $seed step $i running value disagrees with op');

            running = step.runningValue;

            expect(running, greaterThanOrEqualTo(0),
                reason: 'seed $seed step $i went negative');
            expect(running, lessThanOrEqualTo(999),
                reason: 'seed $seed step $i exceeded the display range');
          }

          expect(chain.answer, running, reason: 'seed $seed final answer');
        }
      });

      test('${preset.label}: only uses its allowed operations', () {
        for (var seed = 0; seed < 60; seed++) {
          final chain = buildFlashChain(preset, random: Random(seed));
          for (final step in chain.steps) {
            // `+1` is the documented fallback when no allowed op has a legal
            // operand, so addition is always acceptable.
            final allowed = preset.allowedOps.contains(step.op) ||
                (step.op == MathOp.add && step.operand == 1);
            expect(allowed, isTrue,
                reason: 'seed $seed used ${step.op} outside the preset');
          }
        }
      });
    }

    test('valueAfter tracks the running total', () {
      final chain =
          buildFlashChain(mathFlashPresets.last, random: Random(7));
      expect(chain.valueAfter(0), chain.start);
      for (var i = 1; i <= chain.steps.length; i++) {
        expect(chain.valueAfter(i), chain.steps[i - 1].runningValue);
      }
    });

    test('no checkpoints unless asked', () {
      for (final preset in mathFlashPresets) {
        final chain = buildFlashChain(preset, random: Random(3));
        expect(chain.checkpointIndices, isEmpty);
        expect(chain.promptCount, 1);
      }
    });

    test('checkpoints land mid-chain and never on the final step', () {
      for (final preset in mathFlashPresets) {
        for (var seed = 0; seed < 40; seed++) {
          final chain = buildFlashChain(
            preset,
            withCheckpoints: true,
            random: Random(seed),
          );
          final last = chain.steps.length - 1;
          for (final idx in chain.checkpointIndices) {
            expect(idx, greaterThanOrEqualTo(0));
            expect(idx, lessThan(last),
                reason: '${preset.label}: checkpoint on the final step '
                    'would duplicate the main prompt');
          }
          // Ascending and distinct.
          final sorted = [...chain.checkpointIndices]..sort();
          expect(chain.checkpointIndices, sorted);
          expect(chain.checkpointIndices.toSet().length,
              chain.checkpointIndices.length);
          expect(chain.promptCount, chain.checkpointIndices.length + 1);
        }
      }
    });

    test('Easy has too few steps for a checkpoint; Hard gets them', () {
      // Easy is 3 steps, so the "every 3rd, excluding the last" rule yields
      // nothing — a deliberate consequence, asserted so it can't regress
      // silently into asking a checkpoint that is also the final answer.
      final easy = buildFlashChain(
        mathFlashPresets.first,
        withCheckpoints: true,
        random: Random(1),
      );
      expect(easy.checkpointIndices, isEmpty);

      final hard = buildFlashChain(
        mathFlashPresets.last,
        withCheckpoints: true,
        random: Random(1),
      );
      expect(hard.checkpointIndices, isNotEmpty);
    });
  });

  group('custom presets', () {
    test('preset timings are 3s / 2s / 1s', () {
      expect(mathFlashPresetById('easy').secondsPerStep, 3.0);
      expect(mathFlashPresetById('medium').secondsPerStep, 2.0);
      expect(mathFlashPresetById('hard').secondsPerStep, 1.0);
    });

    test('stepDuration follows secondsPerStep, including half seconds', () {
      final p = mathFlashPresets.first.copyWith(secondsPerStep: 1.5);
      expect(p.stepDuration, const Duration(milliseconds: 1500));
      expect(
        mathFlashPresets.first.copyWith(secondsPerStep: 0.5).stepDuration,
        const Duration(milliseconds: 500),
      );
    });

    test('copyWith re-derives the blurb so it cannot go stale', () {
      final custom = mathFlashPresets.first.copyWith(
        id: flashCustomId,
        label: 'Custom',
        steps: 9,
        secondsPerStep: 2.5,
        allowedOps: const [MathOp.add, MathOp.mul],
      );
      expect(custom.steps, 9);
      expect(custom.secondsPerStep, 2.5);
      expect(custom.blurb, '9 steps · 2.5s · + ×');
      expect(custom.id, flashCustomId);
    });

    test('describeFlashSettings drops the trailing zero on whole seconds', () {
      expect(
        describeFlashSettings(3, 3.0, const [MathOp.add]),
        '3 steps · 3s · +',
      );
      expect(
        describeFlashSettings(4, 1.5, const [MathOp.add, MathOp.div]),
        '4 steps · 1.5s · + ÷',
      );
    });

    test('chains built from custom settings hold the same invariants', () {
      // Sweep the whole slider range the custom sheet exposes, including the
      // division-heavy combinations most likely to strand the generator.
      for (var steps = flashMinSteps; steps <= flashMaxSteps; steps++) {
        for (final ops in const [
          [MathOp.add],
          [MathOp.sub],
          [MathOp.mul],
          [MathOp.add, MathOp.div],
          [MathOp.mul, MathOp.div],
          [MathOp.add, MathOp.sub, MathOp.mul, MathOp.div],
        ]) {
          final preset = mathFlashPresets.first.copyWith(
            id: flashCustomId,
            steps: steps,
            allowedOps: ops,
          );
          for (var seed = 0; seed < 25; seed++) {
            final chain = buildFlashChain(preset, random: Random(seed));
            expect(chain.steps, hasLength(steps),
                reason: 'steps=$steps ops=$ops seed=$seed');

            var running = chain.start;
            for (final step in chain.steps) {
              if (step.op == MathOp.div) {
                expect(running % step.operand, 0,
                    reason: 'steps=$steps ops=$ops seed=$seed: '
                        '$running ÷ ${step.operand}');
              }
              expect(step.runningValue, step.op.apply(running, step.operand));
              running = step.runningValue;
              expect(running, greaterThanOrEqualTo(0));
              expect(running, lessThanOrEqualTo(999));
            }
            expect(chain.answer, running);
          }
        }
      }
    });

    test('checkpoints on a long custom chain never hit the final step', () {
      final preset = mathFlashPresets.last.copyWith(
        id: flashCustomId,
        steps: flashMaxSteps,
      );
      for (var seed = 0; seed < 30; seed++) {
        final chain = buildFlashChain(
          preset,
          withCheckpoints: true,
          random: Random(seed),
        );
        expect(chain.checkpointIndices, isNotEmpty);
        for (final idx in chain.checkpointIndices) {
          expect(idx, lessThan(chain.steps.length - 1));
        }
      }
    });
  });

  group('buildQuizQuestions', () {
    test('produces well-formed questions for every class', () {
      for (var level = 1; level <= 8; level++) {
        for (var seed = 0; seed < 40; seed++) {
          final questions = buildQuizQuestions(
            classLevel: level,
            count: 10,
            random: Random(seed),
          );
          expect(questions, hasLength(10));

          for (final q in questions) {
            expect(q.prompt, isNotEmpty);
            expect(q.explanation, isNotEmpty);
            expect(q.options, hasLength(4),
                reason: 'class $level seed $seed: ${q.prompt}');
            expect(q.correctIndex, greaterThanOrEqualTo(0));
            expect(q.correctIndex, lessThan(q.options.length));

            // Distractors must be distinct, or two taps would both be "right".
            expect(q.options.toSet().length, q.options.length,
                reason: 'duplicate options in "${q.prompt}": ${q.options}');
          }
        }
      }
    });

    test('clamps out-of-range class levels instead of throwing', () {
      expect(buildQuizQuestions(classLevel: 0, random: Random(1)), hasLength(10));
      expect(
          buildQuizQuestions(classLevel: 99, random: Random(1)), hasLength(10));
    });

    test('lower classes stay on addition and subtraction', () {
      final questions =
          buildQuizQuestions(classLevel: 1, count: 40, random: Random(5));
      for (final q in questions) {
        expect(q.prompt.contains('×') || q.prompt.contains('÷'), isFalse,
            reason: 'class 1 should not see × or ÷: ${q.prompt}');
      }
    });
  });

  group('buildDrillFacts', () {
    test('every fact is self-consistent and non-negative', () {
      for (var seed = 0; seed < 100; seed++) {
        final facts = buildDrillFacts(
          ops: MathOp.values,
          count: 40,
          random: Random(seed),
        );
        expect(facts, hasLength(40));
        for (final f in facts) {
          expect(f.op.apply(f.left, f.right), f.answer,
              reason: 'seed $seed: ${f.prompt} claims ${f.answer}');
          expect(f.answer, greaterThanOrEqualTo(0), reason: 'seed $seed');
          expect(f.right, isNot(0), reason: 'never divide by zero');
          if (f.op == MathOp.div) {
            expect(f.left % f.right, 0, reason: 'seed $seed: ${f.prompt}');
          }
        }
      }
    });

    test('respects the requested operator set', () {
      final facts = buildDrillFacts(
        ops: const [MathOp.mul],
        count: 30,
        random: Random(2),
      );
      expect(facts.every((f) => f.op == MathOp.mul), isTrue);
    });

    test('an empty operator set falls back to all four', () {
      final facts =
          buildDrillFacts(ops: const [], count: 20, random: Random(4));
      expect(facts, hasLength(20));
    });
  });

  group('buildTableQuestions', () {
    test('covers each multiplicand exactly once', () {
      for (var table = 1; table <= 20; table++) {
        final facts = buildTableQuestions(table, random: Random(table));
        expect(facts, hasLength(12));
        final rights = facts.map((f) => f.right).toList()..sort();
        expect(rights, List.generate(12, (i) => i + 1));
        for (final f in facts) {
          expect(f.left, table);
          expect(f.answer, table * f.right);
        }
      }
    });
  });

  group('buildNumberSenseRound', () {
    test('questions are well-formed with a valid correct index', () {
      for (var level = 1; level <= 8; level++) {
        for (var seed = 0; seed < 40; seed++) {
          final round = buildNumberSenseRound(
            count: 10,
            classLevel: level,
            random: Random(seed),
          );
          expect(round, hasLength(10));
          for (final q in round) {
            expect(q.prompt, isNotEmpty);
            expect(q.options.length, greaterThanOrEqualTo(2));
            expect(q.correctIndex, greaterThanOrEqualTo(0),
                reason: 'class $level seed $seed: ${q.prompt} / ${q.options}');
            expect(q.correctIndex, lessThan(q.options.length),
                reason: 'class $level seed $seed: ${q.prompt} / ${q.options}');
            expect(q.options.toSet().length, q.options.length,
                reason: 'duplicate options: ${q.prompt} ${q.options}');
          }
        }
      }
    });

    test('odd/even and prime answers are actually correct', () {
      for (var seed = 0; seed < 200; seed++) {
        final round =
            buildNumberSenseRound(count: 8, classLevel: 8, random: Random(seed));
        for (final q in round) {
          if (q.kind == NumberSenseKind.oddEven) {
            final n = int.parse(
                RegExp(r'\d+').firstMatch(q.prompt)!.group(0)!);
            expect(q.options[q.correctIndex], n.isEven ? 'Even' : 'Odd');
          }
          if (q.kind == NumberSenseKind.prime) {
            final n = int.parse(
                RegExp(r'\d+').firstMatch(q.prompt)!.group(0)!);
            expect(q.options[q.correctIndex],
                isPrime(n) ? 'Prime' : 'Not prime');
          }
        }
      }
    });

    test('lower classes only get the simpler kinds', () {
      final round =
          buildNumberSenseRound(count: 40, classLevel: 1, random: Random(9));
      for (final q in round) {
        expect(
          const [
            NumberSenseKind.larger,
            NumberSenseKind.smaller,
            NumberSenseKind.oddEven,
          ].contains(q.kind),
          isTrue,
          reason: 'class 1 got ${q.kind}',
        );
      }
    });
  });

  group('isPrime', () {
    test('matches known values', () {
      const primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47];
      for (var n = 0; n <= 50; n++) {
        expect(isPrime(n), primes.contains(n), reason: 'isPrime($n)');
      }
    });
  });

  group('Fraction', () {
    test('always stores lowest terms with a positive denominator', () {
      expect(Fraction(6, 8).display, '3/4');
      expect(Fraction(10, 5).display, '2/1');
      expect(Fraction(3, -4).display, '-3/4');
      expect(Fraction(0, 7).display, '0/1');
    });

    test('rejects a zero denominator', () {
      expect(() => Fraction(1, 0), throwsArgumentError);
    });

    test('raw keeps the unsimplified form for simplify exercises', () {
      final raw = Fraction.raw(6, 8);
      expect(raw.display, '6/8');
      expect(raw.simplified.display, '3/4');
      expect(raw.isSimplified, isFalse);
      expect(Fraction(3, 4).isSimplified, isTrue);
    });

    test('adds and subtracts exactly', () {
      expect((Fraction(1, 2) + Fraction(1, 3)).display, '5/6');
      expect((Fraction(1, 2) + Fraction(1, 2)).display, '1/1');
      expect((Fraction(3, 4) - Fraction(1, 4)).display, '1/2');
    });

    test('equality is by simplified value', () {
      expect(Fraction(2, 4), Fraction(1, 2));
      expect(Fraction(2, 4).hashCode, Fraction(1, 2).hashCode);
    });
  });

  group('buildFractionTasks', () {
    test('tasks are well-formed and the stated answer is in the options', () {
      for (var seed = 0; seed < 120; seed++) {
        final tasks = buildFractionTasks(count: 9, random: Random(seed));
        expect(tasks, hasLength(9));

        for (final t in tasks) {
          expect(t.options.length, greaterThanOrEqualTo(2),
              reason: 'seed $seed ${t.kind}');
          expect(t.correctIndex, greaterThanOrEqualTo(0),
              reason: 'seed $seed ${t.kind}: ${t.options}');
          expect(t.correctIndex, lessThan(t.options.length),
              reason: 'seed $seed ${t.kind}: ${t.options}');
          expect(t.options.toSet().length, t.options.length,
              reason: 'seed $seed duplicate options: ${t.options}');
          expect(t.explanation, isNotEmpty);

          // Compare and add both show two bars; simplify shows one.
          if (t.kind == FractionTaskKind.simplify) {
            expect(t.right, isNull);
          } else {
            expect(t.right, isNotNull, reason: 'seed $seed ${t.kind}');
          }
        }
      }
    });

    test('simplify answers really are the simplified left fraction', () {
      for (var seed = 0; seed < 120; seed++) {
        final tasks = buildFractionTasks(count: 9, random: Random(seed));
        for (final t in tasks.where(
            (t) => t.kind == FractionTaskKind.simplify)) {
          expect(t.options[t.correctIndex], t.left.simplified.display,
              reason: 'seed $seed: ${t.left.display}');
        }
      }
    });

    test('compare picks the genuinely larger fraction', () {
      for (var seed = 0; seed < 120; seed++) {
        final tasks = buildFractionTasks(count: 9, random: Random(seed));
        for (final t
            in tasks.where((t) => t.kind == FractionTaskKind.compare)) {
          final chosen = t.options[t.correctIndex];
          final other = t.options.firstWhere((o) => o != chosen,
              orElse: () => chosen);
          final chosenVal = _parse(chosen).value;
          final otherVal = _parse(other).value;
          expect(chosenVal, greaterThanOrEqualTo(otherVal),
              reason: 'seed $seed picked $chosen over $other');
        }
      }
    });

    test('addition answers are exact', () {
      for (var seed = 0; seed < 120; seed++) {
        final tasks = buildFractionTasks(count: 9, random: Random(seed));
        for (final t in tasks.where((t) => t.kind == FractionTaskKind.add)) {
          final expected =
              (t.left.simplified + t.right!.simplified).display;
          expect(t.options[t.correctIndex], expected,
              reason: 'seed $seed: ${t.left.display} + ${t.right!.display}');
        }
      }
    });
  });
}

Fraction _parse(String display) {
  final parts = display.split('/');
  return Fraction(int.parse(parts[0]), int.parse(parts[1]));
}
