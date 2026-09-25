# Vidya AI — Release Plan

_Phases 1–6 are done: release polish, math in AI answers, formulas, content gaps,
class-aware Explore, and regional language for study content. This file now tracks only
what's left._

Phase 7 (new learning tools) runs in a separate session. Phase 8 (the backend Explore Assist
agent) comes last.

**Legend:** `[ ]` todo · `[x]` done · 🔸 needs a decision from you before starting

---

## Ground rules (carried over from Phases 1–6)

- **Language:** only *study content* switches to Odia/Hindi, via the per-screen
  `RegionalLanguageSwitch`. App labels, titles, buttons and navigation stay English. Python,
  the AI hub, Profile, Settings, Timetable and Notes are English-only. Content translations
  live next to the content as `LocalizedText` (`lib/data/models/localized_text.dart`), with
  no global string table.
- **Class ranges:** every Explore tool, diagram and formula category has a `ClassRange` in
  `lib/data/models/class_range.dart`. Content outside the student's classes is never hidden;
  it moves under "More tools" or the "All classes" switch. Class ranges are your decision.
- **Brand:** user-facing name is "Vidya AI"; technical identifiers stay `vidyalaya`.
- **Git diffs:** don't run `dart format` on whole files that weren't formatted before; keep
  diffs to the lines that changed.

---

## Open follow-ups from Phases 1–6

- [ ] 🔸 **Native-speaker review** of the new Odia/Hindi text: new formulas (Phase 3),
  30 timeline events (Phase 4), Math practice and Science Lab content (Phase 6).
- [ ] 🔸 **Timeline dates** marked "c." or given as a century are approximate. Check them.
- [ ] **Math in AI answers: real samples.** Check the LaTeX renderer against 10–15 real
  math-heavy answers on a device (the tests use made-up answers).
- [ ] 🔸 **Backend prompt rule.** Ask the Learn Assist prompt to write math only as
  `$…$` / `$$…$$` (backend repo).
- [ ] 🔸 **(optional) `flutter_markdown` → `flutter_markdown_plus`.** The old package is
  discontinued upstream.
- [ ] **Diagrams follow-up (you).** Correct labels, and fix some images such as the maps.
  Every new diagram needs an entry in `diagramClassRanges`; a test fails without one.
- [ ] **Formula figures.** New solids (cone, sphere, parallelogram, trapezium…) have no
  drawn diagram yet; `FormulaDiagramPainter` only knows the original 9 shapes.
- [ ] **Science Lab header** still reads "CLASS 7 · SCIENCE · CHAPTER …" although the lab is
  now recommended from Class 6.

---

## Phase 7 — New learning tools (separate session)

Every new tool also needs:
- an entry in `exploreToolClassRanges`,
- a tile in `explore_screen.dart` and a route in `app/router.dart`,
- Odia/Hindi for its study content only.

Do the steps in order within each tool; tools themselves can be picked in any order.
Suggested order: 7A → 7B → 7C → 7D → 7E → 7F → 7G → 7H.

### 7A — Subject quizzes (Science, Social Science, English)
- [ ] **7A.1** 🔸 Decide the class bands and subjects for v1 (suggested: Classes 3–5, 6–8, 9–10).
- [ ] **7A.2** Question model: prompt, options, answer, explanation as `LocalizedText`, plus
  subject and class range. Store banks under `lib/data/quiz/<subject>/`.
- [ ] **7A.3** Write the first bank: about 20 questions per subject per band.
- [ ] **7A.4** Quiz screen: reuse the Math Quiz shell (`MathOptionTile`, `MathExplanation`,
  results sheet) with a subject picker.
- [ ] **7A.5** Best scores per subject, stored the way `mathProgressProvider` does it.
- [ ] **7A.6** Tests: every question has a valid answer index and all three languages.

### 7B — Units & measurement (extend, don't duplicate)
Formulas → Measurement already converts length, mass, capacity, time and money.
- [ ] **7B.1** 🔸 Decide: extend the Measurement category (recommended) or build a separate tool.
- [ ] **7B.2** Add temperature (°C/°F/K), area (m², cm², hectare, acre) and volume
  (m³, cm³, L).
- [ ] **7B.3** Tests with known conversions.

### 7C — Alphabet & first words (Classes 1–3)
- [ ] **7C.1** Letter data for Odia, Hindi and English: each letter with 1–2 example words.
- [ ] **7C.2** Browse screen: a letter grid, and a letter detail with example words.
- [ ] **7C.3** "Find the letter" game with 10 rounds and a score.
- [ ] **7C.4** 🔸 Decide whether to add audio later. It's out of scope for v1.
- [ ] **7C.5** Tests: complete letter sets and no empty examples.

