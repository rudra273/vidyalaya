# Vidyakalp — Next Release Plan (high level)

**Status:** Draft — iteration 1 (owner + Claude) done; next: second opinion.
**Last updated:** 2026-10-16

**How this plan is being made**

1. **My Thought** — the product owner's initial ideas.
2. **Decisions** — what we agreed while discussing.
3. **Claude's Thought** — app audit, principles and a 6-month roadmap with
   feature IDs.
4. **Second opinion** — sections 1–3 reviewed by another AI.
5. **Final plan** — written after a couple of iterations.

---

## 1. My Thought (product owner)

> Initial input, recorded as given. Lightly edited for spelling only.

### Where we are

The app is in production now. The app is good and has a lot of content. Now
let's plan for the next release. We want many upgrades in the next release, so
we need a high-level features plan first. As project manager, I want a strong
upgrade for the next release.

First, go through the app and find what is missing: missing features plus new
features that can be added.

From my side I want:

### 1. More AI agents for different work

Agents are backend names; a user will not see them in the UI.

- Math agent
- English speaking agent
- AI Tutor agent

### 2. Integrate AI into the Explore section

Right now the Explore section is limited. Everything is limited, from the
quizzes to the diagrams. So I want to use AI for dynamic content generation.
Some of these features will be only for Pro users.

Example: AI will generate more quizzes.

### 3. A Test feature where a student can prepare for exams (this can be an agent)

- It can generate MCQs for any chapter, and any user can take an exam there.
- The student can see the live score.
- It should work subject-wise or chapter-wise. AI should prepare the questions.
- There should be a dynamic checkbox list (which the AI creates), and the test
  is built from the user's selection.
- At the end of the exam it shows the rating.
- Initially, let's plan for MCQs only; we will upgrade later.
- On the Home screen we can add something like "Take a test".

### 4. Engagement — the most important one (open question)

I don't know yet what to put here. I want something that makes the student come
back to the app every day, or share the app with other users. Something fun or
interesting — not just increasing credits when sharing the app with someone
else (that is obviously a good one and we will add it).

Can we do something to engage the student here? Ideas:

- A rank board that shows who is in the top ranks.
- Every week we conduct a test and show who topped it.
- Groups / organizations that students can join. Students can't create them —
  teachers create them and add students. This will be the biggest feature, so
  it is planned for a later release (not now). Added here so we don't forget.

---

## 2. Decisions (from our discussion, 2026-10-16)

1. **One release per month, planned for the next 6 months.** Not one big
   release — we can't rush these things.
2. **Most features are free, with daily limits.**
3. **Some features can't be entirely free; they are for Plus accounts.** For
   testing, the owner makes some accounts Plus by hand. Everyone else gets a
   **"Request Plus"** button: each tap sends the owner a request, which also
   shows how many students are interested.
4. **Subscription (payments) comes last**, not now.
5. **SCERT tests depend on re-ingesting the SCERT books with chapters.** That
   must be done before SCERT tests go live.
6. **Leaderboards are global for now** — one list, no separate boards.
7. **AI keys in production:** free users use the free Gemini key; paid users
   use the paid OpenRouter key. Gemini moves to a paid key in the future.
8. **Teacher groups** (from My Thought) are for a later release, outside these
   6 months.
9. **Weekly Championship ranking is global:** each class gets its own paper,
   and everyone is ranked together in one list by score % and then time.
10. **Weekly Championship runs on Sunday, 10 am – 8 pm IST.**
11. **Invite reward:** both students get bonus AI questions, with a cap of 10
    rewarded invites per student.

---

## 3. Claude's Thought

### 3.1 What the app is missing today (audit, 2026-10-16)

**Foundations**

- No notifications (push or local).
- No product analytics or crash reporting; only the backend's
  `learning_events`.
- No payments: Plus and Pro are assigned by an admin.
- Progress lives only on the phone (streak, scores, notes, bookmarks,
  highlights), and Android backup is off
  (`android/app/src/main/AndroidManifest.xml:7`). A new phone or a reinstall
  loses everything, and a phone-only streak can't back a fair leaderboard.
- No deep links or install attribution.
- No microphone, speech-to-text or text-to-speech.

**Product gaps**

- The PDF reader isn't connected to the AI.
- AI answers can only be copied (no save to notes, no share).
- Quizzes are grouped by subject and class band, not by textbook chapter;
  there is no exam mode or test history.
- AI Tutor is a scripted preview.

**Bugs and risks**

