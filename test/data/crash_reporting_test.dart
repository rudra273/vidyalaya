import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/services/crash_reporting.dart';

class _FakeCrashlytics extends Fake implements FirebaseCrashlytics {
  bool? collectionEnabled;
  final recordedErrors = <({Object error, bool fatal})>[];
  final recordedFlutterErrors = <FlutterErrorDetails>[];

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    recordedFlutterErrors.add(details);
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
    bool? ignored,
  }) async {
    recordedErrors.add((error: exception as Object, fatal: fatal));
  }
}

void main() {
  final originalFlutterOnError = FlutterError.onError;
  final originalPlatformOnError = PlatformDispatcher.instance.onError;

  tearDown(() {
    FlutterError.onError = originalFlutterOnError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
  });

  test('collection follows the build mode and is off in tests', () async {
    final off = _FakeCrashlytics();
    await initCrashReporting(crashlytics: off);
    expect(off.collectionEnabled, isFalse);

    final on = _FakeCrashlytics();
    await initCrashReporting(crashlytics: on, enabled: true);
    expect(on.collectionEnabled, isTrue);
  });

  test('framework and async errors are forwarded as fatal', () async {
    final crashlytics = _FakeCrashlytics();
    await initCrashReporting(crashlytics: crashlytics, enabled: true);

    final details = FlutterErrorDetails(exception: StateError('framework'));
    FlutterError.onError!(details);
    expect(crashlytics.recordedFlutterErrors, [details]);

    final handled = PlatformDispatcher.instance.onError!(
      StateError('async'),
      StackTrace.current,
    );
    expect(handled, isTrue);
    expect(crashlytics.recordedErrors.single.fatal, isTrue);
    expect(crashlytics.recordedErrors.single.error, isA<StateError>());
  });
}
