import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/programming/python_course_data.dart';
import '../data/programming/python_models.dart';
import 'core_providers.dart';

// ─── Python progress ──────────────────────────────────────────────────────────
//
// Reads completion + best quiz scores from UserPrefsRepository and exposes
// derived helpers for the UI (per-chapter fraction/stars, overall fraction).
// Mirrors ProgressNotifier: build from the repo, mutate via the repo, then
// refresh so watchers rebuild.

class PythonProgress {
  final Set<String> completedLessonIds;
  final Map<String, int> quizBestScores; // chapterId → best correct count

  const PythonProgress({
    required this.completedLessonIds,
    required this.quizBestScores,
  });

  bool isLessonDone(String lessonId) => completedLessonIds.contains(lessonId);

  int completedInChapter(PythonChapter c) =>
      c.lessons.where((l) => completedLessonIds.contains(l.id)).length;

  double chapterFraction(PythonChapter c) {
    if (c.lessons.isEmpty) return 0;
    return completedInChapter(c) / c.lessons.length;
  }

  bool isChapterComplete(PythonChapter c) =>
      c.lessons.isNotEmpty && completedInChapter(c) == c.lessons.length;

  /// 0–3 stars from the best quiz score: ≥60% → 1★, ≥80% → 2★, 100% → 3★.
  int chapterStars(PythonChapter c) {
    final best = quizBestScores[c.id];
    if (best == null || c.quiz.isEmpty) return 0;
    final ratio = best / c.quiz.length;
    if (ratio >= 1.0) return 3;
    if (ratio >= 0.8) return 2;
    if (ratio >= 0.6) return 1;
    return 0;
  }

  double overallFraction() {
    final total = pythonTotalLessons;
    if (total == 0) return 0;
    return completedLessonIds.length / total;
  }

  int get completedCount => completedLessonIds.length;
}

class PythonProgressNotifier extends Notifier<PythonProgress> {
  @override
  PythonProgress build() => _load();

  PythonProgress _load() {
    final repo = ref.read(userPrefsRepositoryProvider);
    return PythonProgress(
      completedLessonIds: repo.getPythonCompletedLessons(),
      quizBestScores: repo.getPythonQuizScores(),
    );
  }

  void refresh() => state = _load();

  Future<void> completeLesson(String lessonId) async {
    await ref.read(userPrefsRepositoryProvider).markPythonLessonCompleted(
          lessonId,
        );
    refresh();
  }

  Future<void> recordQuizScore(String chapterId, int correct) async {
    await ref.read(userPrefsRepositoryProvider).recordPythonQuizScore(
          chapterId,
          correct,
        );
    refresh();
  }
}

final pythonProgressProvider =
    NotifierProvider<PythonProgressNotifier, PythonProgress>(
  PythonProgressNotifier.new,
);
