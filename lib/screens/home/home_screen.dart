import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/reading_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/progress_provider.dart';

import 'widgets/hero_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recently_added_row.dart';

/// AI-first Home dashboard. Leads with an "Ask AI" call-to-action and a learning
/// streak; reading is demoted below AI and is hidden when books are disabled.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadBook = ref.watch(readingProvider);
    final books = ref.watch(selectedBooksProvider);
    final booksEnabled = ref.watch(booksEnabledProvider);
    final streak = ref.watch(progressProvider).currentStreak;
    final cs = Theme.of(context).colorScheme;

    final showContinueReading = booksEnabled && lastReadBook != null;
    final showRecentlyAdded = booksEnabled && books.isNotEmpty;

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
                  if (streak > 0) ...[
                    _StreakChip(streak: streak),
                    const SizedBox(width: 12),
                  ],
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: cs.primary,
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

          // ── Ask AI hero (primary CTA) ───────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 0,
            ),
            sliver: SliverToBoxAdapter(
              child: _AskAiCard(onTap: () => context.go('/learn-ai')),
            ),
          ),

          // ── Jump back into reading (demoted below AI) ───────────
          if (showContinueReading) ...[
            const _MiniHeader('JUMP BACK IN'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 0,
              ),
              sliver: SliverToBoxAdapter(
                child: HeroCard(lastReadBook: lastReadBook),
              ),
            ),
          ],

          // ── Explore section ─────────────────────────────────────
          const _MiniHeader('EXPLORE'),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 0,
            ),
            sliver: const SliverToBoxAdapter(
              child: QuickActionsGrid(),
            ),
          ),

          // ── Recently added (books, gated) ───────────────────────
          if (showRecentlyAdded) ...[
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
                      onTap: () => context.go('/library'),
                      child: Text(
                        'See all',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.primary,
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

/// A compact uppercase section header used between Home blocks.
class _MiniHeader extends StatelessWidget {
  final String label;

  const _MiniHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding, 28, AppSpacing.screenPadding, 0,
      ),
      sliver: SliverToBoxAdapter(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

/// Learning-streak pill shown in the app bar (any learning activity counts).
class _StreakChip extends StatelessWidget {
  final int streak;

  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// The primary Home action: a big, friendly "Ask AI" card.
class _AskAiCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AskAiCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final cardBg = isDark ? AppColors.darkSurfaceElevated : AppColors.navy;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  Text(
                    'Learn with AI',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask any question or start a guided lesson.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ask AI',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: cs.onPrimary),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: cs.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
