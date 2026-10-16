# Vidyakalp — Next Release Plan (high level)

**Status:** Draft — iteration 2 (owner + Codex) agreed; see section 4 for the current timeline and dependencies.
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

## 4. Second opinion — agreed draft (Codex + owner, 2026-10-16)

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

## 5. Final plan

_To be consolidated after the remaining planning choices. Section 4 is the
current agreed draft and takes precedence over earlier conflicting proposals._
