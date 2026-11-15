import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_notice.dart';
import '../data/models/plus.dart';
import '../data/models/timetable_period.dart';
import '../utils/ai_labels.dart';
import 'auth_provider.dart';
import 'core_providers.dart';
import 'games_progress_provider.dart';
import 'plus_provider.dart';

// ─── Notifications inbox ─────────────────────────────────────────────────
//
// An in-app inbox only: there is no push service. Every notice is derived from
// state the app already holds, and only notices that apply right now are
// listed. Read state is the set of seen ids in SharedPreferences.
//
// Quiet hours: time-of-day notices (timetable, Daily Brain Challenge) are only
// derived between 7 am and 9 pm, matching the footer on the screen.

const _quietEndHour = 7; // 7 am
const _quietStartHour = 21; // 9 pm

// ─── Clock ───────────────────────────────────────────────────────────────

/// "Now" for notice derivation. Ticks every few minutes and when the app
/// returns to the foreground, so the next timetable period and the day's
/// challenge move on without the student reopening anything.
final noticeClockProvider = NotifierProvider<_NoticeClock, DateTime>(
  _NoticeClock.new,
);

class _NoticeClock extends Notifier<DateTime> {
  @override
  DateTime build() {
    final timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => state = DateTime.now(),
    );
    final listener = AppLifecycleListener(
      onResume: () => state = DateTime.now(),
    );
    ref.onDispose(() {
      timer.cancel();
      listener.dispose();
    });
    return DateTime.now();
  }

  void tick() => state = DateTime.now();
}

/// In-memory "first noticed at" times for notices whose source has no date
/// (e.g. running out of AI questions), so their relative time does not reset
/// to "just now" on every rebuild.
final _firstNoticedAtProvider = Provider<Map<String, DateTime>>((ref) => {});

/// Optional in-app reminders. Account and AI allowance notices stay visible.
enum ReminderType { timetable, dailyChallenge }

final reminderEnabledProvider =
    NotifierProvider.family<ReminderEnabled, bool, ReminderType>(
      ReminderEnabled.new,
    );

class ReminderEnabled extends Notifier<bool> {
  ReminderEnabled(this.type);

  final ReminderType type;

  String get _key => 'notification_reminder_${type.name}';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set(bool enabled) async {
    if (await ref.read(sharedPreferencesProvider).setBool(_key, enabled)) {
      if (ref.mounted) state = enabled;
    }
  }
}

// ─── Notices ─────────────────────────────────────────────────────────────

/// Every notice that applies right now, newest first.
final notificationsProvider = Provider<List<AppNotice>>((ref) {
  final now = ref.watch(noticeClockProvider);
  final firstNoticed = ref.watch(_firstNoticedAtProvider);
  DateTime firstSeen(String id) => firstNoticed.putIfAbsent(id, () => now);

  final notices = <AppNotice>[
    ..._plusNotices(ref.watch(plusProvider).status, now, firstSeen),
    ?_aiAllowanceNotice(ref, firstSeen),
    if (ref.watch(reminderEnabledProvider(ReminderType.timetable)))
      ?_timetableNotice(ref, now),
    if (ref.watch(reminderEnabledProvider(ReminderType.dailyChallenge)))
      ?_challengeNotice(ref, now),
  ]..sort((a, b) => b.time.compareTo(a.time));
  return List.unmodifiable(notices);
});

// ─── Read / unread ───────────────────────────────────────────────────────

/// Ids of notices the student has seen, persisted in SharedPreferences.
final seenNoticeIdsProvider = NotifierProvider<SeenNoticeIds, Set<String>>(
  SeenNoticeIds.new,
);

class SeenNoticeIds extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      ref.read(userPrefsRepositoryProvider).getSeenNoticeIds();

  Future<void> markRead(Iterable<String> ids) async {
    final fresh = ids.where((id) => !state.contains(id)).toList();
    if (fresh.isEmpty) return;
    state = {...state, ...fresh};
    await ref.read(userPrefsRepositoryProvider).addSeenNoticeIds(fresh);
  }

  /// Marks every notice that applies right now as read.
  Future<void> markAllRead() =>
      markRead(ref.read(notificationsProvider).map((n) => n.id));
}

/// How many current notices are unread — the badge on Home's bell.
final notificationsUnreadCountProvider = Provider<int>((ref) {
  final seen = ref.watch(seenNoticeIdsProvider);
  return ref
      .watch(notificationsProvider)
      .where((notice) => !seen.contains(notice.id))
      .length;
});

// ─── Plus ────────────────────────────────────────────────────────────────
// Copy stays general (no limit numbers) and a decline stays neutral, with no
// reason given.

