import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/avatars.dart';
import 'core_providers.dart';
import 'auth_provider.dart';

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

/// Signed-in avatars come from the uid-scoped profile cache. Guest choices
/// stay local and cannot leak into another account on a shared device.
final effectiveAvatarIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) return null;
  final user = auth.value;
  if (user == null) return ref.watch(avatarIdProvider);
  final account = ref.watch(backendAccountCacheProvider);
  if (account.uid != user.uid) return null;
  return account.profile.value?.avatarId;
});

/// The resolved avatar for the current selection (null = letter default).
final selectedAvatarProvider = Provider<StudentAvatar?>((ref) {
  return avatarById(ref.watch(effectiveAvatarIdProvider));
});
