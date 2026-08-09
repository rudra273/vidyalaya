// ─── Recent question ──────────────────────────────────────────────────────
// One question the student asked the AI, kept in SharedPreferences so the AI
// tab can offer "pick up where you left off" across subjects. The backend
// caches only one conversation's history at a time, so reading every subject's
// thread just to build this row would be slow and would clobber that cache.

class RecentQuestion {
  final String text;

  /// Subject conversation it was asked in, or null for cross-subject.
  final String? subject;
  final DateTime askedAt;

  const RecentQuestion({
    required this.text,
    this.subject,
    required this.askedAt,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'subject': subject,
    'asked_at': askedAt.millisecondsSinceEpoch,
  };

  factory RecentQuestion.fromJson(Map<String, dynamic> json) {
    return RecentQuestion(
      text: json['text'] as String? ?? '',
      subject: json['subject'] as String?,
      askedAt: DateTime.fromMillisecondsSinceEpoch(
        json['asked_at'] as int? ?? 0,
      ),
    );
  }
}
