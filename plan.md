# Vidyālaya — AI-First Refactor — Implementation Plan

> **Status:** planned, not yet implemented. Phased, file-by-file blueprint for the
> AI-first repositioning. Direction decided (see "Decisions"); high-level rationale
> lives in `refactor_highlevel.md`.

## Context

The app's priority inverted. New order:
1. **AI Learning** (primary) — Q&A (live) + **Tutor** (mock for now) + future agents.
2. **Interactive Learning** (secondary) — the tools in today's Learn tab
   (Math, Periodic Table, Diagrams, Timeline, Cosmulator, Quizzes, Virtual Lab).
3. **Reading books** (tertiary) — board PDFs; kept, but demoted.

Today the nav is `Home · My Books · Learn · Progress`, AI is buried as one card
inside Learn, and Progress measures **reading only**. This refactor re-centers the
app on **AI + learning activity**.

## Decisions (locked)

- **Landing:** keep a **Home dashboard** (Option B). App does **not** open into chat.
- **Bottom nav (4 tabs):** `Home · Learn AI · Explore · Library`.
  - Library **stays in nav** (user requirement) as the **3rd feature** (tab #4 slot).
  - AI is tab #2 and prominent; books demoted but present.
  - **Me/Profile** is reached from the **Home avatar** (as Profile is today), keeping
    the bar at 4 tabs. **Progress is merged into Me.**
- **Tutor:** **mock UI only** — agent picker + a scripted guided-lesson mockup.
  No real agent/backend yet. Reuses the chat shell so the real agent drops in later.
- **Progress → "learning", not "reading":** count AI sessions, tools opened, and
  reading. Streak becomes a **learning streak** (any learning activity counts).
  Merged into the **Me** screen.
- **Books:** **kept** (not removed). Demoted to tab #3 / renamed `Library`.
  Add a `booksEnabled` flag now (defaults **true**) so books *can* be hidden later
  without dead links — but it stays on for now.

## Final navigation

```
🏠 Home        🤖 Learn AI      🧭 Explore       📚 Library
 (dashboard)   (AI agents)     (tools)         (books, #3 feature)
                                          avatar → 👤 Me (profile + progress)
```

- `Home` — dashboard (greeting, learning streak, jump-back, big "Ask AI" CTA).
- `Learn AI` — agent hub: Q&A (live) + Tutor (mock). Reusable chat shell.
- `Explore` — the de-tangled tools (was `Learn`), sectioned + 2-col grid.
- `Library` — was `My Books`; reading, demoted, `booksEnabled`-gated.
- `Me` — merge of Profile + Progress; **learning** metrics + settings.

---

## Phase 0 — Learning-activity tracking (foundation)

Everything downstream (Home streak, Me dashboard) needs a unified activity signal.
Generalize today's reading-only tracking into **learning** tracking.

### `lib/data/repositories/user_prefs_repository.dart`

Current keys: `total_study_seconds`, `total_pages_read`, `pages_read_today`,
`last_active_date`, `current_streak`, per-subject pages. The streak already keys off
`last_active_date` inside `addPagesRead` → `_updateStreak`. **Generalize the trigger.**

- Extract the streak/today-rollover logic out of `addPagesRead` into a private
  `_recordActivityToday()` and call it from **every** learning action.
- Add counters:
  ```dart
  static const _aiSessionsKey  = 'ai_sessions_total';
  static const _toolsOpenedKey = 'tools_opened_total';

  int getAiSessions()  => _prefs.getInt(_aiSessionsKey) ?? 0;
  int getToolsOpened() => _prefs.getInt(_toolsOpenedKey) ?? 0;

  Future<void> recordAiSession() async {
    await _prefs.setInt(_aiSessionsKey, getAiSessions() + 1);
    await _recordActivityToday(); // streak counts AI too
  }
  Future<void> recordToolOpened(String toolId) async {
    await _prefs.setInt(_toolsOpenedKey, getToolsOpened() + 1);
    await _recordActivityToday();
  }
  ```
- `addPagesRead` now also calls `_recordActivityToday()` (no behavior change for reading;
  it just shares the same streak/rollover code).

> Net effect: **any** learning action (read a page, send an AI message, open a tool)
> keeps the streak alive — that's the "learning everything" requirement.

### `lib/providers/progress_provider.dart`

Rename intent from reading → learning. Extend `ProgressStats`:
```dart
class ProgressStats {
  final int currentStreak;        // now a LEARNING streak
  final int totalPagesRead;
  final int totalStudySeconds;
  final int pagesReadToday;
  final int aiSessions;           // new
  final int toolsOpened;          // new
  final Map<String, int> subjectPages;
  ...
}
```
`_loadStats()` reads the new counters. Keep the `progressProvider` name (no rename
churn); it's now a learning-stats provider.

---

## Phase 1 — Reusable AI agent shell + Learn AI tab

### New: `lib/screens/learn_ai/agent.dart`
Declarative agent registry so future agents are a list entry, not a new screen:
```dart
enum AgentStatus { live, mock, comingSoon }

class LearnAgent {
  final String id, title, subtitle;
  final IconData icon;
  final AgentStatus status;
  final String? channel; // LearnAssistChannel for live agents
  const LearnAgent({...});
}

const learnAgents = <LearnAgent>[
  LearnAgent(id: 'qa', title: 'Q&A', subtitle: 'Ask anything from your books',
      icon: Icons.auto_awesome, status: AgentStatus.live,
      channel: LearnAssistChannel.learnAssist),
  LearnAgent(id: 'tutor', title: 'AI Tutor',
      subtitle: 'Step-by-step guided lessons', icon: Icons.school_rounded,
      status: AgentStatus.mock),
];
```

### New: `lib/screens/learn_ai/learn_ai_hub_screen.dart` (the new tab)
- Header "Learn with AI".
- An **agent picker**: one prominent card per `learnAgents` entry.
  - `live` → `context.push('/learn/ai?channel=...')` (existing chat).
  - `mock` → `context.push('/learn-ai/tutor')` (Phase 2 mock).
- Below: recent conversations (reuse history via `backendAccountCacheProvider`).
- This is the **landing for the Learn AI tab**, not a blank chat (Class-5 safe).

### Existing chat: `lib/screens/learn/learn_ai_screen.dart`
- No structural change. On a successful send, call
  `userPrefsRepository.recordAiSession()` then `ref.read(progressProvider.notifier).refresh()`.
  (Hook where `prependLatestHistoryMessages` runs.)

---

## Phase 2 — Tutor (mock only)

### New: `lib/screens/learn_ai/widgets/chat_bubble.dart`
Extract the user/assistant bubble widgets from `learn_ai_screen.dart` so both the
live chat and the Tutor mock share one look.

### New: `lib/screens/learn_ai/tutor_mock_screen.dart`
A **convincing mock**, clearly labelled, no backend:
- Subject chips (Math, Science, English, …) — selectable, cosmetic.
- A pre-scripted "lesson" bubble flow (static) showing the intended step-by-step UX.
- A pinned banner: "AI Tutor preview — full tutoring coming soon."
- Composer disabled or replies with a canned "coming soon" message.
- **No** network calls.

### Route (`lib/app/router.dart`)
```dart
GoRoute(path: '/learn-ai/tutor', parentNavigatorKey: _rootNavigatorKey,
    builder: (_, __) => const TutorMockScreen()),
```

---

## Phase 3 — Explore tab (de-tangled tools) + FeatureCard

### New: `lib/widgets/feature_card.dart`
Extract the repeated ~60-line inlined card (used ~10× in `learn_screen.dart`) into one
data-driven widget: `FeatureCard({icon, iconColor, bg, title, subtitle, status, onTap})`
with a `FeatureCardData` model and a `status` (live / comingSoon) badge.

### New: `lib/screens/explore/explore_screen.dart` (renamed Learn, AI removed)
Drive from a data list, **sectioned** + a 2-col grid (halves the scroll):
- **🔬 Explore & Play** (2-col grid): Periodic Table · Diagrams · Cosmulator ·
  Timeline · Math Formulas. Each `onTap` → existing route **and**
  `userPrefsRepository.recordToolOpened(id)` + `progressProvider.refresh()`.
- **🎯 Coming soon** (muted): Quizzes · Virtual Lab.
- **AI cards are REMOVED here** — they now live in the Learn AI tab.

Replace the old `learn_screen.dart` with `explore_screen.dart` (delete the AI/Tutor cards).

---

## Phase 4 — Home dashboard

### `lib/screens/home/home_screen.dart`
Re-center from "continue reading" to "continue learning":
- Greeting + avatar (avatar still → `/profile`, i.e. **Me**).
- **Big primary CTA:** "Ask AI 💬" → Learn AI tab.
- **Learning streak** chip (`progressProvider.currentStreak`, now learning-wide).
- **Jump back in:** last AI thread (if any) **then** continue-reading (reading below AI).
- Keep `EXPLORE` quick-actions (Bookmarks · Notes · Timetable); drop "Assignment".
- `RECENTLY ADDED` books row → only shown when `booksEnabled`.

### `lib/screens/home/widgets/quick_actions_grid.dart`
Migrate to the new `FeatureCard`; remove the disabled "Assignment (soon)" tile.

---

## Phase 5 — Library (demote + flag)

### `lib/providers/core_providers.dart`
```dart
final booksEnabledProvider = Provider<bool>((_) => true); // flip to hide later
```

### `lib/screens/my_books/my_books_screen.dart`
- Retitle to **"Library"** (file stays `my_books_screen.dart` to avoid churn).
- No feature changes; just demoted to tab #3.

### Gate entry points on `booksEnabled`
- The Library **tab** (Phase 6), the Home `RECENTLY ADDED` row, and the
  continue-reading surface read `booksEnabledProvider` and hide cleanly when false.
  (Default true → no visible change now; ready for copyright pressure later.)

---

## Phase 6 — Navigation rewrite

### `lib/widgets/app_shell.dart`
```dart
static const _tabs = [
  ('/',         Icons.home_rounded,        'Home'),
  ('/learn-ai', Icons.auto_awesome,        'Learn AI'),
  ('/explore',  Icons.explore_rounded,     'Explore'),
  ('/library',  Icons.menu_book_rounded,   'Library'),
];
```
Keep the existing `_NavBarItem` look; Class-5 pass: ≥56dp targets, keep icon+label.

### `lib/app/router.dart`
- Shell routes: `/` (Home), `/learn-ai` (LearnAiHubScreen), `/explore`
  (ExploreScreen), `/library` (MyBooksScreen).
- Keep `/learn/ai`, `/learn/math-formulas`, `/learn/periodic-table`,
  `/learn/timeline`, `/learn/diagrams`, `/learn/cosmulator` as **detail routes**
  (re-pointed from the new tabs).
- Add `/learn-ai/tutor`.
- Redirects (avoid dead links / saved deep links):
  `/learn` → `/explore`, `/my-books` → `/library`, `/progress` → `/profile`.
- Remove the `/progress` shell route (merged into Me).

---

## Phase 7 — Merge Progress → Me (Profile)

### `lib/screens/profile/profile_screen.dart` → conceptually "Me"
Insert a **"My Learning"** section near the top (above the existing settings),
reusing the Progress widgets:
- Move `_StatCard` row, the goal ring, and `_SubjectProgressBar` from
  `progress_screen.dart` into `lib/screens/profile/widgets/learning_summary.dart`.
- Headline the **learning streak** + new stat cards: AI sessions, Tools explored,
  Pages read, Time. Keep the subject-focus bars.
- Reframe "Daily Reading Goal" copy → "Daily Learning Goal" (any activity counts),
  or keep the reading goal as one card among the learning stats.
- Existing Profile sections (Classes, Downloads, Notes, Privacy, About, theme, auth)
  stay below.

### `lib/screens/progress/progress_screen.dart`
- Delete the screen. Its widgets now live in `profile/widgets/learning_summary.dart`.

---

## Critical files

| File | Change |
|------|--------|
| `lib/data/repositories/user_prefs_repository.dart` | learning-activity counters + unified streak trigger |
| `lib/providers/progress_provider.dart` | add `aiSessions`, `toolsOpened`; learning streak |
| `lib/providers/core_providers.dart` | `booksEnabledProvider` |
| `lib/screens/learn_ai/agent.dart` | **new** — agent registry |
| `lib/screens/learn_ai/learn_ai_hub_screen.dart` | **new** — Learn AI tab landing |
| `lib/screens/learn_ai/tutor_mock_screen.dart` | **new** — Tutor mock |
| `lib/screens/learn_ai/widgets/chat_bubble.dart` | **new** — extracted bubbles |
| `lib/screens/learn/learn_ai_screen.dart` | record AI session on send |
| `lib/widgets/feature_card.dart` | **new** — data-driven card |
| `lib/screens/explore/explore_screen.dart` | **new** — tools only (was Learn, AI removed) |
| `lib/screens/learn/learn_screen.dart` | removed/replaced by Explore |
| `lib/screens/home/home_screen.dart` | AI-first dashboard |
| `lib/screens/home/widgets/quick_actions_grid.dart` | FeatureCard migration |
| `lib/screens/my_books/my_books_screen.dart` | retitle "Library"; `booksEnabled` gating |
| `lib/widgets/app_shell.dart` | new 4-tab set |
| `lib/app/router.dart` | new shell routes + redirects (`/learn`→`/explore`, `/my-books`→`/library`, `/progress`→`/profile`) |
| `lib/screens/profile/profile_screen.dart` | "My Learning" section (Progress merged in) |
| `lib/screens/profile/widgets/learning_summary.dart` | **new** — moved Progress widgets |
| `lib/screens/progress/progress_screen.dart` | deleted / redirect |

## Verification

1. **Nav order:** bottom bar reads `Home · Learn AI · Explore · Library`; AI is tab #2,
   Library is the 3rd feature, no Progress tab.
2. **AI-first Home:** Home shows greeting + "Ask AI" CTA + learning streak; reading is
   below AI, not the hero.
3. **Learn AI tab:** lands on the agent picker (Q&A live, Tutor mock) — not a blank chat.
4. **Tutor mock:** opens a clearly-labelled preview; no network call; composer canned.
5. **Explore:** tools only (no AI cards), 2-col grid, shorter scroll; opening a tool
   bumps `toolsOpened` and the streak.
6. **Learning streak counts everything:** send an AI message OR open a tool OR read a
   page → streak stays alive (not reading-only). Verify via the Me dashboard.
7. **Me merge:** Profile shows "My Learning" (streak + AI sessions + tools + pages) and
   all old settings; `/progress` redirects to `/profile`.
8. **Books kept but flaggable:** `booksEnabled=true` → Library tab + Home book row
   visible; setting it false hides them with **no dead links** (don't ship false).
9. **Redirects:** `/learn`→`/explore`, `/my-books`→`/library`, `/progress`→`/profile`.
10. `flutter analyze` clean.
```
