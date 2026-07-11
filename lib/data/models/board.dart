class Board {
  final String id;

  /// Human-readable display label (e.g. 'SCERT Odisha'), shown in the
  /// onboarding dropdown and profile/library headers.
  final String name;

  final String state;

  /// Code of the regional language shown alongside English for students on
  /// this board ('or', 'hi', ...). The board is the default; a student's
  /// profile preference or manual switch overrides it.
  final String defaultLanguageCode;

  const Board({
    required this.id,
    required this.name,
    required this.state,
    required this.defaultLanguageCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'default_language_code': defaultLanguageCode,
      };

  factory Board.fromJson(Map<String, dynamic> json) => Board(
        id: json['id'] as String,
        name: json['name'] as String,
        state: json['state'] as String,
        defaultLanguageCode:
            json['default_language_code'] as String? ?? 'or',
      );
}
