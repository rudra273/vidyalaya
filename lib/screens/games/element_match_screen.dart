import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/games/daily_challenge.dart';
import '../../data/games/element_match_data.dart';
import '../../data/science/periodic_table_data.dart';
import '../../providers/games_progress_provider.dart';
import '../../providers/regional_language_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/pressable.dart';
import 'games_widgets.dart';

// ─── Element Match ────────────────────────────────────────────────────────────
//
// Flip two cards at a time to pair each element's symbol with its name. A move
// is one pair of flips; the best score is the fewest moves.

class ElementMatchScreen extends ConsumerStatefulWidget {
  /// When true, plays today's Daily Brain Challenge deck.
  final bool daily;

  const ElementMatchScreen({super.key, this.daily = false});

  static String bestKey(ElementLevel level) => 'element-match-${level.name}';

  @override
  ConsumerState<ElementMatchScreen> createState() => _ElementMatchScreenState();
}

class _ElementMatchScreenState extends ConsumerState<ElementMatchScreen> {
  ElementLevel _level = ElementLevel.easy;
  late List<ElementCard> _deck;
  final List<int> _flipped = [];
  final Set<int> _matched = {};
  int _moves = 0;

  int _seconds = 0;
  Timer? _ticker;

  /// Blocks taps while a mismatched pair is showing.
  Timer? _flipBack;

  bool _finished = false;
  String? _note;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _flipBack?.cancel();
    super.dispose();
  }

  void _newGame() {
    Random? random;
    if (widget.daily) {
      final challenge = dailyChallengeFor(
        DateTime.now(),
        classNo: ref.read(gamesClassLevelProvider),
      );
      _level = challenge.elementLevel;
      random = challenge.random;
    }
    _deck = buildElementDeck(_level, random: random);
    _flipped.clear();
    _matched.clear();
    _moves = 0;
    _seconds = 0;
    _finished = false;
    _note = null;
    _ticker?.cancel();
    _ticker = null; // starts on the first flip
    _flipBack?.cancel();
    _flipBack = null;
  }

  void _tap(int i) {
    if (_flipBack != null || _flipped.contains(i) || _matched.contains(i)) {
      return;
    }
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
    Haptics.selection(ref);
    setState(() => _flipped.add(i));
    if (_flipped.length < 2) return;

    final a = _flipped[0], b = _flipped[1];
    setState(() => _moves++);
    if (_deck[a].pairId == _deck[b].pairId) {
      Haptics.medium(ref);
      setState(() {
        _matched.addAll([a, b]);
        _flipped.clear();
      });
      if (_matched.length == _deck.length) _finish();
    } else {
      _flipBack = Timer(const Duration(milliseconds: 850), () {
        if (!mounted) return;
        setState(() {
          _flipped.clear();
          _flipBack = null;
        });
      });
    }
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    final notifier = ref.read(gamesProgressProvider.notifier);
    final key = ElementMatchScreen.bestKey(_level);
    final previous = ref.read(gamesProgressProvider).bestFor(key);
    final wasDailyDone = ref.read(gamesProgressProvider).dailyDoneToday;

    await notifier.recordScore(key, _moves, lowerIsBetter: true);
    if (widget.daily) await notifier.recordDailyDone();
    if (!mounted) return;

    final streak = ref.read(gamesProgressProvider).dailyStreak;
    // A short beat so the last pair is seen matching before the results.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _finished = true;
      _note = widget.daily && !wasDailyDone
          ? 'Daily challenge done — $streak-day streak!'
          : previous == null || _moves < previous
          ? 'A new best — fewest moves yet!'
          : 'Your best at ${_level.label} is $previous moves.';
    });
  }

  void _changeLevel(ElementLevel level) {
    if (level == _level) return;
    Haptics.selection(ref);
    setState(() {
      _level = level;
      _newGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = gameAccent(context, GameKind.elementMatch);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Element Match')),
      body: _finished
          ? GameResultView(
              accent: accent,
              icon: Icons.science_rounded,
              title: 'All pairs found!',
              stats: [
                GameStat('Moves', '$_moves'),
                GameStat('Time', formatGameTime(_seconds)),
                GameStat('Pairs', '${_level.pairs}'),
              ],
              note: _note,
              againLabel: widget.daily ? 'Play more' : 'Play again',
              onAgain: widget.daily
                  ? () => context.pushReplacement('/games/element-match')
                  : () => setState(_newGame),
              onDone: () => context.pop(),
            )
          : _playView(accent),
    );
  }

  Widget _playView(Color accent) {
    final lang = ref.watch(regionalLanguageProvider);
    final best = ref
        .watch(gamesProgressProvider)
        .bestFor(ElementMatchScreen.bestKey(_level));

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
            GameLevelChips<ElementLevel>(
              values: ElementLevel.values,
              selected: _level,
              label: (l) => l.label,
              onSelected: _changeLevel,
              accent: accent,
            ),
          const SizedBox(height: 8),
          Text(
            _level.sub,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: AppFontSize.small,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Moves $_moves',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeight.extraBold,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.timer_outlined, size: 17, color: accent),
              const SizedBox(width: 4),
              Text(formatGameTime(_seconds)),
              const Spacer(),
              if (best != null)
                Text(
                  'Best $best moves',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _deck.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, i) => _FlipCard(
              card: _deck[i],
              faceUp: _flipped.contains(i) || _matched.contains(i),
              matched: _matched.contains(i),
              accent: accent,
              lang: lang,
              onTap: () => _tap(i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _FlipCard extends StatelessWidget {
  final ElementCard card;
  final bool faceUp;
  final bool matched;
  final Color accent;
  final RegionalLanguage lang;
  final VoidCallback onTap;

  const _FlipCard({
    required this.card,
    required this.faceUp,
    required this.matched,
    required this.accent,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: faceUp ? null : onTap,
      scale: 0.94,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: faceUp ? 1 : 0),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        builder: (context, t, _) {
          final showFront = t >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi * t + (showFront ? pi : 0)),
            child: showFront ? _front(context) : _back(),
          );
        },
      ),
    );
  }

  Widget _back() {
    return Container(
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.help_outline_rounded,
        color: Colors.white.withValues(alpha: 0.85),
        size: 26,
      ),
    );
  }

  Widget _front(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final e = card.element;
    final border = matched ? kGameGood : accent;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: matched ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? cs.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 2),
        ),
        alignment: Alignment.center,
        child: card.isSymbol
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${e.atomicNumber}',
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    e.symbol,
                    style: TextStyle(
                      fontSize: AppFontSize.displaySmall,
                      fontWeight: AppFontWeight.extraBold,
                      color: accent,
                    ),
                  ),
                ],
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.name,
                      style: TextStyle(
                        fontSize: AppFontSize.body,
                        fontWeight: AppFontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    if (_regionalName(e) case final name?)
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: AppFontSize.small,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  String? _regionalName(ElementData e) => switch (lang) {
    RegionalLanguage.english => null,
    RegionalLanguage.odia => e.nameOdia,
    RegionalLanguage.hindi => e.nameHindi,
  };
}
