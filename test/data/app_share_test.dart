import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/seed/seed_data.dart';
import 'package:vidyalaya/data/services/app_share.dart';

void main() {
  test('share message names every supported board', () {
    for (final board in boards) {
      expect(AppShare.shareMessage, contains(board.name));
    }
    expect(AppShare.shareMessage, contains('Vidyakalp'));
    expect(AppShare.shareMessage, endsWith(AppShare.playStoreUrl));
  });

  test('only SCERT Odisha books are advertised as free', () {
    // NCERT textbooks are not hosted in the app, so the free-books claim must
    // not cover them.
    expect(
      AppShare.shareMessage,
      contains('free ${scertOdisha.name} books'),
    );
    expect(AppShare.shareMessage, isNot(contains('free NCERT')));
  });
}
