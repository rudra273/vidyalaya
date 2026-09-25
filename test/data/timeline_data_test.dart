import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/history/timeline_data.dart';

void main() {
  test('parses every year format used in the data', () {
    expect(timelineSortYear('320 CE'), 320);
    expect(timelineSortYear('c. 3100 BCE'), -3100);
    expect(timelineSortYear('12th century CE'), 1150);
    expect(timelineSortYear('c. 1st century BCE'), -50);
    for (final e in timelineEvents) {
      expect(e.sortYear, lessThan(1 << 30), reason: '${e.title}: ${e.year}');
    }
  });

  test('sorts oldest first, keeping listed order for the same year', () {
    final sorted = sortedChronologically(timelineEvents);
    for (var i = 1; i < sorted.length; i++) {
      expect(sorted[i - 1].sortYear, lessThanOrEqualTo(sorted[i].sortYear));
    }
    final y1945 = sorted.where((e) => e.year == '1945 CE').toList();
    expect(y1945.map((e) => e.title), [
      'End of World War II',
      'United Nations Founded',
    ]);
  });

  test('state picker only offers states with events', () {
    expect(statesWithEvents, contains('Odisha'));
    expect(statesWithEvents, isNot(contains('Goa')));
    for (final s in statesWithEvents) {
      expect(timelineEvents.any((e) => e.region == s), isTrue, reason: s);
    }
  });

  test('Odisha and India have enough events', () {
    expect(
      timelineEvents.where((e) => e.region == 'Odisha').length,
      greaterThanOrEqualTo(20),
    );
    expect(
      timelineEvents.where((e) => e.region == kRegionIndia).length,
      greaterThanOrEqualTo(24),
    );
  });

  test('every event has all three languages and a known era', () {
    for (final e in timelineEvents) {
      for (final t in [
        e.title,
        e.titleOdia,
        e.titleHindi,
        e.description,
        e.descriptionOdia,
        e.descriptionHindi,
      ]) {
        expect(t.trim(), isNotEmpty, reason: e.title);
      }
      expect(
        ['Ancient', 'Medieval', 'Modern'],
        contains(e.era),
        reason: e.title,
      );
    }
  });

  test('no duplicate events', () {
    final keys = timelineEvents.map((e) => '${e.year}|${e.title}').toList();
    expect(keys.toSet().length, keys.length);
  });
}
