import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book.dart';
import '../data/seed/seed_data.dart';
import 'books_provider.dart';
import 'core_providers.dart';

/// Notifier that tracks the last book the user opened.
class ReadingNotifier extends Notifier<Book?> {
  @override
  Book? build() {
    final repo = ref.read(userPrefsRepositoryProvider);
    final lastId = repo.getLastReadBookId();
    if (lastId == null) return null;
    return getBookById(lastId);
  }

  void setLastRead(Book book) {
    state = book;
    final repo = ref.read(userPrefsRepositoryProvider);
    repo.setLastReadBookId(book.id);
    repo.recordBookOpened(book.id);
    // Nudge the recents row so it reorders without waiting for a rebuild.
    ref.invalidate(recentBooksProvider);
  }
}

final readingProvider = NotifierProvider<ReadingNotifier, Book?>(
  ReadingNotifier.new,
);

/// Books the student has actually opened, most recent first, followed by the
/// rest of their selected books so the row is never empty on a fresh install.
final recentBooksProvider = Provider<List<Book>>((ref) {
  final selected = ref.watch(selectedBooksProvider);
  final recentIds = ref.watch(userPrefsRepositoryProvider).getRecentBookIds();

  final byId = {for (final book in selected) book.id: book};
  final opened = [for (final id in recentIds) ?byId[id]];
  final openedIds = opened.map((b) => b.id).toSet();

  return [
    ...opened,
    ...selected.where((book) => !openedIds.contains(book.id)),
  ];
});
