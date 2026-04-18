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

final userSelectionProvider =
    NotifierProvider<UserSelectionNotifier, Set<int>>(
  UserSelectionNotifier.new,
);
