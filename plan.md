# Vidya AI — Release Readiness Plan

_Created 2026-09-24 from a full app audit (analyzer: 11 lint infos, tests: 411/411 passing)._

Frontend work comes first (Phases 1–7). The new backend **Explore Assist** agent is the
last phase (Phase 8). New diagrams are tracked separately in the **Appendix** and will be
built in a different session.

Each step is small enough to review on its own. Nothing is started until it is approved.

**Legend:** `[ ]` todo · `[x]` done · 🔸 needs a decision from you before starting

---

## Phase 1 — Release polish (visible "unfinished" spots)

Quick fixes that remove anything a student would read as broken or stale.

- [x] **1.1 About screen copy** — [about_screen.dart](lib/screens/profile/about_screen.dart)
  - Remove "More is on the way, including Quizzes and a Virtual Science Lab" (both already ship).
  - Add the missing Explore tools to the list: Math practice (tables, flash, quiz, drills,
    number sense, fractions), Vocabulary, Python, and Science Lab.
- [x] **1.2 Explore "Math" tile subtitle** — [explore_screen.dart](lib/screens/explore/explore_screen.dart)
  - `'Tables and drills'` → `'Formulas, tables & practice'`.
  - Also remove the stale "Coming soon group" mention in the class doc comment.
- [x] **1.3 Average formula description** — [math_formulas_screen.dart](lib/screens/learn/math_formulas_screen.dart)
  - "average of **two numbers**" → "average of a set of numbers" (EN/OR/HI).
- [x] **1.4 Remove "More formulas coming soon..." footer** in every formula category list.
- [x] **1.5 Periodic Table "Ask AI" button** — [periodic_table_screen.dart:846](lib/screens/learn/periodic_table_screen.dart:846)
  - Today it only shows a "coming soon" snackbar. **Recommendation:** hide the button until
    Phase 8 wires it to the new agent (the TODO stays and points to Phase 8).
- [x] **1.6 AI Tutor row** in the AI hub (already labelled "Preview", but any typed
  question gets a canned "coming soon" reply).
  - Option A: hide the row for this release and bring it back with a real agent.
  - ✅ Option B chosen: row kept; composer disabled, banner reads "Preview — guided lesson demo", About lists it as a preview.
  - Also update the About screen line "AI Tutor (coming soon)" to match whichever option is chosen.
- [x] **1.7 Clear analyzer infos** — 10× `curly_braces_in_flow_control_structures` in
  `math_formulas_screen.dart`, 1× deprecated `cacheExtent` → `scrollCacheExtent` in
  `vocabulary_screen.dart`. Goal: `flutter analyze` reports 0 issues.
- [x] **1.8 Docs** — CLAUDE.md says "classes 1–8", but the catalog now ships Classes 9–10. Update it.
- [x] **1.9 Version bump** — `pubspec.yaml` is `1.0.3+4`. Bumped to `1.0.4+5`.

---

## Phase 2 — Math rendering in AI answers

Today AI answers go through plain `flutter_markdown` `MarkdownBody`, in
[learn_ai_screen.dart:1656](lib/screens/learn/learn_ai_screen.dart:1656) and
[chat_bubble.dart:56](lib/screens/learn_ai/widgets/chat_bubble.dart:56). Nothing handles LaTeX,
so `$x^2$`, `\frac{a}{b}`, `\sqrt{}` and `\[ ... \]` show up as raw text.

- [ ] **2.1 Collect real failing samples** — pull 10–15 math-heavy answers (quadratics,
  fractions, trig, physics units, Class 9–10 algebra) and note exactly which delimiters the
  backend emits (`$…$`, `$$…$$`, `\(…\)`, `\[…\]`, bare `\frac`, Unicode like `x²`).
  These samples become the test fixtures.
  - Done partly: backend logs don't store answer text, and the Learn Assist prompt has no
    math-format rule, so fixtures cover all four delimiter styles. Still to do: check them
    against 10–15 real answers on a device.
- [x] **2.2 One shared answer renderer** — create `lib/widgets/ai_markdown.dart`, used by both
  the Learn AI screen and `chat_bubble.dart`, so the two can't drift apart.
