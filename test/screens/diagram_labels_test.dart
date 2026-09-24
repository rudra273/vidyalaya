import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/seed/interactive_diagrams_data.dart';
import 'package:vidyalaya/screens/learn/interactive_diagram_viewer_screen.dart';

void main() {
  for (final diagram in interactiveDiagrams) {
    test('${diagram.id} labels stay outside the image and one another', () {
      final image = Rect.fromLTWH(200, 230, 600, 600 / diagram.aspectRatio);
      final callouts = diagramCallouts(diagram, image);
      expect(callouts.length, diagram.labels.length);
      expect(
        callouts.any((callout) => callout.bounds.left < image.left),
        isTrue,
      );
      expect(
        callouts.any((callout) => callout.bounds.right > image.right),
        isTrue,
      );
      for (var i = 0; i < callouts.length; i++) {
        expect(callouts[i].bounds.overlaps(image), isFalse);
        expect(image.contains(callouts[i].target), isTrue);
        for (var j = i + 1; j < callouts.length; j++) {
          expect(callouts[i].bounds.overlaps(callouts[j].bounds), isFalse);
        }
      }
    });

    for (final language in DiagramLanguage.values) {
      testWidgets('${diagram.id} ${language.name} sheet renders and exports', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1100, 1700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: key,
                  child: DiagramLabelSheet(
                    diagram: diagram,
                    language: language,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final label in diagram.labels) {
          expect(find.text(label.title.inLanguage(language)), findsOneWidget);
        }
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        expect(image.width, 1000);
        image.dispose();
      });
    }
  }
}
