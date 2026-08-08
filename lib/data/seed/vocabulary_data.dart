import 'vocabulary/vocabulary_a.dart';
import 'vocabulary/vocabulary_b.dart';
import 'vocabulary/vocabulary_c.dart';
import 'vocabulary/vocabulary_d_f.dart';
import 'vocabulary/vocabulary_g_k.dart';
import 'vocabulary/vocabulary_l_o.dart';
import 'vocabulary/vocabulary_p_r.dart';
import 'vocabulary/vocabulary_s.dart';
import 'vocabulary/vocabulary_t_z.dart';
import 'vocabulary/vocabulary_word.dart';

export 'vocabulary/vocabulary_word.dart';

/// Full curated word list, aggregated from the per-letter-range files under
/// data/seed/vocabulary/. The "Word of the day" rotates through these by date.
const vocabularyWords = <VocabularyWord>[
  ...vocabularyWordsA,
  ...vocabularyWordsB,
  ...vocabularyWordsC,
  ...vocabularyWordsDF,
  ...vocabularyWordsGK,
  ...vocabularyWordsLO,
  ...vocabularyWordsPR,
  ...vocabularyWordsS,
  ...vocabularyWordsTZ,
];

/// The word for [date] (defaults to today), chosen deterministically so it is
/// the same for everyone on a given day and rotates through the list.
VocabularyWord wordOfTheDay([DateTime? date]) {
  final d = date ?? DateTime.now();
  final dayNumber = DateTime(d.year, d.month, d.day)
      .difference(DateTime(2000))
      .inDays;
  return vocabularyWords[dayNumber % vocabularyWords.length];
}
