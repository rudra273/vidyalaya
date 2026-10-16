# Vidyakalp — Next Release Plan (high level)

**Status:** Draft — iteration 3. Section 5 merges sections 1–4 and adds new
suggestions; the owner writes the final plan in section 6.
**Last updated:** 2026-10-16

**How this plan is being made**

1. **My Thought** — the product owner's initial ideas.
2. **Decisions** — what we agreed while discussing.
3. **Claude's Thought** — app audit, principles and a 6-month roadmap with
   feature IDs.
4. **Second opinion (Codex)** — sections 1–3 reviewed by another AI.
5. **Draft final plan** — sections 1–4 merged by Claude, with suggestions.
6. **Final plan** — written by the owner from the draft.

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

_Historical iteration 1 decisions. Section 4 supersedes conflicts, including
Championship ranking and automatic question generation._

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

_Preserved iteration 1 proposal. Use section 4 for the current agreed draft;
its admin-authored question bank replaces the automatic generation below._

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

## 4. Second opinion — (Codex Thought)

**Status:** Agreed direction for planning; implementation has not started from
this document. This section supersedes conflicting proposals in sections 2–3,
which remain as discussion history. Section 5 is reserved for the final plan.

### 4.1 Decisions and changes from iteration 1

- A team will deliver monthly releases, with parallel work across platform,
  mobile, content and admin. This is not a single-developer estimate or one
  large release. Months are targets; dependencies and release gates determine
  what can ship.
- The primary learning loop is **take a test → understand mistakes → practise
  weak areas → see improvement → return tomorrow**. Competition supports it.
- **Questions are admin-created and explicitly reviewed and approved.** The
  backend must not autonomously generate or publish questions. AI drafting is
  optional, initiated by an admin, and produces drafts only. Manual authoring
  is a complete supported workflow.
- The admin panel and editorial question bank are core Month 1–2 deliverables.
  They replace the automatic batch-generation proposal in 3002.
- Start with one complete board/class/subject pilot, selected by student demand
  and content readiness, then expand reviewed coverage. Do not generate or
  promise all 812 chapters upfront.
- Keep one global Championship event hub, but rank participants within the
  same board/class/paper cohort. Percentages from different papers are not
  comparable. This replaces Decision 9's cross-class score ranking.
- Global weekly XP rankings use equal, capped competitive opportunities for
  Free and Plus. Extra paid usage and referral bonus usage do not earn extra
  competitive XP. Personal learning progress still records all valid activity.
- Move a simple version of weak-chapter practice (4008) into Month 3. Launch
  the weekly XP leaderboard first; consider all-time rankings after feedback.
- Most features remain free with limits. Manually granted Plus and Request
  Plus support testing before billing. Interest requests inform packaging,
  but do not establish willingness to pay.
- **Payments and subscription activation (9001) are the final implementation
  and release step.** If earlier milestones slip, billing moves later too.
- Retain the Sunday 10 am–8 pm IST Championship window, the cap of 10 rewarded
  invites per student, and teacher groups outside this six-month scope.

### 4.2 Content ownership and publishing rules

| Experience | Question selection and ownership |
|---|---|
| Weekly Championship / official mock test | Admin selects every question and publishes the exact paper |
| Daily 5 | Admin schedules a set, or explicitly enables selection from the approved bank |
| Custom chapter practice | Backend selects approved questions matching the student's choices |
| Retry my mistakes | Backend selects previously missed, eligible approved questions |
| AI Tutor | Dynamic teaching; formal scored checks use approved questions |

Automatic selection is allowed; automatic question creation and publication
are not. Personalized Daily 5 can vary by student, so competitive XP rewards
capped completion rather than comparing accuracy on different sets.

Editorial lifecycle: **draft → review → approved → included in a published
or scheduled test**. Questions can also be withdrawn. Admins preview the actual
student rendering before approval, including Odia, equations and images.
Published question and paper versions are retained with attempts. Edits create
new versions; they must not silently alter active tests or historical scores.
Corrections require an explicit, audited decision about affected results.

Each question contains its text, four options, correct answer, explanation,
language, estimated difficulty, curriculum mapping and textbook evidence/reference.
Chapter identity includes board, class, subject/book and edition, not just a
chapter number. Difficulty labels are estimates until attempt data validates them.
AI checking can assist reviewers but cannot replace editorial approval.

### 4.3 Feature IDs and responsibility

Existing feature IDs remain stable. 3002 now means the **admin-authored question
bank**, not an autonomous test agent. 4008 moves forward from the backlog.
The new **8xxx** range covers admin and editorial operations:

| ID | Admin feature |
|---|---|
| 8001 | Admin access, author/reviewer/administrator roles and audit history |
| 8002 | Curriculum and content-availability management |
| 8003 | Question editor and bank, including image and maths support |
| 8004 | Review, approval, versioning and student-view preview |
| 8005 | Test/paper builder, preview, scheduling and publication |
| 8006 | Bulk question import with validation and draft preview |
| 8007 | Reports, corrections, withdrawal and affected-result review |
| 8008 | Daily practice, revision content, announcements and notification templates |
| 8009 | Championship scheduling, attempt review, results and certificates |
| 8010 | Tutor objectives, lesson outlines and approved check-question management |
| 8011 | Subscription support and entitlement administration |

Editable content includes test instructions, explanations, revision notes,
flashcards, announcements, relevant Home banners and notification templates.
Ordinary interface labels stay in app localization files. Content management
expands with each feature; this is not a general-purpose app layout editor.

### 4.4 Timeline overview

| Target | Theme | Student outcome | Release gate |
|---|---|---|---|
| Month 1 — Nov 2026 | Foundations, editorial admin and pilot | Clear AI limits, reliable progress and a small chapter-test pilot | Approved pilot content and reliable scoring |
| Month 2 — Dec 2026 | Full tests and content expansion | Chapter/subject practice, exam mode, explanations and history | Reviewed coverage and resilient attempt handling |
| Month 3 — Jan 2027 | Daily habit and improvement | Daily 5, weak-area practice, synced progress and weekly XP | Verified progress and equal competitive opportunities |
| Month 4 — Feb 2027 | Competition and sharing | Championship, friend challenges, cards and invites | Reviewed common papers, fair rankings and working links |
| Month 5 — Mar 2027 | Math and guided learning | Checked maths assistance and chapter Tutor | Agent evaluations and approved lesson content |
| Month 6 — Apr 2027 | Speaking, then paid Plus | Speaking practice, followed by paid subscriptions | Validated quality/costs, then billing readiness |

