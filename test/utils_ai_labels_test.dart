import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/utils/ai_labels.dart';

void main() {
  group('refreshPhrase', () {
    // Built from local time so the result does not depend on the machine's zone.
    test('says midnight when the allowance refills at local midnight', () {
      expect(refreshPhrase(DateTime(2026, 10, 18)), 'at midnight');
      expect(refreshPhrase(DateTime(2026, 10, 18).toUtc()), 'at midnight');
    });

    test('says tomorrow when the server gave no time', () {
      expect(refreshPhrase(null), 'tomorrow');
    });

    test('reads a clock time otherwise', () {
      expect(refreshPhrase(DateTime(2026, 10, 18, 18, 30)), 'at 6:30 PM');
      expect(refreshPhrase(DateTime(2026, 10, 18, 9, 5)), 'at 9:05 AM');
    });

    test('handles the 12 o\'clock edges', () {
      expect(refreshPhrase(DateTime(2026, 10, 18, 0, 5)), 'at 12:05 AM');
      expect(refreshPhrase(DateTime(2026, 10, 18, 12)), 'at 12:00 PM');
      expect(refreshPhrase(DateTime(2026, 10, 18, 12, 59)), 'at 12:59 PM');
    });

    test('converts an IST reset to the student\'s local time', () {
      final istMidnight = DateTime.parse('2026-10-18T00:00:00+05:30');

      final local = istMidnight.toLocal();
      final expected = local.hour == 0 && local.minute == 0
          ? 'at midnight'
          : startsWith('at ');

      expect(refreshPhrase(istMidnight), expected);
    });
  });
}
