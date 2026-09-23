import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

// ─── Shared MCQ option tile ───────────────────────────────────────────────────
//
// Extracted from the Python quiz's _OptionTile so Math Quiz, Number Sense and
// Fractions Lab all tint answers identically instead of each re-deriving the
// green/red treatment.

enum MathOptionState { idle, correct, wrong, dim }

/// Maps an answered question to the visual state of option [i].
MathOptionState mathOptionState({
  required bool answered,
  required int index,
  required int correctIndex,
  required int? selected,
}) {
  if (!answered) return MathOptionState.idle;
  if (index == correctIndex) return MathOptionState.correct;
  if (index == selected) return MathOptionState.wrong;
  return MathOptionState.dim;
}

class MathOptionTile extends StatelessWidget {
  final String label;
  final MathOptionState state;
  final VoidCallback? onTap;

  /// Centres the label — used by grid-style layouts like Number Sense.
  final bool centered;

  const MathOptionTile({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
    this.centered = false,
  });

  static const _green = Color(0xFF3E8E5A);
  static const _greenInk = Color(0xFF2C7A48);
  static const _red = Color(0xFFC0483C);
  static const _redInk = Color(0xFFB0433A);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color border = cs.outlineVariant;
    Color bg = Theme.of(context).brightness == Brightness.dark
        ? cs.surface
        : Colors.white;
    Color? fg;

    switch (state) {
      case MathOptionState.correct:
        border = _green;
        bg = _green.withValues(alpha: 0.15);
        fg = _greenInk;
      case MathOptionState.wrong:
        border = _red;
        bg = _red.withValues(alpha: 0.12);
        fg = _redInk;
      case MathOptionState.dim:
        bg = bg.withValues(alpha: 0.5);
      case MathOptionState.idle:
        break;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: centered
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              if (!centered)
                Expanded(child: _label(context, fg))
              else
                _label(context, fg),
              if (state == MathOptionState.correct)
                const Icon(Icons.check_circle_rounded, color: _greenInk),
              if (state == MathOptionState.wrong)
                const Icon(Icons.cancel_rounded, color: _redInk),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, Color? fg) => Text(
        label,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: fg,
            ),
      );
}

/// The explanation panel shown under an answered question.
class MathExplanation extends StatelessWidget {
  final bool correct;
  final String text;

  const MathExplanation({
    super.key,
    required this.correct,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 8),
            child: correct
                ? const Icon(Icons.check_circle_rounded,
                    size: 18, color: Color(0xFF3E8E5A))
                : const Icon(Icons.cancel_rounded,
                    size: 18, color: Color(0xFFE86A5E)),
          ),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

/// The end-of-round score page shared by the MCQ-style math tools.
class MathScorePage extends StatelessWidget {
  final int correct;
  final int total;
  final Color accent;
  final int? best;
  final VoidCallback onRetry;
  final VoidCallback onExit;
  final String exitLabel;

  const MathScorePage({
    super.key,
    required this.correct,
    required this.total,
    required this.accent,
    required this.best,
    required this.onRetry,
    required this.onExit,
    this.exitLabel = 'Back to Math',
  });

  int get _stars {
    if (total == 0) return 0;
    final ratio = correct / total;
    if (ratio >= 1.0) return 3;
    if (ratio >= 0.8) return 2;
    if (ratio >= 0.6) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _stars == 3
                  ? Icons.emoji_events_rounded
                  : _stars >= 1
                      ? Icons.celebration_rounded
                      : Icons.fitness_center_rounded,
              size: 64,
              color: accent,
            ),
            const SizedBox(height: 12),
            Text(
              'You got $correct / $total',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: i < _stars ? 1 : 0.25),
                  duration: Duration(milliseconds: 300 + i * 120),
                  curve: Curves.elasticOut,
                  builder: (context, v, _) => Transform.scale(
                    scale: 0.7 + v * 0.5,
                    child: Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: i < _stars
                          ? const Color(0xFFE6B028)
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              _stars == 3
                  ? 'Perfect score! You nailed it.'
                  : _stars >= 1
                      ? 'Great job — try again for 3 stars!'
                      : 'Keep going — practice makes it click.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            if (best != null) ...[
              const SizedBox(height: 10),
              Text(
                'Best so far: $best',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: onExit,
                child: Text(exitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
