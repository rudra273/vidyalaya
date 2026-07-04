import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

/// Notifier that manages the set of class numbers the user has selected.
class UserSelectionNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    final repo = ref.read(userPrefsRepositoryProvider);
    return repo.getSelectedClasses();
  }

  void toggleClass(int classNumber) {
    final current = Set<int>.from(state);
    if (current.contains(classNumber)) {
      current.remove(classNumber);
    } else {
      current.add(classNumber);
    }
    state = current;
    _persist(current);
  }

  void setClasses(Set<int> classes) {
    state = classes;
    _persist(classes);
  }

  void _persist(Set<int> classes) {
    final repo = ref.read(userPrefsRepositoryProvider);
    repo.setSelectedClasses(classes);
  }
}

final userSelectionProvider = NotifierProvider<UserSelectionNotifier, Set<int>>(
  UserSelectionNotifier.new,
);

/// Notifier that manages the user's selected syllabus board.
class UserBoardNotifier extends Notifier<String> {
  @override
  String build() {
    final repo = ref.read(userPrefsRepositoryProvider);
    return repo.getSelectedBoard();
  }

  void setBoard(String board) {
    // Profile saves call this redundantly with the current board; only a real
    // change should reset language state.
    if (board == state) return;
    final repo = ref.read(userPrefsRepositoryProvider);
    // An explicit language switch was made in the old board's context; clear
    // it before updating state so the regional language re-resolves straight
    // to the new board's default.
    repo.clearRegionalLanguage();
    state = board;
    repo.setSelectedBoard(board);
  }
}

final userBoardProvider = NotifierProvider<UserBoardNotifier, String>(
  UserBoardNotifier.new,
);
