import 'regional_language.dart';

// ─── Localized text ───────────────────────────────────────────────────────────
//
// Study content (questions, explanations, lab observations) in English, Odia
// and Hindi. App chrome — titles, buttons, labels — stays English and does not
// use this. Numbers stay as Western digits in every language.

class LocalizedText {
  final String en;
  final String or;
  final String hi;

  const LocalizedText({required this.en, required this.or, required this.hi});

  /// Same text in every language — for content that is only numbers/symbols.
  const LocalizedText.same(String text) : en = text, or = text, hi = text;

  String of(RegionalLanguage lang) => switch (lang) {
    RegionalLanguage.english => en,
    RegionalLanguage.odia => or,
    RegionalLanguage.hindi => hi,
  };

  @override
  String toString() => en;
}
