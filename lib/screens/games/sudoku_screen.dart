import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/games/daily_challenge.dart';
import '../../data/games/sudoku_generator.dart';
import '../../providers/games_progress_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/pressable.dart';
import 'games_widgets.dart';

// ─── Sudoku ───────────────────────────────────────────────────────────────────
//
// 4×4, 6×6 or 9×9, every puzzle generated on the fly with a unique solution.
// Clashing digits turn red as soon as they're placed. A hint fills one cell;
// using any hint means the time doesn't count toward the best.

class SudokuScreen extends ConsumerStatefulWidget {
  /// When true, plays today's Daily Brain Challenge puzzle.
  final bool daily;

  const SudokuScreen({super.key, this.daily = false});

  static String bestKey(SudokuSize size) => 'sudoku-${size.size}';

  @override
  ConsumerState<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends ConsumerState<SudokuScreen> {
  late SudokuSize _size;
  late SudokuPuzzle _puzzle;
  late List<int> _grid;
  final Set<int> _hinted = {};
  int? _selected;

  int _seconds = 0;
  Timer? _ticker;
  bool _solved = false;

  /// Result note computed once when the puzzle is solved.
  String? _note;

  @override
  void initState() {
    super.initState();
    final classNo = ref.read(gamesClassLevelProvider);
    final challenge = dailyChallengeFor(DateTime.now(), classNo: classNo);
    _size = widget.daily ? challenge.sudokuSize : SudokuSize.forClass(classNo);
    _newPuzzle(seeded: widget.daily ? challenge : null);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _newPuzzle({DailyChallenge? seeded}) {
    _puzzle = generateSudoku(_size, random: seeded?.random);
    _grid = List<int>.of(_puzzle.givens);
    _hinted.clear();
    _selected = null;
    _solved = false;
    _note = null;
    _seconds = 0;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  bool _locked(int i) => _puzzle.givens[i] != 0 || _hinted.contains(i);

  void _place(int value) {
    final i = _selected;
    if (_solved || i == null || _locked(i)) return;
    Haptics.light(ref);
    setState(() => _grid[i] = value);
    _checkSolved();
  }

  void _hint() {
    if (_solved) return;
    bool wrong(int i) => !_locked(i) && _grid[i] != _puzzle.solution[i];
    final target = (_selected != null && wrong(_selected!))
        ? _selected!
        : List<int>.generate(
            _grid.length,
            (i) => i,
          ).firstWhere(wrong, orElse: () => -1);
    if (target < 0) return;
    Haptics.medium(ref);
    setState(() {
      _grid[target] = _puzzle.solution[target];
      _hinted.add(target);
      _selected = target;
    });
    _checkSolved();
  }

  Future<void> _checkSolved() async {
    for (var i = 0; i < _grid.length; i++) {
      if (_grid[i] != _puzzle.solution[i]) return;
    }
    _ticker?.cancel();
    Haptics.medium(ref);

    final notifier = ref.read(gamesProgressProvider.notifier);
    final key = SudokuScreen.bestKey(_size);
    final previous = ref.read(gamesProgressProvider).bestFor(key);
    final wasDailyDone = ref.read(gamesProgressProvider).dailyDoneToday;

    if (_hinted.isEmpty) {
      await notifier.recordScore(key, _seconds, lowerIsBetter: true);
    }
    if (widget.daily) await notifier.recordDailyDone();
    if (!mounted) return;

    final streak = ref.read(gamesProgressProvider).dailyStreak;
    setState(() {
      _solved = true;
      _note = widget.daily && !wasDailyDone
          ? 'Daily challenge done — $streak-day streak!'
          : _hinted.isNotEmpty
          ? 'Solve it without hints to set a best time.'
          : previous == null || _seconds < previous
          ? 'A new best time!'
          : 'Your best is ${formatGameTime(previous)}.';
    });
  }

  void _changeSize(SudokuSize size) {
    if (size == _size) return;
    Haptics.selection(ref);
    setState(() {
      _size = size;
      _newPuzzle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = gameAccent(context, GameKind.sudoku);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Sudoku')),
      body: _solved
          ? GameResultView(
              accent: accent,
              icon: Icons.grid_on_rounded,
              title: 'Solved!',
              stats: [
                GameStat('Time', formatGameTime(_seconds)),
                GameStat('Grid', _size.label),
                GameStat('Hints', '${_hinted.length}'),
              ],
              note: _note,
              // The daily puzzle is one per day, so "again" leaves daily mode.
              againLabel: widget.daily ? 'Play more Sudoku' : 'New puzzle',
              onAgain: widget.daily
                  ? () => context.pushReplacement('/games/sudoku')
                  : () => setState(_newPuzzle),
              onDone: () => context.pop(),
            )
          : _playView(accent),
    );
  }

  Widget _playView(Color accent) {
    final best = ref
        .watch(gamesProgressProvider)
        .bestFor(SudokuScreen.bestKey(_size));
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          12,
          AppSpacing.screenPadding,
          24,
        ),
        children: [
          if (widget.daily)
            const Align(
              alignment: Alignment.centerLeft,
              child: DailyChallengeBanner(),
            )
          else
            GameLevelChips<SudokuSize>(
              values: SudokuSize.values,
              selected: _size,
              label: (s) => s.label,
              onSelected: _changeSize,
              accent: accent,
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: accent),
              const SizedBox(width: 6),
              Text(
                formatGameTime(_seconds),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeight.extraBold,
                ),
              ),
              const Spacer(),
              if (best != null)
                Text(
                  'Best ${formatGameTime(best)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Board(
            puzzle: _puzzle,
            grid: _grid,
            hinted: _hinted,
            selected: _selected,
            accent: accent,
            onTap: (i) {
              Haptics.selection(ref);
              setState(() => _selected = i);
            },
          ),
          const SizedBox(height: 18),
          _NumberPad(
            n: _puzzle.n,
            accent: accent,
            onDigit: _place,
            onErase: () => _place(0),
            onHint: _hint,
          ),
        ],
      ),
    );
  }
}

