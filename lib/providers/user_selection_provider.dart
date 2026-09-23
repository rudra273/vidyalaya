import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'core_providers.dart';

final accountUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

/// Notifier that manages the set of class numbers the user has selected.
class UserSelectionNotifier extends Notifier<Set<int>> {
  String? _accountUid;

  @override
  Set<int> build() {
    _accountUid = ref.watch(accountUidProvider);
    final repo = ref.read(userPrefsRepositoryProvider);
    return repo.getSelectedClasses(uid: _accountUid);
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
    // Profile loads/saves call this with the class the student already has.
    // `Set` compares by identity, so re-assigning an equal-but-new set would
    // still notify every listener — enough to rebuild screens that fetch on
    // build and re-trigger the load that called us.
    if (classes.length == state.length && state.containsAll(classes)) return;
    state = classes;
    _persist(classes);
  }

  void _persist(Set<int> classes) {
    final repo = ref.read(userPrefsRepositoryProvider);
    repo.setSelectedClasses(classes, uid: _accountUid);
  }
}

final userSelectionProvider = NotifierProvider<UserSelectionNotifier, Set<int>>(
  UserSelectionNotifier.new,
);

/// Notifier that manages the user's selected syllabus board.
class UserBoardNotifier extends Notifier<String> {
  String? _accountUid;

  @override
  String build() {
    _accountUid = ref.watch(accountUidProvider);
    final repo = ref.read(userPrefsRepositoryProvider);
    return repo.getSelectedBoard(uid: _accountUid);
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
    repo.setSelectedBoard(board, uid: _accountUid);
  }
}

final userBoardProvider = NotifierProvider<UserBoardNotifier, String>(
  UserBoardNotifier.new,
);