- [x] **2.3 LaTeX support**
  - Add `flutter_math_fork` (pure-Dart KaTeX, works offline).
  - Custom markdown syntaxes: inline math for `$…$` and `\(…\)`, block math for `$$…$$` and
    `\[…\]`.
  - Don't treat currency like `₹5` or `$5` as math: a `$` followed by a digit and a space
    is not an opening delimiter.
  - Wide equations scroll horizontally instead of overflowing the bubble.
  - Math follows the theme text colour, so it's readable in dark mode.
  - If an expression fails to parse, show the raw TeX in monospace instead of crashing.
- [x] **2.4 Streaming safety** — while an answer is still streaming, an unclosed `$`/`\[` is
  rendered as plain text until its closing delimiter arrives. This avoids flicker and parse
  errors mid-stream. The `▌` cursor must never end up inside a math span.
- [x] **2.5 Tables & code** — check that GFM tables (common in step-by-step solutions) and
  code blocks still render, and that tables scroll horizontally on narrow phones.
- [ ] 🔸 **2.6 Backend prompt alignment** — ask the Learn Assist prompt to use only
  `$…$` / `$$…$$`, so the client doesn't have to guess. The client still accepts all four forms.
- [x] **2.7 Copy button** — "Copy answer" should copy readable text rather than raw
  `\frac{}{}` (keep the TeX, but strip the delimiters).
- [x] **2.8 Tests** — widget tests using the 2.1 fixtures: inline math, block math, currency
  that should *not* be treated as math, an unclosed delimiter mid-stream, and invalid TeX falling back to text.
- [ ] 🔸 **2.9 (optional) Package migration** — `flutter_markdown` is discontinued upstream,
  and its successor is `flutter_markdown_plus`. It's cheap to switch while this code is open.

This also sets up Phase 8: Explore Assist answers (formula explanations) reuse the same renderer.

---

## Phase 3 — Math formulas expansion

Currently 35 formulas (roughly Class 6–7 level). Target: about 75, covering Classes 3–10.
Every new formula gets EN/OR/HI title and description, plus a working calculator (a new
`FormulaType` and calculator branch), matching the existing entries.

- [ ] **3.1 New category "Measurement" (Classes 3–6)**
  - Length conversions (km ↔ m ↔ cm ↔ mm), mass (kg ↔ g), capacity (L ↔ mL),
    time (h ↔ min ↔ s), money (₹ ↔ paise), perimeter of a triangle.
- [ ] **3.2 Arithmetic additions**
  - Discount & selling price, marked price after discount, ratio → share (divide ₹N in a:b),
    unitary method, HCF × LCM = product of two numbers, percentage increase and decrease.
- [ ] **3.3 Algebra additions**
  - Laws of exponents (aᵐ·aⁿ, aᵐ/aⁿ, (aᵐ)ⁿ), (a+b+c)², a³+b³, a³−b³,
    discriminant D = b²−4ac (nature of roots), sum of the first n natural numbers, linear equation ax+b=0.
- [ ] **3.4 Geometry / mensuration additions**
  - Area of a parallelogram, trapezium, rhombus; Heron's formula; sector area;
    surface area of a cube, cuboid and cylinder (curved + total);
    cone (slant height, CSA, volume); sphere (surface area, volume); hemisphere (CSA, TSA, volume);
    angle sum of a polygon.
- [ ] **3.5 New category "Coordinate Geometry" (Classes 9–10)**
  - Distance formula, midpoint, section formula, slope, area of a triangle from its vertices.
- [ ] **3.6 Trigonometry additions**
  - Identities: sin²θ+cos²θ=1, 1+tan²θ=sec²θ, 1+cot²θ=cosec²θ; reciprocal ratios;
    a standard-angle table (0°, 30°, 45°, 60°, 90°) as a reference card with no calculator.
- [ ] **3.7 New category "Statistics & Probability" (Classes 6–10)**
  - Mean of a list of values, median, mode, range, grouped mean (assumed-mean method),
    probability of an event P(E) = favourable / total.