- **Bug:** the subject bars in My Learning are always empty. Pages are saved
  under subject keys such as `maths`
  (`lib/screens/pdf_viewer/pdf_viewer_screen.dart:89`) but read as
  `Mathematics`, `Science`, … (`lib/providers/progress_provider.dart:47`).
- The share message names only SCERT Odisha
  (`lib/data/services/app_share.dart:15`).
- The daily quota is counted per agent
  (`vidyalaya-ai/src/vidyalaya_ai/subscriptions/plans.py:12`), so every new
  agent would add a full extra allowance.
- Textbook search filters only by board, class and subject
  (`vidyalaya-ai/src/vidyalaya_ai/rag/retrieval.py:73`). NCERT text is tagged
  by chapter; SCERT text only by page.
- **Free Gemini key:** free users' answers *and every user's search
  embeddings* (Plus too — embeddings always use Gemini) go through it, so its
  free-tier caps are the ceiling for all AI questions. The unpaid tier's terms
  also let Google use the content we send to improve its products.

### 3.2 Principles

1. **One test engine, reused.** A server-side question bank, test builder and
   scoring power Take a Test, Explore quizzes, Daily 5, the Weekly
   Championship and friend challenges — and teacher-assigned tests later.
2. **Write questions once, check them, store them, reuse them.** A batch job
   (the backend "test agent") runs on the paid OpenRouter key across the 812
   chapters of the AI-supported classes (SCERT 7–10, NCERT 6–9). Students
   taking tests cost no AI calls, which matters while free users are on the
   free Gemini key.
3. **Static content stays the free, fast, offline base;** AI adds "more" and
   "explain".
4. **Agents are backend routing.** The app shows tasks ("Ask", "Learn this
   chapter", "Practice speaking"); the backend picks the agent by screen and
   subject with simple rules.
5. **The loops that bring students back stay free:** Daily 5, Weekly
   Championship, challenges and the leaderboard.
6. **Plus = higher limits + the long AI sessions** (Tutor, Speaking), which run
   on the paid key. "Request Plus" records which feature each request came
   from, so we know what students want before we set prices.
7. **Measure first.** Analytics ships in Month 1, so every later release is
   judged against a retention baseline.

### 3.3 Feature IDs

Four-digit IDs grouped by area. An ID never changes, even when its month
moves.

| Range | Area |
|---|---|
| 1xxx | Platform |
| 2xxx | AI agents (backend names) |
| 3xxx | Tests |
| 4xxx | Explore + AI |
| 5xxx | Engagement and growth |
| 6xxx | Content |
| 7xxx | Schools and teachers (later) |
| 9xxx | Subscription |

Sizes are rough, for one developer: **S** = a few days, **M** = about a week,
**L** = two weeks or more.

### 3.4 Six-month roadmap

Calendar months are indicative. One theme per month. **Stretch** items move to
the next month first if a month runs long; Subscription always stays last.

| Month | Theme | Features |
|---|---|---|
| 1 (≈ Nov 2026) | Foundations & quick wins | 1001, 1002, 1003, 1004, 1006, 1008, 4001, 4002 · stretch 4003 · 6001 starts |
| 2 (≈ Dec 2026) | Take a Test | 3001, 3002, 3003, 3004, 3005, 3006, 4004 |
| 3 (≈ Jan 2027) | Daily 5 & global leaderboard | 1005, 5001, 5002, 5003 · stretch 4005 |
| 4 (≈ Feb 2027) | Weekly Championship & sharing | 1007, 5004, 5005, 5006, 5007 · groundwork 2001 |
| 5 (≈ Mar 2027) | Math agent & AI Tutor | 2001, 2002, 2003 · stretch 4007 |
| 6 (≈ Apr 2027) | English speaking & Plus subscription | 2004, 9001 · stretch 4006 |

**Why this order**

- The test engine (Month 2) unlocks Daily 5, the Weekly Championship and
  friend challenges, so it comes first. Agents come later because nothing else
  depends on them.
- It follows the school year (dates typical, not fixed): tests before revision
  season, Daily 5 in January, weekly mock-exam championships in February, the
  Tutor for March revision, English speaking as summer holidays start, and
  subscription with the new school year in April.

**Critical path:** 6001 → 3001 → 3002 → 3003 → 3004 → 5001 / 5004 / 5006, and
1005 → 5003 → 5004.

**Heaviest months:** 2 and 6. 3001 can start at the end of Month 1 to ease
Month 2.

### 3.5 Features by month

#### Month 1 — Foundations & quick wins

Goal: measure the app, reach students with reminders, add limits and Plus
requests, and connect pieces that already exist.

| ID | Feature | Free / Plus | Depends on | Size |
|---|---|---|---|---|
| 1001 | Analytics, crash reporting and remote switches | — | — | S |
| 1002 | Notifications and daily study reminder | — | — | M |
| 1003 | Per-feature daily limits | — | — | M |
| 1004 | Request Plus | — | 1003, 1002 | S |
| 1006 | Audit bug fixes | — | — | S |
| 1008 | AI capacity guard | — | — | S |
| 4001 | Ask about this page (reader) | Free, limited | 1003 | S |
| 4002 | "Explain this" buttons | Free, limited | 1003 | S |
| 4003 | Save and share AI answers (stretch) | Free | — | S |
| 6001 | SCERT re-ingestion with chapters (starts; runs into Month 3) | — | — | L |

- **1001** — Firebase Analytics, Crashlytics and Remote Config. Track D1/D7/D30
  retention, daily and weekly active students, and feature use. Remote
  switches roll features out gradually and turn an AI feature off if a key
  runs out.
- **1002** — Push (Firebase Cloud Messaging) plus local scheduled
  notifications. A daily study reminder at a time the student picks, and
  notification settings. Ask for permission at a useful moment, not on first
  launch.
- **1003** — Replace the per-agent quota with a daily allowance per feature per
  plan (AI questions, tests, Tutor, Speaking). Show "X left today". When a
  limit is reached, show a sheet with "Request Plus".
- **1004** — "Request Plus" (sign-in required) on the limit sheet, on Plus-only
  features and in Profile. One request per student, tagged with the feature
  that triggered it. Admin panel: list, total, count by feature, and one-click
  approve (assigns Plus through the existing admin flow), after which the
  student gets a notification.
- **1006** — Fix the My Learning subject bars; add NCERT to the share message.
- **1008** — Admin-panel view of today's free-Gemini-key use (chat and
  embeddings) against its caps, an alert close to the cap, and a friendly "AI
  is busy — try again later" message instead of an error. Its numbers trigger
  the Gemini upgrade (backlog 1010).
