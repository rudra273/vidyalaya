import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/book.dart';
import '../data/seed/seed_data.dart';
import 'core_providers.dart';
import 'user_selection_provider.dart';

/// Notifier for the subject filter on My Books screen.
/// null means "All".
class SubjectFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? subject) {
    state = subject;
  }
}

final subjectFilterProvider = NotifierProvider<SubjectFilterNotifier, String?>(
  SubjectFilterNotifier.new,
);

// ─── The student's own books ────────────────────────────────────────────────

/// Raised when a picked file cannot be added to the Library.
class BookImportException implements Exception {
  final String message;
  const BookImportException(this.message);

  @override
  String toString() => message;
}

/// PDFs the student added from their own files. They stay on the device: the
/// file is copied into the app's `books/` folder (where the reader already
/// looks) and the list lives in SharedPreferences.
class UserBooksNotifier extends Notifier<List<Book>> {
  @override
  List<Book> build() => ref.read(userPrefsRepositoryProvider).getUserBooks();

  Future<Book> importPdf({
    required String sourcePath,
    required String title,
    required String subject,
    required int classNumber,
    required String boardId,
  }) async {
    final source = File(sourcePath);
    if (!source.existsSync() || source.lengthSync() == 0) {
      throw const BookImportException('That file could not be read.');
    }
    final header = await source.openRead(0, 5).expand((b) => b).toList();
    if (String.fromCharCodes(header) != '%PDF-') {
      throw const BookImportException('Please choose a PDF file.');
    }

    final id = 'user_${DateTime.now().microsecondsSinceEpoch}';
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/books');
    if (!booksDir.existsSync()) booksDir.createSync(recursive: true);

    // Copy to a temp name and rename, so a failed copy never leaves a
    // half-written file that the reader would treat as a valid book.
    final target = '${booksDir.path}/$id.pdf';
    final tmp = File('$target.part');
    try {
      await source.copy(tmp.path);
      await tmp.rename(target);
    } catch (_) {
      if (tmp.existsSync()) tmp.deleteSync();
      throw const BookImportException(
        'Could not save the file. Is there free space?',
      );
    }

    final book = Book(
      id: id,
      title: title,
      subject: subject,
      classNumber: classNumber,
      boardId: boardId,
      pdfUrl: '',
      coverEmoji: '📄',
      isOfficial: false,
    );
    state = [...state, book];
    await ref.read(userPrefsRepositoryProvider).setUserBooks(state);
    return book;
  }

  Future<void> remove(Book book) async {
    state = [
      for (final b in state)
        if (b.id != book.id) b,
    ];
    await ref.read(userPrefsRepositoryProvider).setUserBooks(state);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/books/${book.id}.pdf');
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }
}

final userBooksProvider = NotifierProvider<UserBooksNotifier, List<Book>>(
  UserBooksNotifier.new,
);

/// Every book the app can open: the official catalog plus the student's own.
final libraryBooksProvider = Provider<List<Book>>(
  (ref) => [...allBooks, ...ref.watch(userBooksProvider)],
);

/// Looks a book up by id among official and student-added books.
Book? findBook(Iterable<Book> books, String id) {
  for (final book in books) {
    if (book.id == id) return book;
  }
  return null;
}

/// Books for the classes selected in the Library filter.
final selectedBooksProvider = Provider<List<Book>>((ref) {
  final selectedClasses = ref.watch(libraryClassSelectionProvider);
  final selectedBoard = ref.watch(userBoardProvider);
  final own = ref
      .watch(userBooksProvider)
      .where(
        (b) =>
            b.boardId == selectedBoard &&
            selectedClasses.contains(b.classNumber),
      );
  return [
    ...getBooksForBoardAndClasses(selectedBoard, selectedClasses),
    ...own,
  ];
});

/// Books filtered by the currently active subject chip.
final filteredBooksProvider = Provider<List<Book>>((ref) {
  final books = ref.watch(selectedBooksProvider);
  final filter = ref.watch(subjectFilterProvider);
  if (filter == null) return books;
  return books.where((b) => b.subject == filter).toList();
});
