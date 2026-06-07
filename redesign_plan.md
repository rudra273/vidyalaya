# Vidyālaya — Whole-App Redesign Plans (v2)

> **Status:** proposal. Whole-app layout/IA options designed for a
> **Class-5-friendly UX** and current + upcoming features.
> **Subject-centric navigation is rejected** — all options below are
> **feature/tool-oriented** and flat (no "pick a subject first" gate).
> Nothing here is implemented yet.

---

## 0. Where we are today (the baseline)

**Navigation:** 4-tab bottom bar → `Home · My Books · Learn · Progress`
(Profile pushed from the Home avatar).

**Home** (`home_screen.dart`)
- Title "Vidyālaya" + avatar → Profile
- Hero card = *Continue reading* (last-read book)
- `EXPLORE` grid: Bookmarks · Timetable · Notes · Assignment *(soon)*
- `RECENTLY ADDED` book row
- **Problem:** feels empty / it's a launcher, not a daily destination.

**Learn** (`learn_screen.dart`) — a flat list of **10 cards**:
Q&A (LIVE AI) · AI Tutor *(soon)* · Math Formulas · Periodic Table · Science
Diagrams · Timeline · Cosmulator · Quizzes *(soon)* · Virtual Lab *(soon)*.
- **Problem:** one long undifferentiated scroll; mixes a conversational AI,
  reference tools, 3D explorers, and coming-soon stubs as 10 equal cards.

**My Books / Progress / Profile** — library, reading progress, settings.

**Live AI today:** only **Q&A**. Tutor / Quizzes / Lab are "soon."

**Upcoming:** **Tutor agent** (teaches subjects step-by-step) + Quizzes + Virtual Lab.

---

## 1. Design thesis (no subjects)

The root issue is **flat IA**: Learn = 10 peers, Home = a second launcher.
Fix it by separating **what kind of thing** each feature is — not by subject:

> **(a) AI helpers** that talk to the student (Q&A, Tutor) ·
> **(b) Interactive tools** (Periodic Table, Cosmulator, Diagrams, Timeline, Math) ·
> **(c) Curriculum** (Books, Notes, Progress, Timetable).
> Give **Home a job** (today's plan) instead of being a launcher.

**Class-5 rules applied everywhere:** min 56dp tap targets, icon **+** word labels
(never icon-only), ≤4 primary destinations, big body text, warm rounded cards,
one obvious "what do I do now" action per screen, no nested drill-downs to reach a tool.

---

## Plan A — "AI-First" (5 tabs)

**Bet:** the AI tutor is the product's future. Give AI its own tab; demote the
grab-bag tools into a tidy, grouped "Explore."

### Bottom nav
```
🏠 Home    📚 Books    💬 Ask AI    🧭 Explore    📊 Progress
```

### Home = "Today" dashboard
Greeting + avatar · Continue-reading hero · Today's timetable strip (next 2–3
periods) · "Pick up where you left off" (last Q&A + last book) · playful streak
nudge · quick chips (Bookmarks · Notes · Timetable).

### Ask AI tab
Mode switcher at top: `Q&A` | `Tutor (Soon→Live)`.
`Q&A` = today's `learn_ai_screen.dart` lifted to a tab. `Tutor` = the upcoming
agent slots in here with **zero IA churn**. Recent conversations below.

### Explore tab (de-cluttered Learn, grouped by *tool type* not subject)
- **Science tools:** Periodic Table · Diagrams · Cosmulator
- **Math tools:** Formulas & Calculator
- **History:** Timeline
- **Coming soon:** Quizzes · Virtual Lab (one muted, collapsed row)

| ✅ Pros | ⚠️ Cons |
|--------|---------|
| AI unmissable; Tutor launch needs no re-navigation | 5 tabs is the max for kids; tight on small phones |
| Learn overload solved by grouping | "Ask AI" tab looks thin until Tutor ships |
| Home becomes a daily destination | Most build effort |

**Best if:** the Tutor agent is the headline feature.

---

## Plan B — "Calm 4-Tab" (least disruption) ⭐ recommended

**Bet:** keep the familiar 4-tab shape, but fix both problems: turn Learn into a
**sectioned Explore** with AI pinned at top, and make Home a real dashboard.

### Bottom nav (count unchanged)
```
🏠 Home    📚 Books    🧭 Explore    📊 Progress
```
(`Learn` → `Explore`; Profile still from the Home avatar.)

### Home = dashboard
Continue-reading · Today's timetable strip · streak nudge · quick chips, **plus
one big primary CTA:** "Ask a question 💬" → jumps straight into Q&A.