- **4001** — In the PDF reader, "Ask about this page" sends the current page as
  an image to the existing AI chat.
- **4002** — "Explain" on wrong quiz answers, the warm-up, diagram parts,
  elements, timeline events and lab results. It opens the AI chat already
  filled in.
- **4003** — Save an AI answer to Notes; share it.
- **6001** — Re-read the SCERT books with the image-reading pipeline so every
  chunk knows its chapter. Order: Class 10 → 9 → 8 → 7 (board-exam class
  first). Each class goes live only after it passes evaluation.

Success: crash-free sessions ≥ 99%; a retention baseline recorded; Plus
requests counted by feature.

#### Month 2 — Take a Test

Goal: chapter-wise and subject-wise MCQ tests built from the student's own
textbook.

| ID | Feature | Free / Plus | Depends on | Size |
|---|---|---|---|---|
| 3001 | Chapter-scoped textbook content | — | 6001 (SCERT only) | S |
| 3002 | Question bank (backend "test agent") | — | 3001 | L |
| 3003 | Test service | — | 3002 | M |
| 3004 | Take a Test | Free, limited; Plus more | 3003, 1003 | L |
| 3005 | Report a question | Free | 3002, 3004 | S |
| 3006 | SCERT classes join tests | Free, limited | 6001, 3004 | S |
| 4004 | More quizzes from my textbook (Explore) | Free, limited | 3003 | S |

- **3001** — Fetch a chapter's text by chapter number, with no search needed.
  Ready for NCERT 6–9 now; SCERT after 6001.
- **3002** — A batch job on the paid OpenRouter key writes MCQs for every
  chapter at three difficulty levels: question, four options, the answer and
  an explanation, in the book's language. A second pass checks that exactly
  one option is correct, that the chapter text supports it, and that the
  language is right. Questions are stored on the server and topped up when a
  chapter runs low.
- **3003** — Builds a test from the chosen chapters, number of questions and
  difficulty; scores it on the server; keeps attempt history. The backend
  says which classes have tests, so new classes switch on without an app
  update.
- **3004** — A "Take a test" card on Home (also reachable from AI and
  Explore). Subject → chapter checklist ("Select all" = whole subject) → 10,
  20 or 30 questions → difficulty → mode:
  - **Practice:** live score and an explanation after each question.
  - **Exam:** timer; score revealed at the end.

  Results: score, star rating, time taken, strong and weak chapters, review
  with explanations, "Ask AI about this question", "Retry my mistakes" and
  test history.
