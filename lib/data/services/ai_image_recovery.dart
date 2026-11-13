import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/ai_image_draft.dart';
import '../repositories/user_prefs_repository.dart';

class RecoveredAiImage {
  final AiImageDraft draft;
  final XFile? file;
  final bool failed;

  const RecoveredAiImage(this.draft, {this.file, this.failed = false});
}

/// Startup recovery must run before routing: the original picker Future no
/// longer exists when Android recreates the app.
class AiImageRecovery {
  final UserPrefsRepository prefs;
  final ImagePicker picker;
  RecoveredAiImage? _recovered;

  AiImageRecovery(this.prefs, {ImagePicker? picker})
    : picker = picker ?? ImagePicker();

  String? get initialLocation => _recovered?.draft.location;

  RecoveredAiImage? takeRecovered() {
    final result = _recovered;
    _recovered = null;
    return result;
  }

  Future<void> recover(String? uid) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final draft = prefs.getAiImageDraft();
    try {
      // Drain plugin data even if our draft is missing or belongs to another uid.
      final response = await picker.retrieveLostData();
      if (draft == null || draft.uid != uid) return;
      _recovered = RecoveredAiImage(
        draft,
        file: response.files?.firstOrNull,
        failed: response.exception != null,
      );
    } catch (_) {
      if (draft != null && draft.uid == uid) {
        _recovered = RecoveredAiImage(draft, failed: true);
      }
    } finally {
      await prefs.clearAiImageDraft();
    }
  }
}
