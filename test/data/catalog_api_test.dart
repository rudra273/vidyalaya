import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/models/ingested_books.dart';

void main() {
  test('remote catalog replaces bundled AI coverage by board and class', () {
    final catalog = IngestedBooks.fromCatalogApi({
      'version': 1,
      'items': [
        {
          'board': 'scert_odisha',
          'class_no': 8,
          'subject': 'science',
          'language': 'or',
          'title': 'Jigyasa',
          'content_type': 'ai_textbook',
        },
        {
          'board': 'scert_odisha',
          'class_no': 9,
          'subject': 'english',
          'language': 'en',
          'title': 'English',
          'content_type': 'ai_textbook',
        },
      ],
    });

    expect(catalog.classesFor('scert_odisha'), {8, 9});
    expect(catalog.subjectsFor('scert_odisha', 8).single.subject, 'science');
    expect(catalog.subjectsFor('ncert', 8), isEmpty);
  });
}
