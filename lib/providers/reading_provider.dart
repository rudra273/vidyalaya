import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book.dart';
import '../data/seed/seed_data.dart';
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
  }
}

final readingProvider = NotifierProvider<ReadingNotifier, Book?>(
  ReadingNotifier.new,
);
