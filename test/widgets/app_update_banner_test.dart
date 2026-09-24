import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/widgets/app_update_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('de.ffuf.in_app_update/methods');
  var updateAvailability = 1;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'checkForUpdate');
          return <String, Object?>{
            'updateAvailability': updateAvailability,
            'immediateAllowed': false,
            'flexibleAllowed': true,
            'availableVersionCode': updateAvailability == 2 ? 5 : null,
            'installStatus': 0,
            'packageName': 'com.vidyalaya.ai',
            'clientVersionStalenessDays': null,
            'updatePriority': 0,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows and dismisses the banner for a Play update', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    updateAvailability = 2;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(bottomNavigationBar: AppUpdateBanner())),
    );
    await tester.pump();

    expect(
      find.text('A new version of Vidya AI is available.'),
      findsOneWidget,
    );
    expect(find.text('Update'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss update banner'));
    await tester.pump();
    expect(find.text('Update'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('hides the banner when Google Play has no update', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    updateAvailability = 1;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(bottomNavigationBar: AppUpdateBanner())),
    );
    await tester.pump();

    expect(find.text('Update'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });
}
