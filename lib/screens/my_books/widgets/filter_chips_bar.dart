import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../providers/books_provider.dart';

class FilterChipsBar extends ConsumerWidget {
  const FilterChipsBar({super.key});

  static const _filters = [
    (null, 'All'),
    ('odia', 'Odia'),
    ('english', 'English'),
    ('maths', 'Maths'),
    ('hindi', 'Hindi'),
    ('sanskrit', 'Sanskrit'),
    ('science', 'Science'),
    ('social_science', 'Social Sci'),
    ('skill', 'Skill'),
    ('work', 'Work'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(subjectFilterProvider);
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = _filters[index];
          final isSelected = activeFilter == value;

          return GestureDetector(
            onTap: () {
              ref.read(subjectFilterProvider.notifier).setFilter(value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? cs.secondary : cs.surface,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                border: Border.all(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.3)
                      : cs.outline,
                ),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? cs.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
