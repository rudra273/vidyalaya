import 'dart:math';

import 'element_match_data.dart';
import 'sudoku_generator.dart';
import 'word_builder_data.dart';

// ─── Daily Brain Challenge ────────────────────────────────────────────────────
//
// One puzzle a day. The game rotates by date, and the puzzle is seeded by the
// date too, so every student at the same class level gets the same challenge on
// the same day. Element Match only joins the rotation from class 6, when the
// periodic table enters the syllabus.

enum GameKind { wordBuilder, sudoku, elementMatch }

class DailyChallenge {
  final GameKind kind;

  /// Seed for the day's puzzle — pass `Random(seed)` to the generator.
  final int seed;

  final WordLevel wordLevel;
  final SudokuSize sudokuSize;
  final ElementLevel elementLevel;

  const DailyChallenge({
    required this.kind,
    required this.seed,
    required this.wordLevel,
    required this.sudokuSize,
    required this.elementLevel,
  });

  Random get random => Random(seed);

  /// Words in the daily Word Builder round.
  static const wordCount = 5;
}

int _dayNumber(DateTime d) =>
    DateTime(d.year, d.month, d.day).difference(DateTime(2000)).inDays;

/// Today's challenge for a student whose lowest selected class is [classNo]
/// (null = no class chosen, treated as middle school).
DailyChallenge dailyChallengeFor(DateTime date, {int? classNo}) {
  final day = _dayNumber(date);
  final rotation = [
    GameKind.wordBuilder,
    GameKind.sudoku,
    if (classNo == null || classNo >= 6) GameKind.elementMatch,
  ];

  return DailyChallenge(
    kind: rotation[day % rotation.length],
    seed: day,
    wordLevel: WordLevel.forClass(classNo),
    sudokuSize: classNo == null
        ? SudokuSize.six
        : classNo <= 4
        ? SudokuSize.four
        : classNo <= 7
        ? SudokuSize.six
        : SudokuSize.nine,
    elementLevel: classNo != null && classNo >= 9
        ? ElementLevel.medium
        : ElementLevel.easy,
  );
}
