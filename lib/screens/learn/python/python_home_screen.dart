import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/programming/python_course_data.dart';
import '../../../data/programming/python_models.dart';
import '../../../providers/python_progress_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/calm_widgets.dart';
import '../../../widgets/pressable.dart';

// ─── Python home ──────────────────────────────────────────────────────────────
//
// Course map: an overall progress ring, a pinned Playground card, and chapters
// grouped by level with completion + quiz stars.

class PythonHomeScreen extends ConsumerWidget {
  const PythonHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(pythonProgressProvider);
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cPythonDark
        : AppColors.cPython;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Python')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const PageTitle(
            title: 'Learn Python',
            sub: 'Code step by step — read, run, and play 🐍',
          ),
          const SizedBox(height: 8),
          _HeaderCard(progress: progress, accent: accent),
          const SizedBox(height: 8),
          _PlaygroundCard(accent: accent),
          for (final level in PythonLevel.values)
            _LevelSection(level: level, progress: progress, accent: accent),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final PythonProgress progress;
  final Color accent;
  const _HeaderCard({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = progress.completedCount;
    final total = pythonTotalLessons;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          _ProgressRing(fraction: progress.overallFraction(), accent: accent),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your progress',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$done of $total lessons complete',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double fraction;
  final Color accent;
  const _ProgressRing({required this.fraction, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction,
          accent: accent,
          track: Theme.of(context).colorScheme.outlineVariant,
        ),
        child: Center(
          child: Text(
            '${(fraction * 100).round()}%',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w800, color: accent),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color accent;
  final Color track;
  _RingPainter(
      {required this.fraction, required this.accent, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final progressPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.accent != accent;
}

class _PlaygroundCard extends ConsumerWidget {
  final Color accent;
  const _PlaygroundCard({required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 4),
      child: Pressable(
        onTap: () {
          Haptics.light(ref);
          context.push('/learn/python/playground');
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? cs.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              const Text('🧪', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Playground',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Write and run any code you like',
                        style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  final PythonLevel level;
  final PythonProgress progress;
  final Color accent;

  const _LevelSection({
    required this.level,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final chapters = pythonChaptersFor(level);
    if (chapters.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 22, AppSpacing.screenPadding, 4),
          child: SectionHead(label: level.label),
        ),
        ...chapters.map((c) => _ChapterCard(
              chapter: c,
              progress: progress,
              accent: accent,
            )),
      ],
    );
  }
}

class _ChapterCard extends ConsumerWidget {
  final PythonChapter chapter;
  final PythonProgress progress;
  final Color accent;

  const _ChapterCard({
    required this.chapter,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final doneCount = progress.completedInChapter(chapter);
    final total = chapter.lessons.length;
    final stars = progress.chapterStars(chapter);
    final complete = progress.isChapterComplete(chapter);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 6, AppSpacing.screenPadding, 6),
      child: Pressable(
        onTap: () {
          Haptics.light(ref);
          context.push('/learn/python/chapter/${chapter.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? cs.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: complete
                  ? accent.withValues(alpha: 0.4)
                  : cs.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                ),
                child: Text(chapter.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chapter.subtitle,
                      style: TextStyle(color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$doneCount/$total lessons',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 10),
                        ...List.generate(3, (i) {
                          return Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: i < stars
                                ? const Color(0xFFE6B028)
                                : cs.outlineVariant,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
