import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../data/programming/python_course_data.dart';
import '../../../data/programming/python_models.dart';
import '../../../providers/python_progress_provider.dart';
import '../../../utils/haptics.dart';

// ─── Quiz screen ──────────────────────────────────────────────────────────────
//
// One question per page. Tapping an option locks it in, tints green/red and
// shows the explanation; then "Next". The final page shows the star score and
// records the best via the progress provider.

class PythonQuizScreen extends ConsumerStatefulWidget {
  final String chapterId;
  const PythonQuizScreen({super.key, required this.chapterId});

  @override
  ConsumerState<PythonQuizScreen> createState() => _PythonQuizScreenState();
}

class _PythonQuizScreenState extends ConsumerState<PythonQuizScreen> {
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final chapter = pythonChapterById(widget.chapterId);
    if (chapter == null || chapter.quiz.isEmpty) {
      return const Scaffold(body: Center(child: Text('Quiz not found')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('${chapter.title} · Quiz')),
      body: _finished
          ? _ScorePage(
              chapter: chapter,
              correct: _correct,
              onRetry: () => setState(() {
                _index = 0;
                _selected = null;
                _answered = false;
                _correct = 0;
                _finished = false;
              }),
            )
          : _questionView(chapter),
    );
  }

  Widget _questionView(PythonChapter chapter) {
    final q = chapter.quiz[_index];
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cPythonDark
        : AppColors.cPython;
    final isLast = _index == chapter.quiz.length - 1;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Text(
          'Question ${_index + 1} of ${chapter.quiz.length}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          q.prompt,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, height: 1.35),
        ),
        if (q.code != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1512),
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              border: Border.all(color: const Color(0xFF25322B)),
            ),
            child: Text(
              q.code!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13.5,
                height: 1.55,
                color: const Color(0xFFE6EDE8),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionTile(
              label: q.options[i],
              state: _optionState(q, i),
              accent: accent,
              onTap: _answered ? null : () => _answer(q, i),
            ),
          );
        }),
        if (_answered) ...[
          const SizedBox(height: 4),
          Container(
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
                  child: _selected == q.correctIndex
                      ? const Icon(Icons.check_circle_rounded,
                          size: 18, color: Color(0xFF3E8E5A))
                      : const Icon(Icons.cancel_rounded,
                          size: 18, color: Color(0xFFE86A5E)),
                ),
                Expanded(
                  child: Text(q.explanation,
                      style: const TextStyle(height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _next(chapter, isLast),
            icon: Icon(
                isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded),
            label: Text(isLast ? 'See results' : 'Next question'),
          ),
        ],
      ],
    );
  }

  _OptionState _optionState(PyQuizQuestion q, int i) {
    if (!_answered) return _OptionState.idle;
    if (i == q.correctIndex) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.dim;
  }

  void _answer(PyQuizQuestion q, int i) {
    final right = i == q.correctIndex;
    right ? Haptics.medium(ref) : Haptics.error(ref);
    setState(() {
      _selected = i;
      _answered = true;
      if (right) _correct++;
    });
  }

  void _next(PythonChapter chapter, bool isLast) {
    if (isLast) {
      ref
          .read(pythonProgressProvider.notifier)
          .recordQuizScore(chapter.id, _correct);
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    }
  }
}

enum _OptionState { idle, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  final String label;
  final _OptionState state;
  final Color accent;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.state,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color border = cs.outlineVariant;
    Color bg = Theme.of(context).brightness == Brightness.dark
        ? cs.surface
        : Colors.white;
    Color? fg;

    switch (state) {
      case _OptionState.correct:
        border = const Color(0xFF3E8E5A);
        bg = const Color(0xFF3E8E5A).withValues(alpha: 0.15);
        fg = const Color(0xFF2C7A48);
      case _OptionState.wrong:
        border = const Color(0xFFC0483C);
        bg = const Color(0xFFC0483C).withValues(alpha: 0.12);
        fg = const Color(0xFFB0433A);
      case _OptionState.dim:
        bg = bg.withValues(alpha: 0.5);
      case _OptionState.idle:
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
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                ),
              ),
              if (state == _OptionState.correct)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2C7A48)),
              if (state == _OptionState.wrong)
                const Icon(Icons.cancel_rounded, color: Color(0xFFB0433A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePage extends ConsumerWidget {
  final PythonChapter chapter;
  final int correct;
  final VoidCallback onRetry;

  const _ScorePage({
    required this.chapter,
    required this.correct,
    required this.onRetry,
  });

  int get _stars {
    final ratio = correct / chapter.quiz.length;
    if (ratio >= 1.0) return 3;
    if (ratio >= 0.8) return 2;
    if (ratio >= 0.6) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cPythonDark
        : AppColors.cPython;
    final total = chapter.quiz.length;

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
            const SizedBox(height: 8),
            Text(
              _stars == 3
                  ? 'Perfect score! You nailed it.'
                  : _stars >= 1
                      ? 'Great job — try again for 3 stars!'
                      : 'Keep going — review the lessons and retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
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
                onPressed: () => context.pop(),
                child: const Text('Back to chapter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