- [ ] **3.8 Split "Science" into a proper "Physics" category** (keep the temperature conversions)
  - Speed/velocity, acceleration, F = ma, momentum, weight W = mg, density, pressure,
    work, power, kinetic energy, potential energy, Ohm's law V = IR,
    series and parallel resistance, electric power P = VI.
- [ ] **3.9 Tests** — one test per new calculator type, checking a known answer.

> The calculator code is a ~2,200-line single file. Before adding 40 formulas, move the
> formula data into `lib/data/math/formulas/` (per-category files, the same way vocabulary
> is split). This is a data-only move that doesn't change behaviour.

---

## Phase 4 — Other content gaps

- [ ] **4.1 Timeline: fill the state filter or trim it**
  - Today there are 52 events: 30 World, 12 India, 6 Odisha, 2 Tamil Nadu, 1 Maharashtra,
    1 West Bengal. The picker offers all 28 states, so most show nothing.
  - (a) Make the picker list only states that have events.
  - (b) Add Odisha events (target ~20): Kharavela & the Hathigumpha inscription, Konark Sun
    Temple, Jagannath Temple (Puri), Lingaraj Temple, the Somavamshi and Eastern Ganga dynasties,
    Na'anka Durbhiksha (1866 famine), Madhusudan Das, Gopabandhu Das & Satyabadi school,
    Utkal Sammilani (1903), Cuttack as capital → Bhubaneswar (1948), the 1999 super cyclone,
    Hirakud Dam, and others.
  - (c) Add more India events (target ~30 total): Harappan cities, Ashoka's edicts, Chola
    empire, Vijayanagara, Akbar, Shivaji, Non-Cooperation Movement, Dandi March, Constitution
    (1950), first general elections, Green Revolution, Chandrayaan, and others.
- [ ] 🔸 **4.2 Books catalog gaps**
  - Class 1 and Class 2 have only 2 books each; Class 8 has no PE book (Classes 6–7 do).
  - This needs the real OSEPA PDF URLs. I can search osepa.odisha.gov.in for them, or you
    can supply the links.
- [ ] **4.3 Vocabulary: word of the day** — a deterministic daily pick from the ~930 words,
  shown on the Vocabulary screen header (and optionally on the Home warm-up).

---

## Phase 5 — Class-aware Explore

Today the Explore class filter only hides or shows the Science Lab tile. A Class 3 student
sees trigonometry and Python and can't filter them out.

- [ ] **5.1 Class ranges on content**
  - Add `minClass` / `maxClass` to `FormulaData` and `InteractiveDiagram` (including the existing 12).
  - Add a class range to each Explore `_Tool`.
- [ ] **5.2 Filter behaviour**
  - Explore tiles outside the selected classes move to a collapsed "More tools" section,
    so nothing is hidden completely.
  - Formula categories and formulas: show "For your class" first, then a "Show all classes" toggle.
  - Diagrams list: same pattern.
- [ ] 🔸 **5.3 Proposed tool ranges** (please confirm)
  - Math 1–10 · Diagrams 3–10 · Vocabulary 3–10 · Timeline 5–10 · Cosmulator 3–10 ·
    Periodic Table 7–10 · Python 6–10 · Science Lab 5–10 (after Phase 7 adds labs for
    younger classes; stays 7+ until then).
- [ ] **5.4 Tests** for the filtering, including class ranges on formulas and diagrams.

---

## Phase 6 — Regional language for study content (Math practice + Science Lab)

**Rule:** only *study content* can switch to Odia or Hindi. App labels, navigation, screen
titles, buttons and other UI chrome stay **English everywhere**. This matches how
Formulas, Diagrams, Periodic Table, Vocabulary and Timeline already work: a per-screen
`RegionalLanguageSwitch` that changes the content, not the app.

**Out of scope (English only):** Python (all of it, including lessons), the AI hub,
Profile, Settings, Timetable, Notes, and navigation or titles anywhere.

