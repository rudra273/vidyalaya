import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/repositories/user_prefs_repository.dart';
import '../../../providers/app_usage_provider.dart';
import 'settings_group.dart';

enum _Metric {
  studyTime('Study time'),
  tests('Tests'),
  scores('Scores');

  const _Metric(this.label);

  final String label;
}

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Placeholder bars for the tabs that are not built yet. They sit under the
/// "Coming soon" veil, so they only show the shape of the chart.
const _demoTests = [1, 1, 0, 0, 1, 1, 0];
const _demoScores = [80, 90, null, null, 75, 95, null];

/// "45m", "1h 5m", "2h".
String formatStudyMinutes(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// Short bar label that fits a seventh of the card: "45", "1.5h".
String _shortMinutes(int minutes) {
  if (minutes < 60) return '$minutes';
  final hours = minutes / 60;
  return hours >= 10 || minutes % 60 == 0
      ? '${hours.round()}h'
      : '${hours.toStringAsFixed(1)}h';
}

/// Minutes of app use for each day of the current week, Monday first.
List<int> weekAppUseMinutes(Map<String, int> secondsByDay, DateTime today) {
  final monday = DateTime(
    today.year,
    today.month,
    today.day,
  ).subtract(Duration(days: today.weekday - DateTime.monday));
  return [
    for (var i = 0; i < 7; i++)
      (secondsByDay[UserPrefsRepository.dayKey(
                DateTime(monday.year, monday.month, monday.day + i),
              )] ??
              0) ~/
          60,
  ];
}

class ProfileActivityCard extends ConsumerStatefulWidget {
  const ProfileActivityCard({
    super.key,
    required this.onProgress,
    required this.locked,
  });

  final VoidCallback onProgress;
  final bool locked;

  @override
  ConsumerState<ProfileActivityCard> createState() =>
      _ProfileActivityCardState();
}

class _ProfileActivityCardState extends ConsumerState<ProfileActivityCard> {
  _Metric _metric = _Metric.studyTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();
    final week = weekAppUseMinutes(ref.watch(appUsageProvider), now);
    final weekTotal = week.fold<int>(0, (sum, m) => sum + m);
    // Future days of the week stay empty rather than showing 0.
    final todayIndex = now.weekday - DateTime.monday;

    final tabs = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.paperDark
            : AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final metric in _Metric.values)
            Expanded(
              child: Semantics(
                selected: metric == _metric,
                child: Material(
                  color: metric == _metric
                      ? (theme.brightness == Brightness.dark
                            ? AppColors.surface3Dark
                            : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () => setState(() => _metric = metric),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Center(
                        child: Text(
                          metric.label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: metric == _metric
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final Widget body;
    if (_metric == _Metric.studyTime) {
      final barMax = week.fold<int>(30, (top, m) => m > top ? m : top);
      body = _MetricBody(
        total: formatStudyMinutes(weekTotal),
        caption: 'Time in Vidyakalp this week',
        bars: [
          for (var i = 0; i < 7; i++)
            _ActivityBar(
              day: _dayLabels[i],
              value: i > todayIndex ? null : week[i],
              valueLabel: i > todayIndex ? '' : _shortMinutes(week[i]),
              description: i > todayIndex
                  ? 'Not yet'
                  : formatStudyMinutes(week[i]),
              maximum: barMax,
            ),
        ],
      );
    } else {
      final scores = _metric == _Metric.scores;
      final values = scores ? _demoScores : _demoTests;
      body = _ComingSoon(
        child: _MetricBody(
          total: scores ? '85%' : '4 tests',
          caption: scores ? 'Average score' : 'Tests completed',
          bars: [
            for (var i = 0; i < 7; i++)
              _ActivityBar(
                day: _dayLabels[i],
                value: values[i],
                valueLabel: values[i] == null ? '—' : '${values[i]}',
                description: '',
                maximum: scores ? 100 : 2,
              ),
          ],
        ),
      );
    }

    final card = Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This week', style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                tabs,
                const SizedBox(height: 12),
                body,
              ],
            ),
          ),
          const Divider(height: 1),
          SettingsRow(
            color: colors.primary,
            icon: Icons.insights_rounded,
            title: 'My progress',
            onTap: widget.onProgress,
          ),
        ],
      ),
    );

    if (!widget.locked) return card;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: ExcludeFocus(
              child: IgnorePointer(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: card,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: colors.surface.withValues(alpha: 0.50)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sign in to view your learning activity',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// The headline number, its caption and the seven day bars.
class _MetricBody extends StatelessWidget {
  const _MetricBody({
    required this.total,
    required this.caption,
    required this.bars,
  });

  final String total;
  final String caption;
  final List<Widget> bars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(total, style: theme.textTheme.headlineSmall),
              Text(caption, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [for (final bar in bars) Expanded(child: bar)],
        ),
      ],
    );
  }
}

// ─── Coming soon veil ───────────────────────────────────────────────────
// Tests and Scores are not recorded yet, so their placeholder chart sits under
// a light blur with a "Coming soon" note: the shape of the feature shows
// through, the made-up figures don't read as real. The tabs above stay clear
// so the student can switch back to Study time.

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeSemantics(
          child: ExcludeFocus(
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: child,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: colors.surface.withValues(alpha: 0.35)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'Coming soon',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.day,
    required this.value,
    required this.valueLabel,
    required this.description,
    required this.maximum,
  });

  final String day;
  final int? value;
  final String valueLabel;
  final String description;
  final int maximum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maximum <= 0
        ? 0.0
        : ((value ?? 0) / maximum).clamp(0.0, 1.0);
    return Semantics(
      label: '$day, $description',
      excludeSemantics: true,
      child: Tooltip(
        message: '$day · $description',
        child: Column(
          children: [
            Text(valueLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            SizedBox(
              height: 84 * fraction,
              width: 18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outline),
            const SizedBox(height: 5),
            Text(day, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
