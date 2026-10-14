import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/models/book.dart';
import 'package:vidyalaya/data/seed/seed_data.dart';
import 'package:vidyalaya/providers/books_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/user_selection_provider.dart';

Future<ProviderContainer> _container({
  required String board,
  required Set<int> classes,
}) async {
  SharedPreferences.setMockInitialValues({
    'selected_board': board,
    'library_selected_classes': jsonEncode(classes.toList()),
  });
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );

  addTearDown(container.dispose);
  return container;
}

void main() {
  test('Explore selection does not change Library books', () async {
    final container = await _container(board: 'scert_odisha', classes: {8});

    container.read(exploreClassSelectionProvider.notifier).setClasses({7, 9});

    final books = container.read(selectedBooksProvider);
    expect(books, isNotEmpty);
    expect(books.every((book) => book.classNumber == 8), isTrue);
  });

  test(
    'profile class remains singular and independent of both filters',
    () async {
      final container = await _container(board: 'scert_odisha', classes: {8});
      container.read(primaryClassProvider.notifier).setClass(9);
      container.read(exploreClassSelectionProvider.notifier).setClasses({6, 7});
      container.read(libraryClassSelectionProvider.notifier).setClasses({4, 5});

      expect(container.read(primaryClassProvider), 9);
    },
  );

  test('selected books are scoped to the selected board and class', () async {
    final container = await _container(board: 'scert_odisha', classes: {8});

    final books = container.read(selectedBooksProvider);

    expect(books, isNotEmpty);
    expect(books.every((book) => book.boardId == 'scert_odisha'), isTrue);
    expect(books.every((book) => book.classNumber == 8), isTrue);
  });

  test('NCERT has no official books, so its Library starts empty', () async {
    final container = await _container(board: 'ncert', classes: {8});

    expect(container.read(selectedBooksProvider), isEmpty);
  });

  test('switching to NCERT empties the Library of official books', () async {
    final container = await _container(board: 'scert_odisha', classes: {8});
    expect(container.read(selectedBooksProvider), isNotEmpty);

    container.read(userBoardProvider.notifier).setBoard('ncert');

    expect(container.read(selectedBooksProvider), isEmpty);
  });

  test('NCERT students still pick from the shared class list', () {
    expect(availableClassNumbersForBoard('ncert'), isNotEmpty);
    expect(
      availableClassNumbersForBoard('ncert'),
      availableClassNumbersForBoard('scert_odisha'),
    );
  });

  test('books the student added show for their board and class only', () async {
    final own = Book(
      id: 'user_1',
      title: 'My Maths',
      subject: 'maths',
      classNumber: 8,
      boardId: 'ncert',
      pdfUrl: '',
      coverEmoji: '📄',
      isOfficial: false,
    );
    SharedPreferences.setMockInitialValues({
      'selected_board': 'ncert',
      'library_selected_classes': jsonEncode([8]),
      'user_imported_books': jsonEncode([own.toJson()]),
    });
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    expect(container.read(selectedBooksProvider).map((b) => b.id), ['user_1']);
    expect(
      findBook(container.read(libraryBooksProvider), 'user_1')?.title,
      'My Maths',
    );

    container.read(libraryClassSelectionProvider.notifier).setClasses({9});
    expect(container.read(selectedBooksProvider), isEmpty);

    container.read(libraryClassSelectionProvider.notifier).setClasses({8});
    container.read(userBoardProvider.notifier).setBoard('scert_odisha');
    expect(
      container.read(selectedBooksProvider).any((b) => b.id == 'user_1'),
      isFalse,
    );
  });
}
