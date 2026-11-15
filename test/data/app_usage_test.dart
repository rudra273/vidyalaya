import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/screens/profile/widgets/profile_activity.dart';

// ─── Study time from app use ──────────────────────────────────────────────────

void main() {
  Future<UserPrefsRepository> repo() async {
    SharedPreferences.setMockInitialValues({});
    return UserPrefsRepository(await SharedPreferences.getInstance());
  }

  test('app use adds up per day', () async {
    final r = await repo();
    final day = DateTime(2026, 11, 15, 10);
    await r.addAppUseSeconds(day, 120);
    await r.addAppUseSeconds(day, 60);
    await r.addAppUseSeconds(DateTime(2026, 11, 14, 23), 30);
    expect(r.getDailyAppUseSeconds(), {'2026-11-15': 180, '2026-11-14': 30});
  });

  test('old days are dropped', () async {
    final r = await repo();
    await r.addAppUseSeconds(DateTime(2026, 10, 1), 600);
    await r.addAppUseSeconds(DateTime(2026, 11, 15), 60);
    expect(r.getDailyAppUseSeconds().keys, ['2026-11-15']);
  });

  test('zero or negative seconds are ignored', () async {
    final r = await repo();
    await r.addAppUseSeconds(DateTime(2026, 11, 15), 0);
    expect(r.getDailyAppUseSeconds(), isEmpty);
  });

  test('the week runs Monday to Sunday in minutes', () {
    // 2026-11-15 is a Sunday; its week starts Monday 2026-11-09.
    final minutes = weekAppUseMinutes({
      '2026-11-08': 6000, // previous Sunday, not this week
      '2026-11-09': 600,
      '2026-11-11': 59,
      '2026-11-15': 3720,
    }, DateTime(2026, 11, 15, 21));
    expect(minutes, [10, 0, 0, 0, 0, 0, 62]);
  });

  test('study time reads as hours and minutes', () {
    expect(formatStudyMinutes(0), '0m');
    expect(formatStudyMinutes(45), '45m');
    expect(formatStudyMinutes(60), '1h');
    expect(formatStudyMinutes(150), '2h 30m');
  });
}