// ─── Board ────────────────────────────────────────────────────────────────────

class _Board extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final List<int> grid;
  final Set<int> hinted;
  final int? selected;
  final Color accent;
  final ValueChanged<int> onTap;

  const _Board({
    required this.puzzle,
    required this.grid,
    required this.hinted,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final n = puzzle.n;
    final conflicts = sudokuConflicts(puzzle.size, grid);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? cs.surface : Colors.white,
          border: Border.all(
            color: isDark ? AppColors.ink2Dark : AppColors.ink2,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var r = 0; r < n; r++)
              Expanded(
                child: Row(
                  children: [
                    for (var c = 0; c < n; c++)
                      Expanded(
                        child: _cell(
                          context,
                          r * n + c,
                          clash: conflicts.contains(r * n + c),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, int i, {required bool clash}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = puzzle.size;
    final n = puzzle.n;
    final r = i ~/ n, c = i % n;
    final thin = cs.outlineVariant;
    final thick = isDark ? AppColors.ink2Dark : AppColors.ink2;
    final fontSize = switch (s) {
      SudokuSize.four => 30.0,
      SudokuSize.six => 26.0,
      SudokuSize.nine => 21.0,
    };

    // Highlight the selected cell, its row/column/box, and matching digits.
    final sel = selected;
    final selValue = sel == null ? 0 : grid[sel];
    final isRelated =
        sel != null &&
        (r == sel ~/ n ||
            c == sel % n ||
            (r ~/ s.boxRows == (sel ~/ n) ~/ s.boxRows &&
                c ~/ s.boxCols == (sel % n) ~/ s.boxCols));

    final value = grid[i];
    final given = puzzle.givens[i] != 0;

    Color? bg;
    if (i == sel) {
      bg = accent.withValues(alpha: 0.26);
    } else if (value != 0 && value == selValue) {
      bg = accent.withValues(alpha: 0.16);
    } else if (isRelated) {
      bg = accent.withValues(alpha: 0.07);
    }

    // Thick lines on box edges; the outer frame is drawn by the board.
    final boxRight = (c + 1) % s.boxCols == 0;
    final boxBottom = (r + 1) % s.boxRows == 0;

    return GestureDetector(
      onTap: () => onTap(i),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            right: c < n - 1
                ? BorderSide(
                    color: boxRight ? thick : thin,
                    width: boxRight ? 2 : 1,
                  )
                : BorderSide.none,
            bottom: r < n - 1
                ? BorderSide(
                    color: boxBottom ? thick : thin,
                    width: boxBottom ? 2 : 1,
                  )
                : BorderSide.none,
          ),
        ),
        alignment: Alignment.center,
        child: value == 0
            ? null
            : Text(
                '$value',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: given
                      ? AppFontWeight.extraBold
                      : AppFontWeight.semibold,
                  color: clash
                      ? kGameBad
                      : given
                      ? cs.onSurface
                      : hinted.contains(i)
                      ? accent.withValues(alpha: 0.6)
                      : accent,
                ),
              ),
      ),
    );
  }
}

// ─── Number pad ───────────────────────────────────────────────────────────────

class _NumberPad extends StatelessWidget {
  final int n;
  final Color accent;
  final ValueChanged<int> onDigit;
  final VoidCallback onErase;
  final VoidCallback onHint;

  const _NumberPad({
    required this.n,
    required this.accent,
    required this.onDigit,
    required this.onErase,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var v = 1; v <= n; v++) ...[
              if (v > 1) const SizedBox(width: 6),
              Expanded(
                child: _PadKey(
                  accent: accent,
                  onTap: () => onDigit(v),
                  child: Text(
                    '$v',
                    style: TextStyle(
                      fontSize: n == 9 ? 20 : 24,
                      fontWeight: AppFontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onErase,
                icon: const Icon(Icons.backspace_outlined, size: 18),
                label: const Text('Erase'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onHint,
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                label: const Text('Hint'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PadKey extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  final Widget child;

  const _PadKey({
    required this.accent,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: child,
      ),
    );
  }
}
