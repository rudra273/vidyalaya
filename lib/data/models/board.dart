class Board {
  final String id;
  final String name;
  final String state;

  const Board({
    required this.id,
    required this.name,
    required this.state,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
      };

  factory Board.fromJson(Map<String, dynamic> json) => Board(
        id: json['id'] as String,
        name: json['name'] as String,
        state: json['state'] as String,
      );
}
