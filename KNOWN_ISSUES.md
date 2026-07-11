# Known Issues

Findings from the pre-release review of the `UI` branch (v1.0.3). Most have now
been fixed on this branch; the two items left open are called out at the bottom.

## Bugs — fixed

### 1. Signed-out language pick is ignored by the Explore tools ✅ FIXED
- **Where:** `lib/providers/regional_language_provider.dart`
- **Fix:** `RegionalLanguageNotifier.build()` now falls back to
  `getPreferredLanguage()` (the local `preferred_language` pref) after the
  profile check and before the board default. Precedence: manual override →
  profile language → local preferred language → board default → Odia. Covered
  by new cases in `test/providers/regional_language_provider_test.dart`.

### 2. Changing subject mid-answer can crash ✅ FIXED
- **Where:** `lib/screens/learn/learn_ai_screen.dart`
- **Fix:** `_switchConversation` and both `_loadHistory` rebuild paths now reset
  (or re-point) `_streamingMessageIndex`, and every write path is bounds-checked
  — `appendToken` starts a fresh bubble if the slot is stale, and the terminal
  paths go through the new `_finalizeStreamingMessage` helper.

### 3. Profile edit fields grey out mid-edit for accounts with no saved profile ✅ FIXED
- **Where:** `lib/screens/profile/profile_screen.dart`
- **Fix:** `_ensureCachedProfile` now also bails while `_isEditing`, so a
  background `ensureProfile` revalidation can't flip `profile` to `AsyncLoading`
  and disable the form while the student is typing.

### 4. Retry/Regenerate on an image-only chat message silently does nothing ✅ FIXED
- **Where:** `lib/screens/learn/learn_ai_screen.dart` (`_retryLastTurn`)
- **Fix:** A history image-only turn (`text='[Image shared]'`, `imageBytes=null`)
  can't be resent, so Retry now shows "Please send the image again to ask about
  it." instead of silently early-returning.

## Performance (low-end devices) — fixed

### 6. Per-token jank while an AI answer streams ✅ FIXED
- **Where:** `lib/screens/learn/learn_ai_screen.dart`
- **Fix:** Token frames are coalesced (buffer + ~60ms flush timer, cancelled on
  finalize), `_scrollToBottom` is throttled to one queued animation via
  `_scrollScheduled`, and the subject list is memoized (`_subjectsFor`) so it no
  longer re-maps/sorts on every rebuild.

### 7. Vocabulary list re-sorts on every keystroke ✅ FIXED
- **Where:** `lib/screens/learn/vocabulary_screen.dart`
- **Fix:** The full list is sorted once into `_sortedWords` (a `late final`
  field); `_filtered` now only filters that pre-sorted list per query.

## Data sync — fixed

### 8. Prefs mirror only syncs while the Profile screen is open ✅ FIXED
- **Where:** `lib/providers/auth_provider.dart`
- **Fix:** A `_mirrorProfileToPrefs` helper in `BackendAccountCache` now writes
  class/board/language to local prefs on every profile save and load (incl.
  background revalidation / cross-device edits), not just from `ProfileScreen`.

## About / Privacy copy — fixed

### 9. Privacy Policy omits newly-local data ✅ FIXED
- **Where:** `lib/screens/profile/privacy_policy_screen.dart`
- **Fix:** Section 2 now lists preferred language + avatar as local storage, and
  Section 4 notes that the preferred language is also kept on-device.

## Cleanup — done

- Extracted the duplicated Support card into a shared `SupportSection` widget
  (`lib/widgets/support_section.dart`), used by both Profile and Settings.
- Added a top-level `_navTap(ref, context, path, {replace})` helper on the Home
  screen, replacing ~10 hand-inlined `Haptics.light(ref); context.push(...)`.
- Extracted a `_finalizeStreamingMessage` helper in `learn_ai_screen.dart` for
  the "replace streaming bubble else append + clear index" block.
- Named the AI-tutor fallback class constant (`learnAssistDefaultClass = 8`) in
  `learn_assist_provider.dart` instead of a bare `8`.
- Converted the `///` box-divider comments in `app_share.dart` and
  `feedback_service.dart` to the CLAUDE.md `// ─── Title ───` style.
- Removed the stray blank line in `my_books_screen.dart`.

## Still open

### 5. Possible duplicate user message in saved history on retry (unverified)
- **Where:** `lib/screens/learn/learn_ai_screen.dart` (`_performSend`)
- **Status:** Left as-is by request — it's backend-dependent and can't be
  confirmed from the client. If a stream fails after the backend already
  persisted the user turn, Retry re-sends it and the backend may persist it
  again. Verify against the backend before adding a client-side guard.

### Cleanup: `_streamChat` duplicates auth flow — deferred
- **Where:** `lib/data/services/learn_assist_service.dart`
- **Status:** `_streamChat` re-implements token-fetch / 401-retry / error-decode
  that `backend_auth_service.dart` `_sendWithAuth` centralizes, but
  `_sendWithAuth` returns a buffered `http.Response` and the SSE path needs a
  streamed one. Sharing the flow means factoring out a streaming-aware auth
  helper — deferred as too large for a cosmetic cleanup.

## Note

The AI-tutor subject dropdown being empty for classes not in
`ingested_books.json` (6, 10–12) is **intentional** (internationalization /
staged rollout) — not a bug.
