import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';

void main() {
  test('recent questions are isolated by Firebase uid', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = UserPrefsRepository(prefs);

    await repository.recordRecentQuestion('uid-a', 'Question from A');
    await repository.recordRecentQuestion('uid-b', 'Question from B');

    expect(
      repository.getRecentQuestions('uid-a').single.text,
      'Question from A',
    );
    expect(
      repository.getRecentQuestions('uid-b').single.text,
      'Question from B',
    );
  });

  test('keeps one recent question per conversation', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = UserPrefsRepository(prefs);

    await repository.recordRecentQuestion('u', 'how many chapters?',
        subject: 'maths');
    await repository.recordRecentQuestion('u', 'list them', subject: 'maths');
    await repository.recordRecentQuestion('u', 'what is a cell?',
        subject: 'science');

    final recents = repository.getRecentQuestions('u');
    expect(recents.map((q) => q.text), ['what is a cell?', 'list them']);
  });

  test('unowned legacy recent questions are discarded', () async {
    SharedPreferences.setMockInitialValues({
      'recent_ai_questions': jsonEncode([
        {
          'text': 'Private legacy question',
          'subject': 'science',
          'asked_at': DateTime.utc(2026).toIso8601String(),
        },
      ]),
    });
    final prefs = await SharedPreferences.getInstance();
    final repository = UserPrefsRepository(prefs);

    expect(repository.getRecentQuestions('new-user'), isEmpty);
    expect(prefs.containsKey('recent_ai_questions'), isFalse);
  });
}