- **3005** — Students flag a wrong or unclear question. After several reports
  it is hidden and goes to an admin review list.
- **3006** — SCERT classes switch on one by one as 6001 finishes each class.
- **4004** — Explore → Quizzes gains "More from my textbook" chapter quizzes
  from the bank, next to the existing question sets.

Launch scope: NCERT 6–9 plus any SCERT classes already re-ingested. Classes
without a bank keep the existing quizzes. MCQ only (other types: backlog
3007).

Success: share of weekly active students who take a test; test completion
rate; reported-question rate.

#### Month 3 — Daily 5 & global leaderboard

Goal: a two-minute daily habit, and a reason to check your rank.

| ID | Feature | Free / Plus | Depends on | Size |
|---|---|---|---|---|
| 1005 | Server-side progress and XP | — | — | M |
| 5001 | Daily 5 | Free | 3002, 1005, 1002 | M |
| 5002 | Streak rewards | Free | 1005, 1002 | S |
| 5003 | Global leaderboard | Free | 1005 | M |
| 4005 | Revision notes and flashcards (stretch) | Free | 3001 | M |

- **1005** — Activity, streak and XP are kept on the server (built on the
  existing learning events) and come back after a reinstall or on a new phone.
  Only server-checked actions (tests, Daily 5, championship, AI questions)
  earn full leaderboard XP; reading, games and tools keep the streak alive and
  earn a small, capped amount.
- **5001** — Five questions a day from the bank, the same set for everyone in
  the same board and class that day, about two minutes. Classes without a bank
  use the existing quiz questions.
- **5002** — Streak freeze, 7/30/100-day badges, and an evening "streak at
  risk" reminder.
- **5003** — One global list: this week's XP (resets every Monday) and
  all-time. Shows the top 50, your rank, and the students just above you. Only
  first name, initial and app avatar are shown; students can opt out in
  Settings. Signed-out students are invited to sign in to join.
- **4005** — A one-page revision note and a flashcard set per chapter, written
  once by the batch job, stored, and readable offline.

Success: D7 retention against the Month 1 baseline; Daily 5 participation;
share of students with a 7-day streak.

#### Month 4 — Weekly Championship & sharing

Goal: one weekly event, and sharing that carries the app with it.

| ID | Feature | Free / Plus | Depends on | Size |
|---|---|---|---|---|
| 1007 | Deep links and install referral | — | — | M |
| 5004 | Weekly Championship | Free | 3003, 5003, 1002 | M |
| 5005 | Share cards and certificates | Free | 1007, 3004, 5004 | M |
| 5006 | Challenge a friend | Free | 1007, 3003 | M |
| 5007 | Invite rewards | Free | 1007, 1003 | S |

- **1007** — App Links so shared test, challenge and invite links open the
  right screen; Play Install Referrer to credit invites.
