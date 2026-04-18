class Medium {
  final String id;
  final String label;
  final String boardId;

  const Medium({
    required this.id,
    required this.label,
    required this.boardId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'boardId': boardId,
      };

  factory Medium.fromJson(Map<String, dynamic> json) => Medium(
        id: json['id'] as String,
        label: json['label'] as String,
        boardId: json['boardId'] as String,
      );
}
