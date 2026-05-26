import '../models/board.dart';
import '../models/medium.dart';
import '../models/class_level.dart';
import '../models/book.dart';
import 'scert/scert_class_1.dart';
import 'scert/scert_class_2.dart';
import 'scert/scert_class_3.dart';
import 'scert/scert_class_4.dart';
import 'scert/scert_class_5.dart';
import 'scert/scert_class_6.dart';
import 'scert/scert_class_7.dart';
import 'scert/scert_class_8.dart';

// ─── Boards ─────────────────────────────────────────────────────────────────

const scertOdisha = Board(
  id: 'scert_odisha',
  name: 'scert_odisha',
  state: 'Odisha',
);

const ncert = Board(id: 'ncert', name: 'ncert', state: 'India');

const List<Board> boards = [scertOdisha, ncert];

// ─── Mediums ────────────────────────────────────────────────────────────────

const odiaMedium = Medium(
  id: 'odia_medium',
  label: 'Odia Medium',
  boardId: 'scert_odisha',
);

// ─── Class Levels ───────────────────────────────────────────────────────────

const class8 = ClassLevel(id: 'cl8', number: 8, mediumId: 'odia_medium');

// ─── Books — All Classes ──────────────────────────────────────────────────────

const List<Book> allBooks = [
  ...scertClass1Books,
  ...scertClass2Books,
  ...scertClass3Books,
  ...scertClass4Books,
  ...scertClass5Books,
  ...scertClass6Books,
  ...scertClass7Books,
  ...scertClass8Books,
];

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Classes that have books in the database.
Set<int> get availableClassNumbers =>
    allBooks.map((b) => b.classNumber).toSet();

/// Get books for a specific class number.
List<Book> getBooksByClass(int classNumber) =>
    allBooks.where((b) => b.classNumber == classNumber).toList();

/// Get books for multiple selected classes.
List<Book> getBooksForClasses(Set<int> selectedClasses) =>
    allBooks.where((b) => selectedClasses.contains(b.classNumber)).toList();

/// Look up a single book by ID.
Book? getBookById(String id) {
  try {
    return allBooks.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
}

/// All unique subjects across all books.
List<String> get allSubjects =>
    allBooks.map((b) => b.subject).toSet().toList()..sort();