### 7D — English grammar
- [ ] **7D.1** Topic list: parts of speech, tenses, articles, prepositions (more later).
- [ ] **7D.2** Each topic has a short explainer, with an Odia/Hindi explanation where it helps.
- [ ] **7D.3** 5–10 practice questions per topic, reusing the 7A question model and screen.
- [ ] **7D.4** Tests.

### 7E — Maps (India & Odisha)
- [ ] **7E.1** 🔸 Source SVG maps and check their licence before bundling.
- [ ] **7E.2** State/district data: name (EN/OR/HI), capital or HQ, and 1–2 key facts.
- [ ] **7E.3** Tap-to-explore map screen.
- [ ] **7E.4** "Find the state/district" quiz.
- [ ] **7E.5** Tests: every map region has data and every data entry has a region.

### 7F — Revision flashcards
- [ ] **7F.1** Card sources: highlights, notes and bookmarks (`UserPrefsRepository`), plus
  vocabulary words.
- [ ] **7F.2** Flip-card screen with "know it / review again" buttons.
- [ ] **7F.3** Simple spaced repetition: store the next-review date per card, locally.
- [ ] **7F.4** Tests for scheduling.

### 7G — Science Lab: more experiments
- [ ] **7G.1** 🔸 Pick the experiments. Suggested: pendulum, plane mirror, magnets,
  sink or float, germination (for Classes 5–6).
- [ ] **7G.2** Add rules to the local `evaluateLab`, with a `LocalizedText` explanation and
  `labWord` display words.
- [ ] **7G.3** Matching backend evaluator rules (backend repo). Bump `labVersion`.
- [ ] **7G.4** Painter/visual for each experiment.
- [ ] **7G.5** Fix the header (see follow-ups) and update the tile subtitle "Try two experiments".
- [ ] **7G.6** Tests: deterministic observations and translated explanations.

### 7H — Daily challenge
- [ ] **7H.1** 🔸 Decide what counts as a task (one quiz question, one formula, one word …).
- [ ] **7H.2** Deterministic daily pick, the same way `wordOfTheDay()` works.
- [ ] **7H.3** Home card, and completion feeding the existing streak.
- [ ] **7H.4** Tests.

---

## Phase 8 — Backend: new generic "Explore Assist" agent (LAST)

Today the backend has one agent, **Learn Assist** (`/learnassist/chat`,
`/learnassist/chat/stream`). It is grounded in books and the syllabus, cites its sources,
keeps history keyed by `HistorySelector`, and has usage limits.

The new agent answers **generic questions tied to a piece of app content** inside the
Explore tools, rather than a textbook.

- [ ] **8.1 Backend agent (separate backend repo)**
  - Proposed endpoints: `POST /exploreassist/chat` and `/exploreassist/chat/stream`.
  - Request: `board`, `class_no`, `language`, `message`, plus a `context` object:
    `{ kind: element | formula | diagram_label | timeline_event | vocab_word | lab,
       id, title, payload }`. The `payload` holds the data already on screen. Formulas have
    stable ids (`formulaById`) for this.
  - Answers are pitched at the student's class, in their language, with no book citations.
  - Shares auth (Firebase ID token), rate limits and usage accounting with Learn Assist.
  - Include the math-format rule (`$…$` / `$$…$$`) so answers render with `AiMarkdown`.
  - 🔸 Decide: separate daily quota, or shared with Learn Assist?
  - 🔸 Decide: history stored server-side or ephemeral? Recommendation: ephemeral per item.
- [ ] **8.2 Frontend service + provider**
  - `explore_assist_service.dart`, mirroring `learn_assist_service.dart`: same `defaultBaseUrl`,
    token refresh, 401 retry and SSE streaming.
  - Models `ExploreAssistRequest` / `ExploreAssistContext` in `data/models/`.
- [ ] **8.3 Shared "Ask about this" bottom sheet**
  - A context chip, suggested questions, a streaming answer rendered with `AiMarkdown`, and a
    follow-up box.
- [ ] **8.4 Wire it into content**
  - Periodic Table element detail: turn on `_showAskAi` in `periodic_table_screen.dart` and
    resolve its TODO.
  - Formula detail ("Explain this formula", "Show a worked example").
  - Diagram label popups.
  - Timeline event cards.
  - Vocabulary word detail ("Use it in a sentence").
  - Science Lab results ("Why did this happen?").
- [ ] **8.5 AI Tutor** — currently a read-only preview (Option B). Decide whether the tutor
  becomes a mode of this agent or a separate agent later.
- [ ] **8.6 Tests** — service tests with a `baseUrl` override (same pattern as `learn_assist_test.dart`).
