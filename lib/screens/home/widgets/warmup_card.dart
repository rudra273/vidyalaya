import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/seed/warmup_data.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/user_selection_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/calm_widgets.dart';
import '../../../widgets/pressable.dart';

// ─── Today's warm-up ──────────────────────────────────────────────────────
// One multiple-choice question a day, from the static seed pool. A correct
// answer counts as learning activity (it keeps the streak alive), and either
// way the card stays answered for the rest of the day so it can't be farmed.

class WarmupCard extends ConsumerStatefulWidget {
  final WarmupQuestion question;

  const WarmupCard({super.key, required this.question});

  @override
  ConsumerState<WarmupCard> createState() => _WarmupCardState();
}

class _WarmupCardState extends ConsumerState<WarmupCard> {
  int? _picked;
  bool _revealed = false;
  bool _wasCorrect = false;

  /// Extra questions the student pulled up with "Next" after finishing the
  /// day's one. Only the first (index 0) counts toward the streak — the rest
  /// are practice, so the daily card still can't be farmed.
  late WarmupQuestion _question = widget.question;
  int _extra = 0;

  @override
  void initState() {
    super.initState();
    // Already answered today? Come back showing the answer, not a fresh quiz.
    final answered = ref
        .read(userPrefsRepositoryProvider)
        .getWarmupAnsweredToday();
    if (answered != null && answered.id == widget.question.id) {
      _revealed = true;
      _wasCorrect = answered.correct;
      // On a wrong answer we no longer know which option was tapped, so only
      // the right one is highlighted — never the student's mistake, guessed.
      _picked = answered.correct ? widget.question.answerIndex : null;
    }
  }

  Future<void> _pick(int index) async {
    if (_revealed) return;
    final correct = index == _question.answerIndex;
    Haptics.light(ref);
    setState(() {
      _picked = index;
      _revealed = true;
      _wasCorrect = correct;
    });
    if (_extra > 0) return; // practice question — nothing to record
    await ref
        .read(userPrefsRepositoryProvider)
        .recordWarmupAnswered(_question.id, correct: correct);
    if (!mounted) return;
    if (correct) ref.read(progressProvider.notifier).refresh();
  }

  /// Walk the pool forward from the day's question, keeping the class filter.
  void _next() {
    Haptics.light(ref);
    final selected = ref.read(userSelectionProvider);
    final pool = warmupPool(
      classNo: selected.isEmpty ? null : (selected.toList()..sort()).first,
    );
    final start = pool.indexWhere((q) => q.id == widget.question.id);
    final next = pool[((start < 0 ? 0 : start) + _extra + 1) % pool.length];
    setState(() {
      _extra++;
      _question = next;
      _picked = null;
      _revealed = false;
      _wasCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _question;
    final accent = AppColors.subjectColor(
      question.subject,
      Theme.of(context).brightness,
    );
    final meta = subjectMeta(question.subject);
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad - 2),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject eyebrow + answered badge
          Row(
            children: [
              SubjectGlyph(meta: meta, size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '1 MIN · ${meta.label.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: accent,
                  ),
                ),
              ),
              if (_revealed)
                Row(
                  children: [
                    Icon(
                      _wasCorrect
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                      size: 15,
                      color: _wasCorrect ? cs.primary : muted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _wasCorrect ? 'Correct' : 'Answer below',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _wasCorrect ? cs.primary : muted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            question.question,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 17, height: 1.28),
          ),
          const SizedBox(height: 12),

          // Chips stay visually lighter than the question — the answers are
          // the response, not the headline.
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < question.options.length; i++)
                _OptionChip(
                  label: question.options[i],
                  state: _stateFor(i),
                  onTap: () => _pick(i),
                ),
            ],
          ),

          if (_revealed) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: cs.outline),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 15, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.explanation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12.5,
                      height: 1.45,
                      color: muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Pressable(
                    onTap: () {
                      Haptics.light(ref);
                      context.push(
                        '/learn/ai'
                        '?prefill=${Uri.encodeComponent(question.question)}'
                        '&style=simple',
                      );
                    },
                    scale: 0.98,
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 15,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Ask the AI to explain this',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Keep practising past the daily question.
                Pressable(
                  onTap: _next,
                  scale: 0.95,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  _OptionState _stateFor(int index) {
    if (!_revealed) return _OptionState.idle;
    if (index == widget.question.answerIndex) return _OptionState.correct;
    if (index == _picked) return _OptionState.wrong;
    return _OptionState.dimmed;
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionChip extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var background = isDark ? AppColors.surface2Dark : AppColors.surface2;
    var border = cs.outline;
    var ink = cs.onSurface;
    IconData? icon;

    switch (state) {
      case _OptionState.idle:
        break;
      case _OptionState.correct:
        background = Color.alphaBlend(
          cs.primary.withValues(alpha: 0.14),
          cs.surface,
        );
        border = cs.primary.withValues(alpha: 0.45);
        ink = cs.primary;
        icon = Icons.check_rounded;
        break;
      case _OptionState.wrong:
        background = Color.alphaBlend(
          cs.error.withValues(alpha: 0.12),
          cs.surface,
        );
        border = cs.error.withValues(alpha: 0.40);
        ink = cs.error;
        icon = Icons.close_rounded;
        break;
      case _OptionState.dimmed:
        ink = isDark ? AppColors.ink3Dark : AppColors.ink3;
        break;
    }

    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: ink),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
