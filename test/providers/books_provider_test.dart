import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/providers/books_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/user_selection_provider.dart';

Future<ProviderContainer> _container({
  required String board,
  required Set<int> classes,
}) async {
  SharedPreferences.setMockInitialValues({
    'selected_board': board,
    'selected_classes': jsonEncode(classes.toList()),
  });
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('selected books are scoped to the selected board and class', () async {
    final container = await _container(board: 'scert_odisha', classes: {8});

    final books = container.read(selectedBooksProvider);

    expect(books, isNotEmpty);
    expect(books.every((book) => book.boardId == 'scert_odisha'), isTrue);
    expect(books.every((book) => book.classNumber == 8), isTrue);
  });

  test(
    'a board without library books has an empty selected-book list',
    () async {
      final container = await _container(board: 'ncert', classes: {8});

      expect(container.read(selectedBooksProvider), isEmpty);
    },
  );

  test(
    'switching boards refreshes selected books without leaking SCERT books',
    () async {
      final container = await _container(board: 'scert_odisha', classes: {8});
      expect(container.read(selectedBooksProvider), isNotEmpty);

      container.read(userBoardProvider.notifier).setBoard('ncert');

      expect(container.read(selectedBooksProvider), isEmpty);
    },
  );
}
