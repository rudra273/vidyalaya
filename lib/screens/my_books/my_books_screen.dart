import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/books_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/filter_chips_bar.dart';
import 'widgets/book_card.dart';

class MyBooksScreen extends ConsumerWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClasses = ref.watch(userSelectionProvider);
    final filteredBooks = ref.watch(filteredBooksProvider);
    final allSelectedBooks = ref.watch(selectedBooksProvider);


    final hasSelection = selectedClasses.isNotEmpty;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Books',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  hasSelection
                      ? '${selectedClasses.map((c) => "Class $c").join(", ")} · Odia Medium · ${allSelectedBooks.length} books'
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
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                        ),
                        itemCount: filteredBooks.length + 1, // +1 for add banner
                        itemBuilder: (context, index) {
                          if (index == filteredBooks.length) {
                            return _AddClassBanner(
                              onTap: () => context.push('/class-selector'),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BookCard(book: filteredBooks[index]),
                          );
                        },
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
              Icon(Icons.add_circle_outline,
                  size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Add another class',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
