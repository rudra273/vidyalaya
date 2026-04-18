import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book.dart';
import '../data/seed/seed_data.dart';
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

final subjectFilterProvider =
    NotifierProvider<SubjectFilterNotifier, String?>(
  SubjectFilterNotifier.new,
);

/// Books for the user's selected classes.
final selectedBooksProvider = Provider<List<Book>>((ref) {
  final selectedClasses = ref.watch(userSelectionProvider);
  return getBooksForClasses(selectedClasses);
});

/// Books filtered by the currently active subject chip.
final filteredBooksProvider = Provider<List<Book>>((ref) {
  final books = ref.watch(selectedBooksProvider);
  final filter = ref.watch(subjectFilterProvider);
  if (filter == null) return books;
  return books.where((b) => b.subject == filter).toList();
});
