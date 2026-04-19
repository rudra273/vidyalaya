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

// ─── Books — Class 8, SCERT New Syllabus, BSE Odisha ────────────────────────

const List<Book> allBooks = [
  Book(
    id: 'scert_cl8_odia_sahitya_surabhi',
    title: 'Odia Sahitya Surabhi',
    subject: 'odia',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1QKBOWJMg0yPJ3nIvuXS4NPiZMIprzaGg',
    coverEmoji: '📖',
  ),
  Book(
    id: 'scert_cl8_english_jasmine',
    title: 'English Jasmine',
    subject: 'english',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1CRDfeSBGSNOkRdf_tNqoWJXP8U3bkc4t',
    coverEmoji: '🌸',
  ),
  Book(
    id: 'scert_cl8_maths_ganita_prakash',
    title: 'Maths Ganita Prakash',
    subject: 'maths',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1rPDcJkzfUmxM9U45P5dtt0o45byMpTGE',
    coverEmoji: '🔢',
  ),
  Book(
    id: 'scert_cl8_hindi_kalika',
    title: 'Hindi Kalika',
    subject: 'hindi',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1Q8f90Bd1kevXlIm5jcc5VDKL6FFeY9KJ',
    coverEmoji: '🪷',
  ),
  Book(
    id: 'scert_cl8_sanskrit_kalika',
    title: 'Sanskrit Kalika',
    subject: 'sanskrit',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1pobhcsgK4rO3L-wH4caitIY4zDUOg9FE',
    coverEmoji: '🕉️',
  ),
  Book(
    id: 'scert_cl8_science_jigyasa',
    title: 'Science Jigyasa',
    subject: 'science',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1izSmwE6fVOX_He4JQv4TT6Cxt6IggaaI',
    coverEmoji: '🔬',
  ),
  Book(
    id: 'scert_cl8_skill_kaushala_bodha',
    title: 'Skill Kaushala Bodha',
    subject: 'skill',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1n2LveK_j608tuOTfVny_Y--Y_ntzB9Ma',
    coverEmoji: '🛠️',
  ),
  Book(
    id: 'scert_cl8_social_science',
    title: 'Social Science',
    subject: 'social_science',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=17dx5DY74ZxepKiox7oSqhq_Y6HPkC124',
    coverEmoji: '🌍',
  ),
  Book(
    id: 'scert_cl8_work_kruti',
    title: 'Work Kruti',
    subject: 'work',
    classNumber: 8,
    pdfUrl: 'https://drive.google.com/uc?export=download&id=1ZDqQAOKUs1csY_PNqNRUPOnpSY-XlkA2',
    coverEmoji: '⚙️',
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
