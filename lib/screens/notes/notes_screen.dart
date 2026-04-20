import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/models/highlight.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/core_providers.dart';

/// Main Notes screen — shows subjects that have highlights.
/// Tapping a subject navigates to all notes for that subject.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(userPrefsRepositoryProvider);

    // Gather all highlights grouped by subject
    final Map<String, List<Highlight>> bySubject = {};
    for (final book in allBooks) {
      final highlights = repo.getHighlights(book.id);
      if (highlights.isNotEmpty) {
        bySubject.putIfAbsent(book.subject, () => []).addAll(highlights);
      }
    }

    final subjects = bySubject.keys.toList()..sort();
    final totalCount = bySubject.values.fold(0, (sum, list) => sum + list.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: bySubject.isEmpty
            ? _buildEmptyState(context)
            : CustomScrollView(
                slivers: [
                  // Header
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding, 20, AppSpacing.screenPadding, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Notes',
                              style: Theme.of(context).textTheme.displaySmall),
                          const SizedBox(height: 4),
                          Text(
                            '$totalCount highlight${totalCount == 1 ? '' : 's'} across ${subjects.length} subject${subjects.length == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Subject cards
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding, 20, AppSpacing.screenPadding, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final subject = subjects[index];
                          final highlights = bySubject[subject]!;
                          final bookIds = highlights.map((h) => h.bookId).toSet();
                          final books = bookIds
                              .map((id) => getBookById(id))
                              .where((b) => b != null)
                              .toList();
                          final (bgColor, textColor) =
                              AppColors.getSubjectColor(subject);

                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: index < subjects.length - 1 ? 12 : 0),
                            child: _SubjectCard(
                              subject: subject,
                              highlightCount: highlights.length,
                              bookNames: books.map((b) => b!.title).join(', '),
                              emoji: books.isNotEmpty ? books.first!.coverEmoji : '📝',
                              bgColor: bgColor,
                              textColor: textColor,
                              onTap: () => context.push('/notes/$subject'),
                            ),
                          );
                        },
                        childCount: subjects.length,
                      ),
                    ),
                  ),
                ],
              ),
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
            const Text('📝', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text('No notes yet',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Open a book and tap the highlighter icon to mark areas and add notes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatefulWidget {
  final String subject;
  final int highlightCount;
  final String bookNames;
  final String emoji;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.highlightCount,
    required this.bookNames,
    required this.emoji,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  bool _pressed = false;

  String _formatSubject(String s) {
    return s.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatSubject(widget.subject),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: widget.textColor,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.bookNames,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.highlightCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
