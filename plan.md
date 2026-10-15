# Static content expansion plan

All study content is trilingual (English, Odia, Hindi). UI labels stay English.
Work top to bottom; tick items as they land.

## 1. Quizzes (`lib/data/quiz/`)
- [x] Add a **Maths** subject to `QuizSubject` (enum, accent, icon) with banks for all three bands
- [x] Grow Science banks to ~60 questions per band (primary / middle / secondary)
- [x] Grow Social Science banks to ~60 questions per band
- [x] Grow English banks to ~60 questions per band
- [x] Grow Maths banks to ~60 questions per band
- [x] Add a Classes 1–2 band (`QuizBand.early`) with starter banks
- [x] Add an optional `topic` tag to `QuizQuestion` + topic filter on the quiz home
- [x] New question types: true/false, fill-in-the-blank, match-the-pairs

## 0. App size
Text content is cheap (all quizzes ≈ 540 KB source, ~0.2% of the APK). The size
comes from images and fat APKs. Last `app-release.apk`: 105.7 MB.
- [x] Convert `assets/diagrams/interactive/` (31 images, 48 MB, mostly 1–3 MB PNGs) to WebP ~80% quality — target ≈ 5–8 MB; update paths in `lib/data/seed/interactive_diagrams*.dart` and check every diagram still renders
- [ ] Ship with `flutter build appbundle --release` (Play Store) or `flutter build apk --release --split-per-abi` (sideload) instead of a fat APK

## 2. Maths formulas (`lib/data/math/formulas/`)
- [x] Geometry: Heron's formula, frustum of a cone, area of a segment, area of a ring
- [x] Statistics: median and mode of grouped data
- [x] Algebra: sum/product of quadratic roots, consistency of a pair of linear equations
- [x] Trigonometry: heights & distances calculator
- [x] Physics: Ohm's law, F = ma, Q = mcΔT, mirror & lens formulas, magnification, refractive index, v = fλ
- [x] Primary reference cards: divisibility rules, Roman numerals, BODMAS, place value, squares & cubes
- [x] New maths tools: clock & money (Classes 1–3), word problems, linear-equation graph plotter

## 3. History timeline (`lib/data/history/timeline_data.dart`, `timeline_data_more.dart`)
- [x] Odisha: Dhauli/Jaugada edicts, Sarala Das, Chaitanya in Puri, Surendra Sai, Laxman Naik, Baji Rout, Prajamandal, Gopabandhu Das (Madhusudan Das is covered by the Utkal Sammilani event)
- [x] India freedom struggle: Permanent Settlement, Ram Mohan Roy, Lucknow Pact, Simon Commission, Poona Pact, Partition
- [x] India post-1947: States Reorganisation, Goa liberation, ISRO, Emergency, 1991 reforms, Pokhran
- [x] India earlier: Mahavira, Nalanda, Aryabhata & zero, Cholas, Bhakti movement, Haldighati, Buxar
- [x] World: Renaissance, printing press, Scientific Revolution, Industrial Revolution, Chinese Revolution, Internet
- [x] 3–5 events each for more states (Bihar, Gujarat, Assam, UP, Rajasthan)
- [x] Schema: optional `keyPerson` (3 languages), `classLevel`, `chapterRef` — key people are filled in; `classLevel` / `chapterRef` exist but are still empty (need the textbook mapping)

## 4. Vocabulary (`lib/data/seed/vocabulary/`)
- [x] Add ~100 adverbs (118 added in `vocabulary_adverbs.dart`)
- [x] Add difficulty / class band field (`level`, estimated from length unless overridden)
- [x] Add synonyms & antonyms fields (filled for the new adverbs; the older words still have none)
- [x] Optional Odia/Hindi example sentence (filled for the new adverbs)
- [x] New sets: idioms, phrasal verbs, homophones & confused words, one-word substitutions, prefixes & suffixes
- [x] Vocabulary quiz / flashcard mode

## 5. Python (`lib/data/programming/`)
- [x] Interpreter: string methods, dictionaries, tuples, `try`/`except`, `random` (plus slicing, `in`, chained comparisons, f-string formats, `print(sep=, end=)`)
- [x] Chapters: string methods, dictionaries & tuples, nested loops, errors, random games (`python_more_data.dart`)
- [x] Mini-projects: quiz game, report card, calculator, rock-paper-scissors
- [x] "Predict the output" quiz per chapter
