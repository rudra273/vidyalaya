import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/models/highlight.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/core_providers.dart';

/// Shows all highlights/notes for a specific subject, grouped by book.
class SubjectNotesScreen extends ConsumerWidget {
  final String subject;

  const SubjectNotesScreen({super.key, required this.subject});

  String _formatSubject(String s) {
    return s.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(userPrefsRepositoryProvider);
    final (bgColor, textColor) = AppColors.getSubjectColor(subject);

    // Get all books for this subject and their highlights
    final subjectBooks = allBooks.where((b) => b.subject == subject).toList();
    final Map<String, List<Highlight>> bookHighlights = {};
    for (final book in subjectBooks) {
      final hl = repo.getHighlights(book.id);
      if (hl.isNotEmpty) {
        bookHighlights[book.id] = hl..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${_formatSubject(subject)} Notes',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: bookHighlights.isEmpty
          ? Center(
              child: Text(
                'No highlights found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              itemCount: bookHighlights.length,
              itemBuilder: (context, bookIndex) {
                final bookId = bookHighlights.keys.elementAt(bookIndex);
                final book = getBookById(bookId);
                final highlights = bookHighlights[bookId]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bookIndex > 0) const SizedBox(height: 20),

                    // Book header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(book?.coverEmoji ?? '📖',
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              book?.title ?? bookId,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: textColor),
                            ),
                          ),
                          Text(
                            '${highlights.length}',
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

                    // Highlight entries
                    ...highlights.map((hl) => _HighlightTile(
                          highlight: hl,
                          onTap: () {
                            context.push('/reader/${hl.bookId}?page=${hl.pageNumber}');
                          },
                          onDelete: () {
                            repo.removeHighlight(hl.bookId, hl.id);
                            // Force rebuild
                            (context as Element).markNeedsBuild();
                          },
                        )),
                  ],
                );
              },
            ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final Highlight highlight;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HighlightTile({
    required this.highlight,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasNote = highlight.note != null && highlight.note!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Page ${highlight.pageNumber + 1}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (hasNote) ...[
                      const SizedBox(height: 4),
                      Text(
                        highlight.note!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.navy,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (!hasNote)
                      Text(
                        'Highlight only',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.open_in_new, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
