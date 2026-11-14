import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../providers/progress_provider.dart';
import '../../../widgets/calm_widgets.dart';

/// "My Learning" dashboard — the former Progress screen, merged into the Me
/// (Profile) page and reframed around *learning* activity (AI + tools + reading)
/// rather than reading alone. Drop into a scrolling Column.
class LearningSummary extends ConsumerWidget {
  /// Whether to render the inline "My Learning" title. The standalone Progress
  /// page sets this false (it shows the title in its header instead).
  final bool showHeader;

  const LearningSummary({super.key, this.showHeader = true});

  // Daily learning goal, measured in pages read today (any activity keeps the
  // streak; the ring still tracks reading as the concrete daily target).
  static const int _dailyGoalPages = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final ink2 = isDark ? AppColors.ink2Dark : AppColors.ink2;
    final stats = ref.watch(progressProvider);

    final goalProgress = (stats.pagesReadToday / _dailyGoalPages).clamp(
      0.0,
      1.0,
    );
    final pagesRemaining = (_dailyGoalPages - stats.pagesReadToday).clamp(
      0,
      _dailyGoalPages,
    );

    Color hue(Color light, Color dark) => isDark ? dark : light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text('My Learning', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
        ],

        // ── Headline learning stats ───────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.auto_awesome_rounded,
                value: stats.aiSessions.toString(),
                label: 'AI sessions',
                color: hue(AppColors.cAi, AppColors.cAiDark),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.science_outlined,
                value: stats.toolsOpened.toString(),
                label: 'Tools explored',
                color: hue(AppColors.cTutor, AppColors.cTutorDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.menu_book_rounded,
                value: stats.totalPagesRead.toString(),
                label: 'Pages read',
                color: hue(AppColors.cEnglish, AppColors.cEnglishDark),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.schedule_rounded,
                value: (stats.totalStudySeconds / 3600).toStringAsFixed(1),
                label: 'Hours studied',
                color: hue(AppColors.cPeriodic, AppColors.cPeriodicDark),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // ── Daily learning goal ring ──────────────────────────
        const SectionHead(label: 'Today'),
        _Card(
          child: Row(
            children: [
              SizedBox(
                height: 92,
                width: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 9,
                      color: isDark
                          ? AppColors.surface3Dark
                          : AppColors.surface3,
                    ),
                    CircularProgressIndicator(
                      value: goalProgress,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      color: cs.primary,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            stats.pagesReadToday.toString(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: AppFontWeight.bold,
                              color: cs.primary,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'pages',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily learning goal',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pagesRemaining > 0
                          ? "You're $pagesRemaining pages away from today's goal. Keep going!"
                          : "Awesome! You've reached your daily goal!",
                      style: theme.textTheme.bodyMedium?.copyWith(color: ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // ── Subject focus ─────────────────────────────────────
        const SectionHead(label: 'Subject focus'),
        _Card(
          child: stats.subjectPages.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Tile(
                        color: hue(AppColors.cEnglish, AppColors.cEnglishDark),
                        icon: Icons.auto_stories_outlined,
                        size: 36,
                        iconSize: 20,
                        radius: 11,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Read some books to see your subject focus here.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ink2,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: _buildSubjectBars(
                    stats.subjectPages,
                    stats.totalPagesRead,
                    theme.brightness,
                  ),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildSubjectBars(
    Map<String, int> subjectPages,
    int totalPages,
    Brightness brightness,
  ) {
    if (totalPages == 0) return [];

    final sortedEntries = subjectPages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bars = <Widget>[];
    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final ratio = entry.value / totalPages;
      // Keys are display labels ("Maths", "Social"); the subject palette keys
      // off the lower-cased family name, falling back to brand green.
      final key = entry.key.toLowerCase().replaceAll(' ', '_');

      bars.add(
        _SubjectProgressBar(
          subject: entry.key,
          progress: ratio,
          color: AppColors.subjectColor(key, brightness),
        ),
      );
      if (i < sortedEntries.length - 1) {
        bars.add(const SizedBox(height: 18));
      }
    }
    return bars;
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────
// The app's standard card: surface fill and card radius; a hairline edge in
// light, none in dark (dark cards read by their lighter surface).

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPad),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surface,
        border: isDark ? null : Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: child,
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tile(color: color, icon: icon, size: 34, iconSize: 19, radius: 10),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: AppFontSize.heading,
                fontWeight: AppFontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? AppColors.ink2Dark : AppColors.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subject progress bar ─────────────────────────────────────────────────

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(subject, style: theme.textTheme.titleSmall)),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            color: color,
            backgroundColor: isDark
                ? AppColors.surface3Dark
                : AppColors.surface3,
          ),
        ),
      ],
    );
  }
}
