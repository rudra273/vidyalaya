import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/seed/interactive_diagrams_data.dart';
import 'package:vidyalaya/screens/learn/interactive_diagram_viewer_screen.dart';

void main() {
  test('interactive diagram catalog is complete and internally valid', () {
    expect(interactiveDiagrams, hasLength(12));
    expect(
      interactiveDiagrams.map((diagram) => diagram.id).toSet(),
      hasLength(12),
    );
    expect(
      interactiveDiagrams.where(
        (diagram) => diagram.section == DiagramSection.biology,
      ),
      hasLength(5),
    );
    expect(
      interactiveDiagrams.where(
        (diagram) => diagram.section == DiagramSection.geography,
      ),
      hasLength(2),
    );
    expect(
      interactiveDiagrams.where(
        (diagram) => diagram.section == DiagramSection.science,
      ),
      hasLength(5),
    );

    for (final diagram in interactiveDiagrams) {
      expect(File(diagram.imagePath).existsSync(), isTrue, reason: diagram.id);
      expect(interactiveDiagramById(diagram.id), same(diagram));
      expect(diagram.labels, isNotEmpty, reason: diagram.id);
      for (final language in DiagramLanguage.values) {
        expect(diagram.title.inLanguage(language), isNotEmpty);
        expect(diagram.description.inLanguage(language), isNotEmpty);
      }
      for (final label in diagram.labels) {
        expect(label.position.dx, inInclusiveRange(0, 1));
        expect(label.position.dy, inInclusiveRange(0, 1));
        for (final language in DiagramLanguage.values) {
          expect(label.title.inLanguage(language), isNotEmpty);
          expect(label.explanation.inLanguage(language), isNotEmpty);
        }
      }
    }
    expect(interactiveDiagramById('missing'), isNull);
  });

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
