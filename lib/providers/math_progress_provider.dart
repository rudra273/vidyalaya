import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

// ─── Math progress ────────────────────────────────────────────────────────────
//
// Best score per math tool, read from UserPrefsRepository. Mirrors
// PythonProgressNotifier: build from the repo, mutate via the repo, then refresh
// so watchers rebuild.
//
// The learning streak needs nothing here — recordMathScore already calls the
// repo's shared _recordActivityToday().

class MathProgress {
  /// toolId → best score.
  final Map<String, int> bestScores;

  const MathProgress({required this.bestScores});

  int? bestFor(String toolId) => bestScores[toolId];

  bool hasPlayed(String toolId) => bestScores.containsKey(toolId);
}

class MathProgressNotifier extends Notifier<MathProgress> {
  @override
  MathProgress build() => _load();

  MathProgress _load() {
    final repo = ref.read(userPrefsRepositoryProvider);
    return MathProgress(bestScores: repo.getMathBestScores());
  }

  void refresh() => state = _load();

  /// Records a finished round. Only improves on the stored best.
  Future<void> recordScore(String toolId, int score) async {
    await ref.read(userPrefsRepositoryProvider).recordMathScore(toolId, score);
    refresh();
  }
}

final mathProgressProvider =
    NotifierProvider<MathProgressNotifier, MathProgress>(
  MathProgressNotifier.new,
);
