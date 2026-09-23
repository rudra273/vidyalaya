import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/programming/python_course_data.dart';
import '../../../providers/python_progress_provider.dart';
import '../../../utils/haptics.dart';

// ─── Chapter screen ───────────────────────────────────────────────────────────
//
// Lists a chapter's lessons (with completion ticks) and a quiz row showing best
// stars earned.

class PythonChapterScreen extends ConsumerWidget {
  final String chapterId;
  const PythonChapterScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = pythonChapterById(chapterId);
    if (chapter == null) {
      return const Scaffold(body: Center(child: Text('Chapter not found')));
    }
    final progress = ref.watch(pythonProgressProvider);
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cPythonDark
        : AppColors.cPython;
    final stars = progress.chapterStars(chapter);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(chapter.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(
            chapter.subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          ...chapter.lessons.asMap().entries.map((entry) {
            final i = entry.key;
            final lesson = entry.value;
            final done = progress.isLessonDone(lesson.id);
            return _LessonRow(
              number: i + 1,
              title: lesson.title,
              done: done,
              accent: accent,
              onTap: () {
                Haptics.light(ref);
                context.push('/learn/python/lesson/${lesson.id}');
              },
            );
          }),
          const SizedBox(height: 16),
          _QuizRow(
            accent: accent,
            stars: stars,
            questions: chapter.quiz.length,
            onTap: () {
              Haptics.light(ref);
              context.push('/learn/python/quiz/${chapter.id}');
            },
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final int number;
  final String title;
  final bool done;
  final Color accent;
  final VoidCallback onTap;

  const _LessonRow({
    required this.number,
    required this.title,
    required this.done,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? cs.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done
                        ? accent.withValues(alpha: 0.18)
                        : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: done
                      ? Icon(Icons.check_rounded, size: 20, color: accent)
                      : Text('$number',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizRow extends StatelessWidget {
  final Color accent;
  final int stars;
  final int questions;
  final VoidCallback onTap;

  const _QuizRow({
    required this.accent,
    required this.stars,
    required this.questions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.psychology_rounded, size: 24, color: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chapter Quiz',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('$questions questions',
                        style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Row(
                children: List.generate(3, (i) {
                  return Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: i < stars
                        ? const Color(0xFFE6B028)
                        : Theme.of(context).colorScheme.outlineVariant,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
