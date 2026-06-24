/// A standalone, free-form note the student types directly — not tied to a
/// book page or highlight. Persisted locally for now; a backend may sync these
/// later (see [UserPrefsRepository] note methods).
class Note {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  /// True when there is nothing worth keeping — used to discard empty notes
  /// that the user opened but never filled in.
  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  Note copyWith({
    String? title,
    String? body,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
