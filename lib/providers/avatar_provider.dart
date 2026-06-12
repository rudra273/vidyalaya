import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/avatars.dart';
import 'core_providers.dart';

/// Notifier for the student's chosen avatar id, persisted locally.
/// Null means no avatar picked — UI falls back to the letter circle.
class AvatarIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final stored = ref.read(userPrefsRepositoryProvider).getAvatarId();
    // Drop ids that no longer exist in the catalog.
    return avatarById(stored)?.id;
  }

  void setAvatarId(String? id) {
    state = id;
    ref.read(userPrefsRepositoryProvider).setAvatarId(id);
  }
}

final avatarIdProvider = NotifierProvider<AvatarIdNotifier, String?>(
  AvatarIdNotifier.new,
);

/// The resolved avatar for the current selection (null = letter default).
final selectedAvatarProvider = Provider<StudentAvatar?>((ref) {
  return avatarById(ref.watch(avatarIdProvider));
});
