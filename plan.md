# Vidyakalp — Six-month product and delivery plan

**Planning period:** November 2026–April 2027.

**Prepared:** 16 October 2026.

**Status:** Final plan — reviewed by the owner. Implementation remains subject
to the release gates and delivery decisions below.

This plan includes the product direction, monthly scope, release gates,
operating rules, remaining delivery decisions and later backlog. Feature IDs
remain stable. Recommended defaults remain subject to the delivery decisions
below; staffing, budgets and vendors are not yet confirmed.

## Feature tracker and progress log

**Tracker:** [Vidyakalp feature tracker (Google Sheet)](https://docs.google.com/spreadsheets/d/1chsbW_SRAsX1nch75yPQsOe6E7ZhNWlI7kYSyHpJ5LM/edit).
**Progress log:** [steps.md](steps.md).

This plan defines the scope; the sheet tracks delivery status. AI assistants
working in this repository keep both current:

- When work on a feature starts, moves to review, is blocked or finishes, update
  its **Status** in the sheet's **Features** tab and add a dated line to
  `steps.md` naming the feature ID and what changed.
- When this plan changes (a feature added, moved, split or dropped; a gate or
  decision changed), make the same change in the sheet and note it in `steps.md`.
- Features tab columns: ID, Feature, Release, Scope, Lead workstream, Status,
  Owner, Notes. One row per ID per release, so an ID that spans months has
  several rows. Do not merge them.
- Keep **Release** text exactly as it appears in the sheet (for example
  `Month 2 (Dec 2026)`); the Roadmap tab's counts match on it.
- Status values are limited to: Backlog, Not started, In progress, In review,
  Blocked, Done, Deferred, Retired.
- Do not change the Roadmap tab's formulas; its counts update from Features.
  The Decisions tab mirrors section 14: update its Status and Outcome when a
  decision is made.
- Edit the existing sheet through the Google Sheets connector. Never create a
  replacement file, since that would change the link.

## 1. Goal and product direction

Make Vidyakalp a daily learning companion: **take a test → understand mistakes
→ practise weak chapters → see improvement → return tomorrow.**

The six months deliver textbook tests, daily practice, private progress and
competition, better maths help, guided tutoring and spoken-English practice.
Sharing supports growth. Paid Plus is the final implementation and release step.

The rules governing every release are:

1. **One release per month, delivered by a team.** API, Flutter, admin and
   content work proceed in parallel. Dates are targets; acceptance gates
   determine what is ready to ship.
2. **Most learning stays free, with limits.** Plus provides higher limits and
   longer Tutor and Speaking sessions. Daily 5, Championship participation,
   friend challenges and private ranks remain free.
3. **Admins control assessed content.** Authors create questions manually or
   explicitly request AI drafts. Reviewers approve them before use. No
   autonomous question generation or publication.
4. **One approved bank and test engine.** Reuse them for Take a Test, Explore,
   Daily 5, Championship, friend challenges and Tutor checks. Taking a stored
   test requires no AI generation call.
5. **Start with one complete pilot.** Expand only where reviewed content is
   ready. Do not promise every class, subject or chapter at launch.
6. **Agents stay behind the scenes.** Students see tasks such as “Ask”,
   “Learn this chapter” and “Practise speaking”. Extend the existing
   LearnAssist system with routing by task and subject.
7. **Paid production AI for all plans.** Free chat goes directly to Gemini;
   Plus chat uses OpenRouter; embeddings remain on Gemini. The production
   Gemini key is a paid one, so a Free student account does not use an
   unpaid provider tier.
8. **Treat student accounts as under 18.** Private ranks, no public student
   names or profiles, no student messaging, no personalised ads. Parent
   consent is scheduled for April, with method selection in March.
9. **Equal competitive opportunities.** Plus usage and referral bonuses do
   not increase competitive XP. Championship results compare the same paper.
10. **Keep the existing free offline base.** Downloaded books and existing
    offline tools remain useful when an online feature is unavailable.
11. **App labels stay English; study content supports its reviewed languages.**
    Preserve English, Odia and Hindi content where available. Use Vidyakalp
    in product copy; retain existing technical identifiers.
12. **Payments stay last.** If prerequisite learning features slip, billing
    slips. Teacher groups remain outside these six months.

## 2. Roadmap at a glance

| Target | Theme | Student outcome | Main release gate |
|---|---|---|---|
| Month 1 — Nov 2026 | Foundations and editorial pilot | Clear limits, Request Plus, Ask about this page, corrected progress display; selected accounts try tests | Reliable allowances and paid AI routes; separately, approved pilot content and correct scoring |
| Month 2 — Dec 2026 | Take a Test | Chapter/subject MCQs, practice and exam modes, explanations, history and reminders | Sufficient approved coverage; reliable save, resume and submission |
| Month 3 — Jan 2027 | Daily habit and improvement | Daily 5, weak-chapter practice, synced progress, streaks and private weekly rank | Verified progress, one XP award per action and equal earning caps |
| Month 4 — Feb 2027 | Competition and sharing | Sunday Championship, challenges, share cards, referrals and parent progress card | Reviewed papers, tested timing/ranking and working links |
| Month 5 — Mar 2027 | Maths and guided learning | Checked maths assistance and chapter Tutor | Agent evaluations pass; every offered Tutor chapter has approved content |
| Month 6 — Apr 2027 | Speaking, parent consent, then paid Plus | Speaking practice, parent approval flow, followed by subscriptions | Speech and consent ready; earlier gates passed; billing verified end to end |

## 3. Before Month 1

The product owner assigns an engineering lead for each workstream, a content
lead and reviewers for every pilot language. Confirm reviewer-hours per week
and measure review throughput before promising question counts or dates.

**Recommended pilot:** SCERT Class 10 Science if chapter references and Odia
reviewers are ready; otherwise NCERT Class 9 Science after confirming its
source coverage. Select one board/class/subject, not both. Class 10 is the
first expansion priority when reviewed content supports it. Check published
exam schedules before advertising event dates as board-exam preparation.

Before development starts, record the pilot, named owners, supported chapters,
acceptance criteria, analytics events, AI spending ceiling and evaluated paid
model. Start with the current model family as the evaluation baseline; a new
model must pass quality, language, safety, latency and cost checks.

## 4. Month 1 — Foundations and editorial pilot

**Public release**

| IDs | Deliverable | Lead workstream |
|---|---|---|
| 1001 | Analytics, crash reporting and rollout switches; baseline retention and feature use; no advertising ID or raw learning content in analytics | App + API |
| 1006 | Correct My Learning subject-key mismatch and update sharing copy to include the supported boards | App |
| 1003 | One shared AI-question allowance; separate test, Tutor and Speaking meters; show remaining allowance and reset time | API + App |
| 1004 | Request Plus in Profile, limit sheets and Plus features; deduplicated requests, feature-interest counts, manual approval and account-state refresh | API + Admin + App |
| 1008 | Usage, estimated cost and capacity dashboard for chat and embeddings; budget alerts and graceful provider failures | API + Admin |
| 1011 | Paid AI routing for every student plan, paid Gemini embedding configuration, evaluated model selection and controlled provider settings — done by switching production to a paid Gemini key; no code change needed | API |
| 4001 | Ask about this page: hand off the current textbook page and relevant context to AI chat | App + API |

Request Plus records one pending request per student and tracks source-feature
interest without creating duplicate approval work. Approval is audited and
appears on account refresh; it does not depend on notifications.

The existing code counts quota per agent. Replace that before adding agents
so routing cannot multiply allowances. Server-side accounting must handle
concurrent requests, retries and failures without duplicate charging.

The paid-provider gate includes embeddings, editorial AI drafts and any
automatic fallback. Paying for chat alone does not establish that every AI
route uses paid terms. Keep the current embedding model unless there is a
separate evaluated migration; a billing change alone does not require
re-embedding books. Provider accounts and billing must be checked operationally,
because source code cannot prove their billing status.

Free chat stays on direct Gemini and Plus/Pro on OpenRouter; the code already
routes this way. The production Gemini key was switched to a paid one
(17 October 2026), which covers Free chat and embeddings, so 1011 needed no
code change. Chat reads `GOOGLE_API_KEY` before `GEMINI_API_KEY`; both must
hold the paid key in production.

**Private editorial tools and test pilot**

| IDs | Deliverable | Lead workstream |
|---|---|---|
| 8001 | Extend the existing admin panel with author, reviewer and administrator permissions and audit history | API + Admin |
| 8002 | Curriculum catalog: board, class, subject, book, edition, chapter, page range and availability | Admin + Content |
| 6001 | SCERT chapter maps first; then reviewed ingestion batches, Class 10 → 9 → 8 → 7 | Content + API |
| 3001 | Chapter lookup and explicit content-coverage catalog | API |
| 8003, 3002 | Manual question editor and bank; admin-triggered “Draft with AI” from selected chapter sources | Admin + Content |
| 8004 | Review, approval, withdrawal, versioning and student-view preview for language, maths and images | Admin + Content |
| 3003, 8005 | Core test attempts, scoring and basic paper builder | API + Admin |
| 3004 | Pilot screens: choose an available chapter, answer questions and review results | App |

SCERT tests can start from approved chapter maps and textbook page references;
they do not require the entire vector index to be rebuilt. Chapter-aware AI
and Tutor require their own validated source coverage. Keep these availability
states separate.

**Public gate:** limits, approval refresh, paid routes and failure handling
work; page-context AI passes the existing answer and safety checks.
**Pilot gate:** every offered question is approved and referenced; scoring and
rendering are correct; retrying a submission neither loses nor duplicates it.
The public foundation release can ship while the private pilot continues.

**Measure:** crash-free sessions, D1/D7 retention, active students, AI cost per
successful answer, failure rates and Plus requests by feature. D30 becomes
available only after a full observation window.

## 5. Month 2 — Take a Test

| IDs | Deliverable | Lead workstream |
|---|---|---|
| 3002, 3006 | Expand approved coverage; enable SCERT chapters/classes as ready | Content |
| 3003 | Save/resume, server scoring, fixed question versions, safe retries and server-controlled answer release | API |
| 3004 | Public Take a Test, results, history, chapter breakdown and Retry my mistakes | App + API |
| 8005 | Full paper builder: questions, order, sections, duration, marks, preview and publication | Admin |
| 8006 | Validated bulk import into drafts; review suitable existing app quizzes | Admin + Content |
| 3005, 8007 | Report a question, editorial review, withdrawal and audited result corrections | App + Admin + API |
| 4004 | Explore → More from my textbook, powered by the same bank | App |
| 4002 | Explain actions on tests and supported Explore items; stored explanations first, optional AI follow-up | App + API |
| 4003 | Save an AI answer to Notes and share it | App |
| 1002 | Opt-in push/local reminders, settings, results and Plus-approved notifications; quiet hours | App + API |
| 1013 | School-topic AI safeguards, answer reporting and an admin review queue | API + App + Admin |

**Test flow:** Home → Take a test → subject → chapter checklist → question
count (10/20/30 where supported) → difficulty → Practice or Exam. Also expose
the entry through AI and Explore. The checklist comes from the approved
curriculum catalog, not live AI-generated chapter names.

Practice shows the score and reviewed explanation after each answer. Exam
mode uses a timer and reveals results at completion. Results include score,
a clearly defined star rating, time, chapter performance, answer review,
“Ask AI more”, Retry my mistakes and history. AI follow-ups use the shared
AI allowance; stored explanations do not.

Only offer question counts and difficulty combinations the bank can satisfy.
“Select all” means all available chapters; call it a whole-subject test only
when the whole subject has approved coverage. Existing general quizzes may
be imported with topic/class-band tags, but cannot become chapter tests until
their curriculum mapping and evidence are reviewed. Imports do not guarantee
coverage for every class.

**Gate:** the pilot passes; every advertised test can be assembled; interrupted
attempts resume; duplicate submission returns the same result; exam answers
cannot be retrieved early; content reports reach reviewers.

**Measure:** test adoption and completion, resume failures, question reports,
AI-answer reports and stored-explanation versus AI-follow-up use.

## 6. Month 3 — Daily habit and visible improvement

| IDs | Deliverable | Lead workstream |
|---|---|---|
| 1005 | Server-backed personal progress, streaks and verified competitive XP | API + App |
| 4008 | Chapter performance and Practise my weak chapters | API + App |
| 8008 | Daily-set scheduling, reviewed revision content, announcements and notification templates | Admin + Content |
| 5001 | Daily 5: three common questions plus two personal revision questions | API + App |
| 5002 | 7/30/100-day badges, streak freeze and optional evening reminder | App + API |
| 5003 | Private weekly XP rank bands, overall and within the student's board/class cohort | API + App |
| 5012 | Gentle break reminder after about an hour of continuous study | App |
| 4005 | Reviewed chapter notes and flashcards, readable offline — stretch | Content + App |

Daily 5's common set is shared within the same board/class and supported
language version. Admins schedule it or explicitly enable approved-bank
selection. Personal questions come from eligible mistakes/weak chapters. With
insufficient history or questions, fill from the approved common pool; with
insufficient total coverage, do not advertise Daily 5 for that cohort yet.

Personal progress records valid learning activity. Competitive XP uses a
separate, published schedule of equal capped opportunities available to Free
and Plus students. Extra paid tests, AI turns, Tutor/Speaking usage and referral
bonuses do not add competitive XP. Replaying the same eligible activity cannot
award it again. Weekly XP resets Monday at 00:00 IST. Daily boundaries and
streak rules use the same documented timezone.

Use private bands such as top 1%, 5%, 10%, 25% and 50%, with consistent tie
handling. Below that, show a useful learning action rather than a discouraging
rank. Do not promise that a fixed number of activities guarantees a future
rank. Suspicious speed is a review signal, not automatic proof of cheating.

Restore synced progress on a new phone after sign-in. Existing local history
may be preserved as personal history under a defined migration rule; it must
not create retrospective competitive XP. Notes, bookmarks and highlights
remain device-local until their separate sync feature ships.

Show observed performance (“7 of 10 right in Chapter 4”), without calling a
small number of answers proven mastery.

**Gate:** retries and multiple devices award XP once; weekly boundaries,
ties and rank bands are correct; available competitive opportunities are equal.
**Measure:** D7/D30 retention, repeat practice, Daily 5 completion and 7-day
streak participation; compare like-for-like chapter performance over time.

## 7. Month 4 — Competition and sharing

| IDs | Deliverable | Lead workstream |
|---|---|---|
| 1007 | App links, hosted fallback pages and install-referral handling | API + App |
| 8009 | Event scheduling, approved papers, attempt review, final results and certificates | Admin + API |
| 5004 | Weekly Championship | App + API + Content |
| 5005 | Student-initiated result, rank-band and streak cards; top-performer certificates | App |
| 5006 | Challenge a friend using the same approved questions; private score comparison | App + API |
| 5007 | Bonus AI questions for qualifying invites, issued once | API + App |
| 5008 | Student-shared weekly parent progress card: tests, streak and chapter performance | App |
| 2001 | Begin shared agent configuration, routing and evaluation groundwork | API |

**Championship rules:** one event hub; Sunday **10:00 AM–8:00 PM IST**; one
attempt per student. Each board/class cohort gets an admin-selected paper.
Rank only equivalent versions of the same paper; language variants need
reviewed equivalence or separate ranking. No cross-paper percentage ranking.

Publish duration, entry cutoff and tie rules before the event. Recommended
ranking is score descending, then server-measured elapsed time ascending;
exact ties share a rank and certificate eligibility. Do not use early arrival
within the ten-hour window as an academic advantage. This tie policy is a
recommended refinement for owner review.

Students receive questions during their attempt. Answers, explanations and
reviewable paper copies remain unavailable until the event closes and results
are released. Shuffle question/option order; review flagged attempts before
publishing final results. Exclusions and score adjustments require an audit
record. Each student sees their own result and cohort rank; certificates are
shared voluntarily, without a public list of students.

Friend challenges use private links and share only the agreed score comparison,
not student profiles or messages. Do not reuse an embargoed Championship paper
for challenges. Referral bonuses go to both students after the invited student's
first qualifying completed test, once per invited student, with at most **10
rewarded invites per inviter**. Exclude self-referrals and duplicate claims;
publish bonus quantity and expiry before launch. No competitive XP bonus.

**Gate:** paper approval, one-attempt enforcement, timing, tie handling and
answer-release rules pass; link routing and referral deduplication work.
**Measure:** participation, completed challenges, voluntary shares and
qualifying referrals. Sharing is always initiated by the student.

## 8. Month 5 — Maths and guided learning

| IDs | Deliverable | Lead workstream |
|---|---|---|
| 2001 | Extend existing agent routing, configuration, shared metering and evaluation sets | API |
| 2002 | Calculation-assisted maths explanations and Check my working from a photo | API + App |
| 8010 | Admin-managed Tutor objectives, outlines and approved check questions | Admin + Content |
| 2003 | Guided chapter Tutor with pause/resume, checks and final practice | API + App |
| 2004 | Speaking prototype tested on representative student phones and networks | App + API |
| 1012 | Confirm parent-consent method, account flow and migration requirements in March | Owner + API + App |
| 4007 | Python Explain my error with learning hints — stretch | App + API |

Math assistance uses calculation tools to check supported operations, explains
steps and identifies mistakes in submitted working. It remains within the
shared AI-question allowance.

Tutor teaches roughly 4–6 approved ideas per chapter, checks understanding,
offers another explanation when needed, supports revisiting and resuming,
and finishes with approved practice questions. Live teaching is AI-generated;
formal scored checks come from the approved bank. Enable it chapter by chapter
after source coverage and lesson outlines pass review. Plus gets metered
lessons; Free gets one sample lesson per account.

Evaluate maths correctness, textbook grounding, English/Odia/Hindi support
where offered, safety, latency and cost before changing models or launching
agents. Safety checks also apply to Month 1 provider changes; they do not wait
for this shared evaluation work.

The speech prototype determines recognition/synthesis technology and whether
audio leaves the device. Test low-cost phones, noisy environments and weak
connections before setting quality promises. Confirm the data path and costs.

**Gate:** agent evaluations pass; offered Tutor chapters are ready; lessons
resume correctly; sample access and paid allowances are enforced.
**Measure:** maths accuracy, Tutor completion, lesson cost and feature-specific
Plus interest. Test a clearly labelled proposed Plus price in March; interest
requests are not evidence of actual paid conversion.

## 9. Month 6 — Speaking, parent consent, then paid Plus

Finish and release these in dependency order. Parent consent has a protected
April delivery target and must not wait for a delayed Speaking launch.

| IDs | Deliverable | Gate |
|---|---|---|
| 2004 | English speaking role-plays, corrected sentences and short supportive tips; explanations in Odia/Hindi where supported | Device/language evaluation, disclosed audio handling, reliable duration metering |
| 1012 | Parent approval, consent records, withdrawal, existing-account migration and guest access | March-selected method and tested end-to-end flow |
| 4006 | Vocabulary Use it in a sentence — stretch | Evaluated feedback and shared allowance |
| — | Finalise Free/Plus packaging, costs, support and prices | Actual usage and cost data from earlier releases |
| **9001, 8011 — last** | **Plus subscriptions and billing administration** | **Earlier committed gates passed; purchase lifecycle verified** |

Speaking includes short scenarios such as introductions, shopping and
interviews. Free gets one sample session per account; Plus gets a daily minute
allowance. Pronunciation scoring is later scope. Do not claim processing is
fully on-device unless the chosen implementation demonstrates it.

**Parent-consent product flow:**

1. A student can continue with guest books/offline tools or start parent approval.
2. A parent approves on the same phone or through a secure, expiring browser
   link shared by the family, without needing an app install.
3. Explain the data, purposes and controls in a short notice. Verify the
   parent's adult identity using the method settled in March.
4. Record approval and complete/link student sign-in under the reviewed flow.
   For existing accounts, enforce the migration and access rules before rollout.
5. Support withdrawal and deletion, with documented retention exceptions and
   deletion handling for processors, logs and backups.

Do not assume that placing an approval screen after ordinary Google sign-in
prevents earlier processing. The implementation must address Firebase,
profile creation, SDK collection and server requests. OTP plus a self-declared
birth date is not a pre-approved verification method; retain only necessary
verification evidence under the selected design.

**Timing basis:** the notified DPDP framework places Section 9 and Rule 10 in
the eighteen-month commencement phase. Using the Gazette date of 13 November
2025 gives a planning deadline of **13 May 2027**. Target April completion;
reconfirm applicability, amendments and method with counsel in March. Rule 10
addresses verifiable parental consent before processing children's personal
data. Sources: [Act commencement notification](https://www.meity.gov.in/static/uploads/2025/11/c56ceae6c383460ca69577428d36828b.pdf)
and [DPDP Rules, Rules 1 and 10](https://www.meity.gov.in/static/uploads/2025/11/53450e6e5dc0bfa85ebd78686cadad39.pdf).

**Billing:** Android starts with Google Play Billing, monthly and yearly.
Verify purchases on the server; handle restore, renewals, cancellation,
expiry, payment interruptions, refunds and revocation. Cancelling renewal
must preserve access through the verified paid entitlement period. Reconcile
delayed or repeated billing events. Admins inspect entitlements and make
audited grants; provider purchase status remains authoritative.

Request Plus becomes Get Plus only after billing is ready. Set explicit expiry
and transition rules for manually granted Plus, and clearly state any launch
offer. If the month overruns, defer vocabulary first and billing next. Do not
bring payments forward or sacrifice the consent target.

**Measure:** Speaking completion/cost, consent completion and failures,
verified purchase/restore success and paid conversion after launch.

## 10. Content and admin operating rules

Every assessed MCQ has four options with exactly one correct answer, a reviewed
explanation, language, estimated difficulty, curriculum mapping and evidence.
Chapter identity includes board, class, subject/book, edition and chapter.
General imported questions retain their topic/class-band mapping until a
reviewer establishes a genuine chapter match.

Lifecycle: **draft → review → approved → published/scheduled use**; withdrawal
is available at any point it is needed. Manual authoring is a complete workflow.
AI drafting or checking never replaces approval. Preview actual student
rendering, including Odia text, equations and images.

Edits create new question/paper versions. Attempts retain the versions used.
Do not silently change historical scores; review affected attempts and record
explicit correction decisions. Report counts prioritise review but do not
prove that an answer is wrong. Withdrawn content is excluded from new tests;
define handling of active attempts before applying a correction.

| Experience | Who controls the questions |
|---|---|
| Championship and official mocks | Admin selects and publishes the exact paper |
| Daily 5 | Admin schedules common sets or enables approved selection; backend selects eligible personal revision |
| Custom tests and Explore textbook quizzes | Backend selects matching approved questions |
| Retry my mistakes | Backend selects eligible, still-approved missed questions |
| Friend challenge | Fixed approved set shared by participants |
| Tutor scored checks | Approved questions attached to reviewed lesson objectives |

Admin content management grows with the roadmap: questions and papers first,
then revision material, instructions, announcements, Home banners, notification
templates and Tutor outlines. It is not a general app-layout editor. Ordinary
English interface labels stay in app code.

## 11. Free, Plus and usage rules

These are **provisional planning defaults**, to validate against costs and
Month 1 usage before publishing them. “Daily” means the documented server
reset at 00:00 IST; sample access is once per account, not once per day.

| Feature | Free | Plus |
|---|---|---|
| Shared AI questions: Ask, page questions, Explain follow-ups, Math and sentence checks | Start evaluation at 3/day | Start evaluation at 25/day |
| Custom tests, including Explore textbook tests | 3/day | 20/day |
| Stored explanations and viewing completed results | No AI charge | No AI charge |
| Daily 5, Championship, challenges and private rank | Free within event/abuse rules | Same competitive access |
| Competitive XP opportunities and cap | Identical | Identical |
| Tutor | One sample lesson per account | 3 lessons/day |
| Speaking | One sample session per account | 15 minutes/day |

The current 3/25 code defaults are per agent; the proposed numbers above are
shared totals. Production overrides may differ. Define start, resume,
completion and failure charging rules before each meter launches; resuming a
lesson or test must not count as another one. Set finite session lengths and
cost limits for samples and Tutor lessons.

Student packaging is Free and Plus. Recommended handling of the existing
technical `pro` plan is internal testing only; preserve current entitlements
until their holders are reviewed. Do not silently downgrade existing users or
rename technical plan keys during this roadmap.

## 12. Privacy, safety and quality throughout delivery

- Send only necessary learning content and context to AI. Exclude account
  names, email addresses and identifiers from prompts and provider metadata.
  Typed messages, chat history, photos and speech can themselves contain
  personal data: minimise and filter them rather than promising that a
  textbook-only prompt makes disclosure impossible.
- Select provider routes whose terms and data controls fit the intended
  student use. Paid billing alone does not prove suitable retention or
  training settings. Verify these alongside model evaluation.
- Keep AI focused on school learning, with age-appropriate handling and
  safe responses to sensitive disclosures. Prompt rules, evaluations, reports
  and human review work together; a prompt alone is not the safety gate.
- Keep ranks private and student names out of shared comparison surfaces.
  Students preview and choose their own share cards. Parent cards are shared
  by the student, not automatically sent to contacts.
- Notifications are optional and respect **10 PM–7 AM local quiet hours**.
  Championship schedules remain explicitly in IST. Add the Month 3 break
  reminder without pressuring students to extend sessions.
- Minimise analytics and crash-report payloads; exclude advertising IDs,
  raw questions, answer text, photos and sensitive identifiers. Review SDK
  collection and consent handling, rather than treating removal of the
  advertising ID as complete privacy protection.
- Keep account deletion easy to find and test its actual end-to-end behavior.
  Parent consent work starts with method selection in March and rollout in
  April, as scheduled; it does not replace these ongoing product safeguards.
- No personalised ads. Advertising is a separate later decision, after March
  at the earliest and after parent-consent readiness; it is not a six-month
  delivery commitment or an assumed source of revenue.

## 13. Delivery gates, dependencies and risks

The engineering lead owns technical acceptance; the content lead owns
curriculum accuracy and reviewed coverage; the product owner owns rollout,
packaging and remaining decisions. Assign named people before work begins.

Main dependency chains:

1. Curriculum → authoring → approval → bank → test engine → student tests.
2. Tests/history → weak-chapter practice → personalised Daily 5.
3. Verified activity + equal XP rules → private weekly rank.
4. Test engine + reviewed common papers → Championship → final certificates.
   Championship scoring does not depend on weekly XP ranking.
5. Links + tests → challenges and qualifying referral rewards.
6. Agent extension + chapter sources + lesson outlines + approved checks → Tutor.
7. Paid routes + metering + safety evaluation → expanded AI experiences.
8. March consent design → April implementation/migration → verified readiness.
9. Earlier committed feature gates + costs + entitlements → payments last.

| Risk | Delivery response |
|---|---|
| Month 1 workload | Release public foundations separately; keep the pilot private until ready |
| Reviewer capacity or Odia quality | Set coverage from measured throughput; reduce chapters before reducing review quality |
| Slow SCERT ingestion | Use reviewed chapter maps for authored tests; enable chapter AI/Tutor only when their sources pass |
| Too few eligible questions | Offer only supported selections; expand the bank before widening availability |
| AI cost, capacity or model regressions | Shared metering, budget controls, stored explanations, evaluations and rollback |
| Unreliable networks | Persist attempts, resume safely and make repeated submissions idempotent |
| Grinding or suspicious competition | Equal caps, server validation, explicit ranking rules and audited review |
| Speech or consent integration delays | Prototype speech in March; protect April consent delivery; postpone billing |

Every release uses staged rollout and feature switches. Check backward
compatibility with existing app versions, migrations and recovery before
deployment. A failed gate reduces coverage or moves the feature; it never
removes approval or correctness requirements. The backend advertises actual
availability so reviewed content can expand without a new app release.

Set numerical success targets after baseline data exists. Each month reviews
its measures, content throughput, quality reports and costs before committing
the next expansion. Stretch features can be explicitly deferred; billing does
not wait forever on items removed from committed scope.

## 14. Remaining delivery decisions

These decisions have owners and deadlines; they do not reopen the core
direction or require another planning draft.

| Decision | Default or required output | Owner | Due |
|---|---|---|---|
| Pilot and reviewers | One cohort/subject; named reviewers and weekly capacity | Product + Content | Before November |
| Paid model and budget | Evaluated model, permitted routes, billing verified for embeddings too, spending ceiling | API + Product | Before Month 1 rollout |
| Coverage targets | Minimum eligible questions per offered count/difficulty/language, based on actual throughput | Content + API | Before pilot publication |
| Limits and charging | Validate provisional table; define retries, sample length and failure behavior | API + Product | Before each feature launches |
| XP and streak rules | Fixed awards/caps, eligible actions, freezes, tie bands and migration rules | Product + API | Before Month 3 |
| Championship rules | Duration/cutoff, same-paper cohorts, shared exact ties, certificate eligibility | Product + Content + API | Before Month 4 |
| Referral reward | Bonus quantity, expiry, attribution and qualification rules | Product + API | Before Month 4 |
| Existing Pro accounts | Inventory and explicit handling; internal-only recommendation | Product | Before packaging changes |
| Speech implementation | Evaluated technology, audio data path, supported devices/languages and costs | App + API | March |
| Parent consent | Counsel-reviewed method, account sequence, migration and retention/deletion behavior | Product + Engineering | March; deliver April |
| Plus price and offer | Test proposed price in March; finalise from cost and demand evidence | Product | Before billing implementation |

## 15. After these six months

| IDs | Later scope |
|---|---|
| 1009 | Cloud sync for notes, bookmarks and highlights |
| 1010 | Retired as a separate milestone; paid Gemini embeddings are covered by 1011 |
| 2005 | Pronunciation scoring |
| 3007 | Additional question types and evaluated short-answer grading |
| 4008 | Full mastery map and personal learning plan beyond the initial chapter-performance view |
| 5003 | All-time ranking; public leaderboard remains on hold and needs a new privacy/product decision |
| 5008 | Full parent dashboard and supervision beyond the voluntary progress card |
| 5009 | Leagues with promotion/relegation |
| 5010 | District aggregates, only with sufficient participation to protect privacy |
| 5011 | Friend streaks |
| 6002 | Expanded chapter AI support for SCERT 1–6 and NCERT Class 10 |
| 7001 | Teacher-created groups, student membership and assigned tests |
| 9002 | Optional non-personalised ads, subject to a separate policy and economics review; never inside tests |

This roadmap is complete when the committed learning experiences pass their
release gates, reviewed coverage is accurately advertised, progress and
competition are reliable, parent-consent readiness is verified, and paid Plus
is released last. Broader content coverage then continues through the same
editorial process.