List<AppNotice> _plusNotices(
  PlusStatus? status,
  DateTime now,
  DateTime Function(String id) firstSeen,
) {
  if (status == null) return const [];
  switch (status.state) {
    case PlusState.active:
      final expires = status.plusExpiresAt;
      // An end date already past means the server will flip this to expired.
      if (expires != null && !expires.isAfter(now)) return const [];
      final id = 'plus-approved-${_dayKey(status.decidedAt) ?? 'active'}';
      return [
        AppNotice(
          id: id,
          title: 'Plus is on',
          body: expires == null
              ? 'Your request was approved. Enjoy Plus.'
              : 'Your request was approved. Plus runs until '
                    '${shortDate(expires)}.',
          time: status.decidedAt ?? firstSeen(id),
          kind: AppNoticeKind.plus,
        ),
      ];
    case PlusState.pending:
      if (!status.available) return const [];
      final id = 'plus-requested-${_dayKey(status.requestedAt) ?? 'pending'}';
      return [
        AppNotice(
          id: id,
          title: 'Plus requested',
          body:
              "We'll review it. You don't need to do anything: it shows "
              "up when it's added.",
          time: status.requestedAt ?? firstSeen(id),
          kind: AppNoticeKind.plus,
        ),
      ];
    case PlusState.declined:
      if (!status.available) return const [];
      final id = 'plus-declined-${_dayKey(status.decidedAt) ?? 'declined'}';
      final again = status.canRequestAgainAt;
      return [
        AppNotice(
          id: id,
          title: 'Plus request update',
          // Same wording as the Plus sheet's plusMessage.
          body: status.canRequest
              ? "Plus isn't available for your account right now. You can "
                    'ask again from Profile.'
              : again != null && again.isAfter(now)
              ? "Plus isn't available for your account right now. You can "
                    'ask again after ${shortDate(again)}.'
              : "Plus isn't available for your account right now.",
          time: status.decidedAt ?? firstSeen(id),
          kind: AppNoticeKind.plus,
        ),
      ];
    case PlusState.expired:
      final id = 'plus-ended-${_dayKey(status.plusExpiresAt) ?? 'ended'}';
      final canAsk = status.available && status.canRequest;
      return [
        AppNotice(
          id: id,
          title: 'Plus has ended',
          body: canAsk
              ? 'Your account is back on Free. You can ask for Plus again '
                    'from Profile.'
              : 'Your account is back on Free.',
          time: status.plusExpiresAt ?? firstSeen(id),
          kind: AppNoticeKind.plus,
        ),
      ];
    case PlusState.none:
      return const [];
  }
}

// ─── AI allowance ────────────────────────────────────────────────────────

AppNotice? _aiAllowanceNotice(Ref ref, DateTime Function(String id) firstSeen) {
  final usage = ref
      .watch(backendAccountCacheProvider)
      .usage
      .maybeWhen(data: (value) => value, orElse: () => null);
  if (usage == null || usage.unlimited || usage.remaining > 0) return null;
  final id = 'ai-out-${usage.dateIst}';
  return AppNotice(
    id: id,
    title: 'No AI questions left today',
    body: 'Your questions come back ${refreshPhrase(usage.resetsAt)}.',
    time: firstSeen(id),
    kind: AppNoticeKind.aiQuestions,
  );
}

// ─── Timetable ───────────────────────────────────────────────────────────

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Today's next timetable period, if one is still to start.
AppNotice? _timetableNotice(Ref ref, DateTime now) {
  if (_inQuietHours(now)) return null;
  final today = DateTime(now.year, now.month, now.day);
  final day = _weekdays[now.weekday - 1];
  final periods = ref.read(userPrefsRepositoryProvider).getTimetable()[day];
  if (periods == null || periods.isEmpty) return null;

  final timed = <({TimetablePeriod period, DateTime start, DateTime? end})>[
    for (final p in periods)
      if (_at(today, p.startTime) case final start?)
        (period: p, start: start, end: _at(today, p.endTime)),
  ]..sort((a, b) => a.start.compareTo(b.start));

  final nextIndex = timed.indexWhere((t) => t.start.isAfter(now));
  if (nextIndex < 0) return null;
  final next = timed[nextIndex];

  // It became "next" when the previous period ended, or when quiet hours
  // ended for the first period of the day.
  final dayOpens = today.add(const Duration(hours: _quietEndHour));
  final previousEnd = nextIndex > 0 ? timed[nextIndex - 1].end : null;
  var since = previousEnd ?? dayOpens;
  if (since.isBefore(dayOpens)) since = dayOpens;
  if (since.isAfter(now)) since = now;

  final subject = next.period.subject.trim();
  return AppNotice(
    id: 'timetable-${_dayKey(today)}-${next.period.id}',
    title: 'Coming up: $subject',
    body: 'Your timetable has $subject at ${_clockLabel(next.start)}.',
    time: since,
    kind: AppNoticeKind.timetable,
    route: '/timetable',
  );
}

// ─── Daily Brain Challenge ───────────────────────────────────────────────

AppNotice? _challengeNotice(Ref ref, DateTime now) {
  if (_inQuietHours(now)) return null;
  // Watched so finishing the challenge clears the notice at once; the repo is
  // asked directly because the cached flag can be from yesterday after the day
  // rolls over.
  ref.watch(gamesProgressProvider.select((p) => p.dailyDoneToday));
  if (ref.read(userPrefsRepositoryProvider).isDailyChallengeDoneToday()) {
    return null;
  }
  final today = DateTime(now.year, now.month, now.day);
  return AppNotice(
    id: 'challenge-${_dayKey(today)}',
    title: "Today's Brain Challenge is ready",
    body: 'A quick puzzle to warm up your brain. Can you solve it?',
    time: today.add(const Duration(hours: _quietEndHour)),
    kind: AppNoticeKind.challenge,
    route: '/games',
  );
}

// ─── Helpers ─────────────────────────────────────────────────────────────

bool _inQuietHours(DateTime now) =>
    now.hour < _quietEndHour || now.hour >= _quietStartHour;

/// Local `yyyy-mm-dd`, or null for a missing date.
String? _dayKey(DateTime? date) {
  if (date == null) return null;
  final local = date.toLocal();
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '${local.year}-$m-$d';
}

/// Parses a timetable `HH:mm` onto [day]; null when it does not parse.
DateTime? _at(DateTime day, String hhmm) {
  final parts = hhmm.trim().split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return DateTime(day.year, day.month, day.day, hour, minute);
}

/// "10:00 am" style, matching the timetable's 12-hour reading.
String _clockLabel(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'am' : 'pm'}';
}
