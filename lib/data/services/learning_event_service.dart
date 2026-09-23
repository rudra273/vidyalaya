import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'backend_auth_service.dart';

/// Small, privacy-limited activity events. A failed event never blocks study.
class LearningEventService {
  LearningEventService({
    required BackendAuthService backend,
    required FirebaseAuth auth,
  }) : _backend = backend,
       _auth = auth;

  final BackendAuthService _backend;
  final FirebaseAuth _auth;
  static const _uuid = Uuid();

  Future<void> record({
    required String eventType,
    required String feature,
    String? board,
    int? classNo,
  }) async {
    if (_auth.currentUser == null) return;
    await _backend.recordLearningEvent(
      eventId: _uuid.v4(),
      eventType: eventType,
      feature: feature,
      board: board,
      classNo: classNo,
    );
  }

  Future<void> recordBestEffort({
    required String eventType,
    required String feature,
    String? board,
    int? classNo,
  }) async {
    try {
      await record(
        eventType: eventType,
        feature: feature,
        board: board,
        classNo: classNo,
      );
    } catch (_) {
      // Activity telemetry is non-blocking. Offline actions stay device-local.
    }
  }
}