- [ ] **6.1 Math practice tools** — Tables, Flash Math, Quiz, Speed Drills, Number Sense,
  Fractions Lab.
  - Translate: question text (for example "Which is bigger?", "Is 17 prime?", fraction
    prompts), answer options that are words (odd/even, prime/composite), and the
    explanation/feedback shown after an answer.
  - Stays English: screen titles, buttons (Start, Next, Try again), score and timer labels, the hub list.
  - Numbers stay as Western digits (0–9) in every language.
  - Add the `RegionalLanguageSwitch` to each practice screen, the same way Formulas has it.
- [ ] **6.2 Science Lab** — experiment aim/instructions, control descriptions (sample names
  like lemon/water/soap), the prediction choices, observation values (bright/dim/off,
  colours, acidic/neutral/basic) and the explanation text.
  - Stays English: the screen title, section headers and buttons.
  - The explanation currently comes from `evaluateLab`. Make it return keys or `DiagramText`-style
    EN/HI/OR triples instead of a single English string.
- [ ] **6.3 Approach** — keep content translations next to the content (EN/HI/OR fields, like
  `DiagramText` / `FormulaData`). Don't add a global string table or `intl`/ARB tooling.
- [ ] 🔸 **6.4 Translations** — I'll draft Odia and Hindi. A native speaker should review them
  before release.
- [ ] **6.5 Tests** — for each tool, switching language changes the question/explanation
  text while titles and buttons stay English.

---

## Phase 7 — New learning tools (Explore)

Each tool is its own step. Proposed order, from highest value/effort ratio down.
Language rule from Phase 6 applies here: only study content gets Odia/Hindi, and all UI
labels, titles and navigation stay English.

- [ ] **7.1 Subject quizzes (Science, Social Science, English)**
  - Reuse the math-quiz shell.
  - Static question banks per class (about 20 questions per subject per class band to start).
  - Best scores tracked like `mathProgressProvider`.
- [ ] **7.2 Units & measurement converter** — length, mass, capacity, time, temperature,
  area and volume. Shares the conversion logic from Phase 3.1.
- [ ] **7.3 Alphabet & first words (Classes 1–3)** — Odia, Hindi and English letters with
  example words, then a "find the letter" game. Audio is out of scope for v1.
- [ ] **7.4 English grammar** — parts of speech, tenses, articles, prepositions. Each topic
  has a short explainer and 5–10 practice questions.
- [ ] **7.5 Maps (India & Odisha)** — tap a state or district to see its capital, language
  and key facts, with a "find the state" quiz.
  - Needs SVG map assets. 🔸 Check the licensing of the source before bundling.
- [ ] **7.6 Revision flashcards** — built from the student's own highlights, notes and
  bookmarks (the data already exists in `UserPrefsRepository`), plus vocabulary words.
- [ ] **7.7 Science Lab: more experiments** — pendulum (time period vs length),
  reflection with plane mirrors, magnets (attract/repel, magnetic vs non-magnetic),
  sink or float (density), germination conditions (for Classes 5–6).
  - Needs matching backend evaluator rules; today the local `evaluateLab` mirrors backend v1.
- [ ] **7.8 Daily challenge** — one task a day drawn from any tool, feeding the existing streak.

---

## Phase 8 — Backend: new generic "Explore Assist" agent (LAST)

Today the backend has a single agent, **Learn Assist** (`/learnassist/chat`,
`/learnassist/chat/stream`). It is book- and syllabus-grounded, with citations,
history keyed by `HistorySelector`, and usage limits.

The new agent answers **generic, content-anchored questions** from inside the Explore
tools, where the "context" is a piece of app content rather than a textbook.

