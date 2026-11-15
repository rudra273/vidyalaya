import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../widgets/pressable.dart';

// ─── Streak week ────────────────────────────────────────────────────────
// The current streak, with this week's days ticked: every day inside the
// streak (which always ends today, since opening the app records activity).

class StreakWeek extends StatelessWidget {
  const StreakWeek({super.key, required this.streak, required this.onTap});

  final int streak;
  final VoidCallback onTap;

  static const _flame = Color(0xFFF0884A);
  static const _flameInk = Color(0xFFA8501A);
  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final todayIndex = today.weekday - 1; // Monday = 0
    final empty = dark ? AppColors.surface3Dark : AppColors.surface3;

    return Semantics(
      button: true,
      label: '$streak day streak. Open progress',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 20,
                        color: _flame,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: TextStyle(
                          fontSize: AppFontSize.headingSmall,
                          fontWeight: AppFontWeight.bold,
                          color: dark ? _flame : _flameInk,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'day streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _day(
                            context,
                            label: _labels[i],
                            done: i <= todayIndex && todayIndex - i < streak,
                            isToday: i == todayIndex,
                            empty: empty,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _day(
    BuildContext context, {
    required String label,
    required bool done,
    required bool isToday,
    required Color empty,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? _flame : empty,
            shape: BoxShape.circle,
            border: isToday && !done
                ? Border.all(color: _flame, width: 2)
                : null,
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.small,
            fontWeight: isToday ? AppFontWeight.bold : AppFontWeight.medium,
            color: isToday
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
