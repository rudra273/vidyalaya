# Known Issues — deferred to a later release

Findings from the pre-release review of the `UI` branch (v1.0.3). None of these
block the current build; recorded here to fix later.

## Bugs

### 1. Signed-out language pick is ignored by the Explore tools
- **Where:** `lib/providers/regional_language_provider.dart`
- **What:** A signed-out student changing their language in Profile saves to the
  new `preferred_language` pref via `_syncLocalProfile`, but
  `RegionalLanguageNotifier` only reads `getRegionalLanguage()` (the switcher
  key) and the backend profile — never `getPreferredLanguage()`. So the picked
  language is ignored everywhere except the Profile summary label (diagrams,
  timeline, math formulas keep showing the board default).
- **Fix idea:** Have the resolver fall back to `getPreferredLanguage()` before
  the board default, or write the choice into the `regional_language` key too.

### 2. Changing subject mid-answer can crash
- **Where:** `lib/screens/learn/learn_ai_screen.dart` (`_switchConversation`,
  `appendToken` ~line 442)
- **What:** Switching subject/language while a reply is still streaming calls
  `setState(_messages.clear())` without resetting `_streamingMessageIndex`. The
  in-flight `appendToken` then writes `_messages[_streamingMessageIndex!]`
  against the cleared/repopulated list → RangeError or overwrites the wrong
  bubble. `_loadHistory`'s forced-refresh clear/addAll is a second path with the
  same stale-index exposure.
- **Fix idea:** Guard subject/language chips while `_isSending`, or reset
  `_streamingMessageIndex` whenever `_messages` is rebuilt.

### 3. Profile edit fields grey out mid-edit for accounts with no saved profile
- **Where:** `lib/screens/profile/profile_screen.dart` (~line 216),
  `lib/providers/auth_provider.dart` (`ensureProfile`)
- **What:** For a signed-in user whose backend profile is null, `hasCache` is
  false, so a background `ensureProfile` revalidation (fired every build by
  `_ensureCachedProfile`, not guarded by `_isEditing`) can flip `profile` to
  `AsyncLoading` mid-edit → `isBusy` true → Name/School fields and Save button
  disable while the user is typing.
- **Fix idea:** Skip the background revalidation while `_isEditing`, or don't let
  a background refresh drive `isBusy` in the form.

### 4. Retry/Regenerate on an image-only chat message silently does nothing
- **Where:** `lib/screens/learn/learn_ai_screen.dart` (`_retryLastTurn` ~line 379)
- **What:** History image turns carry `text='[Image shared]'` and
  `imageBytes=null`. Retry maps that to `query=''` + `imageBytes=null`, so
  `_performSend` early-returns with no request and no user feedback.

### 5. Possible duplicate user message in saved history on retry (unverified)
- **Where:** `lib/screens/learn/learn_ai_screen.dart` (`_performSend`)
- **What:** If a stream fails after the backend already persisted the user turn,
  tapping Retry re-sends the same turn, which the backend may persist again →
  duplicate user message on the next history fetch. Not confirmable from the
  client; verify against the backend.

## Performance (low-end devices)

### 6. Per-token jank while an AI answer streams
- **Where:** `lib/screens/learn/learn_ai_screen.dart` (`appendToken`,
  `_scrollToBottom`), plus `learnAssistSubjects` re-derived in `build()`
- **What:** Every SSE token calls `setState` (full list rebuild) + a fresh
  post-frame `animateTo` (no throttling → animations stack), and rebuilds the
  subject list (map + sort) each time.
- **Fix idea:** Coalesce tokens (buffer, setState every N chars / on a short
  timer), throttle the scroll to one animation in flight, and memoize the
  subject list.

### 7. Vocabulary list re-sorts on every keystroke
- **Where:** `lib/screens/learn/vocabulary_screen.dart` (`_filtered` ~line 42)
- **What:** The getter clones + sorts the full ~204-word list on every build,
  including each keystroke in the search field.
- **Fix idea:** Sort once (in `initState` or a memoized top-level), filter per
  query.

## Data sync

### 8. Prefs mirror only syncs while the Profile screen is open
- **Where:** `lib/screens/profile/profile_screen.dart` (`_syncLocalProfile`),
  `lib/providers/auth_provider.dart` (`saveProfile`)
- **What:** The backend-profile → local-prefs mirror (class/board/language) is
  written only from inside `ProfileScreen`. A background profile refresh landing
  while the user is elsewhere (e.g. a cross-device edit) updates the cache but
  not local prefs, so class/board selection drifts until the Profile screen is
  reopened.
- **Fix idea:** Move the prefs mirror into the account-cache notifier so any
  profile load/save syncs it.

## About / Privacy copy (verify before a compliance-sensitive release)

### 9. Privacy Policy omits newly-local data
- **Where:** `lib/screens/profile/privacy_policy_screen.dart`
- **What:** Section 2 ("What You Can Use Without an Account") lists local-only
  storage but omits **preferred language** and **avatar**, both now stored
  locally. Section 4 says preferred language is "stored on our servers" — now
  also editable/stored locally for signed-out users.
- **Fix idea:** Add language + avatar to the Section 2 list; soften the Section 4
  "servers only" wording.

## Cleanup (cosmetic, non-blocking)

- **Support card** (Share / Rate / Send feedback) is duplicated verbatim in
  `profile_screen.dart` and `settings_screen.dart` → extract a shared
  `SupportSection` widget.
- **`_streamChat`** in `learn_assist_service.dart` re-implements the
  token-fetch / 401-retry / error-decode flow that `backend_auth_service.dart`
  `_sendWithAuth` centralizes.
- **Home screen** hand-inlines `Haptics.light(ref); context.push(...)` in ~10
  onTap callbacks → a small `_navTap` helper.
- **`learn_ai_screen.dart`** duplicates the "replace streaming bubble else
  append + clear index" block 4× → a `_finalizeStreamingMessage` helper.
- **`learn_assist_provider.dart`** hardcodes the fallback class `8` twice next to
  the named `learnAssistMinClass = 6`.
- **Comment style:** `app_share.dart` and `feedback_service.dart` use `///`
  doc-comment box dividers instead of the CLAUDE.md `// ─── Title ───` style.
- **`my_books_screen.dart`** ~line 197 has a stray blank line left by the removed
  `_boardLabel`.

## Note

The AI-tutor subject dropdown being empty for classes not in
`ingested_books.json` (6, 10–12) is **intentional** (internationalization /
staged rollout) — not a bug.
