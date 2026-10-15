import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/programming/interpreter/py_runner.dart';
import 'package:vidyalaya/data/programming/python_course_data.dart';
import 'package:vidyalaya/data/programming/python_more_data.dart';
import 'package:vidyalaya/data/programming/python_models.dart';

// ─── Content-integrity tests ──────────────────────────────────────────────────
//
// The whole point: lesson content can never claim an output the real
// interpreter doesn't produce. Every CodeBlock (and every ChallengeBlock that
// declares an expectedOutput) is executed and checked.

void main() {
  group('code blocks produce their stated output', () {
    for (final chapter in pythonChapters) {
      for (final lesson in chapter.lessons) {
        for (var i = 0; i < lesson.blocks.length; i++) {
          final block = lesson.blocks[i];
          if (block is CodeBlock) {
            test('${lesson.id} block $i', () async {
              final r = await PyRunner.run(
                block.code,
                presetInputs: block.presetInputs,
              );
              expect(
                r.error,
                isNull,
                reason: 'errored: ${r.error}\ncode:\n${block.code}',
              );
              expect(
                r.output,
                block.expectedOutput,
                reason: 'output mismatch for ${lesson.id} block $i',
              );
            });
          }
        }
      }
    }
  });

  // A challenge's starter code is what the student edits, so it may not yet
  // produce expectedOutput. We only require that the starter always runs
  // without errors (never ship broken starter code to a kid).
  group('challenge starter code runs without errors', () {
    for (final chapter in pythonChapters) {
      for (final lesson in chapter.lessons) {
        for (var i = 0; i < lesson.blocks.length; i++) {
          final block = lesson.blocks[i];
          if (block is ChallengeBlock) {
            test('${lesson.id} challenge $i', () async {
              final r = await PyRunner.run(
                block.starterCode,
                presetInputs: block.presetInputs,
              );
              expect(
                r.error,
                isNull,
                reason:
                    'starter errored: ${r.error}'
                    '\ncode:\n${block.starterCode}',
              );
            });
          }
        }
      }
    }
  });

  group('structure integrity', () {
    test('lesson ids are unique', () {
      final ids = <String>[];
      for (final c in pythonChapters) {
        for (final l in c.lessons) {
          ids.add(l.id);
        }
      }
      expect(ids.toSet().length, ids.length, reason: 'duplicate lesson id');
    });

    test('chapter ids are unique', () {
      final ids = pythonChapters.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate chapter id');
    });

    test('every quiz question is well-formed', () {
      for (final c in pythonChapters) {
        for (final q in c.quiz) {
          expect(
            q.options.length,
            4,
            reason: 'quiz in ${c.id} must have 4 options',
          );
          expect(
            q.correctIndex,
            inInclusiveRange(0, 3),
            reason: 'correctIndex out of range in ${c.id}',
          );
        }
      }
    });

    test('every chapter has lessons and a quiz', () {
      for (final c in pythonChapters) {
        expect(c.lessons, isNotEmpty, reason: '${c.id} has no lessons');
        expect(c.quiz, isNotEmpty, reason: '${c.id} has no quiz');
      }
    });
  });

  group('predict-the-output quizzes', () {
    test('every chapter has at least one', () {
      for (final c in pythonChapters) {
        expect(
          c.quiz.any((q) => q.type == PyQuizType.predictOutput),
          isTrue,
          reason: '${c.id} has no predict-the-output question',
        );
      }
    });

    // The older chapters summarise multi-line output in their answers, so the
    // exact-match check covers the chapters whose answers were generated.
    for (final chapter in pythonMoreChapters) {
      for (var i = 0; i < chapter.quiz.length; i++) {
        final q = chapter.quiz[i];
        if (q.type != PyQuizType.predictOutput || q.code == null) continue;
        test(
          '${chapter.id} quiz $i: the marked answer is what the code prints',
          () async {
            final r = await PyRunner.run(q.code!);
            expect(r.error, isNull, reason: 'errored: ${r.error}');
            expect(
              r.output.trim(),
              q.options[q.correctIndex].trim(),
              reason: 'wrong answer key for:\n${q.code}',
            );
          },
        );
      }
    }
  });
}
