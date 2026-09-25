import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/widgets/ai_markdown.dart';

// Fixtures mirror the shapes the Learn Assist model actually produces: all four
// delimiter styles, prices, code, and half-streamed answers.

Future<void> _pump(WidgetTester tester, String text, {bool streaming = false}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AiMarkdown(text: text, streaming: streaming),
        ),
      ),
    ),
  );
}

Finder _math() => find.byType(Math);

Finder _text(String s) => find.textContaining(s, findRichText: true);

void main() {
  group('normalizeMathDelimiters', () {
    test('rewrites bracket delimiters to dollar form', () {
      expect(normalizeMathDelimiters(r'so \( x^2 \) is'), r'so $x^2$ is');
      expect(
        normalizeMathDelimiters('\\[\nx = \\frac{1}{2}\n\\]'),
        '\$\$\nx = \\frac{1}{2}\n\$\$',
      );
    });

    test('leaves code untouched', () {
      const fenced = '```\nprint("\\(x\\)")\n```';
      expect(normalizeMathDelimiters(fenced), fenced);
      expect(normalizeMathDelimiters(r'use `\(x\)` here'), r'use `\(x\)` here');
    });
  });

  group('aiAnswerPlainText', () {
    test('strips math delimiters but keeps the TeX', () {
      expect(
        aiAnswerPlainText(r'Half is $\frac{1}{2}$ and \(x\).'),
        r'Half is \frac{1}{2} and x.',
      );
      expect(aiAnswerPlainText('\$\$a^2+b^2=c^2\$\$'), 'a^2+b^2=c^2');
    });

    test('keeps prices', () {
      expect(
        aiAnswerPlainText(r'It costs $5 and $10.'),
        r'It costs $5 and $10.',
      );
    });
  });

  group('AiMarkdown', () {
    testWidgets('renders inline dollar math inside the sentence', (
      tester,
    ) async {
      await _pump(tester, r'The area is $\pi r^2$ square units.');
      expect(_math(), findsOneWidget);
      expect(_text('The area is'), findsOneWidget);
      expect(_text(r'$'), findsNothing);
    });

    testWidgets('renders \\( \\) inline math', (tester) async {
      await _pump(tester, r'Here \( a^2 + b^2 = c^2 \) holds.');
      expect(_math(), findsOneWidget);
      expect(_text(r'\('), findsNothing);
    });

    testWidgets('renders a multi-line display block', (tester) async {
      await _pump(
        tester,
        'The roots are:\n\n\$\$\nx = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}\n\$\$\n\nDone.',
      );
      expect(_math(), findsOneWidget);
      expect(_text('The roots are:'), findsOneWidget);
      expect(_text('Done.'), findsOneWidget);
      expect(_text(r'\frac'), findsNothing);
    });

    testWidgets('renders \\[ \\] display math', (tester) async {
      await _pump(tester, 'So:\n\n\\[ F = ma \\]\n');
      expect(_math(), findsOneWidget);
    });

    testWidgets('does not treat prices as math', (tester) async {
      await _pump(tester, r'A pen costs $5 and a book costs $10.');
      expect(_math(), findsNothing);
      expect(_text(r'$5 and a book costs $10'), findsOneWidget);
    });

    testWidgets('leaves math inside code as code', (tester) async {
      await _pump(tester, 'Run `echo \$x\$` now.');
      expect(_math(), findsNothing);
    });

    testWidgets('an unclosed delimiter mid-stream stays plain text', (
      tester,
    ) async {
      await _pump(tester, r'So we get $\frac{1}{', streaming: true);
      expect(_math(), findsNothing);
      expect(_text(r'\frac{1}{'), findsOneWidget);

      await _pump(tester, 'Result:\n\n\$\$\nx = 2', streaming: true);
      expect(_math(), findsNothing);
      expect(_text('x = 2'), findsOneWidget);
    });

    testWidgets('the cursor never lands inside a closed display block', (
      tester,
    ) async {
      await _pump(tester, 'Result:\n\n\$\$x = 2\$\$', streaming: true);
      expect(_math(), findsOneWidget);
      expect(_text('▌'), findsOneWidget);
    });

    testWidgets('invalid TeX falls back to its raw source', (tester) async {
      await _pump(tester, r'Broken: $\frac{1}{\badcommand$ end.');
      expect(tester.takeException(), isNull);
      expect(find.text(r'\frac{1}{\badcommand'), findsOneWidget);
    });

    testWidgets('tables and bold still render', (tester) async {
      await _pump(
        tester,
        '**Step 1**\n\n| x | \$x^2\$ |\n|---|---|\n| 2 | 4 |\n',
      );
      expect(find.byType(Table), findsOneWidget);
      expect(_math(), findsOneWidget);
      expect(_text('Step 1'), findsOneWidget);
    });
  });
}
