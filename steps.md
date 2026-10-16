# Progress log

Dated entries naming the feature ID and what changed. See the tracking rules in [plan.md](plan.md).

- 2026-10-16 — 1001: started (sheet Status → In progress). Scoping analytics, crash reporting and rollout switches.
- 2026-10-16 — 1001: decisions — crash reports via Firebase Crashlytics only (no Firebase Analytics, no Remote Config); retention and feature use stay on our own `learning_events` (D1/D7, active users and per-feature counts already in the admin stats); rollout switches are served by our API.
- 2026-10-16 — 1001: API (vidyalaya-ai, uncommitted): `GET /config/v1` with `FEATURE_SWITCHES` env (kill switch + staged rollout by uid hash; unknown names fail boot), `tests/test_rollout_switches.py`.
- 2026-10-16 — 1001: App (uncommitted): Crashlytics (release builds only, no identifiers), per-uid cached rollout switches with `booksEnabledProvider` now the `books` switch, `AD_ID` removed from the manifest, tests for both. `flutter analyze`, `flutter test` and a debug APK build pass.
- 2026-10-16 — 1001: moved to In review. Before release: enable Crashlytics in the Firebase console, deploy the API before the app, set `FEATURE_SWITCHES` if needed, confirm a release build reports a test crash.
- 2026-10-16 — 1001: verified Crashlytics from a debug build on a Samsung S928B (`--dart-define=CRASH_REPORTING=true`): Firebase returned `activated` settings for com.vidyalaya.ai and crash reports were posted to crashlyticsreports-pa.googleapis.com. Dashboard confirmation still to check by the owner.
- 2026-10-16 — 1001: Crashlytics verified end to end — the test crashes from the debug build appear in the Firebase console, and the dashboard shows crash-free users and crash-free sessions without the Analytics SDK (corrects the earlier assumption that sessions needed Analytics). Remaining before release: check a release build reports, deploy the API first, set FEATURE_SWITCHES if needed.
