import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/books_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../data/models/book.dart';
import '../../widgets/empty_state.dart';
import 'widgets/filter_chips_bar.dart';
import 'widgets/book_grid_card.dart';

class MyBooksScreen extends ConsumerWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClasses = ref.watch(userSelectionProvider);
    final selectedBoard = ref.watch(userBoardProvider);
    final filteredBooks = ref.watch(filteredBooksProvider);
    final allSelectedBooks = ref.watch(selectedBooksProvider);

    final hasSelection = selectedClasses.isNotEmpty;

    // Group books by class
    final booksByClass = <int, List<Book>>{};
    for (var book in filteredBooks) {
      booksByClass.putIfAbsent(book.classNumber, () => []).add(book);
    }
    final sortedClasses = booksByClass.keys.toList()..sort();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              16,
              AppSpacing.screenPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Library',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  hasSelection
                      ? '${selectedClasses.map((c) => "Class $c").join(", ")} · $selectedBoard · ${allSelectedBooks.length} books'
                      : 'No class selected',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // ── Filter chips ──────────────────────────────────────
          if (hasSelection) ...[
            const SizedBox(height: 16),
            const FilterChipsBar(),
          ],

          const SizedBox(height: 12),

          // ── Book list or empty state ──────────────────────────
          Expanded(
            child: !hasSelection
                ? EmptyState(
                    emoji: '📖',
                    title: 'No class selected',
                    subtitle:
                        'Select your class to get started with your textbooks.',
                    ctaLabel: 'Select Class',
                    onCtaTap: () => context.push('/class-selector'),
                  )
                : filteredBooks.isEmpty
                ? EmptyState(
                    emoji: '🔍',
                    title: 'No books found',
                    subtitle: 'Try a different subject filter.',
                  )
                : CustomScrollView(
                    slivers: [
                      for (var classNum in sortedClasses) ...[
                        if (selectedClasses.length > 1)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenPadding,
                              16,
                              AppSpacing.screenPadding,
                              12,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                'Class $classNum',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return BookGridCard(
                                book: booksByClass[classNum]![index],
                              );
                            }, childCount: booksByClass[classNum]!.length),
                          ),
                        ),
                      ],
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                          vertical: 24,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _AddClassBanner(
                            onTap: () => context.push('/class-selector'),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddClassBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _AddClassBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Add another class',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
