import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/reading_provider.dart';
import '../../providers/books_provider.dart';

import 'widgets/hero_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recently_added_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadBook = ref.watch(readingProvider);
    final books = ref.watch(selectedBooksProvider);


    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Vidyālaya',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Hero card ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: HeroCard(lastReadBook: lastReadBook),
            ),
          ),

          // ── Explore section ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'EXPLORE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: QuickActionsGrid(
                bookCount: books.length,
              ),
            ),
          ),

          // ── Recently added ──────────────────────────────────────
          if (books.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENTLY ADDED',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/my-books'),
                      child: Text(
                        'See all',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              sliver: SliverToBoxAdapter(
                child: RecentlyAddedRow(books: books),
              ),
            ),
          ],

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}
