import '../models/board.dart';
import '../models/medium.dart';
import '../models/class_level.dart';
import '../models/book.dart';

// ─── Boards ─────────────────────────────────────────────────────────────────

const bseOdisha = Board(
  id: 'bse_odisha',
  name: 'BSE Odisha',
  state: 'Odisha',
);

// ─── Mediums ────────────────────────────────────────────────────────────────

const odiaMedium = Medium(
  id: 'odia_medium',
  label: 'Odia Medium',
  boardId: 'bse_odisha',
);

// ─── Class Levels ───────────────────────────────────────────────────────────

const class8 = ClassLevel(
  id: 'cl8',
  number: 8,
  mediumId: 'odia_medium',
);

// ─── Books ──────────────────────────────────────────────────────────────────

const List<Book> allBooks = [
  // ── Class 8, Odia Medium, BSE Odisha ──
  Book(
    id: 'cl8_odia_sahitika',
    title: 'Sahitika',
    subject: 'odia',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/Sahitika-8th.pdf',
    coverEmoji: '📖',
  ),
  Book(
    id: 'cl8_odia_byakarana',
    title: 'Ama Byakarana',
    subject: 'odia',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/Ama-Odia-Byakarana-Final-104.pdf',
    coverEmoji: '✏️',
  ),
  Book(
    id: 'cl8_english_reader',
    title: 'A New Approach to English',
    subject: 'english',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/A-New-Approach-to-English-(-1-168-).pdf',
    coverEmoji: '📝',
  ),
  Book(
    id: 'cl8_english_stories',
    title: 'Stories Past & Present',
    subject: 'english',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/Stories-Past-and-Present.pdf',
    coverEmoji: '📚',
  ),
  Book(
    id: 'cl8_science',
    title: 'Bigyan',
    subject: 'science',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/Bigyan.pdf',
    coverEmoji: '🔬',
  ),
  Book(
    id: 'cl8_algebra',
    title: 'Sarala Bijaganita',
    subject: 'maths',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/Sarala-Bijaganita.pdf',
    coverEmoji: '🔢',
  ),
  Book(
    id: 'cl8_geometry',
    title: 'Sarala Jyamiti',
    subject: 'maths',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/Sarala-Geometry.pdf',
    coverEmoji: '📐',
  ),
  Book(
    id: 'cl8_history',
    title: 'Itihas & Rajaniti Bigyana',
    subject: 'social',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/History-&-Political-Science-8.pdf',
    coverEmoji: '🏛️',
  ),
  Book(
    id: 'cl8_geography',
    title: 'Bhugola',
    subject: 'social',
    classNumber: 8,
    pdfUrl:
        'https://osepa.odisha.gov.in/upload/ebooks/CLASS-VIII/Geography.pdf',
    coverEmoji: '🗺️',
  ),
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
