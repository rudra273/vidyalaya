import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/lab/lab_catalog.dart';
import 'package:vidyalaya/data/lab/lab_rules.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/screens/lab/lab_bench_screen.dart';
import 'package:vidyalaya/screens/lab/lab_home_screen.dart';
import 'package:vidyalaya/screens/lab/lab_kit.dart';
import 'package:vidyalaya/screens/lab/rigs/rigs.dart';

late SharedPreferences _prefs;

Widget harness(Widget home, {bool reduceMotion = false}) => ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
  child: MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: home,
      ),
    ),
  ),
);

/// Paints [draw] into a throwaway canvas.
void paintInto(Size size, void Function(Canvas canvas) draw) {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  recorder.endRecording().dispose();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'regional_language': 'en'});
    _prefs = await SharedPreferences.getInstance();
  });

  test('every experiment has a rig', () {
    expect(labRigs.keys.toSet(), labExperiments.map((l) => l.id).toSet());
    for (final rig in labRigs.values) {
      expect(
        rig.controls.map((c) => c.key).toSet(),
        rig.lab.controls.keys.toSet(),
        reason: rig.id,
      );
    }
  });

  test('rigs paint every setup through a whole run', () {
    for (final dark in [false, true]) {
      final p = LabPalette(dark);
      for (final rig in labRigs.values) {
        for (final controls in rig.lab.allControlSets) {
          final result = evaluateLab(rig.id, controls);
          for (final size in const [Size(360, 320), Size(160, 140)]) {
            for (final runT in [-1.0, 0.0, 0.3, 0.9, 1.6, 2.4, 3.1, 6.0]) {
              paintInto(
                size,
                (canvas) => rig.paint(
                  canvas,
                  size,
                  LabScene(
                    controls: controls,
                    previous: rig.lab.defaultControls,
                    sinceChange: 0.1,
                    result: runT < 0 ? null : result,
                    t: 1.7 + runT,
                    runT: runT < 0 ? 0 : runT,
                    p: p,
                    preview: size.width < 200,
                  ),
                ),
              );
            }
          }
          for (final outcome in rig.lab.outcomes) {
            paintInto(
              const Size(60, 60),
              (canvas) => rig.paintOutcome(
                canvas,
                const Size(60, 60),
                outcome,
                controls,
                p,
              ),
            );
          }
        }
        for (final control in rig.controls) {
          for (final value in rig.lab.controls[control.key]!) {
            paintInto(
              const Size(50, 50),
              (canvas) => control.glyph(canvas, const Size(50, 50), value, p),
            );
          }
        }
      }
    }
  });

  testWidgets('hub shows every experiment', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness(const LabHomeScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);
    for (final lab in labExperiments) {
      expect(find.text(lab.title), findsOneWidget, reason: lab.id);
    }
    expect(find.text('0 / 18'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('run needs a prediction, then plays and saves the attempt', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness(const LabBenchScreen(labId: 'float')));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.bySemanticsLabel('Run the experiment'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(UserPrefsRepository(_prefs).getLabAttempts(), isEmpty);

    // Default setup is an egg in plain water: it sinks.
    await tester.tap(find.text('Sinks'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.bySemanticsLabel('Run the experiment'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Spot on!'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Spot on!'), findsOneWidget);
    expect(find.text('1.03 g/cm³'), findsOneWidget);
    final saved = UserPrefsRepository(_prefs).getLabAttempts().single;
    expect(saved.labId, 'float');
    expect(saved.correct, isTrue);
    expect(saved.labVersion, kLabVersion);

    await tester.tap(find.text('Why?'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('heavier than the same volume'), findsOneWidget);

    // Changing the setup clears the result for a fresh try.
    await tester.tap(find.text('Salt water'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Spot on!'), findsNothing);
    expect(find.bySemanticsLabel('Run the experiment'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion reveals the result at once', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      harness(const LabBenchScreen(labId: 'indicator'), reduceMotion: true),
    );
    await tester.pump();
    // Lemon is the default sample; predict blue to miss.
    await tester.tap(find.text('Blue'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Run the experiment'));
    await tester.pump();
    expect(find.text('Surprise!'), findsOneWidget);
    expect(find.text('pH 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