### 4.5 Month 1 — Foundations and a complete test pilot

| IDs | Deliverable | Dependencies |
|---|---|---|
| 1001 | Analytics, crash reporting and rollout switches | Event definitions |
| 1006 | Verify and fix audit bugs, including subject progress | Code verification of each finding |
| 1003 | Shared AI-question allowance; separate test, Tutor and Speaking limits | Existing entitlements and usage accounting |
| 1004 | Request Plus, source-feature interest tracking and manual approval | 1003, existing admin entitlement flow |
| 1008 | AI usage/cost visibility, capacity protection and graceful failure | Provider usage instrumentation |
| 1002 | Notification preferences, optional reminders and push infrastructure | Notification permissions and delivery setup |
| 4001 | Ask about this textbook page | Existing image chat, 1003 |
| 8001 | Admin roles and audit history | Existing authentication/admin system |
| 8002 | Boards, classes, subjects, books, editions, chapters and availability | Content inventory, 8001 |
| 6001 | SCERT ingestion in reviewed chapter batches | Inventory and chapter mapping |
| 3001 | Chapter lookup and coverage catalog | Chapter metadata; 6001 for SCERT |
| 8003, 3002 | Question editor and manually authored pilot bank | 8002, pilot chapter content |
| 8004 | Review, approval, preview and question versions | 8003, 8001 |
| 3003, 8005 | Core attempt/scoring service and basic admin paper builder | Approved pilot bank |
| 3004 | Pilot UI: select chapter, answer MCQs and view results | 3003, 1003 |

Platform, mobile, editorial and ingestion work can proceed in parallel. Assign
both engineering and content owners. Pilot acceptance requires reviewed
textbook evidence, correct scoring, usable language/rendering and submission
retries that neither lose nor duplicate attempts. Plus approval can appear in
account state before push delivery is ready; 1002 is not a hard dependency of
1004. The pilot can be limited to selected accounts while coverage grows.

### 4.6 Month 2 — Full tests and stronger editorial operations

| IDs | Deliverable | Dependencies |
|---|---|---|
| 3002 | Expand approved coverage in prioritized subjects/classes | Successful pilot, content owners and chapter coverage |
| 8006 | Template-based bulk import, validation and preview into drafts | 8003, 8004 |
| 8005 | Full paper builder: questions, order, sections, duration, marks, preview and publication | Approved bank, 3003 |
| 3003 | Save/resume, reliable retries and fixed question versions per attempt | Core test service |
| 3004 | Chapter checklist, question count, difficulty, practice/exam modes | Sufficient approved bank, 3003 |
| 3004 | Explanations, history, chapter breakdown and retry mistakes | Completed attempts |
| 3005, 8007 | Student reports, editorial review, withdrawal and explicit score correction | Question versions and attempt history |
| 3006 | Enable SCERT classes as reviewed content is ready | 6001, 3002, 3004 |
| 4004 | Explore textbook quizzes from the same bank | 3003 |
| 4002 | Explain wrong answers and Explore items through AI | Context handoff, 1003 |
| 4003 | Save and share AI answers | Existing notes and sharing flows |

Practice reveals answers after each question; exam mode reveals them at the
end. Enforce that distinction on the server. Availability is driven by approved
coverage: do not advertise a full subject test when only a few chapters are
ready. Reports enter review; raw report counts alone do not determine correctness.

### 4.7 Month 3 — Daily habit and visible improvement

| IDs | Deliverable | Dependencies |
|---|---|---|
| 1005 | Server-side progress, streaks and verified XP | Activity definitions, test events and idempotent recording |
| 4008 | Initial weak-chapter tracking and targeted practice | Test history, chapter mapping and approved bank |
| 8008 | Daily-set scheduling, revision content and editable announcements/templates | 8001, approved content workflows |
| 5001 | Daily 5, including personalized revision | 3002, 1005, initial 4008, 8008 |
| 5002 | Milestones, freezes and optional reminders | 1005; 1002 for reminders |
| 5003 | Weekly global XP leaderboard with equal earning caps | 1005, competition rules and public-profile review |
| 4005 | Reviewed chapter notes and flashcards, available offline | 3001, 8008, editorial approval |

Start with observable chapter performance, not a claim of scientifically
measured mastery from a handful of answers. Keep competitive XP separate from
personal activity totals. Confirm student identity/display and privacy rules
before public rankings; first-name display alone is not the complete review.

### 4.8 Month 4 — Competition and growth

| IDs | Deliverable | Dependencies |
|---|---|---|
| 1007 | App links, challenge links and install-referral handling | Routing and hosted link destinations |
| 8009 | Admin event scheduling, cohort/paper selection, attempt rules and results publication | 8005, 3003, audit history |
| 5004 | Sunday Championship, one attempt, rankings within the same paper cohort | 8009, reviewed papers and competition rules |
| 5005 | Share cards and milestone/top-performer certificates | Results, 8009; 1007 for actionable links |
| 5006 | Friend challenges using the same approved question set | 3003, 1007 |
| 5007 | Invite rewards after a qualifying first test | 1007, 1003, verified completion and duplicate prevention |
| 2001 | Begin shared agent configuration and evaluation groundwork | Existing agent implementation, 1003 |

Admins choose every Championship question. The backend handles scheduling,
attempt enforcement and scoring. Use server timing and a defined tie policy;
shuffling is helpful but does not establish cheating prevention. Admins review
flagged attempts and audit any exclusion or score adjustment before final
results/certificates. Questions and explanations should not be released early
in a way that undermines the active event. Referral rewards are issued once
per qualifying referral and do not increase competitive XP.

### 4.9 Month 5 — Math and guided learning

| IDs | Deliverable | Dependencies |
|---|---|---|
| 2001 | Shared agent routing, configuration, usage accounting and evaluations | Current agent system, 1003 |
| 2002 | Math assistance with calculation tools and worked solutions | 2001, maths evaluation set |
| 2002 | Check my working from a photo | Image input and evaluated maths workflow |
| 8010 | Admin learning objectives, lesson outlines and check-question selection | 8002, 8004, chapter content |
| 2003 | Guided chapter Tutor, checks and final practice | 2001, 3001, 3002, 8010 |
| 4007 | Python error explanation and hints | Playground context, 1003 |
| 2004 | Speaking prototype and device/language testing | Speech implementation choice, 2001 |

