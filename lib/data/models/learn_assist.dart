/// Agent/surface the student is talking to (the backend "channel"). Each is its
/// own conversation with isolated memory. Only [learnAssist] is live today;
/// [tutor] is reserved for the upcoming AI Tutor agent.
class LearnAssistChannel {
  const LearnAssistChannel._();

  static const learnAssist = 'learn_assist';
  static const tutor = 'tutor';
}

class LearnAssistRequest {
  final String message;
  final String board;
  final int classNo;

  /// Agent/surface, e.g. [LearnAssistChannel.learnAssist].
  final String channel;

  /// Academic subject, or null for cross-subject "ask anything".
  final String? subject;
  final String? language;
  final bool debug;

  const LearnAssistRequest({
    required this.message,
    required this.board,
    required this.classNo,
    this.channel = LearnAssistChannel.learnAssist,
    this.subject,
    this.language,
    this.debug = false,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
    'board': board,
    'class_no': classNo,
    'channel': channel,
    'subject': subject,
    'language': language,
    'debug': debug,
  };
}

class LearnAssistResponse {
  final String answer;
  final List<LearnAssistCitation> citations;
  final LearnAssistRetrieval retrieval;
  final LearnAssistUsage? usage;

  const LearnAssistResponse({
    required this.answer,
    required this.citations,
    required this.retrieval,
    this.usage,
  });

  factory LearnAssistResponse.fromJson(Map<String, dynamic> json) {
    return LearnAssistResponse(
      answer: json['answer'] as String? ?? '',
      citations: _asMapList(
        json['citations'],
      ).map(LearnAssistCitation.fromJson).toList(),
      retrieval: LearnAssistRetrieval.fromJson(
        json['retrieval'] as Map<String, dynamic>? ?? const {},
      ),
      usage: json['usage'] is Map<String, dynamic>
          ? LearnAssistUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LearnAssistCitation {
  final String label;
  final String? bookName;
  final String? sourcePdf;
  final List<int> pageNumbers;
  final double? score;
  final List<String> chunkIds;

  const LearnAssistCitation({
    required this.label,
    this.bookName,
    this.sourcePdf,
    this.pageNumbers = const [],
    this.score,
    this.chunkIds = const [],
  });

  factory LearnAssistCitation.fromJson(Map<String, dynamic> json) {
    return LearnAssistCitation(
      label: json['label'] as String? ?? '',
      bookName: json['book_name'] as String?,
      sourcePdf: json['source_pdf'] as String?,
      pageNumbers: _parsePageNumbers(json['page_no']),
      score: _asDouble(json['score']),
      chunkIds: _asStringList(json['chunk_ids']),
    );
  }

  String get pageLabel {
    if (pageNumbers.isEmpty) return '';
    if (pageNumbers.length == 1) return 'p. ${pageNumbers.first}';
    return 'pp. ${pageNumbers.join(', ')}';
  }
}

class LearnAssistRetrieval {
  final String query;
  final String board;
  final int classNo;
  final String? subjectFilter;
  final List<String> subjectsFound;
  final List<int> pagesFound;
  final double? topScore;
  final int contextBlockCount;
  final bool toolUsed;

  const LearnAssistRetrieval({
    required this.query,
    required this.board,
    required this.classNo,
    this.subjectFilter,
    this.subjectsFound = const [],
    this.pagesFound = const [],
    this.topScore,
    this.contextBlockCount = 0,
    this.toolUsed = false,
  });

  factory LearnAssistRetrieval.fromJson(Map<String, dynamic> json) {
    return LearnAssistRetrieval(
      query: json['query'] as String? ?? '',
      board: json['board'] as String? ?? '',
      classNo: json['class_no'] as int? ?? 0,
      subjectFilter: json['subject_filter'] as String?,
      subjectsFound: _asStringList(json['subjects_found']),
      pagesFound: _asIntList(json['pages_found']),
      topScore: _asDouble(json['top_score']),
      contextBlockCount: json['context_block_count'] as int? ?? 0,
      toolUsed: json['tool_used'] as bool? ?? false,
    );
  }
}

class LearnAssistUsage {
  final String dateIst;
  final int used;
  final int limit;
  final int remaining;
  final bool unlimited;

  const LearnAssistUsage({
    required this.dateIst,
    required this.used,
    required this.limit,
    required this.remaining,
    required this.unlimited,
  });

  factory LearnAssistUsage.fromJson(Map<String, dynamic> json) {
    return LearnAssistUsage(
      dateIst: json['date_ist'] as String? ?? '',
      used: json['used'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 0,
      unlimited: json['unlimited'] as bool? ?? false,
    );
  }
}

class LearnAssistApiException implements Exception {
  final String code;
  final String message;

  const LearnAssistApiException(this.code, this.message);

  @override
  String toString() => message;
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

List<String> _asStringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}

List<int> _asIntList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<int>().toList();
}

double? _asDouble(Object? value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return null;
}

List<int> _parsePageNumbers(Object? value) {
  if (value is int) return [value];
  if (value is List) return value.whereType<int>().toList();
  return const [];
}
