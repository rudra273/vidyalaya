# Vidya AI — Release Plan

_Phases 1–7 are done, and everything validated. Only Phase 8, the backend Explore Assist
agent, is left._

**Legend:** `[ ]` todo · `[x]` done · 🔸 needs a decision from you before starting

---

## Ground rules

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

## References

- **Learn Assist (the pattern to mirror):** `lib/data/services/learn_assist_service.dart`
  (`defaultBaseUrl`, token refresh, 401 retry, SSE streaming) and
  `test/data/learn_assist_test.dart` (`baseUrl` override in tests).
- **Markdown/math rendering:** `AiMarkdown`; math is written as `$…$` / `$$…$$`.
- **Content ids for the `context` object:** formulas use `formulaById`; labs use `labById`
  (`lib/data/lab/lab_catalog.dart`).
- **Explore tools:** `lib/screens/explore/explore_screen.dart`, routes in
  `lib/app/router.dart`, class ranges in `lib/data/models/class_range.dart`.

---

## Phase 8 — Backend: new generic "Explore Assist" agent

Today the backend has one agent, **Learn Assist** (`/learnassist/chat`,
`/learnassist/chat/stream`). It is grounded in books and the syllabus, cites its sources,
keeps history keyed by `HistorySelector`, and has usage limits.

The new agent answers **generic questions tied to a piece of app content** inside the
Explore tools, rather than a textbook.

- [ ] **8.1 Backend agent (separate backend repo)**
  - Proposed endpoints: `POST /exploreassist/chat` and `/exploreassist/chat/stream`.
  - Request: `board`, `class_no`, `language`, `message`, plus a `context` object:
    `{ kind: element | formula | diagram_label | timeline_event | vocab_word | lab,
       id, title, payload }`. The `payload` holds the data already on screen.
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
  - Laboratory results ("Why did this happen?").
- [ ] **8.5 AI Tutor** — currently a read-only preview (Option B). Decide whether the tutor
  becomes a mode of this agent or a separate agent later.
- [ ] **8.6 Tests** — service tests with a `baseUrl` override (same pattern as `learn_assist_test.dart`).
