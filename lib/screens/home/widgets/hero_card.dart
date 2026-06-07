import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/models/book.dart';
import '../../../providers/user_selection_provider.dart';

class HeroCard extends ConsumerWidget {
  final Book? lastReadBook;

  const HeroCard({super.key, this.lastReadBook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lastReadBook != null) {
      return _ContinueReadingCard(book: lastReadBook!);
    }

    final selectedClasses = ref.watch(userSelectionProvider);
    if (selectedClasses.isNotEmpty) {
      return _LibraryHeroCard();
    }

    return _WelcomeHeroCard();
  }
}

class _LibraryHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final cardBg = isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.navy;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: isDark
            ? Border.all(color: AppColors.darkBorder)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⛅',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'Ready to study?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your textbooks are waiting in your library.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/library'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Go to Library →',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.onPrimary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    // Hero card has its own rich background — different in dark vs light
    final cardBg = isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.navy;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: isDark
            ? Border.all(color: AppColors.darkBorder)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📚',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome to Vidyālaya!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your class to start exploring your textbooks.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/class-selector'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Select Class →',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.onPrimary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final Book book;

  const _ContinueReadingCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final (subjectBg, _) =
        AppColors.getSubjectColorFor(book.subject, Theme.of(context).brightness);

    final cardBg = isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.navy;

    return GestureDetector(
      onTap: () => context.push('/reader/${book.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: isDark
              ? Border.all(color: AppColors.darkBorder)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CONTINUE READING',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    book.title,
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Class ${book.classNumber} · ${book.subject[0].toUpperCase()}${book.subject.substring(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Open book',
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          size: 14, color: Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: subjectBg.withValues(alpha: isDark ? 0.4 : 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  book.coverEmoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