Extend the existing agent system rather than creating a second framework.
Tutor availability follows individual chapter readiness, not completion of
all SCERT ingestion. Support pause/resume, alternative explanations and
revisiting concepts when a student struggles. Formal scored checks use the
approved bank. Verify the speech implementation before promising on-device
processing or claiming no audio leaves the phone.

### 4.10 Month 6 — Speaking, then payments as the final step

| Order | IDs | Deliverable | Dependencies |
|---|---|---|---|
| 1 | 2004 | English speaking practice, role-plays and supportive corrections | Speech prototype, 2001, metering and quality evaluation |
| 2 | 4006 | Vocabulary sentence practice | 1003, evaluated feedback |
| 3 | — | Validate operating costs, free/Plus packaging and support flows | Usage across AI, tests, Tutor and Speaking |
| **4 — final** | **9001, 8011** | **Payment integration, paid Plus activation and billing administration** | **Earlier release gates, stable entitlements, validated packaging and purchase lifecycle verification** |

Use the payment method appropriate to each supported distribution platform;
Android starts with Google Play Billing as proposed in iteration 1. Include
server verification, restoration, renewal/cancellation, refunds/revocations,
and defined expiry for manually granted Plus. Admins can inspect billing and
entitlements and make audited authorized grants; provider billing records
remain the source for purchase status. Request Plus becomes Get Plus only
when billing is ready. Billing must not be brought forward to fill time while
prerequisite learning features remain unfinished.

### 4.11 Dependencies, delivery and acceptance

Main dependency chains:

1. Curriculum + chapter content → admin question authoring → review/approval
   → test builder/service → student test experience.
2. Test history + approved bank → weak-area practice → personalized Daily 5.
3. Verified progress + equal competitive rules → weekly XP leaderboard.
4. Test service + admin-selected common papers → Championship → final results
   and certificates. Championship scoring does not depend on XP ranking.
5. Link infrastructure + test service → challenges and qualifying referrals.
6. Agent configuration + chapter content + admin lesson outlines → Tutor.
7. Validated feature quality/costs + stable entitlements → **payments last**.

Plan each release across platform/API, mobile, admin and editorial workstreams.
Assign owners and acceptance criteria to each feature before implementation.
Content preparation is a delivery dependency: every promised chapter needs
sufficient approved questions and a reviewer. If a gate fails, reduce that
release's coverage or move the feature; do not bypass approval to meet a date.

Measure crashes and retention first, then test completion and question reports,
returning practice participation and learning improvement, competition/sharing
participation, Tutor/Speaking completion and costs, and finally paid conversion.
Record baselines before setting numerical targets. Treat earlier audit claims
as findings to verify, not universally confirmed facts.

Remaining implementation choices include pilot scope, content owners, question
coverage targets, competitive XP rules, Championship tie handling, exact limits,
referral reward size and speech technology. They do not change the agreed
admin-controlled publishing model or the payments-last sequence.

Teacher groups, additional question types, pronunciation scoring, parent reports,
full mastery maps, all-time rankings and full notes/bookmark cloud sync remain
later scope unless explicitly reprioritized. Assess provider capacity and data
handling before each relevant launch; a provider upgrade need not wait for
student subscription billing.

---

## 5. Draft final plan (Claude, 2026-10-16)

**What this is.** Sections 1–4 merged into one plan, together with the owner's
decisions from the review discussion on 2026-10-16. Section 4 (agreed with
Codex) is the base. Every change from section 4 is listed in 5.4 as
**S1–S14**, so the owner can keep or drop each one when writing section 6.
Feature IDs are unchanged. New IDs: 1011, 1012, 1013 and 5012, plus later-list
items 5010, 5011 and 9002.

Three owner rules run through the whole plan:

1. **Paid AI only, textbook queries only.** Production AI uses paid keys,
   mainly through OpenRouter. Only textbook questions and textbook content go
   to the AI, never student personal data.
2. **Safe for children by design.** Every student is treated as under 18.
   Ranks are private, and no student's name is shown to other students.
3. **Every blocker gets a way through.** When a risk appears, the plan names a
   solution and schedules it instead of stopping the feature.

### 5.1 The plan on one page

Goal for the six months: students open Vidyakalp every day to test themselves,
fix their mistakes and see their progress. Competition and sharing bring
friends in. Paid Plus comes last.

Core loop: **take a test → understand mistakes → practise weak chapters → see
improvement → come back tomorrow.**

| Month | Theme | What students get | Gate to ship |
|---|---|---|---|
| 1 — Nov 2026 | Foundations and the editorial engine | Clear AI limits, Ask about this page, bug fixes; test pilot for selected accounts | Limits and Request Plus work; free users on the paid AI route |
| 2 — Dec 2026 | Take a Test | Chapter and subject tests, practice and exam modes, explanations, history; reminders with quiet hours; a report button on AI answers | Approved questions behind every test offered; no lost or doubled attempts |
| 3 — Jan 2027 | Daily habit | Daily 5, weak-chapter practice, streaks, your own weekly rank ("top 5%"), break reminders, progress kept on the server | Each action earns XP once; rank bands are correct |
| 4 — Feb 2027 | Competition and sharing | Sunday Championship, friend challenges, share cards, invites, parent progress card | Reviewed papers; tested ranking and tie rules; links open the right screen |
| 5 — Mar 2027 | Maths and guided learning | Math agent, AI Tutor (Plus) | Maths evaluation passed; approved lesson outlines |
| 6 — Apr 2027 | Speaking, parent consent, then paid Plus | English speaking (Plus), parent consent at sign-in, then the Plus subscription | Parent consent live by 13 May 2027; billing tested end to end |

### 5.2 The owner's ideas and where they are

