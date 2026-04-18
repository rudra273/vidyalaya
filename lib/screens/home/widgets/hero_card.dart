import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/models/book.dart';

class HeroCard extends StatelessWidget {
  final Book? lastReadBook;

  const HeroCard({super.key, this.lastReadBook});

  @override
  Widget build(BuildContext context) {
    if (lastReadBook == null) {
      return _WelcomeHeroCard();
    }
    return _ContinueReadingCard(book: lastReadBook!);
  }
}

class _WelcomeHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Select Class →',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
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
    final (subjectBg, _) = AppColors.getSubjectColor(book.subject);

    return GestureDetector(
      onTap: () => context.push('/reader/${book.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
                      color: AppColors.teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CONTINUE READING',
                      style: TextStyle(
                        color: AppColors.tealLight,
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
                color: subjectBg.withValues(alpha: 0.15),
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
