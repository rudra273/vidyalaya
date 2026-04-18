class Book {
  final String id;
  final String title;
  final String subject;
  final int classNumber;
  final String mediumId;
  final String boardId;
  final String pdfUrl;
  final String coverEmoji;
  final bool isOfficial;

  const Book({
    required this.id,
    required this.title,
    required this.subject,
    required this.classNumber,
    this.mediumId = 'odia_medium',
    this.boardId = 'bse_odisha',
    required this.pdfUrl,
    required this.coverEmoji,
    this.isOfficial = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'classNumber': classNumber,
        'mediumId': mediumId,
        'boardId': boardId,
        'pdfUrl': pdfUrl,
        'coverEmoji': coverEmoji,
        'isOfficial': isOfficial,
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String,
        classNumber: json['classNumber'] as int,
        mediumId: json['mediumId'] as String? ?? 'odia_medium',
        boardId: json['boardId'] as String? ?? 'bse_odisha',
        pdfUrl: json['pdfUrl'] as String,
        coverEmoji: json['coverEmoji'] as String,
        isOfficial: json['isOfficial'] as bool? ?? true,
      );
}
