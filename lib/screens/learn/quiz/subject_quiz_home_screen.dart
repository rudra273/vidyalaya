import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/quiz/quiz_bank.dart';
import '../../../data/quiz/quiz_models.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../providers/user_selection_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/pressable.dart';

// ─── Subject quiz hub ─────────────────────────────────────────────────────────
//
// Pick a class band (defaulting to the student's highest selected class), then
// a subject. Each row shows the student's best score for that subject + band.

Color quizSubjectAccent(BuildContext context, QuizSubject subject) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (subject) {
    QuizSubject.science => dark ? AppColors.cScienceDark : AppColors.cScience,
    QuizSubject.social => dark ? AppColors.cTimelineDark : AppColors.cTimeline,
    QuizSubject.english => dark ? AppColors.cEnglishDark : AppColors.cEnglish,
  };
}

IconData quizSubjectIcon(QuizSubject subject) => switch (subject) {
  QuizSubject.science => Icons.science_rounded,
  QuizSubject.social => Icons.public_rounded,
  QuizSubject.english => Icons.menu_book_rounded,
};

class SubjectQuizHomeScreen extends ConsumerStatefulWidget {
  const SubjectQuizHomeScreen({super.key});

  @override
  ConsumerState<SubjectQuizHomeScreen> createState() =>
      _SubjectQuizHomeScreenState();
}

class _SubjectQuizHomeScreenState extends ConsumerState<SubjectQuizHomeScreen> {
  /// Starts at the highest class picked on Explore; the header menu overrides.
  late QuizBand _band;

  @override
  void initState() {
    super.initState();
    _band = QuizBand.forClasses(ref.read(exploreClassSelectionProvider));
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(mathProgressProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Subject Quiz'),
        actions: [
          PopupMenuButton<QuizBand>(
            tooltip: 'Class band',
            initialValue: _band,
            onSelected: (b) => setState(() => _band = b),
            itemBuilder: (_) => [
              for (final b in QuizBand.values)
                PopupMenuItem(value: b, child: Text(b.label)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _band.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          for (final subject in QuizSubject.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuizRow(
                title: subject.label,
                blurb: subject.blurb,
                icon: quizSubjectIcon(subject),
                accent: quizSubjectAccent(context, subject),
                best: progress.bestFor(quizToolId(subject, _band)),
                onTap: () {
                  Haptics.light(ref);
                  context.push('/learn/quiz/${subject.name}/${_band.name}');
                },
              ),
            ),
          // Math generates its questions for the student's class, so it has no
          // band — it lives here so every quiz is in one place.
          _QuizRow(
            title: 'Math',
            blurb: 'Numbers, fractions, mixed practice',
            icon: Icons.calculate_rounded,
            accent: dark ? AppColors.cMathHubDark : AppColors.cMathHub,
            best: progress.bestFor('math-quiz'),
            onTap: () {
              Haptics.light(ref);
              context.push('/learn/math/quiz');
            },
          ),
        ],
      ),
    );
  }
}

class _QuizRow extends StatelessWidget {
  final String title;
  final String blurb;
  final IconData icon;
  final Color accent;
  final int? best;
  final VoidCallback onTap;

  const _QuizRow({
    required this.title,
    required this.blurb,
    required this.icon,
    required this.accent,
    required this.best,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent),
            ),
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
                    best == null
                        ? blurb
                        : 'Best $best/$quizQuestionsPerRound',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: best == null ? AppColors.textMuted : accent,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
