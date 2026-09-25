import 'dart:math';

// ─── Sudoku generator ─────────────────────────────────────────────────────────
//
// Builds a solved grid from the classic shifted-row pattern, scrambles it with
// symmetry-preserving shuffles (rows within a band, bands, columns within a
// stack, stacks, digit relabelling), then blanks cells one at a time, keeping a
// blank only while the puzzle still has exactly one solution. Everything flows
// from the [Random] passed in, so a seeded Random gives the same puzzle every
// time — that is what lets the Daily Challenge be one puzzle for everyone.

/// Supported grid sizes. Boxes are [boxRows] × [boxCols], so 6×6 uses 2×3 boxes.
enum SudokuSize {
  four(size: 4, boxRows: 2, boxCols: 2, blanks: 10, label: '4 × 4'),
  six(size: 6, boxRows: 2, boxCols: 3, blanks: 20, label: '6 × 6'),
  nine(size: 9, boxRows: 3, boxCols: 3, blanks: 44, label: '9 × 9');

  final int size;
  final int boxRows;
  final int boxCols;

  /// How many cells we try to blank. The uniqueness check may stop short.
  final int blanks;
  final String label;

  const SudokuSize({
    required this.size,
    required this.boxRows,
    required this.boxCols,
    required this.blanks,
    required this.label,
  });

  /// The size a practice game opens at for the student's lowest [classNo].
  static SudokuSize forClass(int? classNo) =>
      classNo != null && classNo <= 4 ? SudokuSize.four : SudokuSize.six;
}

class SudokuPuzzle {
  final SudokuSize size;

  /// Row-major, length size². 0 marks an empty cell.
  final List<int> givens;

  /// Row-major full solution, digits 1..size.
  final List<int> solution;

  const SudokuPuzzle({
    required this.size,
    required this.givens,
    required this.solution,
  });

  int get n => size.size;
  int get emptyCount => givens.where((v) => v == 0).length;
}

SudokuPuzzle generateSudoku(SudokuSize size, {Random? random}) {
  final rng = random ?? Random();
  final solution = _solvedGrid(size, rng);
  final givens = List<int>.of(solution);

  final order = List<int>.generate(givens.length, (i) => i)..shuffle(rng);
  var removed = 0;
  for (final cell in order) {
    if (removed >= size.blanks) break;
    final keep = givens[cell];
    givens[cell] = 0;
    if (countSudokuSolutions(size, givens, limit: 2) == 1) {
      removed++;
    } else {
      givens[cell] = keep;
    }
  }

  return SudokuPuzzle(size: size, givens: givens, solution: solution);
}

List<int> _solvedGrid(SudokuSize s, Random rng) {
  final n = s.size;
  final bands = n ~/ s.boxRows; // bands of boxRows rows each
  final stacks = n ~/ s.boxCols; // stacks of boxCols columns each

  List<int> shuffled(int count) =>
      List<int>.generate(count, (i) => i)..shuffle(rng);

  final rows = [
    for (final band in shuffled(bands))
      for (final r in shuffled(s.boxRows)) band * s.boxRows + r,
  ];
  final cols = [
    for (final stack in shuffled(stacks))
      for (final c in shuffled(s.boxCols)) stack * s.boxCols + c,
  ];
  final digits = shuffled(n);

  int pattern(int r, int c) =>
      (s.boxCols * (r % s.boxRows) + r ~/ s.boxRows + c) % n;

  return [
    for (final r in rows)
      for (final c in cols) digits[pattern(r, c)] + 1,
  ];
}

/// Counts solutions of [grid] (0 = empty), stopping once [limit] is reached.
int countSudokuSolutions(SudokuSize s, List<int> grid, {int limit = 2}) {
  final cells = List<int>.of(grid);
  final n = s.size;
  var count = 0;

  bool fits(int idx, int v) {
    final r = idx ~/ n;
    final c = idx % n;
    for (var i = 0; i < n; i++) {
      if (cells[r * n + i] == v || cells[i * n + c] == v) return false;
    }
    final br = r - r % s.boxRows;
    final bc = c - c % s.boxCols;
    for (var dr = 0; dr < s.boxRows; dr++) {
      for (var dc = 0; dc < s.boxCols; dc++) {
        if (cells[(br + dr) * n + bc + dc] == v) return false;
      }
    }
    return true;
  }

  void solve() {
    if (count >= limit) return;
    // Branch on the empty cell with the fewest candidates — keeps 9×9 fast.
    var best = -1;
    var bestOptions = <int>[];
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] != 0) continue;
      final options = [
        for (var v = 1; v <= n; v++)
          if (fits(i, v)) v,
      ];
      if (options.isEmpty) return; // dead end
      if (best == -1 || options.length < bestOptions.length) {
        best = i;
        bestOptions = options;
        if (options.length == 1) break;
      }
    }
    if (best == -1) {
      count++;
      return;
    }
    for (final v in bestOptions) {
      cells[best] = v;
      solve();
      cells[best] = 0;
      if (count >= limit) return;
    }
  }

  solve();
  return count;
}

/// Indices of filled cells that clash with another filled cell in the same
/// row, column or box. Used to paint mistakes red as the student plays.
Set<int> sudokuConflicts(SudokuSize s, List<int> grid) {
  final n = s.size;
  final out = <int>{};
  for (var a = 0; a < grid.length; a++) {
    final v = grid[a];
    if (v == 0) continue;
    for (var b = a + 1; b < grid.length; b++) {
      if (grid[b] != v) continue;
      final ra = a ~/ n, ca = a % n, rb = b ~/ n, cb = b % n;
      final sameBox =
          ra ~/ s.boxRows == rb ~/ s.boxRows &&
          ca ~/ s.boxCols == cb ~/ s.boxCols;
      if (ra == rb || ca == cb || sameBox) out.addAll([a, b]);
    }
  }
  return out;
}
