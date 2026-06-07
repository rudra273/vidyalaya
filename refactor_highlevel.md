# Vidyālaya — High-Level Refactor Plan (AI-First Repositioning)

> **Status:** strategic / high-level only. This sets direction, IA, and the big
> structural moves. A detailed file-by-file `plan.md` comes **after** you pick a
> direction here. Nothing implemented yet.

---

## 1. The repositioning (what actually changed)

The app's center of gravity moved. Stated priority is now:

| Rank | Pillar | What it is | Status today |
|---|---|---|---|
| **1 — primary** | **AI Learning** | Q&A (live), **Tutor agent** (coming), future agents | Q&A live; Tutor next |
| **2 — secondary** | **Interactive Learning** | Static/interactive tools: Math, Periodic Table, Diagrams, Timeline, Cosmulator, **Virtual Lab**, **Quizzes** | mixed live + soon |
| **3 — tertiary** | **Reading (books)** | Board-specific PDF textbooks | live, but **de-emphasize** |

Plus a **copyright-risk** flag on pillar 3: board PDFs are a future liability, so
the design must let books **shrink quietly** without breaking the app.

**Design consequence (the core principle):**

> The app is no longer "a reader with extras." It's an **AI learning companion**
> with a tools library, where books are *one* of several supporting resources.
> Navigation, Home, and even Progress must be re-centered on **AI + learning
> activity**, not on **pages read**.

---

## 2. What this breaks in the current app

- **Bottom nav** leads with `Home · My Books · Learn · Progress` — books are tab #2
  (prime real estate) and AI is buried as one card *inside* Learn. **Inverted.**
- **Home** hero = "Continue reading a book." That's now a tertiary action sitting
  in the most prominent slot. **Inverted.**
- **Progress** is 100% reading metrics (pages read, reading streak, daily *reading*
  goal, subject focus by *pages*). If reading is tertiary, this screen measures the
  wrong thing — it should measure **learning** (AI sessions, tools used, quizzes),
  not just pages.
- **Learn** is a flat 10-card list mixing the #1 pillar (AI) with the #2 pillar
  (tools) as equals. The two top pillars are tangled together.

So the refactor isn't cosmetic — it's an **IA inversion + a metric redefinition**.

---

## 3. Target information architecture

### Proposed bottom nav (4 tabs, AI-led)
```
🤖 Learn AI      🧭 Explore       📚 Library        👤 Me
 (primary)     (tools, #2)      (books, #3)    (profile+progress)
```

- **Learn AI (was the buried Q&A)** → now the **first tab + landing screen.**
  Hosts Q&A now; **Tutor** and future agents slot in as modes/cards here. This is
  the home of pillar #1.
