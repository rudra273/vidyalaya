import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/games/daily_challenge.dart';
import '../../data/games/element_match_data.dart';
import '../../data/games/sudoku_generator.dart';
import '../../data/games/word_builder_data.dart';
import '../../providers/games_progress_provider.dart';
import '../../providers/math_progress_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/pressable.dart';
import 'element_match_screen.dart';
import 'games_widgets.dart';
import 'sudoku_screen.dart';
import 'word_builder_screen.dart';

// ─── Brain Games hub ──────────────────────────────────────────────────────────
//
// Reached from the Home "Games" tile. Today's Daily Brain Challenge is pinned
// up top; below it, every game with the student's best at their default level.

const _gameRoutes = {
  GameKind.wordBuilder: '/games/word-builder',
  GameKind.sudoku: '/games/sudoku',
  GameKind.elementMatch: '/games/element-match',
};

const _gameTitles = {
  GameKind.wordBuilder: 'Word Builder',
  GameKind.sudoku: 'Sudoku',
  GameKind.elementMatch: 'Element Match',
};

const _gameIcons = {
  GameKind.wordBuilder: Icons.spellcheck_rounded,
  GameKind.sudoku: Icons.grid_on_rounded,
  GameKind.elementMatch: Icons.science_rounded,
};

class GamesHomeScreen extends ConsumerStatefulWidget {
  const GamesHomeScreen({super.key});

  @override
  ConsumerState<GamesHomeScreen> createState() => _GamesHomeScreenState();
}

class _GamesHomeScreenState extends ConsumerState<GamesHomeScreen> {
  @override
  void initState() {
    super.initState();
    // The day may have rolled over since the provider was built.
    Future.microtask(() {
      if (mounted) ref.read(gamesProgressProvider.notifier).refresh();
    });
  }

  void _open(String route) {
    Haptics.light(ref);
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(gamesProgressProvider);
    final drillsBest = ref.watch(mathProgressProvider).bestFor('math-drills');
    final classNo = ref.watch(gamesClassLevelProvider);
    final challenge = dailyChallengeFor(DateTime.now(), classNo: classNo);

    final wordLevel = WordLevel.forClass(classNo);
    final sudokuSize = SudokuSize.forClass(classNo);
    final wordBest = progress.bestFor(WordBuilderScreen.bestKey(wordLevel));
    final sudokuBest = progress.bestFor(SudokuScreen.bestKey(sudokuSize));
    final elementBest = progress.bestFor(
      ElementMatchScreen.bestKey(ElementLevel.easy),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drillsAccent = isDark ? AppColors.cMathsDark : AppColors.cMaths;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Brain Games')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 12),
          _DailyCard(
            challenge: challenge,
            done: progress.dailyDoneToday,
            streak: progress.dailyStreak,
            onTap: () => _open('${_gameRoutes[challenge.kind]}?daily=1'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              22,
              AppSpacing.screenPadding,
              4,
            ),
            child: SectionHead(label: 'All games'),
          ),
          _GameRow(
            accent: drillsAccent,
            icon: Icons.bolt_rounded,
            title: 'Speed Drills',
            sub: 'Answer as many math facts as you can in 60 seconds.',
            best: drillsBest == null ? null : '$drillsBest correct',
            onTap: () => _open('/learn/math/drills'),
          ),
          _GameRow(
            accent: gameAccent(context, GameKind.wordBuilder),
            icon: _gameIcons[GameKind.wordBuilder]!,
            title: 'Word Builder',
            sub: 'Read the meaning, unscramble the word.',
            best: wordBest == null
                ? null
                : '$wordBest points (${wordLevel.label})',
            onTap: () => _open(_gameRoutes[GameKind.wordBuilder]!),
          ),
          _GameRow(
            accent: gameAccent(context, GameKind.sudoku),
            icon: _gameIcons[GameKind.sudoku]!,
            title: 'Sudoku',
            sub: 'Fill the grid so every row, column and box has each number.',
            best: sudokuBest == null
                ? null
                : '${formatGameTime(sudokuBest)} (${sudokuSize.label})',
            onTap: () => _open(_gameRoutes[GameKind.sudoku]!),
          ),
          _GameRow(
            accent: gameAccent(context, GameKind.elementMatch),
            icon: _gameIcons[GameKind.elementMatch]!,
            title: 'Element Match',
            sub: 'Flip cards to pair each element with its symbol.',
            best: elementBest == null ? null : '$elementBest moves (Easy)',
            onTap: () => _open(_gameRoutes[GameKind.elementMatch]!),
          ),
        ],
      ),
    );
  }
}

// ─── Daily Brain Challenge card ───────────────────────────────────────────────

class _DailyCard extends StatelessWidget {
  final DailyChallenge challenge;
  final bool done;
  final int streak;
  final VoidCallback onTap;

  const _DailyCard({
    required this.challenge,
    required this.done,
    required this.streak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = dailyAccent(context);
    final title = _gameTitles[challenge.kind]!;
    final detail = switch (challenge.kind) {
      GameKind.wordBuilder =>
        '${DailyChallenge.wordCount} words · ${challenge.wordLevel.label}',
      GameKind.sudoku => '${challenge.sudokuSize.label} grid',
      GameKind.elementMatch =>
        '${challenge.elementLevel.pairs} pairs · ${challenge.elementLevel.label}',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -14,
                bottom: -18,
                child: Icon(
                  _gameIcons[challenge.kind],
                  size: 100,
                  color: accent.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Tile(color: accent, icon: Icons.today_rounded, size: 40),
                      const Spacer(),
                      if (streak > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 18,
                              color: accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$streak-day streak',
                              style: TextStyle(
                                fontSize: AppFontSize.small,
                                fontWeight: AppFontWeight.bold,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Daily Brain Challenge',
                    style: TextStyle(
                      fontSize: AppFontSize.small,
                      fontWeight: AppFontWeight.bold,
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Today: $title",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: AppFontSize.heading,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: AppFontSize.body,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (done)
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: kGameGood,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Done for today — a new one tomorrow.',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontWeight: AppFontWeight.semibold,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "Play today's challenge",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: AppFontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Game row ─────────────────────────────────────────────────────────────────

class _GameRow extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String sub;
  final String? best;
  final VoidCallback onTap;

  const _GameRow({
    required this.accent,
    required this.icon,
    required this.title,
    required this.sub,
    required this.best,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        6,
        AppSpacing.screenPadding,
        6,
      ),
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: best != null
                  ? accent.withValues(alpha: 0.4)
                  : cs.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tile(color: accent, icon: icon, size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: AppFontSize.body,
                      ),
                      maxLines: 2,
                    ),
                    if (best != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 14,
                            color: accent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Best: $best',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: AppFontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
