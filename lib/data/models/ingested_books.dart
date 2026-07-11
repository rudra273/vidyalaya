/// Reference of what is ingested in the backend vector DB, per board/class.
///
/// Parsed from `assets/data/ingested_books.json`, which is generated from the
/// live Qdrant collection by the backend repo
/// (`vidyalaya-ai/scripts/export_qdrant_catalog.py`). LearnAssist subject
/// options must come from here so students only see subjects the AI can
/// actually retrieve textbook content for.
class IngestedSubject {
  final String subject;
  final String bookName;
  final String language;

  const IngestedSubject({
    required this.subject,
    required this.bookName,
    required this.language,
  });

  factory IngestedSubject.fromJson(Map<String, dynamic> json) =>
      IngestedSubject(
        subject: json['subject'] as String,
        bookName: json['book_name'] as String,
        language: json['language'] as String,
      );
}

class IngestedBooks {
  /// board -> class number -> subjects.
  final Map<String, Map<int, List<IngestedSubject>>> _byBoard;

  const IngestedBooks(this._byBoard);

  const IngestedBooks.empty() : _byBoard = const {};

  factory IngestedBooks.fromJson(Map<String, dynamic> json) {
    final byBoard = <String, Map<int, List<IngestedSubject>>>{};
    for (final boardJson in (json['boards'] as List<dynamic>? ?? const [])) {
      final board = boardJson as Map<String, dynamic>;
      final classes = <int, List<IngestedSubject>>{};
      for (final classJson
          in (board['classes'] as List<dynamic>? ?? const [])) {
        final classEntry = classJson as Map<String, dynamic>;
        classes[classEntry['class'] as int] =
            (classEntry['subjects'] as List<dynamic>? ?? const [])
                .map((s) => IngestedSubject.fromJson(s as Map<String, dynamic>))
                .toList();
      }
      byBoard[board['board'] as String] = classes;
    }
    return IngestedBooks(byBoard);
  }

  /// Subjects ingested for a board + class; empty when nothing is ingested.
  List<IngestedSubject> subjectsFor(String board, int classNo) =>
      _byBoard[board]?[classNo] ?? const [];

  /// Class numbers that have ingested content for a board.
  Set<int> classesFor(String board) =>
      _byBoard[board]?.keys.toSet() ?? const {};
}