- **Explore (was "Learn")** → the **interactive tools** library (pillar #2),
  de-tangled from AI and sectioned (Science / Math / History / Coming soon).
- **Library (was "My Books")** → reading (pillar #3), renamed and **demoted to
  tab #3**. Built so it can shrink/disappear with low blast radius (copyright).
- **Me (merge of Profile + Progress)** → your requested merge. One identity +
  settings + a **learning-activity** dashboard (see §4).

> Why "Learn AI" as the landing tab (not Home): a launcher-style Home competes with
> the AI-first message. Making AI the first thing you see *is* the repositioning.
> (If you'd rather keep a dashboard Home, see Option B in §6.)

### Where the Tutor & future agents live
Inside **Learn AI** as selectable agents/modes (Q&A · Tutor · …future). One reusable
chat shell, many agents → new agents ship as a config entry, **not** a new screen
or nav change. This is the single most important future-proofing decision.

---

## 4. Merging Profile + Progress → "Me"

You asked if these can merge — **yes, and it's the right move now**, because:
- Progress today is thin (3 stat cards + a reading goal + subject bars) and
  reading-centric, so it doesn't deserve a top-level tab once reading is tertiary.
- Profile is settings/identity. Together they form a natural "**Me**" space:
  *who I am + how I'm doing + my settings*.

**Proposed "Me" structure:**
- **Header:** avatar, name, class/board, plan badge.
- **My Learning (redefined metrics):** AI sessions, tools explored, quizzes taken,
  *and* reading — with the streak reframed as a **learning streak**, not a reading
  streak. (Reading metrics stay, but become one row among several.)
- **My Stuff:** Bookmarks · Notes · Timetable · Downloads.
- **Settings:** Classes/Board · Theme · Privacy · About · Auth (sign in/out).

This also gives the now-tertiary reading metrics a graceful home instead of a whole tab.

---

## 5. De-risking books (copyright)

Treat reading as a **swappable resource layer**, so legal pressure later = a small
change, not a rewrite:
- Confine all book/PDF surfaces behind the **Library** tab + the reader route.
- Keep "continue reading" *off* the primary surface (it lives in Library / Me).
- Make the Library tab **feature-flaggable** — one flag can hide the tab and its
  Home/Me entry points without dead links, leaving AI + tools fully functional.
- Future option the architecture should allow: per-board availability, or
  user-supplied/official-source books only. (Decide later; just don't hard-wire
  books into core flows now.)

---

## 6. Two directions to choose between

Both keep AI primary, tools #2, books #3, and merge Profile+Progress. They differ
only in whether the landing screen is the **AI** or a **dashboard**.

### Option A — "AI is the front door" (boldest, truest to the repositioning)
```
🤖 Learn AI   🧭 Explore   📚 Library   👤 Me
```
- App opens **into Learn AI.** No separate Home tab.
- Pros: maximally on-message; AI is unavoidable; cleanest 4-tab set.
- Cons: no neutral "dashboard" landing; opening straight into a chat may feel
  abrupt for a Class-5 kid the very first time (mitigate with an agent-picker
  landing state, not a blank chat).

### Option B — "Dashboard front door, AI one tap away" (calmer)
```
🏠 Home   🤖 Learn AI   🧭 Explore   👤 Me
```
- Keeps a **Home** dashboard (greeting, today's plan, "Ask AI" big CTA, jump back
  into last activity) → Learn AI is tab #2. **Library is demoted out of the bottom
  nav** entirely — reached from Home/Me (strongest copyright de-risk).
- Pros: gentle landing; Library fully removable; Home gives a daily reason to open.
- Cons: one more hop to AI than Option A; Home must earn its place (not a launcher).

> Both merge Profile+Progress into **Me**. The real fork is **A: open into AI** vs
> **B: open into a dashboard with AI as tab #2 and books pushed out of the nav.**

---

## 7. The big structural moves (independent of A/B)

1. **Invert the nav** — AI first, books demoted/renamed (`My Books`→`Library`).
2. **Split Learn into two pillars** — `Learn AI` (chat/agents) vs `Explore` (tools).
3. **Reusable AI agent shell** — Q&A + Tutor + future agents as modes, not screens.
4. **Merge Profile + Progress → "Me"**, and **redefine the metrics** from
   *reading* to *learning* (AI/tools/quizzes + reading as one part).
5. **Make Library feature-flaggable** and keep books out of primary flows.
6. **Componentize** the inlined card walls (`learn_screen.dart`,
   `quick_actions_grid`) into a reusable `FeatureCard` data-driven system.
7. **Class-5 UX pass** — big targets, icon+label, warm rounded language, ≤4 tabs.

---

## 8. Open questions before the detailed plan

1. **Landing screen: Option A (open into AI) or B (dashboard Home, AI tab #2)?**
2. **Library in bottom nav, or pushed out** (reached from Home/Me)? (B implies out.)
3. **Progress metrics:** keep reading stats *and add* learning stats, or fully
   replace reading-centric metrics with learning ones?
4. **Tutor scope at launch:** all subjects, or pilot 1–2? (affects Learn AI's
   agent-picker design.)
5. **Books de-risk now or later:** add the feature flag in this refactor, or just
   keep the architecture ready and flip it when needed?

> Answer §8 (even roughly) and I'll write the detailed, phased, file-by-file
> `plan.md` for the chosen direction.

---

## 9. Recommendation

**Option B**, with Library pushed out of the bottom nav:
- It delivers the AI-first message (AI is a prominent tab + the Home CTA) **and**
  gives the strongest copyright de-risk (books aren't even in the nav).
- A gentle dashboard Home is safer for Class-5 first-run than opening into a chat.
- Merge Profile+Progress into **Me**, and **add** learning metrics alongside the
  existing reading ones (don't throw away data you already collect — just reframe
  the headline streak as a *learning* streak).

If you want to be aggressive and fully commit to AI-first, **Option A** is the
purer statement — open straight into Learn AI.
