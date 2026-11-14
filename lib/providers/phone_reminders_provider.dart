import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/timetable_period.dart';
import 'core_providers.dart';
import 'games_progress_provider.dart';
import 'notifications_provider.dart';

final phoneRemindersProvider =
    NotifierProvider<PhoneReminders, PhoneReminderStatus>(PhoneReminders.new);

enum PhoneReminderStatus {
  unsupported,
  checking,
  blocked,
  enabled,
  unavailable,
}

class PhoneReminders extends Notifier<PhoneReminderStatus> {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _destinations = StreamController<String>.broadcast();
  Future<void> _queue = Future.value();
  bool _initialized = false;
  bool _disposed = false;

  Stream<String> get destinations => _destinations.stream;

  @override
  PhoneReminderStatus build() {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return PhoneReminderStatus.unsupported;
    }
    final lifecycle = AppLifecycleListener(
      onResume: () => unawaited(refresh()),
    );
    ref.onDispose(() {
      _disposed = true;
      lifecycle.dispose();
      unawaited(_destinations.close());
    });
    for (final type in ReminderType.values) {
      ref.listen(reminderEnabledProvider(type), (_, _) => unawaited(refresh()));
    }
    ref.listen(
      gamesProgressProvider.select((stats) => stats.dailyDoneToday),
      (_, _) => unawaited(refresh()),
    );
    unawaited(refresh());
    return PhoneReminderStatus.checking;
  }

  Future<void> refresh() => _enqueue(requestPermission: false);

  Future<void> requestPermission() => _enqueue(requestPermission: true);

  Future<void> _enqueue({required bool requestPermission}) {
    _queue = _queue.then((_) async {
      if (_disposed || state == PhoneReminderStatus.unsupported) return;
      try {
        if (!_initialized) {
          zones.initializeTimeZones();
          await _plugin.initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('ic_reminder'),
              iOS: DarwinInitializationSettings(
                requestAlertPermission: false,
                requestBadgePermission: false,
                requestSoundPermission: false,
              ),
            ),
            onDidReceiveNotificationResponse: (response) =>
                _open(response.payload),
          );
          _initialized = true;
          final launch = await _plugin.getNotificationAppLaunchDetails();
          if (launch?.didNotificationLaunchApp == true) {
            _open(launch?.notificationResponse?.payload);
          }
        }
        if (_disposed) return;
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        if (requestPermission) {
          if (android != null) {
            await android.requestNotificationsPermission();
          } else {
            await ios?.requestPermissions(alert: true, sound: true);
          }
        }
        final allowed = android != null
            ? await android.areNotificationsEnabled() ?? false
            : (await ios?.checkPermissions())?.isEnabled ?? false;
        if (_disposed) return;
        await _plugin.cancelAllPendingNotifications();
        if (_disposed) return;
        if (!allowed) {
          state = PhoneReminderStatus.blocked;
          return;
        }

        final zone = tz.getLocation(
          (await FlutterTimezone.getLocalTimezone()).identifier,
        );
        if (_disposed) return;
        final prefs = ref.read(userPrefsRepositoryProvider);
        final schedule = planPhoneReminders(
          now: tz.TZDateTime.now(zone),
          timetable: ref.read(reminderEnabledProvider(ReminderType.timetable))
              ? prefs.getTimetable()
              : const {},
          dailyChallenge: ref.read(
            reminderEnabledProvider(ReminderType.dailyChallenge),
          ),
          challengeDoneToday: prefs.isDailyChallengeDoneToday(),
        );
        for (final (index, event) in schedule.indexed) {
          if (_disposed) return;
          await _plugin.zonedSchedule(
            id: 1000 + index,
            title: event.title,
            body: event.body,
            scheduledDate: event.at,
            payload: event.route,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                event.route == '/timetable'
                    ? 'timetable_reminders'
                    : 'daily_challenge_reminders',
                event.route == '/timetable'
                    ? 'Timetable reminders'
                    : 'Daily challenge reminders',
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );
        }
        if (!_disposed) state = PhoneReminderStatus.enabled;
      } catch (error, stack) {
        debugPrint('Phone reminder setup failed: $error\n$stack');
        if (!_disposed) state = PhoneReminderStatus.unavailable;
      }
    });
    return _queue;
  }

  void _open(String? route) {
    if (!_disposed && (route == '/timetable' || route == '/games')) {
      _destinations.add(route!);
    }
  }
}

typedef PhoneReminder = ({
  tz.TZDateTime at,
  String title,
  String body,
  String route,
});

List<PhoneReminder> planPhoneReminders({
  required tz.TZDateTime now,
  required Map<String, List<TimetablePeriod>> timetable,
  required bool dailyChallenge,
  required bool challengeDoneToday,
}) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final events = <PhoneReminder>[];
  final zone = now.location;
  for (var offset = 0; offset < 7; offset++) {
    final day = tz.TZDateTime(zone, now.year, now.month, now.day + offset);
    for (final period
        in timetable[weekdays[day.weekday - 1]] ?? const <TimetablePeriod>[]) {
      final parts = period.startTime.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null ||
          hour < 0 ||
          hour > 23 ||
          minute == null ||
          minute < 0 ||
          minute > 59) {
        continue;
      }
      final start = tz.TZDateTime(
        zone,
        day.year,
        day.month,
        day.day,
        hour,
        minute,
      );
      final at = start.subtract(const Duration(minutes: 10));
      if (!at.isAfter(now) || at.hour < 7 || at.hour >= 21) continue;
      events.add((
        at: at,
        title: 'Upcoming class',
        body: 'Check your timetable for your next class.',
        route: '/timetable',
      ));
    }
    final at = tz.TZDateTime(zone, day.year, day.month, day.day, 18);
    if (dailyChallenge &&
        (offset != 0 || !challengeDoneToday) &&
        at.isAfter(now)) {
      events.add((
        at: at,
        title: 'Daily Brain Challenge',
        body: 'Your daily puzzle is ready.',
        route: '/games',
      ));
    }
  }
  events.sort((a, b) => a.at.compareTo(b.at));
  final seen = <(DateTime, String)>{};
  return events.where((e) => seen.add((e.at, e.route))).take(60).toList();
}
