# Vidyakalp — bugs and release readiness

Review date: 2026-11-15, branch `dev`. Found by reading the code and building; nothing here was reproduced on a device.

Status key: **Open** = not fixed yet. **Fixed** = changed in code on 2026-11-15 and covered by `flutter analyze` + `flutter test`; not yet checked on a device.

## Release checks that passed

- `flutter analyze`: no issues.
- `flutter test`: all 868 tests pass.
- `flutter build apk --release`: builds signed, with minification and resource shrinking on.
- Notification icon and the notification plugin's classes survive R8.
- All 80 SCERT PDF links return 200 over HTTPS with no redirect.
- Backend `/health` responds.
- Manifest: no cleartext traffic, backups off, `AD_ID` stripped.

## Crashes

### C1. Manage Downloads can run out of memory and kill the app — Fixed
- **Where:** `_downloadBook` in [manage_downloads_screen.dart:101](lib/screens/downloads/manage_downloads_screen.dart:101)
- **What happens:** the whole PDF is collected in a growable `List<int>` (`bytes.addAll(chunk)`) before it is written. A Dart `List<int>` uses several bytes per PDF byte, and the list is copied each time it grows.
- **Why it matters:** the 80 SCERT PDFs average 42 MB, 36 of them are over 40 MB, and the largest is 198 MB. On a low-memory phone Android will kill the app mid-download.
- **Also in the same function:**
  - `setState` runs on every network chunk, so the screen rebuilds thousands of times per download.
  - The file is written straight to `<id>.pdf`. If the app dies mid-write, the reader treats the partial file as a valid book (see C3).
- **Fix:** stream to a `.part` file and rename on success, exactly as the reader already does in [pdf_viewer_screen.dart:449](lib/screens/pdf_viewer/pdf_viewer_screen.dart:449). Update progress only when the whole percent changes.

### C2. Opening a bookmark or highlight for a missing book crashes the reader — Fixed
- **Where:** `book!` in the `/reader/:bookId` route, [router.dart:495](lib/app/router.dart:495)
- **How to trigger:** add your own PDF, bookmark or highlight a page, remove the book from the Library, then tap that bookmark in Bookmarks or that highlight in Notes.
- **Cause:** `UserBooksNotifier.remove` ([books_provider.dart:93](lib/providers/books_provider.dart:93)) deletes the book but leaves its bookmarks and highlights. [bookmarks_screen.dart:133](lib/screens/bookmarks/bookmarks_screen.dart:133) and [subject_notes_screen.dart:110](lib/screens/notes/subject_notes_screen.dart:110) push `/reader/<id>` without checking the book exists.
- **Also triggers when:** an app update removes or renames a book id in the seed catalog.
- **Fix:** redirect to `/library` when the book is not found, and clear a book's bookmarks, highlights and reading position when it is removed.

### C3. A damaged PDF file can never be recovered from the reader — Fixed
- **Where:** `_loadPdf` in [pdf_viewer_screen.dart:436](lib/screens/pdf_viewer/pdf_viewer_screen.dart:436) and the Retry button at [pdf_viewer_screen.dart:1067](lib/screens/pdf_viewer/pdf_viewer_screen.dart:1067)
- **What happens:** any existing file with length above zero is reused. If it is truncated or corrupt (most likely from C1), the viewer reports an error, and Retry opens the same bad file again.
- **Effect:** the book stays broken until the student finds Manage Downloads and deletes it. The error text also wrongly says to check the internet connection.
- **Fix:** when the viewer reports an error for an official book, delete the local file before Retry so it downloads again.

### C4. The app can hang on the splash screen at startup — Fixed
- **Where:** [main.dart:35](lib/main.dart:35) to [main.dart:46](lib/main.dart:46)
- **What happens:** `Firebase.initializeApp()`, `initCrashReporting()`, image recovery, `Hive.openBox` and the `ingested_books.json` load are all awaited with no try/catch before `runApp`. If any one throws, the app never draws a screen.
- **Fix:** wrap the optional steps so a failure falls back (empty cache box, `IngestedBooks.empty()`), and show a simple error screen if Firebase itself fails.

