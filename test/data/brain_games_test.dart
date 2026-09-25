import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/games/daily_challenge.dart';
import 'package:vidyalaya/data/games/element_match_data.dart';
import 'package:vidyalaya/data/games/sudoku_generator.dart';
import 'package:vidyalaya/data/games/word_builder_data.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';

// ─── Brain games invariants ───────────────────────────────────────────────────
//
// Seeded throughout so a failure reproduces exactly.

void main() {
  group('generateSudoku', () {
    for (final size in SudokuSize.values) {
      test('${size.label}: valid solution, consistent givens, unique', () {
        for (var seed = 0; seed < 15; seed++) {
          final p = generateSudoku(size, random: Random(seed));
          final n = size.size;

          expect(p.solution, hasLength(n * n));
          expect(
            sudokuConflicts(size, p.solution),
            isEmpty,
            reason: 'seed $seed',
          );
          expect(p.solution.every((v) => v >= 1 && v <= n), isTrue);

          for (var i = 0; i < p.givens.length; i++) {
            if (p.givens[i] != 0) {
              expect(p.givens[i], p.solution[i], reason: 'seed $seed cell $i');
            }
          }
          expect(p.emptyCount, greaterThan(0), reason: 'seed $seed');
          expect(countSudokuSolutions(size, p.givens), 1, reason: 'seed $seed');
        }
      });
    }

    test('same seed gives the same puzzle', () {
      final a = generateSudoku(SudokuSize.nine, random: Random(42));
      final b = generateSudoku(SudokuSize.nine, random: Random(42));
      expect(a.givens, b.givens);
    });
  });

  test('sudokuConflicts flags row, column and box clashes', () {
    final grid = List<int>.filled(16, 0);
    grid[0] = 1;
    grid[5] = 1; // same 2×2 box as cell 0
    expect(sudokuConflicts(SudokuSize.four, grid), {0, 5});
  });

  group('buildWordPuzzles', () {
    for (final level in WordLevel.values) {
      test('${level.label}: distinct, in range, scrambled', () {
        final puzzles = buildWordPuzzles(level, random: Random(1));
        expect(puzzles, hasLength(10));
        expect(puzzles.map((p) => p.answer).toSet(), hasLength(10));
        for (final p in puzzles) {
          expect(p.answer.length, inInclusiveRange(level.minLen, level.maxLen));
          expect(p.letters.join(), isNot(p.answer));
          expect(
            (p.letters.toList()..sort()).join(),
            (p.answer.split('')..sort()).join(),
          );
        }
      });
    }
  });

  test('buildElementDeck holds each element twice, symbol and name', () {
    for (final level in ElementLevel.values) {
      final deck = buildElementDeck(level, random: Random(3));
      expect(deck, hasLength(level.pairs * 2));
      final ids = deck.map((c) => c.pairId).toSet();
      expect(ids, hasLength(level.pairs));
      for (final id in ids) {
        final pair = deck.where((c) => c.pairId == id).toList();
        expect(pair.map((c) => c.isSymbol).toSet(), {true, false});
        expect(id, lessThanOrEqualTo(level.maxAtomicNumber));
      }
    }
  });

  group('dailyChallengeFor', () {
    test('is stable within a day', () {
      final a = dailyChallengeFor(DateTime(2026, 9, 25, 8), classNo: 7);
      final b = dailyChallengeFor(DateTime(2026, 9, 25, 22), classNo: 7);
      expect(a.kind, b.kind);
      expect(a.seed, b.seed);
    });

    test('leaves Element Match out below class 6', () {
      for (var d = 0; d < 30; d++) {
        final c = dailyChallengeFor(DateTime(2026, 1, 1 + d), classNo: 3);
        expect(c.kind, isNot(GameKind.elementMatch));
      }
    });

    test('rotates through every game for older students', () {
      final kinds = {
        for (var d = 0; d < 3; d++)
          dailyChallengeFor(DateTime(2026, 1, 1 + d), classNo: 9).kind,
      };
      expect(kinds, GameKind.values.toSet());
    });
  });

  group('UserPrefsRepository brain games', () {
    late UserPrefsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = UserPrefsRepository(await SharedPreferences.getInstance());
    });

    test('keeps the best score in the right direction', () async {
      await repo.recordGameScore('words', 40);
      await repo.recordGameScore('words', 30);
      await repo.recordGameScore('sudoku', 200, lowerIsBetter: true);
      await repo.recordGameScore('sudoku', 150, lowerIsBetter: true);
      await repo.recordGameScore('sudoku', 180, lowerIsBetter: true);
      expect(repo.getGameBestScores(), {'words': 40, 'sudoku': 150});
    });

    test('daily challenge counts once per day', () async {
      expect(repo.isDailyChallengeDoneToday(), isFalse);
      await repo.recordDailyChallengeDone();
      await repo.recordDailyChallengeDone();
      expect(repo.isDailyChallengeDoneToday(), isTrue);
      expect(repo.getDailyChallengeStreak(), 1);
    });

    test('streak continues from yesterday and lapses after a gap', () async {
      String iso(DateTime d) => d.toIso8601String().split('T')[0];
      final now = DateTime.now();

      SharedPreferences.setMockInitialValues({
        'daily_challenge_last': iso(now.subtract(const Duration(days: 1))),
        'daily_challenge_streak': 4,
      });
      repo = UserPrefsRepository(await SharedPreferences.getInstance());
      expect(repo.getDailyChallengeStreak(), 4);
      await repo.recordDailyChallengeDone();
      expect(repo.getDailyChallengeStreak(), 5);

      SharedPreferences.setMockInitialValues({
        'daily_challenge_last': iso(now.subtract(const Duration(days: 3))),
        'daily_challenge_streak': 4,
      });
      repo = UserPrefsRepository(await SharedPreferences.getInstance());
      expect(repo.getDailyChallengeStreak(), 0);
      await repo.recordDailyChallengeDone();
      expect(repo.getDailyChallengeStreak(), 1);
    });
  });
}
