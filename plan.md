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

## 0. App size (do before adding diagrams)
Text content is cheap (all quizzes ≈ 540 KB source, ~0.2% of the APK). The size
comes from images and fat APKs. Last `app-release.apk`: 105.7 MB.
- [x] Convert `assets/diagrams/interactive/` (31 images, 48 MB, mostly 1–3 MB PNGs) to WebP ~80% quality — target ≈ 5–8 MB; update paths in `lib/data/seed/interactive_diagrams*.dart` and check every diagram still renders
- [ ] Ship with `flutter build appbundle --release` (Play Store) or `flutter build apk --release --split-per-abi` (sideload) instead of a fat APK
- [x] Rule for section 5: new diagrams must be WebP (or drawn in code / SVG), never raw PNG

## 2. Maths formulas (`lib/data/math/formulas/`)
- [ ] Geometry: Heron's formula, frustum of a cone, area of a segment, area of a ring
- [ ] Statistics: median and mode of grouped data
- [ ] Algebra: sum/product of quadratic roots, consistency of a pair of linear equations
- [ ] Trigonometry: heights & distances calculator
- [ ] Physics: Ohm's law, F = ma, Q = mcΔT, mirror & lens formulas, magnification, refractive index, v = fλ
- [ ] Primary reference cards: divisibility rules, Roman numerals, BODMAS, place value, squares & cubes
- [ ] New maths tools: clock & money (Classes 1–3), word problems, linear-equation graph plotter

## 3. History timeline (`lib/data/history/timeline_data.dart`)
- [ ] Odisha: Dhauli/Jaugada edicts, Sarala Das, Chaitanya in Puri, Surendra Sai, Laxman Naik, Baji Rout, Prajamandal, Madhusudan Das, Gopabandhu Das
- [ ] India freedom struggle: Permanent Settlement, Ram Mohan Roy, Lucknow Pact, Simon Commission, Poona Pact, Partition
- [ ] India post-1947: States Reorganisation, Goa liberation, ISRO, Emergency, 1991 reforms, Pokhran
- [ ] India earlier: Mahavira, Nalanda, Aryabhata & zero, Cholas, Bhakti movement, Haldighati, Buxar
- [ ] World: Renaissance, printing press, Scientific Revolution, Industrial Revolution, Chinese Revolution, Internet
- [ ] 3–5 events each for more states (Bihar, Gujarat, Assam, UP, Rajasthan, …)
- [ ] Schema: optional `classLevel`, `chapterRef`, key person

## 4. Vocabulary (`lib/data/seed/vocabulary/`)
- [ ] Add ~100 adverbs (only 2 today)
- [ ] Add difficulty / class band field
- [ ] Add synonyms & antonyms fields
- [ ] Optional Odia/Hindi example sentence
- [ ] New sets: idioms, phrasal verbs, homophones & confused words, one-word substitutions, prefixes & suffixes
- [ ] Vocabulary quiz / flashcard mode

## 5. Interactive diagrams (`lib/data/seed/interactive_diagrams*.dart`)
- [ ] Biology: skeleton, neuron & nervous system, kidney/nephron, tooth, skin, frog & butterfly life cycles, seed germination, mitosis, DNA, amoeba/bacteria
- [ ] Science: prism & rainbow, electric motor/generator, sound waves, nitrogen & carbon cycles, greenhouse effect, levers
- [ ] Geography: Odisha rivers/physical map, rivers of India, monsoon winds, atmosphere layers, seasons, eclipses & moon phases, rock cycle, river landforms
- [ ] Maths: Pythagoras proof, quadrilateral family, symmetry, number line, unit circle

## 6. Python (`lib/data/programming/`)
- [ ] Interpreter: string methods, dictionaries, tuples, `try`/`except`, `random`
- [ ] Chapters: string methods, dictionaries & tuples, nested loops, errors, random games
- [ ] Mini-projects: quiz game, report card, calculator, rock-paper-scissors
- [ ] "Predict the output" quiz per chapter
