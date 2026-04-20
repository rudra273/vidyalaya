import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/core_providers.dart';

/// Bookmarks screen — shows all bookmarked pages grouped by subject.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(userPrefsRepositoryProvider);

    // Gather bookmarks grouped by subject
    final Map<String, List<_BookmarkEntry>> bySubject = {};
    for (final book in allBooks) {
      final pages = repo.getBookmarks(book.id);
      if (pages.isNotEmpty) {
        final entries = pages
            .map((p) => _BookmarkEntry(
                  bookId: book.id,
                  bookTitle: book.title,
                  emoji: book.coverEmoji,
                  subject: book.subject,
                  page: p,
                ))
            .toList();
        bySubject.putIfAbsent(book.subject, () => []).addAll(entries);
      }
    }

    final subjects = bySubject.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Bookmarks',
            style: Theme.of(context).textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: bySubject.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
              itemCount: subjects.length,
              itemBuilder: (context, sIndex) {
                final subject = subjects[sIndex];
                final entries = bySubject[subject]!
                  ..sort((a, b) => a.bookTitle.compareTo(b.bookTitle));
                final (bgColor, textColor) =
                    AppColors.getSubjectColor(subject);

                // Group entries by book within this subject
                final Map<String, List<_BookmarkEntry>> byBook = {};
                for (final e in entries) {
                  byBook.putIfAbsent(e.bookId, () => []).add(e);
                }

                return Padding(
                  padding: EdgeInsets.only(
                      bottom: sIndex < subjects.length - 1 ? 20 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              entries.first.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatSubject(subject),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: textColor),
                              ),
                            ),
                            Text(
                              '${entries.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Bookmark entries grouped by book
                      ...byBook.entries.map((bookEntry) {
                        final bookmarks = bookEntry.value
                          ..sort((a, b) => a.page.compareTo(b.page));
                        final bookTitle = bookmarks.first.bookTitle;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (byBook.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, top: 4, bottom: 4),
                                child: Text(
                                  bookTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ...bookmarks.map((bm) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: GestureDetector(
                                    onTap: () => context.push(
                                        '/reader/${bm.bookId}?page=${bm.page}'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border:
                                            Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.bookmark,
                                              size: 18,
                                              color: AppColors.teal),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Page ${bm.page + 1}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          Icon(Icons.open_in_new,
                                              size: 16,
                                              color: AppColors.textMuted),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text('No bookmarks yet',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Open a book and tap the bookmark icon to save pages for quick access.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSubject(String s) {
    return s.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }
}

class _BookmarkEntry {
  final String bookId;
  final String bookTitle;
  final String emoji;
  final String subject;
  final int page;

  const _BookmarkEntry({
    required this.bookId,
    required this.bookTitle,
    required this.emoji,
    required this.subject,
    required this.page,
  });
}
