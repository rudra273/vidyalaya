import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/games/daily_challenge.dart';
import '../../data/games/word_builder_data.dart';
import '../../providers/games_progress_provider.dart';
import '../../providers/regional_language_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/pressable.dart';
import 'games_widgets.dart';

// ─── Word Builder ─────────────────────────────────────────────────────────────
//
// Read the meaning, tap the scrambled letters into the right order. A round is
// ten words (five for the daily challenge). Each word is worth 10 points, minus
// 3 per hint, never below 1 once solved; a skipped word scores nothing.

const _roundLength = 10;
const _pointsPerWord = 10;
const _hintCost = 3;

class WordBuilderScreen extends ConsumerStatefulWidget {
  /// When true, plays today's Daily Brain Challenge words.
  final bool daily;

  const WordBuilderScreen({super.key, this.daily = false});

  static String bestKey(WordLevel level) => 'word-builder-${level.name}';

  @override
  ConsumerState<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends ConsumerState<WordBuilderScreen> {
  late WordLevel _level;
  late List<WordPuzzle> _puzzles;
  int _index = 0;

  /// Indices into the current puzzle's letters, in the order tapped.
  final List<int> _answer = [];

  /// Leading answer letters placed by hints — they can't be removed.
  int _lockedCount = 0;
  int _hintsThisWord = 0;
  int _hintsTotal = 0;
  int _points = 0;
  int _solved = 0;

  /// true = just solved, false = wrong attempt, null = neutral.
  bool? _feedback;

  /// While true the answer is shown after a skip and input is ignored.
  bool _revealing = false;
  Timer? _advance;

  bool _finished = false;
  String? _note;

  WordPuzzle get _puzzle => _puzzles[_index];

  @override
  void initState() {
    super.initState();
    final classNo = ref.read(gamesClassLevelProvider);
    _level = WordLevel.forClass(classNo);
    _startRound();
  }

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  void _startRound() {
    _advance?.cancel();
    if (widget.daily) {
      final challenge = dailyChallengeFor(
        DateTime.now(),
        classNo: ref.read(gamesClassLevelProvider),
      );
      _level = challenge.wordLevel;
      _puzzles = buildWordPuzzles(
        _level,
        count: DailyChallenge.wordCount,
        random: challenge.random,
      );
    } else {
      _puzzles = buildWordPuzzles(_level, count: _roundLength);
    }
    _index = 0;
    _points = 0;
    _solved = 0;
    _hintsTotal = 0;
    _finished = false;
    _note = null;
    _resetWord();
  }

  void _resetWord() {
    _answer.clear();
    _lockedCount = 0;
    _hintsThisWord = 0;
    _feedback = null;
    _revealing = false;
  }

  bool get _busy => _revealing || _feedback == true;

  void _tapLetter(int tileIndex) {
    if (_busy || _answer.contains(tileIndex)) return;
    if (_answer.length >= _puzzle.answer.length) return;
    Haptics.selection(ref);
    setState(() {
      _feedback = null;
      _answer.add(tileIndex);
    });
    if (_answer.length == _puzzle.answer.length) _check();
  }

  void _tapSlot(int slot) {
    if (_busy || slot >= _answer.length || slot < _lockedCount) return;
    Haptics.selection(ref);
    setState(() {
      _feedback = null;
      _answer.removeAt(slot);
    });
  }

  void _clear() {
    if (_busy) return;
    setState(() {
      _feedback = null;
      _answer.removeRange(_lockedCount, _answer.length);
    });
  }

  String get _typed => _answer.map((i) => _puzzle.letters[i]).join();

  void _check() {
    if (_typed == _puzzle.answer) {
      Haptics.medium(ref);
      final earned = _pointsPerWord - _hintCost * _hintsThisWord;
      setState(() {
        _feedback = true;
        _solved++;
        _points += earned < 1 ? 1 : earned;
      });
      _advance = Timer(const Duration(milliseconds: 900), _next);
    } else {
      Haptics.error(ref);
      setState(() => _feedback = false);
    }
  }

  /// Places the next correct letter, first undoing anything wrong after the
  /// locked prefix so the hint always lands in the right slot.
  void _hint() {
    if (_busy) return;
    final target = _puzzle.answer;
    var p = _lockedCount;
    while (p < _answer.length && _puzzle.letters[_answer[p]] == target[p]) {
      p++;
    }
    if (p >= target.length) return;
    Haptics.light(ref);
    setState(() {
      _feedback = null;
      _answer.removeRange(p, _answer.length);
      final tile = List<int>.generate(_puzzle.letters.length, (i) => i)
          .firstWhere(
            (i) => !_answer.contains(i) && _puzzle.letters[i] == target[p],
          );
      _answer.add(tile);
      _lockedCount = p + 1;
      _hintsThisWord++;
      _hintsTotal++;
    });
    if (_answer.length == target.length) _check();
  }

  void _skip() {
    if (_busy) return;
    Haptics.light(ref);
    // Show the answer by re-ordering the tiles into it.
    final used = <int>{};
    final order = <int>[];
    for (final ch in _puzzle.answer.split('')) {
      final i = List<int>.generate(
        _puzzle.letters.length,
        (i) => i,
      ).firstWhere((i) => !used.contains(i) && _puzzle.letters[i] == ch);
      used.add(i);
      order.add(i);
    }
    setState(() {
      _answer
        ..clear()
        ..addAll(order);
      _revealing = true;
      _feedback = null;
    });
    _advance = Timer(const Duration(milliseconds: 1600), _next);
  }

  Future<void> _next() async {
    if (!mounted) return;
    if (_index + 1 < _puzzles.length) {
      setState(() {
        _index++;
        _resetWord();
      });
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final notifier = ref.read(gamesProgressProvider.notifier);
    final key = WordBuilderScreen.bestKey(_level);
    final previous = ref.read(gamesProgressProvider).bestFor(key);
    final wasDailyDone = ref.read(gamesProgressProvider).dailyDoneToday;

    if (widget.daily) {
      await notifier.recordDailyDone();
    } else {
      await notifier.recordScore(key, _points);
    }
    if (!mounted) return;

    final streak = ref.read(gamesProgressProvider).dailyStreak;
    setState(() {
      _finished = true;
      _note = widget.daily
          ? (wasDailyDone
                ? 'You already finished today\'s challenge.'
                : 'Daily challenge done — $streak-day streak!')
          : previous == null || _points > previous
          ? 'A new personal best!'
          : 'Your best at ${_level.label} is $previous.';
    });
  }

  void _changeLevel(WordLevel level) {
    if (level == _level) return;
    Haptics.selection(ref);
    setState(() {
      _level = level;
      _startRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = gameAccent(context, GameKind.wordBuilder);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Word Builder')),
      body: _finished
          ? GameResultView(
              accent: accent,
              icon: Icons.spellcheck_rounded,
              title: 'Round complete!',
              stats: [
                GameStat('Points', '$_points'),
                GameStat('Solved', '$_solved / ${_puzzles.length}'),
                GameStat('Hints', '$_hintsTotal'),
              ],
              note: _note,
              againLabel: widget.daily ? 'Play more words' : 'Play again',
              onAgain: widget.daily
                  ? () => context.pushReplacement('/games/word-builder')
                  : () => setState(_startRound),
              onDone: () => context.pop(),
            )
          : _playView(accent),
    );
  }

  Widget _playView(Color accent) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(regionalLanguageProvider);
    final entry = _puzzle.entry;
    final slotColor = _feedback == true
        ? kGameGood
        : _feedback == false
        ? kGameBad
        : accent;

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
            GameLevelChips<WordLevel>(
              values: WordLevel.values,
              selected: _level,
              label: (l) => l.label,
              onSelected: _changeLevel,
              accent: accent,
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Word ${_index + 1} of ${_puzzles.length}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.star_rounded, size: 18, color: accent),
              const SizedBox(width: 4),
              Text(
                '$_points',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeight.extraBold,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _index / _puzzles.length,
            minHeight: 6,
            backgroundColor: cs.outlineVariant,
            valueColor: AlwaysStoppedAnimation(accent),
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 18),

          // ── Clue ──
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPad - 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: accent.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.partOfSpeech} · ${_puzzle.answer.length} letters',
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: AppFontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.meaningEn,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.35),
                ),
                if (lang != RegionalLanguage.english) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.regionalMeaning(lang),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.35,
                      color: isDark ? AppColors.ink2Dark : AppColors.ink2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Answer slots ──
          LayoutBuilder(
            builder: (context, constraints) {
              final n = _puzzle.answer.length;
              const gap = 6.0;
              final size = ((constraints.maxWidth - gap * (n - 1)) / n).clamp(
                24.0,
                46.0,
              );
              return Row(
                // Fresh slots per word, so widths never animate across words.
                key: ObjectKey(_puzzle),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < n; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    GestureDetector(
                      onTap: () => _tapSlot(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: size,
                        height: size * 1.15,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < _answer.length
                              ? slotColor.withValues(
                                  alpha: i < _lockedCount ? 0.22 : 0.12,
                                )
                              : (isDark ? cs.surface : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: i < _answer.length
                                ? slotColor
                                : cs.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: i < _answer.length
                            ? Text(
                                _puzzle.letters[_answer[i]],
                                style: TextStyle(
                                  fontSize: size * 0.5,
                                  fontWeight: AppFontWeight.extraBold,
                                  color: _revealing
                                      ? AppColors.textMuted
                                      : slotColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (_revealing) ...[
            const SizedBox(height: 10),
            Text(
              'The word was ${entry.word}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 26),

          // ── Letter tiles ──
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _puzzle.letters.length; i++)
                _LetterTile(
                  letter: _puzzle.letters[i],
                  used: _answer.contains(i),
                  accent: accent,
                  onTap: () => _tapLetter(i),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _ActionButton(
                icon: Icons.backspace_outlined,
                label: 'Clear',
                onTap: _clear,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Hint',
                onTap: _hint,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.skip_next_rounded,
                label: 'Skip',
                onTap: _skip,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hints cost $_hintCost points each.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: AppFontSize.small,
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  final String letter;
  final bool used;
  final Color accent;
  final VoidCallback onTap;

  const _LetterTile({
    required this.letter,
    required this.used,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: used ? 0.25 : 1,
      child: Pressable(
        onTap: used ? null : onTap,
        scale: 0.9,
        child: Container(
          width: 50,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: AppFontWeight.extraBold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon-over-label button, so three fit side by side on the narrowest phones.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 2),
            FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
