import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';

void main() {
  String day(DateTime d) => d.toIso8601String().split('T')[0];

  test('a new day counts once even when many screens ask at the same time', () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    SharedPreferences.setMockInitialValues({
      'current_streak': 1,
      'last_active_date': day(yesterday),
    });
    final repo = UserPrefsRepository(await SharedPreferences.getInstance());

    // The first open of a day: Home, Profile and progress all read at once.
    repo.getCurrentStreak();
    repo.getPagesReadToday();
    repo.getCurrentStreak();
    await repo.recordAiSession();
    await Future<void>.delayed(Duration.zero);

    expect(repo.getCurrentStreak(), 2);
  });

  test('a missed day starts the streak again', () async {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    SharedPreferences.setMockInitialValues({
      'current_streak': 5,
      'last_active_date': day(twoDaysAgo),
    });
    final repo = UserPrefsRepository(await SharedPreferences.getInstance());

    repo.getCurrentStreak();
    await Future<void>.delayed(Duration.zero);

    expect(repo.getCurrentStreak(), 1);
  });
}
