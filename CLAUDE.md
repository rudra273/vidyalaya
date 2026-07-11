# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Vidyālaya is a Flutter book-reading + AI tutoring app for Indian school students (SCERT Odisha, classes 1–8). Cross-platform (Android primary; iOS/web/desktop scaffolding present).

## Commands

```bash
flutter pub get                 # install deps
flutter run                     # run on connected device/emulator (see dart-define below)
flutter analyze                 # lint (flutter_lints via analysis_options.yaml)
flutter test                    # run all tests
flutter test test/data/learn_assist_test.dart            # single test file
flutter test --name "serializes with a selected subject" # single test by name
flutter build apk --release     # release build
dart run flutter_launcher_icons # regenerate launcher icons after changing assets/icon/
```

### Required build-time config
- `GOOGLE_WEB_CLIENT_ID` is read via `String.fromEnvironment` in [auth_repository.dart](lib/data/repositories/auth_repository.dart). Pass it for Google sign-in to work: `flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=...`
- `android/app/google-services.json` is **gitignored** — it must exist locally for Firebase to initialize.
- The AI backend base URL is hardcoded in [learn_assist_service.dart](lib/data/services/learn_assist_service.dart) (`defaultBaseUrl`, a Railway deployment). Services accept a `baseUrl` override, used in tests.

## Architecture

Layered Flutter + Riverpod app. `lib/` layout: `app/` (router, theme), `data/` (models, repositories, services, seed, cache), `providers/` (Riverpod state), `screens/` (feature UIs), `widgets/` (shared UI).

### State management — Riverpod
All cross-cutting dependencies are providers. Two providers are **overridden in `main.dart`** (their unoverridden definitions throw `UnimplementedError`): `sharedPreferencesProvider` and `cacheStoreProvider`, because both need async init before `runApp`. See [core_providers.dart](lib/providers/core_providers.dart).

`booksEnabledProvider` is a feature flag: when false, every book surface (Library tab, Home rows, continue-reading) hides cleanly, leaving AI + tools functional. Honor this flag when touching book UI.

### Two persistence layers — keep them distinct
1. **SharedPreferences** ([user_prefs_repository.dart](lib/data/repositories/user_prefs_repository.dart)) — local user state: selected classes/board, reading position, bookmarks, highlights, notes, timetable, avatar, onboarding flag, regional language. Survives cache clear, not uninstall. All keys are private constants in this repo.
2. **Hive cache** ([cache_store.dart](lib/data/cache/cache_store.dart)) — versioned (`kCacheSchemaVersion`), JSON-serialized cache of **backend** data, namespaced by Firebase uid via `CacheStore.key(uid:, name:)`. On version mismatch or parse failure the entry self-deletes.

### Auth + backend
Firebase Auth + Google Sign-In ([auth_repository.dart](lib/data/repositories/auth_repository.dart)). Backend calls authenticate with the Firebase ID token (auto-refresh + 401 retry in the services). Two HTTP services share `defaultBaseUrl`: [learn_assist_service.dart](lib/data/services/learn_assist_service.dart) (AI chat) and [backend_auth_service.dart](lib/data/services/backend_auth_service.dart) (user, profile, usage, chat history).

`BackendAccountCache` in [auth_provider.dart](lib/providers/auth_provider.dart) is the central account-state notifier. Key patterns to preserve when editing it:
- **Stale-while-revalidate**: `ensureX()` methods hydrate from Hive cache, return cached value, and revalidate in the background; state only updates if data changed.
- **uid-scoped**: switching uid (or signing out) wipes the previous uid's cache namespace and resets in-flight request slots.
- **History is keyed by `HistorySelector`** (channel + board + class + subject). A single shared request slot is keyed by selector so a slow fetch for one subject never clobbers another — switching subjects quickly was a real bug class here.

### Routing — go_router
Single `routerProvider` in [router.dart](lib/app/router.dart). A `ShellRoute` wraps the 4 bottom-nav tabs (`/`, `/explore`, `/library`, `/profile`) in `AppShell` with `NoTransitionPage`; everything else is a root-level route. A top-level `redirect` forces `/welcome` until onboarding completes. Legacy paths (`/learn`, `/my-books`, `/learn-ai`) redirect to current ones — preserve these so old deep links don't break.

### Data / content
Book catalog is **static seed data**, not a DB: [seed_data.dart](lib/data/seed/seed_data.dart) aggregates per-class `scert/scert_class_N.dart` files into `allBooks`. Helpers like `getBookById`, `getBooksByClass` query it. PDFs stream from `book.pdfUrl`. Other static content lives under `data/` too (periodic table, vocabulary, diagrams, timeline) and is surfaced in the Explore/Learn tools.

### Theme
[theme.dart](lib/app/theme.dart) — "Calm Scholar" palette, parallel light/dark `ThemeData`, Google Fonts. Edge-to-edge system UI is configured in `main.dart`.

## Conventions
- Section headers in source use box-drawing comment dividers (`// ─── Title ───`). Match this style.
- Models are plain immutable classes with `toJson`/`fromJson` (no codegen). Backend models map snake_case JSON to Dart camelCase fields.
- Navigation back-handling uses `BackButtonListener`, not `PopScope` — prefer standard fixes over workarounds.
