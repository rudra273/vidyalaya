// ─── Multiplication table metadata ────────────────────────────────────────────
//
// The grids themselves are computed (table × 1..12), so only the *tips* live
// here — the little pattern hints that make a table easier to remember.
// Pure Dart, no Flutter imports.

/// Which tables the browser offers.
const int minTable = 1;
const int maxTable = 20;

/// How far each table runs (7 × 1 … 7 × 12).
const int tableUpTo = 12;

/// All table numbers, in order.
List<int> get allTables =>
    List.generate(maxTable - minTable + 1, (i) => minTable + i);

/// A memory tip per table. Missing entries simply render no tip.
const tableTips = <int, String>{
  1: 'Anything × 1 stays exactly the same.',
  2: 'Doubling — just add the number to itself.',
  3: 'Add the number three times, or double it and add one more.',
  4: 'Double it, then double again.',
  5: 'Every answer ends in 5 or 0. Half of the 10× answer.',
  6: 'Double the 3× answer.',
  7: 'The tricky one — 7 × 8 = 56 is worth memorising on its own.',
  8: 'Double, double, double.',
  9: 'The digits of every answer add up to 9. Also: 10× minus the number.',
  10: 'Just add a zero to the end.',
  11: 'For 1–9, write the digit twice: 11 × 4 = 44.',
  12: '10× plus 2×.',
  13: '10× plus 3×.',
  14: 'Double the 7× answer.',
  15: '10× plus half of it.',
  16: 'Double the 8× answer.',
  17: '10× plus 7×.',
  18: 'Double the 9× answer, or 20× minus 2×.',
  19: '20× minus the number.',
  20: 'Double it, then add a zero.',
};

String? tipForTable(int table) => tableTips[table];
