import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;
import 'package:vidyalaya/data/models/timetable_period.dart';
import 'package:vidyalaya/providers/phone_reminders_provider.dart';

void main() {
  late tz.Location zone;
  setUpAll(() {
    zones.initializeTimeZones();
    zone = tz.getLocation('Asia/Kolkata');
  });

  TimetablePeriod period(String time) => TimetablePeriod(
    id: time,
    subject: 'Mathematics',
    startTime: time,
    endTime: '11:00',
  );

  test(
    'schedules future local reminders and skips quiet hours and completed challenge',
    () {
      final now = tz.TZDateTime(zone, 2026, 11, 16, 8);
      final alerts = planPhoneReminders(
        now: now,
        timetable: {
          'Monday': [
            period('07:05'),
            period('08:05'),
            period('10:00'),
            period('10:00'),
            period('21:30'),
            period('invalid'),
          ],
        },
        dailyChallenge: true,
        challengeDoneToday: true,
      );
      expect(
        alerts
            .where((alert) => alert.route == '/timetable')
            .map((alert) => alert.at),
        [tz.TZDateTime(zone, 2026, 11, 16, 9, 50)],
      );
      final daily = alerts.where((alert) => alert.route == '/games').toList();
      expect(daily, hasLength(6));
      expect(daily.first.at, tz.TZDateTime(zone, 2026, 11, 17, 18));
      expect(daily.last.at, tz.TZDateTime(zone, 2026, 11, 22, 18));
    },
  );

  test(
    'keeps at most 60 pending reminders and honors a disabled challenge',
    () {
      final now = tz.TZDateTime(zone, 2026, 11, 16, 7);
      final alerts = planPhoneReminders(
        now: now,
        timetable: {
          for (final day in [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ])
            day: [for (var hour = 8; hour < 20; hour++) period('$hour:00')],
        },
        dailyChallenge: false,
        challengeDoneToday: false,
      );
      expect(alerts, hasLength(60));
      expect(alerts.every((alert) => alert.route == '/timetable'), isTrue);
      expect(alerts.last.at, tz.TZDateTime(zone, 2026, 11, 20, 18, 50));
    },
  );
}