| Idea (section 1) | In this plan | Month |
|---|---|---|
| Math agent | 2002 | 5 |
| English speaking agent | 2004 (prototype in Month 5) | 6 |
| AI Tutor agent | 2003 | 5 |
| Agents hidden from students | 2001 routes by screen and subject | 4–5 |
| AI in Explore; AI makes more quizzes | 4004 quizzes from the bank (AI drafts, admins approve — S5); also 4001, 4002, 4003, 4005, 4006, 4007 | 1–6 |
| Some features only for paying users | Plus: higher limits, Tutor, Speaking | 1, 5–6 |
| Test: MCQs by chapter or subject, live score, checkbox list, rating, "Take a test" on Home | 3001–3006 with admin tools 8001–8005. The checkbox list comes from the admin-managed chapter list | pilot 1, everyone 2 |
| Rank board | 5003 private weekly rank ("You're in the top 5%"); public list on hold | 3 |
| A weekly test with toppers | 5004 Championship; toppers get certificates they can share themselves | 4 |
| Rewards for sharing the app | 5007 invite rewards | 4 |
| A reason to come back every day | 5001 Daily 5, 5002 streaks, 4008 weak chapters, 5006 challenges | 3–4 |
| Teacher groups | 7001, after these six months | later |

### 5.3 Decisions

Carried forward from sections 2 and 4, plus the owner's decisions on this
draft.

1. One release a month for six months, built by a team working in parallel
   (API, app, admin, content). Months are targets; gates decide what ships.
2. Most features are free with daily limits. Plus = higher limits and the long
   AI sessions (Tutor, Speaking). Until billing, the owner grants Plus by hand
   and students tap **Request Plus**, tagged with the feature that prompted it.
3. **Payments (9001) are the last product step.** If earlier work slips,
   billing slips.
4. **Admins create and approve every question.** The backend never writes or
   publishes questions on its own. AI drafting is started by an admin and
   produces drafts only.
5. Start with one complete pilot (board + class + subject), then grow approved
   coverage. Never advertise coverage that isn't approved.
6. Agents are backend names only. The app shows tasks; the backend routes by
   screen and subject. Extend the existing LearnAssist agent rather than
   building a second framework.
7. Tests are MCQ only for now (other question types come later: 3007).
8. Weekly Championship: Sunday 10 am – 8 pm IST, one event for everyone, ranked
   within each board + class paper (replaces Decision 9).
9. **No public leaderboard for now.** Each student sees only their own weekly
   rank (for example "You're in the top 5%"), built from the same capped XP for
   Free and Plus. Paid use and invite bonuses never add competitive XP
   (replaces Decision 6).
10. Invite reward: bonus AI questions for both students, at most 10 rewarded
    invites per student.
11. Teacher groups (7001) come after these six months; the test engine and
    ranks leave room for groups.
12. Odia and Hindi are for study content only; app labels stay English.
13. **Production AI uses paid keys only**, mainly through OpenRouter. The model
    can change (Gemini now, maybe GPT or Claude later). Only textbook questions
    and textbook content go to the AI (replaces Decision 7).
14. **Every student is treated as under 18**, and every feature is safe by
    default (rules in 5.12).
15. **Parent consent and ads wait until after March 2027.** Parent consent at
    sign-in ships in Month 6 and must be live by 13 May 2027, when India's DPDP
    Rules require it. Ads, if any, come after that and are never personalised.
16. When a risk or blocker appears, the plan names a way through it instead of
    stopping the feature.

Narrowed by this draft: Decision 5 (SCERT tests wait for re-ingestion) — see
S6.

### 5.4 What this draft changes from section 4 (S1–S14)

**S1 — Paid AI route for everyone (owner decision; new 1011, Month 1).** Free
users move off today's free Gemini key onto paid keys through OpenRouter. The
model stays set in one place per plan, as `plans.py` already does, so moving to
GPT or Claude later is a configuration change. One rule keeps the promise that
no student data reaches the AI: send the question, the textbook content and the
chat so far, never names, emails or account IDs. When choosing the next model,
pick a provider whose terms allow apps used by students; Anthropic's, for
example, does when the app adds safeguards such as a child-safety system prompt
(see S14). Search embeddings still use the Gemini API; if they ever move, do it
during 6001 so the books are re-embedded only once. Paid answers cost money,
so 1003 limits and 1008 cost tracking matter more.

**S2 — Private ranks, and parent consent in April 2027 (owner decision; new
1012).** The public leaderboard is on hold. Each student sees only their own
rank, so no child's name is shown to anyone. India's DPDP Rules require
verifiable parental consent for users under 18 from 13 May 2027. This concerns
the app's own sign-in and profile data, not the AI. The way through is a short
parent-consent step at sign-in, built in Month 6, with the method confirmed
with counsel in March 2027 (flow in 5.11). Nothing on this happens before
March 2027. Separately, from Month 1, analytics is set up without the
advertising ID, which Google Play already expects of apps used by children.

**S3 — Month 1 ships foundations to everyone; the test pilot stays private.**
Section 4 puts 17 feature IDs in Month 1, including the whole editorial system.
Ship the public release on time with 1001, 1003, 1004, 1006, 1008, 1011 and
4001. Run the admin tools and the test pilot for selected accounts, and open
Take a Test to everyone in Month 2 once the pilot gate passes.

**S4 — Notifications (1002) move to Month 2.** Analytics gets about four weeks
of clean baseline before reminders change behaviour, Month 1 gets lighter, and
Month 2 has something worth notifying about (results, new tests, Plus
approved). Plus approval already shows in account state without push (4.5).

**S5 — "Draft with AI" in the question editor from day one.** This keeps the
owner's idea that AI prepares the questions inside the agreed rule that admins
approve everything: an admin picks a chapter, AI drafts questions with page
references, and every draft goes through review. Writing questions by hand
stays fully supported. Rough sizing: a chapter needs about 30–50 approved
questions, so one subject (12–15 chapters) needs about 400–700. Reviewing an AI
draft takes a few minutes; writing a question from scratch takes 10–15. For a
500-question pilot that is roughly 25–35 reviewer-hours instead of 100+. Set
coverage targets from real reviewer-hours per week.

**S6 — SCERT tests start from chapter maps, not the full re-ingestion.**
Admin-written questions need each book's chapter list with page ranges (8002),
not the search index. Make SCERT chapter maps the first step of 6001; AI drafts
can read a chapter's pages directly. SCERT tests can then start as soon as
reviewers are ready. The rest of 6001 (image reading and re-embedding) is still
needed for chapter-aware AI answers and the Tutor.