- [ ] **8.1 Backend agent (separate backend repo)**
  - Proposed endpoints: `POST /exploreassist/chat` and `/exploreassist/chat/stream`.
  - Request: `board`, `class_no`, `language`, `message`, plus a `context` object:
    `{ kind: element | formula | diagram_label | timeline_event | vocab_word | lab,
       id, title, payload }`.
    The `payload` holds the data already on screen (for example an element's properties),
    so the agent doesn't have to look it up.
  - The answer is pitched at the student's class, in the student's language, with no book citations.
  - Shares auth (Firebase ID token), rate limits and usage accounting with Learn Assist.
  - 🔸 Decide: separate daily quota, or shared with Learn Assist?
  - 🔸 Decide: store history server-side or keep it ephemeral? Recommendation: ephemeral per
    content item, because these are quick follow-ups rather than study sessions.
- [ ] **8.2 Frontend service + provider**
  - `explore_assist_service.dart`, mirroring `learn_assist_service.dart`: same `defaultBaseUrl`,
    token refresh, 401 retry and SSE streaming.
  - Models `ExploreAssistRequest` / `ExploreAssistContext` in `data/models/`.
- [ ] **8.3 Shared "Ask about this" bottom sheet**
  - One reusable widget: a context chip, suggested questions, a streaming answer and a
    follow-up box.
- [ ] **8.4 Wire it into content**
  - Periodic Table element detail (replaces the Phase 1.5 hidden button and resolves the TODO)
  - Formula detail ("Explain this formula", "Show a worked example")
  - Diagram label popups
  - Timeline event cards
  - Vocabulary word detail ("Use it in a sentence")
  - Science Lab results ("Why did this happen?")
- [ ] **8.5 AI Tutor** — if Phase 1.6 hid the row, decide whether the tutor becomes a mode of
  this agent or stays a separate future agent.
- [ ] **8.6 Tests** — service tests with a `baseUrl` override (same pattern as `learn_assist_test.dart`).

---

## Appendix — New diagrams (owner: you, separate session)

Existing (12): animal cell, water cycle, food chain, digestive system, heart, photosynthesis,
earth layers, volcano, electric circuit, atom structure, reflection of light, states of matter.

Each new diagram needs an image in `assets/diagrams/interactive/`, labels with positions,
and EN/HI/OR text. If Phase 5 is done first, each also needs a `minClass`/`maxClass`.

| Priority | Diagram | Section | Classes | Key labels |
|---|---|---|---|---|
| P1 | Plant cell | biology | 6–9 | cell wall, membrane, chloroplast, vacuole, nucleus, cytoplasm, mitochondria |
| P1 | Parts of a flower | biology | 5–8 | petal, sepal, stamen (anther, filament), pistil (stigma, style, ovary) |
| P1 | Structure of a leaf | biology | 5–8 | blade, midrib, veins, petiole, stomata |
| P1 | Human eye | biology | 7–10 | cornea, iris, pupil, lens, retina, optic nerve |
| P1 | Respiratory system | biology | 6–10 | nose, trachea, bronchi, lungs, alveoli, diaphragm |
| P1 | Map of India (states) | geography | 4–10 | states, capitals, major rivers |
| P2 | Human skeleton | biology | 5–8 | skull, rib cage, spine, pelvis, femur, humerus |
| P2 | Human ear | biology | 8–10 | pinna, ear canal, eardrum, ossicles, cochlea |
| P2 | Human brain | biology | 8–10 | cerebrum, cerebellum, medulla |
| P2 | Kidney / excretory system | biology | 7–10 | kidney, ureter, bladder, urethra, nephron |
| P2 | Odisha districts | geography | 4–8 | 30 districts, Mahanadi, Chilika |
| P2 | Latitudes & longitudes | geography | 6–8 | equator, tropics, prime meridian, poles |
| P2 | Refraction through a lens | science | 8–10 | convex/concave lens, focus, principal axis |
| P2 | Magnet & field lines | science | 6–10 | N/S poles, field lines, compass |
| P3 | Solar system (2D) | geography | 3–6 | Sun, 8 planets, asteroid belt |
| P3 | Types of angles & triangles | math | 5–7 | acute, right, obtuse, equilateral, isosceles, scalene |
| P3 | Parts of a circle | math | 6–8 | centre, radius, diameter, chord, arc, sector, tangent |
| P3 | 3D solids | math | 5–9 | cube, cuboid, cylinder, cone, sphere (faces, edges, vertices) |
| P3 | Simple machines | science | 6–8 | lever (fulcrum, load, effort), pulley, inclined plane |
| P3 | Soil profile | geography | 7–8 | humus, topsoil, subsoil, bedrock |

Note: the geography section currently has only 2 diagrams (earth layers, volcano).
The math section doesn't exist yet: `DiagramSection` needs a `math` value.
