import 'package:flutter/foundation.dart';

// ─── In-app notice ───────────────────────────────────────────────────────

/// What a notice is about. The Notifications screen picks the icon and tint
/// from this, so the model carries no UI types.
enum AppNoticeKind { plus, aiQuestions, timetable, challenge }

/// One item in the in-app Notifications inbox.
///
/// Notices are derived from app state the device already has (Plus status, the
/// AI allowance, the timetable, the Daily Brain Challenge); nothing is pushed.
/// [id] is stable for as long as the same thing applies (it embeds a date or
/// record id), so the read/unread set in SharedPreferences stays meaningful.
@immutable
class AppNotice {
  final String id;
  final String title;
  final String body;

  /// When this notice started to apply, shown as a relative time.
  final DateTime time;
  final AppNoticeKind kind;

  /// Where tapping the notice goes, or null when it is information only.
  final String? route;

  const AppNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.kind,
    this.route,
  });

  factory AppNotice.fromJson(Map<String, dynamic> json) {
    return AppNotice(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      kind:
          AppNoticeKind.values.asNameMap()[json['kind']] ??
          AppNoticeKind.challenge,
      route: json['route'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'time': time.toIso8601String(),
    'kind': kind.name,
    if (route != null) 'route': route,
  };

  @override
  bool operator ==(Object other) =>
      other is AppNotice &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.time == time &&
      other.kind == kind &&
      other.route == route;

  @override
  int get hashCode => Object.hash(id, title, body, time, kind, route);
}
