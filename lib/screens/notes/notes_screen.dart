import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/models/highlight.dart';
import '../../data/models/note.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/core_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pressable.dart';

/// Main Notes screen — shows the student's own typed notes plus subjects that
/// have book highlights. Tapping a subject opens all notes for that subject;
/// tapping a typed note opens it in the editor.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  Future<void> _openEditor(String location) async {
    await context.push(location);
    // Returning from the editor may have added/edited/removed a note.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(userPrefsRepositoryProvider);

    final notes = repo.getNotes();

    // Gather all highlights grouped by subject
    final Map<String, List<Highlight>> bySubject = {};
    for (final book in allBooks) {
      final highlights = repo.getHighlights(book.id);
      if (highlights.isNotEmpty) {
        bySubject.putIfAbsent(book.subject, () => []).addAll(highlights);
      }
    }

    final subjects = bySubject.keys.toList()..sort();
    final totalHighlights =
        bySubject.values.fold(0, (sum, list) => sum + list.length);

    final isEmpty = notes.isEmpty && bySubject.isEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor('/note/new'),
        tooltip: 'New note',
        child: const Icon(Icons.edit_outlined),
      ),
      body: SafeArea(
        child: isEmpty
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
                              style:
                                  Theme.of(context).textTheme.displaySmall),
                          const SizedBox(height: 4),
                          Text(
                            _buildSummary(notes.length, totalHighlights,
                                subjects.length),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Typed notes section
                  if (notes.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding, 20, AppSpacing.screenPadding, 0),
                      sliver: SliverToBoxAdapter(
                        child: _SectionLabel(label: 'My notes'),
                      ),
                    ),
                  if (notes.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
                          12, AppSpacing.screenPadding, 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final note = notes[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: index < notes.length - 1 ? 12 : 0),
                              child: _NoteCard(
                                note: note,
                                onTap: () => _openEditor('/note/${note.id}'),
                              ),
                            );
                          },
                          childCount: notes.length,
                        ),
                      ),
                    ),

                  // Highlights-by-subject section
                  if (subjects.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 0),
                      sliver: SliverToBoxAdapter(
                        child: _SectionLabel(label: 'From your books'),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
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

  String _buildSummary(int noteCount, int highlightCount, int subjectCount) {
    final parts = <String>[];
    if (noteCount > 0) {
      parts.add('$noteCount note${noteCount == 1 ? '' : 's'}');
    }
    if (highlightCount > 0) {
      parts.add(
          '$highlightCount highlight${highlightCount == 1 ? '' : 's'} across $subjectCount subject${subjectCount == 1 ? '' : 's'}');
    }
    return parts.join(' · ');
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      icon: Icons.edit_note_rounded,
      title: 'No notes yet',
      subtitle:
          'Jot down a quick note, or open a book and use the highlighter to mark areas.',
      ctaLabel: 'New note',
      onCtaTap: () => _openEditor('/note/new'),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.onTap});

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) {
      final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final m = d.minute.toString().padLeft(2, '0');
      final ampm = d.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $ampm';
    }
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = note.title.trim();
    final body = note.body.trim();
    final displayTitle = title.isNotEmpty
        ? title
        : (body.isNotEmpty ? body.split('\n').first : 'Untitled note');

    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('📝', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body.isNotEmpty ? body : _formatDate(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
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

  String _formatSubject(String s) {
    return s.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatSubject(subject),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bookNames,
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
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$highlightCount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
