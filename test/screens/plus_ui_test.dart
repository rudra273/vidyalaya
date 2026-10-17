import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/models/plus.dart';
import 'package:vidyalaya/providers/plus_provider.dart';
import 'package:vidyalaya/screens/plus/plus_sheet.dart';
import 'package:vidyalaya/screens/profile/widgets/plus_card.dart';

class _StubPlus extends PlusNotifier {
  _StubPlus(this.initial);

  final PlusViewState initial;
  final requested = <String>[];
  var refreshes = 0;

  @override
  PlusViewState build() => initial;

  @override
  Future<void> refresh() async => refreshes++;

  @override
  Future<bool> request(String source) async {
    requested.add(source);
    state = state.copyWith(requesting: true);
    await Future<void>.delayed(Duration.zero);
    state = PlusViewState(status: _status(PlusState.pending));
    return true;
  }
}

PlusStatus _status(
  PlusState state, {
  String plan = 'free',
  bool available = true,
  bool canRequest = false,
  DateTime? again,
  DateTime? expires,
}) => PlusStatus(
  state: state,
  planKey: plan,
  available: available,
  canRequest: canRequest,
  canRequestAgainAt: again,
  plusExpiresAt: expires,
);

PlusStatus get _canAsk => _status(PlusState.none, canRequest: true);

/// Every piece of text on screen, joined.
String _screenText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
    .join('\n');

