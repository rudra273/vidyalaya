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
import 'scert/scert_class_9.dart';
import 'scert/scert_class_10.dart';

// ─── Boards ─────────────────────────────────────────────────────────────────

const scertOdisha = Board(
  id: 'scert_odisha',
  name: 'SCERT Odisha',
  state: 'Odisha',
  defaultLanguageCode: 'or',
);

const ncert = Board(
  id: 'ncert',
  name: 'NCERT',
  state: 'India',
  defaultLanguageCode: 'hi',
);

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
  ...scertClass9Books,
  ...scertClass10Books,
];

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Classes that have books in the database.
Set<int> get availableClassNumbers =>
    allBooks.map((b) => b.classNumber).toSet();

/// NCERT is enabled while its own textbook catalog is being prepared. Until
/// then it shares the available SCERT Odisha library content.
const _sharedContentBoardIds = {'ncert'};

String _contentBoardId(String boardId) =>
    _sharedContentBoardIds.contains(boardId) ? 'scert_odisha' : boardId;

/// Classes that have books for a specific board.
Set<int> availableClassNumbersForBoard(String boardId) => allBooks
    .where((b) => b.boardId == _contentBoardId(boardId))
    .map((b) => b.classNumber)
    .toSet();

/// Books for selected classes in one board.
///
/// NCERT temporarily uses the SCERT Odisha collection while its own catalog is
/// being prepared.
List<Book> getBooksForBoardAndClasses(
  String boardId,
  Set<int> selectedClasses,
) => allBooks
    .where(
      (book) =>
          book.boardId == _contentBoardId(boardId) &&
          selectedClasses.contains(book.classNumber),
    )
    .toList();

/// Boards currently available to students.
Set<String> get availableBoardIds => boards.map((board) => board.id).toSet();

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

/// Look up a board by ID (null for unknown/future ids from newer clients).
Board? getBoardById(String id) {
  try {
    return boards.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
}

/// Display label for a board id, falling back to the raw id.
String boardLabel(String id) => getBoardById(id)?.name ?? id;

/// All unique subjects across all books.
List<String> get allSubjects =>
    allBooks.map((b) => b.subject).toSet().toList()..sort();
