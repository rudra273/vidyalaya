import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../profile/widgets/learning_summary.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(
      progressProvider.select((stats) => stats.currentStreak),
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            PageTitle(
              title: 'My Learning',
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/profile'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                16,
                AppSpacing.screenPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LearningStreakCard(days: streak),
                  const SizedBox(height: AppSpacing.sectionGap),
                  const LearningSummary(showHeader: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningStreakCard extends StatelessWidget {
  const _LearningStreakCard({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFEDF6E8) : const Color(0xFF203327);
    final today = DateTime.now();
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? AppColors.streakSurfaceDark : AppColors.streakSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning streak',
            style: theme.textTheme.labelLarge?.copyWith(color: ink),
          ),
          const SizedBox(height: 4),
          Text(
            days == 1 ? '1 day. A good start.' : '$days day streak',
            style: theme.textTheme.headlineSmall?.copyWith(color: ink),
          ),
          const SizedBox(height: 4),
          Text(
            days == 0
                ? 'Study today to start your streak.'
                : 'Come back tomorrow to keep it going.',
            style: theme.textTheme.bodyMedium?.copyWith(color: ink),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final offset = today.weekday - i - 1;
                      final completed = offset >= 0 && offset < days;
                      return Semantics(
                        label:
                            '${labels[i]}, ${completed ? 'in current streak' : 'outside current streak'}',
                        excludeSemantics: true,
                        child: Column(
                          children: [
                            Text(
                              labels[i],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 5),
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: completed
                                  ? ink
                                  : ink.withValues(alpha: .12),
                              foregroundColor: completed
                                  ? (dark
                                        ? AppColors.streakSurfaceDark
                                        : Colors.white)
                                  : ink,
                              child: Icon(
                                completed ? Icons.check : Icons.remove,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
