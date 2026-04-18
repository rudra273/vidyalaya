class ClassLevel {
  final String id;
  final int number;
  final String mediumId;

  const ClassLevel({
    required this.id,
    required this.number,
    required this.mediumId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'mediumId': mediumId,
      };

  factory ClassLevel.fromJson(Map<String, dynamic> json) => ClassLevel(
        id: json['id'] as String,
        number: json['number'] as int,
        mediumId: json['mediumId'] as String,
      );
}
