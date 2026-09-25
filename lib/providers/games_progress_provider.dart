import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'core_providers.dart';
import 'progress_provider.dart';
import 'user_selection_provider.dart';

// ─── Brain games progress ─────────────────────────────────────────────────────
//
// Best scores per game key plus the Daily Brain Challenge state, read from
// UserPrefsRepository. Mirrors MathProgressNotifier: mutate via the repo, then
// reload so watchers rebuild. Every finished game also counts as learning
// activity, so the Home streak is refreshed too.

class GamesProgress {
  final Map<String, int> bestScores;
  final bool dailyDoneToday;
  final int dailyStreak;

  const GamesProgress({
    required this.bestScores,
    required this.dailyDoneToday,
    required this.dailyStreak,
  });

  int? bestFor(String key) => bestScores[key];
}

class GamesProgressNotifier extends Notifier<GamesProgress> {
  @override
  GamesProgress build() => _load();

  GamesProgress _load() {
    final repo = ref.read(userPrefsRepositoryProvider);
    return GamesProgress(
      bestScores: repo.getGameBestScores(),
      dailyDoneToday: repo.isDailyChallengeDoneToday(),
      dailyStreak: repo.getDailyChallengeStreak(),
    );
  }

  /// Re-reads state, e.g. when the day may have rolled over.
  void refresh() => state = _load();

  Future<void> recordScore(
    String key,
    int score, {
    bool lowerIsBetter = false,
  }) async {
    await ref
        .read(userPrefsRepositoryProvider)
        .recordGameScore(key, score, lowerIsBetter: lowerIsBetter);
    _afterActivity();
  }

  Future<void> recordDailyDone() async {
    await ref.read(userPrefsRepositoryProvider).recordDailyChallengeDone();
    _afterActivity();
  }

  void _afterActivity() {
    refresh();
    ref.read(progressProvider.notifier).refresh();
    final classes = ref.read(exploreClassSelectionProvider);
    unawaited(
      ref
          .read(learningEventServiceProvider)
          .recordBestEffort(
            eventType: 'exercise_completed',
            feature: 'practice',
            board: ref.read(userBoardProvider),
            classNo: classes.length == 1 ? classes.single : null,
          ),
    );
  }
}

final gamesProgressProvider =
    NotifierProvider<GamesProgressNotifier, GamesProgress>(
      GamesProgressNotifier.new,
    );

/// The lowest class the student selected, or null — games pitch their default
/// difficulty here so they never land above the student's level.
final gamesClassLevelProvider = Provider<int?>((ref) {
  final selected = ref.watch(exploreClassSelectionProvider);
  if (selected.isEmpty) return null;
  return selected.reduce((a, b) => a < b ? a : b);
});
