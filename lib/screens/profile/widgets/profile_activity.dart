import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'settings_group.dart';

enum _Metric {
  studyTime('Study time', '2h 30m', 'Total study time', ' min', 45, [
    20,
    35,
    0,
    25,
    30,
    40,
    0,
  ]),
  tests('Tests', '4 tests', 'Tests completed', '', 2, [1, 1, 0, 0, 1, 1, 0]),
  scores('Scores', '85%', 'Average score · 4 tests', '%', 100, [
    80,
    90,
    null,
    null,
    75,
    95,
    null,
  ]);

  const _Metric(
    this.label,
    this.total,
    this.caption,
    this.unit,
    this.max,
    this.dailyValues,
  );

  final String label;
  final String total;
  final String caption;
  final String unit;
  final int max;
  final List<int?> dailyValues;
}

class ProfileActivityCard extends StatefulWidget {
  const ProfileActivityCard({
    super.key,
    required this.onProgress,
    required this.locked,
  });

  final VoidCallback onProgress;
  final bool locked;

  @override
  State<ProfileActivityCard> createState() => _ProfileActivityCardState();
}

class _ProfileActivityCardState extends State<ProfileActivityCard> {
  _Metric _metric = _Metric.studyTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
                Text(
                  'Weekly overview · Demo data',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Container(
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
                                  constraints: const BoxConstraints(
                                    minHeight: 44,
                                  ),
                                  child: Center(
                                    child: Text(
                                      metric.label,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
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
                ),
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_metric.total, style: theme.textTheme.headlineSmall),
                      Text(_metric.caption, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: _ActivityBar(
                          day: labels[i],
                          value: _metric.dailyValues[i],
                          unit: _metric.unit,
                          maximum: _metric.max,
                        ),
                      ),
                  ],
                ),
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

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.day,
    required this.value,
    required this.unit,
    required this.maximum,
  });

  final String day;
  final int? value;
  final String unit;
  final int maximum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueLabel = value == null ? '—' : '$value';
    final description = value == null ? 'No test' : '$value$unit';
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
              height: 84 * (value ?? 0) / maximum,
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
