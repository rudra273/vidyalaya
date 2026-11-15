import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// ─── Crash reporting ───

const _forceEnabled = bool.fromEnvironment('CRASH_REPORTING');

/// Routes uncaught errors to Crashlytics.
///
/// Reports carry stack traces only: no user identifier, custom keys, logs or
/// free text are attached, and collection is off in debug and profile builds
/// unless the build passes `--dart-define=CRASH_REPORTING=true` (for checking
/// the Firebase connection from a debug build). Call once, after
/// `Firebase.initializeApp()`.
Future<void> initCrashReporting({
  FirebaseCrashlytics? crashlytics,
  bool? enabled,
}) async {
  final reporter = crashlytics ?? FirebaseCrashlytics.instance;
  await reporter.setCrashlyticsCollectionEnabled(
    enabled ?? (kReleaseMode || _forceEnabled),
  );

  FlutterError.onError = reporter.recordFlutterFatalError;
  // Uncaught async errors do not stop the app (most are a failed request the
  // student never sees), so they are recorded as non-fatal. Counting them as
  // crashes would make the crash-free rate read far worse than it is.
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack, fatal: false);
    return true;
  };
}