- **5004** — One paper per class each week, open Sunday 10 am – 8 pm IST, one
  attempt, scored on the server, with questions and options shuffled. Everyone
  is ranked in one global list by score % and then time. Results ("you beat X%
  of students") arrive by notification.
- **5005** — Image cards for test results, rank and streak milestones, plus
  certificates for the weekly top performers. Ready for WhatsApp, with the app
  link.
- **5006** — Share a test link; the friend takes the same questions; both see a
  side-by-side result.
- **5007** — When an invited friend signs in and finishes a first test, both
  students get bonus AI questions. Up to 10 rewarded invites per student.

Groundwork: the backend part of 2001 (agent framework) can start this month to
ease Month 5.

Success: championship participants; shares per active student; installs from
invite and challenge links.

#### Month 5 — Math agent & AI Tutor

Goal: better maths answers for everyone, and guided chapter lessons for Plus.

| ID | Feature | Free / Plus | Depends on | Size |
|---|---|---|---|---|
| 2001 | Agent framework | — | 1003 | M |
| 2002 | Math agent | Free, limited | 2001 | M |
| 2003 | AI Tutor agent | Plus (1 free sample lesson) | 2001, 3001, 3002, 6001 | L |
| 4007 | Python "explain my error" (stretch) | Free, limited | 1003 | S |

- **2001** — Each agent is a backend channel with its own prompt, tools and
  model. Routing uses simple rules on screen and subject (no extra AI call).
  Each agent's use counts toward the 1003 limits, and each agent gets its own
  evaluation set.
- **2002** — Maths questions go to this agent. It checks arithmetic and algebra
  with a calculation tool instead of guessing, writes step-by-step solutions
  with formatted maths, and can "check my working" from a photo to find the
  step that went wrong.
- **2003** — "Learn this chapter": the tutor plans 4–6 ideas from the chapter,
  teaches one at a time, asks a check question after each, moves on when the
  student gets it right, and ends with a short test from the bank. It replaces
  the current preview screen and runs on the paid key.
- **4007** — In the Python playground, explain an error message and give a
  hint, not the answer.

Success: maths accuracy on the evaluation set; tutor lesson completion rate;
Plus requests from the Tutor.

#### Month 6 — English speaking & Plus subscription

Goal: spoken-English practice, then paid Plus to close the plan.

| ID | Feature | Free / Plus | Depends on | Size |
|---|---|---|---|---|
| 2004 | English speaking agent | Plus (1 free sample session) | 2001 | L |
| 4006 | Vocabulary "use it in a sentence" (stretch) | Free, limited | 1003 | S |
| 9001 | Plus subscription | — | 1001, 1003, 1004 | L |

- **2004** — Spoken English practice. The phone turns speech into text and
  reads replies aloud, so no audio leaves the phone or is stored. Role-plays
  such as introducing yourself, at a shop or an interview. After each turn:
  the corrected sentence and a short tip, explained in Odia or Hindi when
  asked. Pronunciation scoring comes later (backlog 2005).
- **4006** — The student writes a sentence using a vocabulary word; the AI
  checks it and suggests a better version.
- **9001** — Google Play Billing for Plus (monthly and yearly). Purchases are
  verified on the server; renewals and cancellations are handled; purchases
  can be restored. "Request Plus" becomes "Get Plus". Prices are informed by
  the 1004 request data; students who requested Plus get a launch offer;
  hand-granted test accounts keep Plus until a set date.

Success: Plus conversion rate; speaking sessions per Plus student.

### 3.6 Free and Plus limits (draft)

Numbers are placeholders, to tune with Month 1 data.

| Daily allowance | Free | Plus |
|---|---|---|
| AI questions (Ask, Explain, Ask about this page, Math, sentence checks) | today's free cap | today's Plus cap |
| Custom tests (Take a Test, textbook quizzes) | 3 | 20 |
| Daily 5, Weekly Championship, challenges, leaderboard | always free | always free |
| AI Tutor | 1 sample lesson | 3 lessons |
| English speaking | 1 sample session | 15 minutes |

### 3.7 Risks and how the plan handles them

- **Free Gemini key caps.** Free users' answers and every user's search
  embeddings depend on it. Tests and Daily 5 come from the stored bank (no AI
  calls); limits (1003) and the capacity guard (1008) protect it; the long AI
  sessions are Plus-only on the paid key; 1010 upgrades Gemini when usage says
  so.
- **Children's privacy.** Most students are minors. Leaderboards show first
  name, initial and avatar only, with an opt-out; there is no chat between
  students. Get a legal check of the parental-consent rules in India's DPDP
  Act before 5003 goes public.
- **SCERT re-ingestion takes time.** Class 10 goes first; tests switch on class
  by class (3006).
- **Odia question quality.** Each class passes an evaluation before its
  questions go live, and students can report questions (3005).
- **Cheating in the Weekly Championship.** Server timing, one attempt,
  shuffled questions and options, and a time limit per question.
- **Capacity.** Months 2 and 6 are the heaviest; stretch items move first.

### 3.8 Backlog (after these 6 months)

| ID | Feature |
|---|---|
| 1009 | Cloud sync for notes, bookmarks and highlights |
| 1010 | Gemini paid key — when 1008 shows sustained use near the free caps; also ends the unpaid tier's data-use terms |
| 2005 | Pronunciation scoring in speaking practice |
| 3007 | More question types: true/false, fill in the blank, short answers marked by AI |
| 4008 | Mastery map and a personal daily plan from weak chapters |
| 5008 | Weekly progress report for parents (WhatsApp) |
| 5009 | Leagues (small groups with promotion and relegation) |
| 6002 | AI support for SCERT classes 1–6 and NCERT Class 10 |
| 7001 | Teacher groups: teachers create groups, add students and assign tests. From Month 2 the test engine and leaderboard leave room for a group, so this plugs in later. |

### 3.9 Open questions for iteration 2

None open. Championship ranking, time window and invite reward were settled
(Decisions 9–11). The exact number of bonus AI questions per invite is tuned
with Month 1 data, like the other limits in 3.6.

---

## 4. Second opinion

_To be added._

---

## 5. Final plan

_To be written after the iterations._