### C5. Saved data is parsed without protection — Fixed
- **Where:** [user_prefs_repository.dart](lib/data/repositories/user_prefs_repository.dart): `getSelectedClasses` (176), `getLibrarySelectedClasses` (205), `getBookmarks` (309), `getHighlights` (337), `getNotes` (392), `getTimeSlots` (502), `getTimetable` (517), `getPythonCompletedLessons` (644), `getPythonQuizScores` (663), `getMathBestScores` (697)
- **What happens:** these do `jsonDecode(...) as List` or `as Map` and cast every field with no try/catch. Other getters in the same file already guard this.
- **Why it matters:** several are read while screens build (class selection is read at startup, the timetable is read by reminders). One bad stored value, or a field added in a later version and read by older saved data, gives an error screen every time that screen opens, with no way for the student to clear it.
- **Fix:** catch the parse error, return the empty default, and remove the bad key.

## Features that silently stop working

### F1. Phone reminders fail on devices that report an old timezone name — Fixed
- **Where:** `tz.getLocation(...)` in [phone_reminders_provider.dart:117](lib/providers/phone_reminders_provider.dart:117)
- **What happens:** the app loads `timezone/data/latest.dart`, which leaves out old alias names. I ran it: `Asia/Kolkata` is found, but `Asia/Calcutta`, `Asia/Katmandu`, `Asia/Dacca`, `Asia/Rangoon`, `UTC` and `GMT` are missing.
- **Effect:** on a phone that reports `Asia/Calcutta` (older Android versions and some manufacturers), the lookup throws, the catch block sets the status to `unavailable`, and no timetable or daily-challenge reminder is ever scheduled.
- **Fix:** import `timezone/data/latest_all.dart`, or fall back to `Asia/Kolkata` when the lookup fails.

### F2. "Start fresh" can fail with no message — Fixed
- **Where:** `_resetMemory` in [learn_ai_screen.dart:362](lib/screens/learn/learn_ai_screen.dart:362)
- **What happens:** only `LearnAssistApiException` is caught. Any other network failure (for example a TLS handshake error, which the services do not convert) escapes as an uncaught error, so the student sees nothing and Crashlytics logs a fatal.
- **Fix:** add a general `catch` that shows the same snackbar.

## Confirm before release

- **Version number:** [pubspec.yaml](pubspec.yaml) and [app_info.dart](lib/app/app_info.dart) say `1.2.0+8`, but the last commit is titled "relese 1.2.1". If build 8 is already on Play, the upload is rejected until the build number goes up.
- **Sign-in build flag:** build the release with `--dart-define=GOOGLE_WEB_CLIENT_ID=...`. The APK currently in `build/` was built without it for this review; do not ship that file.
- **AI for younger classes — Fixed:** classes 1–5 get no AI (AI and Ask tabs removed, AI links redirect Home); class 6+ with no textbook for that board shows "coming soon" on the AI tabs and hides other AI shortcuts. See `aiAccessProvider` / `AiGate`. Original note: textbooks are ingested only for SCERT 7–10 and NCERT 6–9. `learnAssistMinClass` in [learn_assist_provider.dart:22](lib/providers/learn_assist_provider.dart:22) is never used, so a class 1–6 student can open Ask and send questions with no textbook behind them. Decide whether that is intended.

## Lower-risk issues

- **Feedback sends name and email silently — Fixed (no longer sent):** [feedback_screen.dart:40](lib/screens/profile/feedback_screen.dart:40) attaches the Google account name and email to a Google Form without telling the student.
- **Crash numbers will read high — Fixed (async errors now non-fatal):** [crash_reporting.dart:25](lib/data/services/crash_reporting.dart:25) records every uncaught async error as fatal, including ones the student never notices.
- **Mock screen still routed — Fixed (screen removed, path redirects to the chat):** `/learn-ai/tutor` opens `TutorMockScreen` ([router.dart:230](lib/app/router.dart:230)); nothing links to it.
- **Stale doc — Fixed:** CLAUDE.md says the backend is on Railway; the code points at Render.

## Not reviewed in depth

The games, lab, math, quiz and vocabulary screens, most of the profile screen, and iOS were only pattern-scanned (unguarded lookups, parses and `.first`), not read line by line. No device or emulator run was done.
