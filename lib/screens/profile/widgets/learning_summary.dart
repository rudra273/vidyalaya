import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../providers/progress_provider.dart';

/// "My Learning" dashboard — the former Progress screen, merged into the Me
/// (Profile) page and reframed around *learning* activity (AI + tools + reading)
/// rather than reading alone. Drop into a scrolling Column.
class LearningSummary extends ConsumerWidget {
  const LearningSummary({super.key});

  // Daily learning goal, measured in pages read today (any activity keeps the
  // streak; the ring still tracks reading as the concrete daily target).
  static const int _dailyGoalPages = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(progressProvider);

    final goalProgress =
        (stats.pagesReadToday / _dailyGoalPages).clamp(0.0, 1.0);
    final pagesRemaining =
        (_dailyGoalPages - stats.pagesReadToday).clamp(0, _dailyGoalPages);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Learning', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),

        // Headline learning stats.
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: '🔥',
                title: 'Streak',
                value: stats.currentStreak.toString(),
                subtitle: 'Days',
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: '🤖',
                title: 'AI',
                value: stats.aiSessions.toString(),
                subtitle: 'Sessions',
                color: Colors.teal,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: '🧪',
                title: 'Tools',
                value: stats.toolsOpened.toString(),
                subtitle: 'Explored',
                color: Colors.indigo,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: '📖',
                title: 'Pages',
                value: stats.totalPagesRead.toString(),
                subtitle: 'Read',
                color: Colors.blue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: '⏳',
                title: 'Time',
                value: (stats.totalStudySeconds / 3600).toStringAsFixed(1),
                subtitle: 'Hours',
                color: Colors.purple,
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Daily learning goal ring.
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      color: cs.surfaceContainerHighest,
                    ),
                    CircularProgressIndicator(
                      value: goalProgress,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: cs.primary,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            stats.pagesReadToday.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                          ),
                          Text(
                            'pages',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Learning Goal',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pagesRemaining > 0
                          ? "You're $pagesRemaining pages away from today's goal. Keep going!"
                          : "Awesome! You've reached your daily goal!",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'SUBJECT FOCUS',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: stats.subjectPages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Read some books to see your subject focus here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              : Column(
                  children: _buildSubjectBars(
                    stats.subjectPages,
                    stats.totalPagesRead,
                  ),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildSubjectBars(Map<String, int> subjectPages, int totalPages) {
    if (totalPages == 0) return [];

    final sortedEntries = subjectPages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = <Color>[
      Colors.blueAccent,
      Colors.green,
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.purpleAccent,
      Colors.teal,
    ];

    final bars = <Widget>[];
    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final ratio = entry.value / totalPages;

      bars.add(
        _SubjectProgressBar(
          subject: entry.key,
          progress: ratio,
          color: colors[i % colors.length],
        ),
      );
      if (i < sortedEntries.length - 1) {
        bars.add(const SizedBox(height: 20));
      }
    }
    return bars;
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(icon, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressBar extends StatelessWidget {
  final String subject;
  final double progress;
  final Color color;

  const _SubjectProgressBar({
    required this.subject,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: (progress * 100).toInt(),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 100 - (progress * 100).toInt(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