### Explore = sectioned, with a 2-column tile grid
- **🌟 Your AI Helpers** (hero, top): Q&A (live) + Tutor (soon) as two prominent cards.
- **🔬 Explore & Play:** Periodic Table · Diagrams · Cosmulator · Timeline · Math
  as a **2-col grid of friendly tiles** (not full-width rows) → ~half the scroll.
- **🎯 Coming soon:** Quizzes · Virtual Lab (muted).

The 2-col grid is the key fix for "too much content" — it shortens the scroll and
visually separates AI from tools, with **no extra navigation**.

| ✅ Pros | ⚠️ Cons |
|--------|---------|
| Smallest change — keeps 4 tabs & muscle memory | AI shares a tab; less prominent than Plan A |
| 2-col grid fixes the long scroll | Tutor launch = a card, not a destination |
| Same Home upgrade win | Explore still holds AI + tools together |

**Best if:** you want the fastest, safest win and AI prominence can wait.

---

## Plan C (new) — "Action Bar" (4 tabs + a center AI button)

**Bet:** keep 4 tabs *and* make AI unmissable — without a 5th tab — by putting a
floating **center "Ask AI" button** in the nav bar (the pattern kids know from
chat/social apps). Tools stay flat and grouped; no subjects, no drill-down.

### Bottom nav — 4 tabs with a raised center action
```
🏠 Home    📚 Books   ( 💬 )   🧭 Explore   📊 Progress
                     raised AI
```
- The center button opens **Ask AI** (Q&A now; Q&A **+** Tutor mode-switcher later)
  as a full-screen sheet/route — reachable from *every* tab in one tap.
- Four real tabs stay: Home · Books · Explore · Progress.

### Home = dashboard
Same "Today" dashboard as Plans A/B (timetable strip, streak, continue-reading).
No primary "Ask" CTA needed — the center button *is* the always-present CTA.

### Explore = sectioned 2-col grid
Identical to Plan B's Explore (AI helpers hero optional here since AI has the
center button) — **Explore & Play** 2-col grid + **Coming soon** muted row.

| ✅ Pros | ⚠️ Cons |
|--------|---------|
| AI is one tap from anywhere, yet stays 4 tabs | Center-button pattern needs careful Class-5 sizing/labeling |
| No 5th tab crowding; no subject gate | Slightly more custom nav-bar work than B |
| Tutor mode drops into the same AI sheet later | A floating button can feel "app-y," less "calm" than B |
| Best AI reach-to-effort ratio | The raised button must not overlap content/keyboards |

**Best if:** you love B's calm layout but want AI as prominent as Plan A —
**this is the A/B hybrid.**

---

## 2. Side-by-side

| Dimension | **A — AI-First** | **B — Calm 4-Tab** ⭐ | **C — Action Bar** |
|---|---|---|---|
| Bottom tabs | 5 | 4 | 4 + center AI button |
| Learn overload fix | Group into Explore | Sectioned + 2-col grid | Sectioned + 2-col grid |
| Home emptiness fix | Dashboard | Dashboard | Dashboard |
| AI prominence | ★★★ (own tab) | ★★ (top of Explore) | ★★★ (center, everywhere) |
| Tutor agent home | Ask AI tab | A card in Explore | Center AI sheet |
| Extra navigation to reach a tool | None | None | None |
| Build effort | High | **Low** | Low–Medium |
| Risk | Medium | **Low** | Low–Medium |

---

## 3. Shared work (any plan)

1. **Home → dashboard:** add Today's-timetable strip + streak/return nudge + one
   clear primary action. (`home_screen.dart`, new `today_strip` widget; reuse
   timetable + reading providers.)
2. **Break up `learn_screen.dart`:** it's a 600-line build with 10 inlined card
   blocks → extract a reusable `FeatureCard` / `FeatureTile` driven by a data
   list. Prerequisite for all plans.
3. **Reusable AI shell:** lift `learn_ai_screen.dart` so it works as a tab, a
   route, *and* a center-button sheet — so the Tutor agent reuses the same chat.
4. **Consistent "Soon" treatment:** replace snackbar/disabled cards with a muted
   card + optional "notify me."
5. **Class-5 visual pass** via `theme.dart` + the new `FeatureCard`: bigger
   targets, icon+label, larger text, warm rounded cards.

---

## 4. Recommendation

- **Safest, ship-now:** **Plan B** — keeps 4 tabs/muscle memory, fixes both
  complaints (2-col grid + dashboard).
- **AI is the headline:** **Plan A** — its own tab; Tutor launches with no redesign.
- **Want both calm *and* prominent AI:** **Plan C** — B's layout + a center "Ask AI"
  button reachable from every screen.

Pragmatic path: **ship B**, and if AI proves central, the center button of **C**
is a small, additive upgrade on top of B later.

> Tell me which plan (or hybrid) you want and I'll turn it into a phased,
> file-by-file implementation plan like `plan.md`.
