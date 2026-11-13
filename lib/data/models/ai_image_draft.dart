/// Composer state saved before Android hands control to Camera/Gallery.
class AiImageDraft {
  final String? uid;
  final String board;
  final int classNo;
  final String channel;
  final String? subject;
  final String text;
  final String language;
  final String style;

  const AiImageDraft({
    required this.uid,
    required this.board,
    required this.classNo,
    required this.channel,
    required this.subject,
    required this.text,
    required this.language,
    required this.style,
  });

  factory AiImageDraft.fromJson(Map<String, dynamic> json) => AiImageDraft(
    uid: json['uid'] as String?,
    board: json['board'] as String,
    classNo: json['classNo'] as int,
    channel: json['channel'] as String,
    subject: json['subject'] as String?,
    text: json['text'] as String,
    language: json['language'] as String,
    style: json['style'] as String,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'board': board,
    'classNo': classNo,
    'channel': channel,
    'subject': subject,
    'text': text,
    'language': language,
    'style': style,
  };

  String get location => Uri(
    path: '/learn/ai',
    queryParameters: {
      'channel': channel,
      'subject': ?subject,
      'resume': '1',
      'style': style,
    },
  ).toString();
}
