import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/games/daily_challenge.dart';

// ─── Shared pieces for the brain games ────────────────────────────────────────

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

/// Accent colour per game, shared by the hub rows and the game screens.
Color gameAccent(BuildContext context, GameKind kind) => switch (kind) {
  GameKind.wordBuilder =>
    _isDark(context) ? AppColors.cEnglishDark : AppColors.cEnglish,
  GameKind.sudoku =>
    _isDark(context) ? AppColors.cMathHubDark : AppColors.cMathHub,
  GameKind.elementMatch =>
    _isDark(context) ? AppColors.cPeriodicDark : AppColors.cPeriodic,
};

Color dailyAccent(BuildContext context) =>
    _isDark(context) ? AppColors.cTutorDark : AppColors.cTutor;

const kGameGood = Color(0xFF3E8E5A);
const kGameBad = Color(0xFFC0483C);

/// 75 → "1:15".
String formatGameTime(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

// ─── Level picker ─────────────────────────────────────────────────────────────

class GameLevelChips<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  final Color accent;

  const GameLevelChips({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(label(v)),
            selected: v == selected,
            showCheckmark: false,
            selectedColor: accent.withValues(alpha: 0.16),
            side: BorderSide(
              color: v == selected
                  ? accent
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            labelStyle: TextStyle(
              fontWeight: AppFontWeight.bold,
              color: v == selected ? accent : null,
            ),
            onSelected: (_) => onSelected(v),
          ),
      ],
    );
  }
}

// ─── Daily banner (shown on a game while it is today's challenge) ─────────────

class DailyChallengeBanner extends StatelessWidget {
  const DailyChallengeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = dailyAccent(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.today_rounded, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            'Daily Brain Challenge',
            style: TextStyle(
              fontSize: AppFontSize.small,
              fontWeight: AppFontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result screen ────────────────────────────────────────────────────────────

class GameStat {
  final String label;
  final String value;
  const GameStat(this.label, this.value);
}

class GameResultView extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final List<GameStat> stats;

  /// A short line under the stats — "A new personal best!", streak, etc.
  final String? note;
  final VoidCallback onAgain;
  final String againLabel;
  final VoidCallback onDone;

  const GameResultView({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.stats,
    this.note,
    required this.onAgain,
    this.againLabel = 'Play again',
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: accent),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: AppFontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isDark(context) ? cs.surface : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.tileRadius,
                        ),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Text(
                            stats[i].value,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: AppFontWeight.extraBold,
                                  color: accent,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stats[i].label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: AppFontSize.small,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (note != null) ...[
              const SizedBox(height: 16),
              Text(
                note!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAgain,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(againLabel),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: onDone,
                child: const Text('Back to Games'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
