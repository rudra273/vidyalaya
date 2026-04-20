/// A rectangular highlight on a specific page of a book, with an optional note.
class Highlight {
  final String id;
  final String bookId;
  final int pageNumber;
  // Stored as fractions (0.0–1.0) of page dimensions
  final double left;
  final double top;
  final double right;
  final double bottom;
  final String? note;
  final DateTime createdAt;

  const Highlight({
    required this.id,
    required this.bookId,
    required this.pageNumber,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    this.note,
    required this.createdAt,
  });

  Highlight copyWith({String? note}) => Highlight(
        id: id,
        bookId: bookId,
        pageNumber: pageNumber,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        note: note ?? this.note,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'pageNumber': pageNumber,
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        pageNumber: json['pageNumber'] as int,
        left: (json['left'] as num).toDouble(),
        top: (json['top'] as num).toDouble(),
        right: (json['right'] as num).toDouble(),
        bottom: (json['bottom'] as num).toDouble(),
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
