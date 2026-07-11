import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/programming/python_course_data.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/python_progress_provider.dart';

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts empty', () async {
    final container = await _container();
    final progress = container.read(pythonProgressProvider);
    expect(progress.completedCount, 0);
    expect(progress.overallFraction(), 0);
  });

  test('completing a lesson persists and updates state', () async {
    final container = await _container();
    final notifier = container.read(pythonProgressProvider.notifier);

    final firstLesson = pythonChapters.first.lessons.first;
    await notifier.completeLesson(firstLesson.id);

    final progress = container.read(pythonProgressProvider);
    expect(progress.isLessonDone(firstLesson.id), isTrue);
    expect(progress.completedCount, 1);
  });

  test('completion survives a fresh container (persisted)', () async {
    final firstLesson = pythonChapters.first.lessons.first;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final c1 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    await c1.read(pythonProgressProvider.notifier).completeLesson(
          firstLesson.id,
        );
    c1.dispose();

    final c2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c2.dispose);
    expect(
      c2.read(pythonProgressProvider).isLessonDone(firstLesson.id),
      isTrue,
    );
  });

  test('quiz score keeps only the best', () async {
    final container = await _container();
    final notifier = container.read(pythonProgressProvider.notifier);
    final chapter = pythonChapters.first;

    await notifier.recordQuizScore(chapter.id, 3);
    await notifier.recordQuizScore(chapter.id, 5);
    await notifier.recordQuizScore(chapter.id, 2); // lower — ignored

    expect(
      container.read(pythonProgressProvider).quizBestScores[chapter.id],
      5,
    );
  });

  test('chapterFraction reflects completed lessons', () async {
    final container = await _container();
    final notifier = container.read(pythonProgressProvider.notifier);
    final chapter = pythonChapters.first;

    await notifier.completeLesson(chapter.lessons.first.id);

    final frac = container.read(pythonProgressProvider).chapterFraction(chapter);
    expect(frac, closeTo(1 / chapter.lessons.length, 0.0001));
  });

  test('chapterStars maps full score to 3 stars', () async {
    final container = await _container();
    final notifier = container.read(pythonProgressProvider.notifier);
    final chapter = pythonChapters.first;

    await notifier.recordQuizScore(chapter.id, chapter.quiz.length);
    expect(
      container.read(pythonProgressProvider).chapterStars(chapter),
      3,
    );
  });
}
