/// Bundled profile avatars.
///
/// Students under 13 pick from these preset illustrations instead of
/// uploading a photo — no camera/gallery permissions, nothing leaves the
/// device. Add new avatars by dropping an SVG in `assets/avatars/` and
/// appending an entry here; ids are persisted, so never reuse or rename one.
class StudentAvatar {
  final String id;
  final String assetPath;
  final String label;

  const StudentAvatar({
    required this.id,
    required this.assetPath,
    required this.label,
  });
}

const List<StudentAvatar> kStudentAvatars = [
  StudentAvatar(
    id: 'boy_1',
    assetPath: 'assets/avatars/boy_1.svg',
    label: 'Boy 1',
  ),
  StudentAvatar(
    id: 'boy_2',
    assetPath: 'assets/avatars/boy_2.svg',
    label: 'Boy 2',
  ),
  StudentAvatar(
    id: 'girl_1',
    assetPath: 'assets/avatars/girl_1.svg',
    label: 'Girl 1',
  ),
  StudentAvatar(
    id: 'girl_2',
    assetPath: 'assets/avatars/girl_2.svg',
    label: 'Girl 2',
  ),
  // Older-looking set (roughly 13–16).
  StudentAvatar(
    id: 'boy_3',
    assetPath: 'assets/avatars/boy_3.svg',
    label: 'Boy 3',
  ),
  StudentAvatar(
    id: 'boy_4',
    assetPath: 'assets/avatars/boy_4.svg',
    label: 'Boy 4',
  ),
  StudentAvatar(
    id: 'girl_3',
    assetPath: 'assets/avatars/girl_3.svg',
    label: 'Girl 3',
  ),
  StudentAvatar(
    id: 'girl_4',
    assetPath: 'assets/avatars/girl_4.svg',
    label: 'Girl 4',
  ),
];

/// Resolves a stored id to its avatar, or null for unknown/unset ids
/// (callers fall back to the letter avatar).
StudentAvatar? avatarById(String? id) {
  if (id == null) return null;
  for (final avatar in kStudentAvatars) {
    if (avatar.id == id) return avatar;
  }
  return null;
}