**S7 — Import the quiz questions the app already has.** The app ships about 760
questions in English, Odia and Hindi (`lib/data/quiz`), grouped by subject,
class band and topic. Review the ones that fit the MCQ format and import them
through 8006, tagged by topic instead of chapter. Daily 5 then has content for
every class from launch, including classes without chapter questions.

**S8 — Follow the exam calendar: Class 10 first.** Class 10 board exams usually
run from late February into March, so December to February is when tests
matter most to them. If the pilot is not Class 10, make Class 10 the first
expansion in Month 2, and use the February Championship papers as board-exam
mocks. 6001 already puts Class 10 first.

**S9 — Daily 5 = 3 common + 2 personal.** Three questions are the same for the
whole class (scheduled by an admin, or picked from approved questions when the
admin turns that on), so students can compare and share them. Two come from the
student's weak chapters or past mistakes. With no test history, all five are
common. Competitive XP still rewards capped completion.

**S10 — The weekly rank is a band, with a next step.** Keep completion-based XP
within equal daily caps (section 4), and don't count answers given too fast to
be real. Show the rank as a band (top 1%, 5%, 10%, 25%, 50%); tied students
share a band, so no tie-break is needed. Below the top half, show the next step
instead of a low rank ("2 more Daily 5s to reach the top 50%"). Students can
share their own rank card through 5005. The weekly rank rewards habit; the
Championship is the fair contest.

**S11 — Show the stored explanation first.** Every approved question has a
reviewed explanation. "Explain" on a test answer shows it at no AI cost; "Ask
AI more" opens the chat and uses the AI allowance. It is cheaper, and the first
explanation a student sees has been reviewed.

**S12 — A weekly progress card for parents (5008 lite, Month 4).** Reuse the
5005 card maker: tests taken, streak, strong and weak chapters, sent by the
student to a parent on WhatsApp. Parents decide on phone time and will pay for
Plus in Month 6; the card shows them the app is working. A fuller parent view
comes later.

**S13 — Child-safe by design, like the big apps (new 5012).** YouTube and
Instagram protect teens with private-by-default accounts, quiet hours at night,
time reminders, parent supervision and limits on ads aimed at teens. Vidyakalp
does the same at little cost: private ranks and no chat between students
(already in this plan), notification quiet hours from 10 PM to 7 AM (1002,
Month 2), a gentle break reminder after about an hour of continuous study
(5012, Month 3), the parent progress card (S12), and non-personalised ads only
(9002, after March 2027). The full rules are in 5.12. A clean design also helps
later: the DPDP Act lets the government relax its children's rules for apps it
finds verifiably safe.

**S14 — Safe AI for students (new 1013, Month 2).** On Vidyakalp, AI answers
play the part that posts play on social apps, so they get the same care. The AI
stays on school topics and follows child-safety instructions in its prompt, and
every answer has a "Report this answer" button. Reports go to the admin panel,
next to reported test questions (8007). From Month 4, each agent's evaluation
set (2001) also includes safety checks.

### 5.5 Before Month 1 (now → 1 Nov 2026)

- Name an owner for each workstream (API, app, admin, content), a content lead,
  and reviewers for each pilot language.
- Choose the pilot cohort (5.17).
- Choose the paid OpenRouter model that free users will move to (1011).
- Write the analytics event list for 1001: screens, AI questions, tests,
  limits reached, Plus requests.
- Write acceptance criteria for every Month 1 feature.

### 5.6 Month 1 — Nov 2026 — Foundations and the editorial engine

Goal: measure the app, move every user to the paid AI route, fix verified bugs,
and build the admin tools every test feature needs. The test pilot runs
privately (S3).

_Team column in all month tables: **API** = backend, **App** = Flutter app,
**Admin** = admin panel, **Content** = editorial team, **Owner** = product
owner with legal help._

Public release:

| ID | Feature | Free / Plus | Depends on | Team |
|---|---|---|---|---|
| 1001 | Analytics, crash reporting and remote switches; no advertising ID (S2) | — | event list | App |
| 1006 | Verified bug fixes: My Learning subject bars; share text names NCERT too | — | — | App |
| 1003 | One shared AI allowance, plus separate test, Tutor and Speaking limits; "X left today" | — | existing quota | API + App |
| 1004 | Request Plus, tagged by feature; admin list, counts and one-click approve | — | 1003 | API + App + Admin |
| 1008 | AI use, cost and capacity view; a friendly "AI is busy" message | — | provider usage data | API + Admin |
| 4001 | Ask about this page (reader) | Free, limited | 1003 | App |
| 1011 | Paid AI route: free users move to paid keys through OpenRouter; model set per plan; only textbook queries reach the AI (S1) | — | model choice | API |

Private — admin, content and pilot (selected accounts):