void main() {
  Future<_StubPlus> pumpSheet(
    WidgetTester tester,
    PlusStatus? status, {
    String source = PlusSource.profile,
    bool limitReached = false,
    DateTime? resetsAt,
    String? error,
    bool requesting = false,
  }) async {
    // A spinner animates forever, so a request in flight cannot "settle".
    final settle = !requesting;
    final stub = _StubPlus(
      PlusViewState(status: status, error: error, requesting: requesting),
    );
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [plusProvider.overrideWith(() => stub)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showPlusSheet(
                    context,
                    source: source,
                    limitReached: limitReached,
                    limitResetsAt: resetsAt,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 400));
    }
    return stub;
  }

  group('the Plus sheet', () {
    testWidgets('says what Plus gives and that it is not for sale', (tester) async {
      await pumpSheet(tester, _canAsk);

      expect(find.text('Vidyakalp Plus'), findsOneWidget);
      for (final line in plusFeatureLines) {
        expect(find.text(line), findsOneWidget);
      }
      expect(find.text(plusNotForSale), findsOneWidget);
      expect(find.text('Request Plus'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('promises no numbers while the limits are still being validated', (tester) async {
      for (final status in [
        _canAsk,
        _status(PlusState.pending),
        _status(PlusState.expired, canRequest: true),
        null,
      ]) {
        await pumpSheet(tester, status);
        expect(
          RegExp(r'\d').hasMatch(_screenText(tester)),
          isFalse,
          reason: 'a number reached the student for ${status?.state}: ${_screenText(tester)}',
        );
        await tester.tapAt(const Offset(10, 10)); // dismiss
        await tester.pumpAndSettle();
      }
    });

    testWidgets('asking sends the screen and then shows the request as pending', (tester) async {
      final stub = await pumpSheet(tester, _canAsk);

      await tester.tap(find.text('Request Plus'));
      await tester.pumpAndSettle();

      expect(stub.requested, [PlusSource.profile]);
      expect(find.text('Request Plus'), findsNothing);
      expect(find.textContaining('Plus requested'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('a refused question names when it refreshes, and asks from AI questions', (tester) async {
      final stub = await pumpSheet(
        tester,
        _canAsk,
        source: PlusSource.aiQuestions,
        limitReached: true,
        resetsAt: DateTime(2026, 11, 3),
      );

      expect(find.text("That's all your questions for today"), findsOneWidget);
      expect(find.text('They refresh at midnight.'), findsOneWidget);
      await tester.tap(find.text('Request Plus'));
      await tester.pumpAndSettle();
      expect(stub.requested, [PlusSource.aiQuestions]);
    });

    testWidgets('without a reset time it still says when', (tester) async {
      await pumpSheet(tester, _canAsk, limitReached: true);

      expect(find.text('They refresh tomorrow.'), findsOneWidget);
    });

    testWidgets('a pending request offers nothing more to do', (tester) async {
      await pumpSheet(tester, _status(PlusState.pending));

      expect(find.textContaining("We'll review it"), findsOneWidget);
      expect(find.text('Request Plus'), findsNothing);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('a decline is neutral: a date to ask again, never a reason', (tester) async {
      await pumpSheet(
        tester,
        _status(PlusState.declined, again: DateTime(2026, 12, 3)),
      );
      final text = _screenText(tester).toLowerCase();

      expect(text, contains("plus isn't available for your account right now"));
      expect(text, contains('you can ask again after 3 dec'));
      expect(text, isNot(contains('declin')));
      expect(text, isNot(contains('reject')));
      expect(text, isNot(contains('reason')));
      expect(find.text('Request Plus'), findsNothing);
    });

    testWidgets('a decline without a date is just as neutral', (tester) async {
      await pumpSheet(tester, _status(PlusState.declined));
      final text = _screenText(tester).toLowerCase();

      expect(text, contains("plus isn't available for your account right now."));
      expect(text, isNot(contains('declin')));
      expect(text, isNot(contains('reject')));
      expect(text, isNot(contains('ask again after')));
    });

    testWidgets('Plus that has ended can be asked for again', (tester) async {
      await pumpSheet(tester, _status(PlusState.expired, canRequest: true));

      expect(find.textContaining('Your Plus access has ended'), findsOneWidget);
      expect(find.text('Request Plus'), findsOneWidget);
    });

    testWidgets('an active Plus student sees when it ends, not a sales pitch', (tester) async {
      await pumpSheet(
        tester,
        _status(PlusState.active, plan: 'plus', expires: DateTime(2026, 12, 10)),
      );

      expect(find.text('Plus is on for your account until 10 Dec.'), findsOneWidget);
      expect(find.text(plusFeatureLines.first), findsNothing);
      expect(find.text('Request Plus'), findsNothing);
    });

    testWidgets('Pro accounts are told they already have everything', (tester) async {
      await pumpSheet(tester, _status(PlusState.active, plan: 'pro'));

      expect(find.text('Your account already has everything in Plus.'), findsOneWidget);
      expect(find.text('Request Plus'), findsNothing);
    });

    testWidgets('no request is offered when the server has closed requests', (tester) async {
      await pumpSheet(tester, _status(PlusState.none, available: false, canRequest: true));

      expect(find.text('Request Plus'), findsNothing);
    });

    testWidgets('no request is offered until the server has confirmed eligibility', (tester) async {
      await pumpSheet(tester, null);

      expect(find.text('Request Plus'), findsNothing);
      expect(find.text(plusFeatureLines.first), findsOneWidget);
    });

    testWidgets('a failed request explains itself in plain words', (tester) async {
      await pumpSheet(tester, _canAsk, error: "Couldn't send your request. Please check your connection and try again.");

      expect(find.textContaining('check your connection'), findsOneWidget);
      expect(find.text('Request Plus'), findsOneWidget, reason: 'the student can try again');
    });

    testWidgets('the button locks while the request is on its way', (tester) async {
      await pumpSheet(tester, _canAsk, requesting: true);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('opening it checks for an approval, and Not now closes it', (tester) async {
      final stub = await pumpSheet(tester, _canAsk);

      expect(stub.refreshes, 1);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('Request Plus'), findsNothing);
    });
  });

  group('the Profile card', () {
    Future<_StubPlus> pumpCard(WidgetTester tester, PlusStatus? status) async {
      final stub = _StubPlus(PlusViewState(status: status));
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [plusProvider.overrideWith(() => stub)],
          child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: PlusCard()))),
        ),
      );
      await tester.pump();
      return stub;
    }

    testWidgets('is hidden until the server confirms, and when requests are closed', (tester) async {
      for (final status in [
        null,
        _status(PlusState.none, available: false, canRequest: true),
        _status(PlusState.pending, available: false),
        _status(PlusState.active, plan: 'pro'),
      ]) {
        await pumpCard(tester, status);
        expect(find.byType(InkWell), findsNothing, reason: 'shown for ${status?.state} ${status?.planKey}');
      }
    });

    testWidgets('stays visible for active Plus even if requests are switched off', (tester) async {
      await pumpCard(tester, _status(PlusState.active, plan: 'plus', available: false));

      expect(find.text('Plus is on'), findsOneWidget);
    });

    testWidgets('says the right thing in each state', (tester) async {
      final cases = <PlusStatus, (String, String)>{
        _canAsk: ('Vidyakalp Plus', 'More AI questions every day. Asking costs nothing.'),
        _status(PlusState.pending): ('Plus requested', "We'll review it. You don't need to do anything."),
        _status(PlusState.declined, again: DateTime(2026, 12, 3)): (
          "Plus isn't available right now",
          'You can ask again after 3 Dec.',
        ),
        _status(PlusState.expired, canRequest: true): ('Your Plus access has ended', 'You can ask for it again.'),
        _status(PlusState.active, plan: 'plus', expires: DateTime(2026, 12, 10)): ('Plus is on', 'Until 10 Dec.'),
        _status(PlusState.active, plan: 'plus'): ('Plus is on', 'Higher limits are on for your account.'),
      };
      for (final entry in cases.entries) {
        await pumpCard(tester, entry.key);
        expect(find.text(entry.value.$1), findsOneWidget, reason: '${entry.key.state}');
        expect(find.text(entry.value.$2), findsOneWidget, reason: '${entry.key.state}');
      }
    });

    testWidgets('a decline without a date says to ask later, never why', (tester) async {
      await pumpCard(tester, _status(PlusState.declined));

      expect(find.text("Plus isn't available right now"), findsOneWidget);
      expect(find.text('You can ask again later.'), findsOneWidget);
    });

    testWidgets('opens the sheet, and asking from it comes from Profile', (tester) async {
      final stub = await pumpCard(tester, _canAsk);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.text('Not now'), findsOneWidget);
      await tester.tap(find.text('Request Plus'));
      await tester.pumpAndSettle();

      expect(stub.requested, [PlusSource.profile]);
    });

    testWidgets('keeps the screen\'s spacing out of the way when hidden', (tester) async {
      await pumpCard(tester, null);

      expect(tester.getSize(find.byType(PlusCard)).height, 0);
    });
  });
}