| ID | Feature | Depends on | Team |
|---|---|---|---|
| 8001 | Author, reviewer and admin roles with audit history (extends today's admin panel) | — | API + Admin |
| 8002 | Boards, classes, subjects, books, editions, chapters with page ranges, availability | 8001 | Admin + Content |
| 6001 | SCERT chapter maps first (S6), then image-reading re-ingestion in batches: Class 10 → 9 → 8 → 7 | 8002 | Content + API |
| 3001 | Chapter lookup and coverage catalog | 8002; 6001 for SCERT AI | API |
| 8003, 3002 | Question editor with "Draft with AI" (S5); pilot bank | 8002 | Admin + Content |
| 8004 | Review, approval, student-view preview (Odia, maths, images) and versions | 8003 | Admin |
| 3003, 8005 | Core attempt and scoring service; basic paper builder | approved pilot bank | API + Admin |
| 3004 | Pilot test screens: pick a chapter, answer, see results | 3003, 1003 | App |

Pilot gate (needed for the public launch in Month 2): every pilot question is
approved and has a textbook reference; scoring is correct; Odia, maths and
images render properly; retries never lose or double an attempt.

Success: retention baseline recorded (D1/D7/D30, weekly active students);
crash-free sessions; cost per AI answer; Plus requests by feature.

### 5.7 Month 2 — Dec 2026 — Take a Test

Goal: chapter-wise and subject-wise MCQ tests from the student's own textbook,
for every class with approved coverage.

| ID | Feature | Free / Plus | Depends on | Team |
|---|---|---|---|---|
| 3004 | Take a Test for everyone (flow below) | Free, limited; Plus more | 3003, approved coverage | App |
| 3003 | Save and resume; safe retries; each attempt keeps its question versions; the server decides when answers are shown | — | core service | API |
| 3002 | Grow approved coverage in priority order (S8) | — | pilot gate, reviewers | Content |
| 8005 | Full paper builder: questions, order, sections, duration, marks, preview, publish | — | 3003 | Admin |
| 8006 | Bulk import with validation into drafts; first import = the app's existing quizzes (S7) | — | 8003, 8004 | Admin + Content |
| 3005, 8007 | Report a question; review, withdrawal, and explicit, audited score corrections | Free | versions, history | App + Admin |
| 3006 | SCERT classes switch on as reviewed content is ready | Free, limited | 3002, 8002 | Content |
| 4004 | Explore → "More from my textbook" quizzes from the same bank | Free, limited | 3003 | App |
| 4002 | "Explain" buttons: stored explanation first, then AI (S11) | Free, limited | 1003 | App |
| 4003 | Save AI answers to Notes; share them | Free | — | App |
| 1002 | Notification settings, optional daily reminder, results and "Plus approved"; quiet hours 10 PM – 7 AM; asks permission at a useful moment (S4, S13) | — | push setup | App + API |
| 1013 | Safe AI for students: school topics only, child-safety instructions, "Report this answer" into the admin review list (S14) | Free | existing agent, 8007 | API + App + Admin |

**Take a Test flow (3004):** "Take a test" card on Home (also from AI and
Explore) → subject → chapter checklist ("Select all" = whole subject) → 10, 20
or 30 questions → difficulty → mode.

- **Practice:** live score, and the explanation after each question.
- **Exam:** timer; score at the end.
- **Results:** score, star rating, time taken, strong and weak chapters, review
  with explanations, "Ask AI about this question", "Retry my mistakes", history.

Gate: every test the app offers has enough approved questions; attempts are
never lost or doubled.

Success: share of weekly active students who take a test; completion rate;
reported-question rate; reported-AI-answer rate.

### 5.8 Month 3 — Jan 2027 — Daily habit and visible improvement

Goal: a two-minute daily habit, practice aimed at weak chapters, and a reason
to check your rank.

| ID | Feature | Free / Plus | Depends on | Team |
|---|---|---|---|---|
| 1005 | Progress, streak and verified XP kept on the server; back after a reinstall | — | activity rules, test events | API + App |
| 4008 | Weak-chapter tracking and "Practise my weak chapters" (simple version) | Free | test history | API + App |
| 8008 | Daily-set scheduling, revision content, announcements, notification templates | — | 8001 | Admin |
| 5001 | Daily 5 (S9) | Free | 3002, 1005, 4008, 8008 | App + API |
| 5002 | 7/30/100-day badges, streak freeze, "streak at risk" reminder (outside quiet hours) | Free | 1005, 1002 | App |
| 5003 | My weekly rank, shown only to the student: a band such as "top 5%", overall and in their class, with a next step below the top half (S2, S10) | Free | 1005 | API + App |
| 5012 | Break reminder: a gentle "take a short break" after about an hour of continuous study (S13) | Free | — | App |
| 4005 | Reviewed chapter notes and flashcards, offline (stretch) | Free | 3001, 8008 | Content + App |

Show chapter performance as it is ("7 of 10 right in Chapter 4"), not as
measured mastery. Keep competitive XP separate from personal activity totals.

Gate: each action earns XP once; rank bands are calculated correctly.

Success: D7 retention against the Month 1 baseline; Daily 5 participation;
share of students with a 7-day streak.

### 5.9 Month 4 — Feb 2027 — Competition and sharing

Goal: one weekly event, and sharing that brings the app with it.

| ID | Feature | Free / Plus | Depends on | Team |
|---|---|---|---|---|
| 1007 | App links (tests, challenges, invites) and install referral | — | link domain | App + API |
| 8009 | Championship admin: schedule, paper per cohort, attempt rules, flagged attempts, results, certificates | — | 8005, 3003 | Admin |
| 5004 | Weekly Championship: one paper per board + class, one attempt, server timing; each student sees their own score and rank in their cohort; Class 10 papers double as board-exam mocks (S8) | Free | 8009 | App + API |
| 5005 | Share cards (results, rank band, streaks) and certificates for top performers, shared by the students themselves | Free | 5004; 1007 for links | App |
| 5006 | Challenge a friend on the same approved questions; only scores are shared, no messages | Free | 3003, 1007 | App + API |
| 5007 | Invite rewards after the friend's first finished test; once per friend; no competitive XP | Free | 1007, 1003 | API + App |
| 5008 | Weekly progress card for parents, lite version (S12) | Free | 1005, 5005 | App |
| 2001 | Agent groundwork: shared configuration and evaluation, including safety checks | — | 1003 | API |

Admins pick every Championship question. Questions and answers are not
released while the event is open. Admins review flagged attempts, and any
exclusion or score change is audited before results and certificates go out.

Gate: reviewed papers for each cohort; ranking and tie rules tested; links open
the right screen.

Success: Championship participants; shares per active student; installs from
invite and challenge links.

### 5.10 Month 5 — Mar 2027 — Maths and guided learning

Goal: better maths answers for everyone, and guided chapter lessons for Plus.

| ID | Feature | Free / Plus | Depends on | Team |
|---|---|---|---|---|
| 2001 | Agent routing by screen and subject, configuration, usage accounting, evaluation sets | — | 1003 | API |
| 2002 | Math agent: calculation tool, step-by-step solutions; "check my working" from a photo | Free, limited | 2001, maths evaluation set | API + App |
| 8010 | Tutor objectives, lesson outlines and check questions | — | 8002, 8004 | Admin + Content |
| 2003 | AI Tutor: 4–6 ideas per chapter, one at a time, a check after each, another explanation when stuck, pause and resume, final practice from the bank | Plus (1 free sample lesson) | 2001, 3001, 3002, 8010 | API + App |
| 4007 | Python "explain my error" with hints (stretch) | Free, limited | 1003 | App + API |
| 2004 | Speaking prototype on real students' phones | — | speech technology choice | App + API |

The Tutor switches on chapter by chapter, as each chapter's outline is
approved. Don't promise that no audio leaves the phone until the prototype
settles the speech technology. In March, confirm the parent-consent method with
counsel so 1012 can be built in April.

Gate: maths accuracy passes its evaluation set; approved outlines for every
Tutor chapter offered.

Success: maths accuracy; Tutor lesson completion; Plus requests from the Tutor.

### 5.11 Month 6 — Apr 2027 — Speaking, parent consent, then paid Plus

| Order | ID | Feature | Free / Plus | Depends on |
|---|---|---|---|---|
| 1 | 2004 | English speaking: role-plays (introduce yourself, at a shop, an interview); after each turn, the corrected sentence and a short tip, explained in Odia or Hindi when asked | Plus (1 free sample session) | prototype, 2001, metering, quality evaluation |
| 2 | 1012 | Parent-consent step at sign-in (flow below), live by 13 May 2027 (S2) | — | method confirmed with counsel in March |
| 3 | 4006 | Vocabulary "use it in a sentence" (stretch) | Free, limited | 1003 |
| 4 | — | Check costs, Free/Plus packaging and support flows against real usage | — | Months 1–5 data |
| **5 — last** | **9001, 8011** | **Plus subscription (details below)** | — | **all earlier gates, stable limits, verified purchase lifecycle** |

**Parent-consent flow (1012):** every student counts as under 18, so there is
no age question.

1. The student signs in with Google, as today.
2. The app shows "Ask a parent to approve". A parent nearby takes the phone; a
   parent elsewhere gets a link on WhatsApp or SMS that opens on their own
   phone, with no app install.
3. The parent reads a short notice: what is stored (name, class, test scores,
   AI questions), why, and how to delete it.
4. The parent shows they are an adult: a light option (name, date of birth and
   phone OTP) or a strong one (DigiLocker, keeping only "adult: yes"). Counsel
   decides which is enough.
5. The parent taps "I approve" and the account unlocks. The parent can withdraw
   later, and the data is then deleted.

While waiting, students can still read books and use the offline tools, which
work without sign-in. Students who are already signed in see the same step on
their next app open.

**Plus subscription (9001, 8011):** Google Play Billing, monthly and yearly.
Purchases verified on the server; renewals, cancellations, refunds and restore
handled. Admins see billing and entitlements and make audited grants. "Request
Plus" becomes "Get Plus" only when billing is ready. Students who requested
Plus get a launch offer; hand-granted Plus gets an end date.

If Month 6 runs long, 4006 moves out first and billing moves next. Parent
consent keeps its date, because the law sets it. Billing is never brought
forward to fill time.

Gate: parent consent live by 13 May 2027; earlier gates passed; billing tested
end to end.

Success: Plus conversion; speaking sessions per Plus student; share of signed-in
students with parent approval.

### 5.12 Rules for every month

**Child safety** (S2, S13, S14)

- Every student is treated as under 18; classes 1–10 need no age check.
- Only textbook questions and textbook content go to the AI, never names,
  emails or account IDs.
- No public profiles or names. Weekly ranks are private; in the Championship,
  each student sees only their own place, and toppers share their own
  certificates if they want.
- No chat between students. Friend challenges share only scores.
- Notifications are opt-in and never sent between 10 PM and 7 AM.
- A gentle break reminder after about an hour of continuous study.
- The AI stays on school topics, follows child-safety instructions, and every
  answer can be reported.
- No personalised ads, ever. Any ads come after March 2027 (9002).
- Analytics runs without the advertising ID.
- Delete account stays easy to find (Settings → Delete account, already live).
- Parents can see progress: the lite card from Month 4, a fuller view later.

**Who picks the questions** (from 4.2)

| Experience | Who picks |
|---|---|
| Weekly Championship | Admin picks every question and publishes the paper |
| Daily 5 | Common part: admin schedules it, or turns on picking from approved questions. Personal part: backend picks from approved questions (S9) |
| Custom tests, Retry my mistakes | Backend picks approved questions that match the student's choices |
| AI Tutor | Teaching is live AI; scored checks use approved questions |

**Question rules**

- Lifecycle: draft → review → approved → used in a published or scheduled
  test. Questions can be withdrawn. An edit creates a new version; attempts
  keep the version they used; score corrections are explicit and audited.
- Each question has text, four options, the answer, an explanation, language,
  estimated difficulty, its chapter (board, class, book, edition, chapter) and a
  textbook page reference. Difficulty stays an estimate until attempt data
  confirms it.
- Admins preview questions exactly as students will see them before approval.
- Student reports go to review; report counts alone never decide that a
  question is wrong.

**Free and Plus** (placeholders; tune with Month 1 data)

| Daily allowance | Free | Plus |
|---|---|---|
| AI questions, one shared allowance (Ask, Ask about this page, Explain follow-ups, Math, sentence checks) | small (code default today: 3 per agent) | larger (code default today: 25 per agent) |
| Stored explanations on test questions | unlimited | unlimited |
| Custom tests | 3 | 20 |
| Daily 5, Championship, challenges, your rank | always free | always free |
| Competitive XP cap | same | same |
| AI Tutor | 1 sample lesson | 3 lessons |
| English speaking | 1 sample session | 15 minutes |

**Delivery**

- Every feature gets an engineering owner, a content owner where needed, and
  acceptance criteria before work starts.
- If a gate fails, shrink coverage or move the feature. Never skip approval to
  hit a date.
- Ship each release as a staged rollout on Play (for example 10% → 50% →
  100%), watching crashes. Remote switches can turn a feature off.
- The backend says what is available (classes with tests, Tutor chapters), so
  new content goes live without an app update.
- Measure first: record baselines in Month 1 and set numerical targets after.

### 5.13 Dependencies (critical paths)

1. 8001 → 8002 → 8003/8004 → approved bank (3002) → 3003 → 3004 → 4008 → 5001.
2. 1005 → 5003 (private rank).
3. 8005 → 8009 → 5004 → 5005.
4. 1007 → 5006 and 5007.
5. 2001 + 8010 + approved bank → 2003; 2001 → 2002 and 2004.
6. 1011 (paid route) before AI use grows with 4001, 4002 and 2002.
7. Counsel's answer in March → 1012 built in April → live before 13 May 2027.
8. Everything above → 9001, last.

### 5.14 Risks

| Risk | How the plan handles it |
|---|---|
| Not enough reviewer time — the real limit on tests | AI drafts (S5), existing quizzes imported (S7), coverage set by reviewer-hours, pilot first |
| Odia quality: wording, rendering, equations | Odia reviewers, student-view preview before approval, student reports (3005) |
| SCERT re-ingestion takes a long time | Tests start from chapter maps (S6); classes switch on one by one (3006) |
| Month 1 is overloaded | Public foundations, private pilot (S3); notifications in Month 2 (S4) |
| AI costs grow on paid keys | Shared limits (1003), cost per answer tracked (1008), stored explanations (S11); tests from the bank need no AI |
| Answer quality changes when the model changes (for example to GPT or Claude) | Switch only after the backend's answer evaluation passes in English, Odia and Hindi; each agent gets its own evaluation set (2001) |
| An unsafe or off-topic AI answer reaches a child | School-topics-only instructions, a report button and admin review (1013); safety checks in each agent's evaluation (2001) |
| Children's privacy | Safe-by-default rules (5.12): private ranks, no names, no student chat, no personalised ads; parent consent in Month 6 (1012) |
| Month 6 holds both a legal date and billing | 4006 moves out first, then billing; 1012 keeps its 13 May 2027 date |
| Cheating in the Championship | Server timing, one attempt, shuffled order, nothing released early, flagged attempts reviewed |
| Grinding, or low ranks discouraging students | Equal caps, too-fast answers don't count, rank bands, a next step instead of a low rank (S10) |
| Speech technology unproven on low-cost phones | Prototype in Month 5 before the Month 6 launch |
| Pressure to bring billing forward | Payments stay last (decision 3) |

### 5.15 Later (after these six months)

| ID | Feature |
|---|---|
| 1009 | Cloud sync for notes, bookmarks and highlights |
| 1010 | Gemini paid key — replaced by 1011 (paid keys through OpenRouter) |
| 2005 | Pronunciation scoring in speaking practice |
| 3007 | More question types: true/false, fill in the blank, short answers |
| 4008 | Full mastery map and personal daily plan (the simple version is in Month 3) |
| 5003 | Public leaderboard (on hold) and all-time ranking |
| 5008 | Full parent view: progress, study time and data deletion (the lite card is in Month 4) |
| 5009 | Leagues: small groups with promotion and relegation |
| 5010 | *New idea:* district board for the Championship — average score and participation per district, no individual data; students pick a district in Profile |
| 5011 | *New idea:* friend streaks — two friends keep a streak together |
| 6002 | AI support for SCERT classes 1–6 and NCERT Class 10 |
| 7001 | Teacher groups: teachers create groups, add students and assign tests |
| 9002 | *After March 2027:* child-safe ads for Free users — not personalised, from an ad network certified for children's apps, never inside tests; "No ads" as a Plus benefit |

### 5.16 Checked against the code (2026-10-16)

Section 4 asked for the audit findings to be verified. Results:

- **Bug confirmed:** My Learning subject bars stay empty. The reader saves pages
  under `maths`, `science`, … (`lib/screens/pdf_viewer/pdf_viewer_screen.dart:89`)
  but My Learning reads `Mathematics`, `Science`, …
  (`lib/providers/progress_provider.dart:47`).
- **Confirmed:** the share text names only SCERT Odisha
  (`lib/data/services/app_share.dart:15`).
- **Confirmed:** the AI quota is counted per agent, so each new agent would add
  a full allowance (`vidyalaya-ai/src/vidyalaya_ai/subscriptions/plans.py:12`).
  Code defaults are 3 (free), 25 (plus) and 100 (pro) a day; production can
  override them with `PLAN_DAILY_LIMIT_*`.
- **Confirmed:** textbook search filters only by board, class and subject
  (`vidyalaya-ai/src/vidyalaya_ai/rag/retrieval.py:73`).
- **Confirmed:** free users' answers use the direct Gemini provider, and search
  embeddings use the Gemini API key (`GEMINI_API_KEY`) for every user; 1011
  moves free users' answers to the paid route.
- **Confirmed:** Android backup is off
  (`android/app/src/main/AndroidManifest.xml:7`); 1005 brings progress back
  after a reinstall.
- **Confirmed:** no analytics, crash-reporting or notification packages in
  `pubspec.yaml`.
- **Already exists:** an admin panel (`/admin-panel`) with users, plans, stats
  and an audit log, behind a single `admin` role. 8001 extends it.
- **Already exists:** Settings → Delete account (a web link), which Google Play
  requires for apps with accounts. Keep it.
- **Correction to 4.3:** the app has no localization files. App labels are
  English in code; Odia and Hindi are for study content only (owner decision,
  2026-09-24).
- **Note:** the backend has three plans (`free`, `plus`, `pro`); this plan
  only talks about Free and Plus (see 5.17).

### 5.17 Decisions to make for the final plan

| # | Decision | Recommendation |
|---|---|---|
| 1 | Keep or drop each of S1–S14 | Keep all; S1, S2 and S13 already follow your decisions |
| 2 | Pilot cohort | Pick by active students in the admin panel. Default: SCERT Class 10 Maths or Science if Odia reviewers are ready; otherwise NCERT Class 9 Science, whose chapter text is ready now |
| 3 | Content team and reviewer-hours per week, per language | Settle before 1 Nov; it sets every coverage target |
| 4 | Which paid model free users get first, and when to try GPT or Claude | Pick the first one before Month 1; switch models only after the answer evaluation passes |
| 5 | Championship tie rule (decides who gets certificates) | Higher score → shorter total time → earlier submission |
| 6 | Exact limits and invite bonus size | Set from Month 1 data |
| 7 | The `pro` plan | Students see Free and Plus only; keep `pro` for staff testing until teacher accounts (7001) |
| 8 | Speech technology for 2004 | Decide from the Month 5 prototype |
| 9 | Plus price | In Month 5, show the planned price on Request Plus ("Plus will be ₹X a month") to measure interest at that price |
| 10 | Championship toppers: a public list, or private like weekly ranks? | Private: each student sees their own result; toppers get a certificate they can share themselves |

---

## 6. Final plan

AT the end
