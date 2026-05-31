# Offline-First Persistent Cache (Hive) — Architecture Plan

> Status: **planned, not yet implemented.** This document is the implementation
> blueprint for the next release. Code referenced here (e.g. `CacheStore`,
> `cacheStoreProvider`) does not exist yet.

## Context

**Problem:** Every time the user opens the Q&A chat or the profile screen, the app
shows loading spinners while it re-fetches data it already had seconds ago. Chat
history is the worst offender — it shows a "loading all chat" indicator on every
open because `ensureHistory(selector, forceRefresh: true)` always blocks on the
network. All backend data (`BackendUser`, `StudentProfile`, `LearnAssistUsage`,
chat history) lives **in memory only** and is lost on every app restart.

**Goal:** A persistent, offline-first cache so screens paint **instantly** from
local storage (no spinner unless truly cold), then silently revalidate in the
background. Built as a **reusable framework** so future endpoints (e.g. the
upcoming Tutor agent) get offline-first for free.

**Decisions:**
- Storage engine: **Hive** — the maintained `hive_ce` / `hive_ce_flutter` fork
  (classic `hive` is discontinued).
- Refresh policy: **stale-while-revalidate (SWR)** — paint cache with no spinner,
  refetch in background, update the UI silently only if data changed.
- Scope: chat history **+** user/profile/usage **+** a reusable generic cache
  framework.

## Recommended approach

**JSON-in-box over Hive**, reusing each model's existing `fromJson`/`toJson` — no
TypeAdapters, no codegen. One generic `CacheStore` backed by a single Hive box of
`String → String` (JSON-encoded `CacheEntry` envelopes). Per-uid namespaced keys,
with a schema `version` field inside each envelope for cheap lazy schema-busting.
`BackendAccountCache` hydrates synchronously from the cache before any network
call (so the first paint has data and `loaded = true`), then runs the existing
`_loadX` as a background revalidate.

## Dependencies

Add to `pubspec.yaml` under `dependencies` (`path_provider` already present, used
by `hive_ce_flutter.initFlutter` internally):

```yaml
  hive_ce: ^2.11.3
  hive_ce_flutter: ^2.3.1
```

---

## Phase 1 — Framework, bootstrap & serialization

### New file: `lib/data/cache/cache_store.dart`

```dart
/// Envelope persisted for every cached value.
class CacheEntry<T> {
  final T value;
  final DateTime savedAt;
  const CacheEntry({required this.value, required this.savedAt});
}

/// Bump this to invalidate ALL cached envelopes on next read (schema-busting).
const int kCacheSchemaVersion = 1;

/// JSON-in-box cache over a single Hive box (String key -> String JSON).
/// Each stored record is: { "v": <version>, "savedAt": <ISO8601>, "value": <T-as-json> }.
class CacheStore {
  final Box<String> _box;
  CacheStore(this._box);

  static const boxName = 'app_cache';

  /// Per-uid namespacing: "<uid>:<name>". Pass uid=null for app-global keys.
  static String key({String? uid, required String name}) =>
      uid == null ? 'global:$name' : '$uid:$name';

  /// Reads value only (null on miss / decode failure / version skew).
  /// [fromJson] rebuilds T from the decoded `value` payload (Map or List).
  T? read<T>(String key, T Function(Object json) fromJson) =>
      readWithMeta<T>(key, fromJson)?.value;

  /// Reads value + savedAt. Drops & treats as miss on corruption or version skew.
  CacheEntry<T>? readWithMeta<T>(String key, T Function(Object json) fromJson) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['v'] != kCacheSchemaVersion) {
        _box.delete(key); // lazy schema-bust
        return null;
      }
      return CacheEntry(
        value: fromJson(decoded['value'] as Object),
        savedAt: DateTime.parse(decoded['savedAt'] as String),
      );
    } catch (_) {
      _box.delete(key); // corrupt entry -> drop, treat as miss
      return null;
    }
  }

  /// Writes value as JSON. [toJson] must return a JSON-encodable Object
  /// (Map for objects, List for collections of toJson'd items).
  Future<void> write<T>(String key, T value, Object Function(T value) toJson) {
    return _box.put(key, jsonEncode({
      'v': kCacheSchemaVersion,
      'savedAt': DateTime.now().toIso8601String(),
      'value': toJson(value),
    }));
  }

  Future<void> delete(String key) => _box.delete(key);

  /// Clear-on-signout: deletes every key under one uid namespace.
  Future<void> deleteNamespace(String uid) async {
    final prefix = '$uid:';
    final keys = _box.keys
        .whereType<String>()
        .where((k) => k.startsWith(prefix))
        .toList();
    await _box.deleteAll(keys);
  }
}
```

Design notes:
- Single box + key namespacing keeps init/lifecycle trivial vs. multiple boxes.
- `fromJson(Object)` (not `Map`) so the same store serves object payloads (Map)
  and collection payloads (List).
- `version` lives per-entry; a single `kCacheSchemaVersion` bump invalidates
  everything lazily on read — no migration code.

### `lib/providers/core_providers.dart` — add a provider (mirrors `sharedPreferencesProvider`)

```dart
final cacheStoreProvider = Provider<CacheStore>((ref) {
  throw UnimplementedError('cacheStoreProvider must be overridden in ProviderScope');
});
```

### `lib/main.dart` — open Hive before `runApp`, add the override

```dart
await Firebase.initializeApp();
final prefs = await SharedPreferences.getInstance();
await Hive.initFlutter();                                       // new
final cacheBox = await Hive.openBox<String>(CacheStore.boxName);// new
final cacheStore = CacheStore(cacheBox);                        // new
runApp(ProviderScope(overrides: [
  sharedPreferencesProvider.overrideWithValue(prefs),
  cacheStoreProvider.overrideWithValue(cacheStore),             // new
], child: const VidyalayaApp()));
```

### Model `toJson` additions

DateTime fields → `toIso8601String()` (mirroring `Highlight`). Each model's
existing `fromJson` already reads these keys, so cache **reads** reuse `X.fromJson`.

In `lib/data/services/backend_auth_service.dart`:

```dart
// BackendUser — snake_case keys matching its fromJson.
Map<String, dynamic> toJson() => {
  'user_id': userId, 'firebase_uid': firebaseUid, 'db_id': dbId,
  'email': email, 'name': name, 'role': role, 'status': status,
  'plan_key': planKey, 'plan_daily_limit': planDailyLimit,
  'plan_provider': planProvider, 'plan_model': planModel,
};

// ChatHistoryMessage
Map<String, dynamic> toJson() => {
  'id': id, 'role': role, 'content': content,
  'citations': citations.map((c) => c.toJson()).toList(),
  'created_at': createdAt?.toIso8601String(),
};

// ChatHistoryPage
Map<String, dynamic> toJson() => {
  'messages': messages.map((m) => m.toJson()).toList(),
  'next_before': nextBefore,
};
```

**⚠️ `StudentProfile` caveat:** it already has a `toJson`, but it is **lossy** — it
was built for the PUT body and drops `onboarding_completed`, `created_at`,
`updated_at`. **Do not reuse it for caching.** Add a separate full-fidelity
`toCacheJson()`; cache reads use the existing full `StudentProfile.fromJson`:

```dart
Map<String, dynamic> toCacheJson() => {
  'board': board, 'class_no': classNo, 'preferred_language': preferredLanguage,
  'school_name': schoolName, 'onboarding_completed': onboardingCompleted,
  'created_at': createdAt?.toIso8601String(),
  'updated_at': updatedAt?.toIso8601String(),
};
```

In `lib/data/models/learn_assist.dart`:

```dart
// LearnAssistUsage
Map<String, dynamic> toJson() => {
  'date_ist': dateIst, 'used': used, 'limit': limit,
  'remaining': remaining, 'unlimited': unlimited,
};

// LearnAssistCitation — keys matching its fromJson; page_no as the list form.
Map<String, dynamic> toJson() => {
  'label': label, 'book_name': bookName, 'source_pdf': sourcePdf,
  'page_no': pageNumbers, 'score': score, 'chunk_ids': chunkIds,
};
```

**Unit test:** round-trip every model `toJson → fromJson` and assert equality
(catches the `StudentProfile` lossy trap and any DateTime/format drift).

---

## Phase 2 — Account / profile / usage SWR

All in `lib/providers/auth_provider.dart` (`BackendAccountCache`). Keep all public
method signatures and the `_loadX` network paths intact.

- Add `CacheStore get _cache => ref.read(cacheStoreProvider);` and key helpers:
  ```dart
  String _userKey(String uid)    => CacheStore.key(uid: uid, name: 'backend_user');
  String _profileKey(String uid) => CacheStore.key(uid: uid, name: 'student_profile');
  String _usageKey(String uid)   => CacheStore.key(uid: uid, name: 'usage');
  ```
- Add hydrate helpers, each guarded by the corresponding `loaded` bool:
  ```dart
  void _hydrateUserFromCache(String uid) {
    if (state.userLoaded) return;
    final entry = _cache.readWithMeta<BackendUser>(
        _userKey(uid), (j) => BackendUser.fromJson(j as Map<String, dynamic>));
    if (entry != null) {
      state = state.copyWith(uid: uid, user: AsyncData(entry.value), userLoaded: true);
    }
  }
  // analogous: _hydrateProfileFromCache, _hydrateUsageFromCache
  ```
- **`ensureX` SWR rewrite** (same shape for user/profile/usage). Hydrate first; if a
  cache hit exists, **do not** flip to `AsyncLoading` (that's the spinner cause) —
  keep painting cached data and fire `_loadX` in the background (single-flight via
  the existing `_xRequest` field). Show `AsyncLoading` only on a true cold miss:
  ```dart
  Future<BackendUser?> ensureUser({bool forceRefresh = false}) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    _hydrateUserFromCache(uid);

    final cached = _asyncData(state.user);
    final hasCache = state.userLoaded && cached != null;

    if (_userRequest == null && (forceRefresh || _shouldRevalidate())) {
      if (!hasCache) state = state.copyWith(uid: uid, user: const AsyncLoading());
      _userRequest = _loadUser(uid, cached);
    }
    return hasCache ? Future.value(cached) : (_userRequest ?? Future.value(null));
  }
  ```
- In each `_loadX` **success** branch: write the cache **and diff** — only
  `copyWith(AsyncData(fresh))` if the value actually changed (compare via a value
  helper or `jsonEncode(toJson)`), else just set `xLoaded = true`. Avoids needless
  rebuilds:
  ```dart
  final user = await ref.read(backendAuthServiceProvider).me();
  if (_currentUid == uid) {
    final changed = !_userEquals(_asyncData(state.user), user);
    await _cache.write<BackendUser>(_userKey(uid), user, (u) => u.toJson());
    if (changed) state = state.copyWith(user: AsyncData(user), userLoaded: true);
    else if (!state.userLoaded) state = state.copyWith(userLoaded: true);
  }
  ```
- In each `_loadX` **failure** branch: **keep the cache** — when `cached != null`,
  do not overwrite visible `AsyncData(cached)` with `AsyncError` (silent failure).
- `saveProfile`: on success write `_profileKey` via `toCacheJson()`; existing error
  rollback stays.
- `updateUsage`: write `_usageKey` whenever usage updates from a chat response (badge
  survives restart).
- **Clear-on-signout**: in the notifier `build()`, track `previousUid`; when `uid`
  becomes null (or changes) and a previous uid existed, call
  `_cache.deleteNamespace(previousUid)`. Wipes the per-uid namespace exactly on
  sign-out / account switch. (SharedPreferences prefs are out of scope, untouched.)

---

## Phase 3 — Chat history SWR + UI

### `lib/providers/auth_provider.dart`

- History cache key (per conversation):
  ```dart
  String _historyKey(String uid, HistorySelector s) => CacheStore.key(
      uid: uid,
      name: 'history:${s.channel}:${s.board}:${s.classNo}:${s.subject ?? "_all"}');
  ```
- `_hydrateHistoryFromCache(uid, selector)` — on a selector switch, hydrate the NEW
  selector's cached page so chat repaints that conversation instantly (no
  `AsyncLoading` flash):
  ```dart
  void _hydrateHistoryFromCache(String uid, HistorySelector selector) {
    if (state.historySelector == selector && state.historyLoaded) return;
    final entry = _cache.readWithMeta<ChatHistoryPage>(
        _historyKey(uid, selector),
        (j) => ChatHistoryPage.fromJson(j as Map<String, dynamic>));
    if (entry != null) {
      state = state.copyWith(
        uid: uid,
        history: AsyncData(entry.value),
        historySelector: selector,
        historyLoaded: true,
      );
    }
  }
  ```
- `ensureHistory`: hydrate-then-background-revalidate. The background fetch always
  uses `before: null` (first page) — same as today's `forceRefresh: true`. Do not
  flip to `AsyncLoading` when a cached page is present. On success, replace and
  `_cache.write(_historyKey, mergedPage, (p) => p.toJson())`.
- `loadOlderHistory`: after a successful merge, **rewrite the full merged page** to
  the history key so an offline reopen shows everything loaded so far. Keep the
  existing `_historyRequest` single-flight guard so older-page loads and background
  revalidate don't collide.
- `prependLatestHistoryMessages`: after building the new `ChatHistoryPage`, **write
  through** to the history cache so a just-sent message persists immediately
  (offline-visible, no refetch). This is what makes "after a chat send the persisted
  history updates" pass.
- `markHistoryStale`: keep setting `historyLoaded = false` (forces the next
  `ensureHistory` to revalidate) but **do not delete** the cache — the stale page
  still paints instantly while the refetch runs.
- Add a synchronous accessor for the screen:
  ```dart
  ChatHistoryPage? peekHistory(HistorySelector selector) {
    final uid = _currentUid;
    if (uid == null) return null;
    _hydrateHistoryFromCache(uid, selector);
    return state.historySelector == selector ? _asyncData(state.history) : null;
  }
  ```

### `lib/screens/learn/learn_ai_screen.dart`

- Add an `_isRevalidating` flag (subtle background-refresh state, distinct from the
  cold `_isLoadingHistory`).
- `_loadHistory()`: read `cache.peekHistory(selector)` first. If non-null, paint it
  immediately **without** setting `_isLoadingHistory = true`; set `_isRevalidating`
  around the background `await cache.ensureHistory(selector, forceRefresh: true)`.
  Only set `_isLoadingHistory = true` on a true cold cache miss:
  ```dart
  final cache = ref.read(backendAccountCacheProvider.notifier);
  final cachedPage = cache.peekHistory(selector);
  if (cachedPage != null) {
    setState(() {
      _historyNextBefore = cachedPage.nextBefore;
      _messages..clear()..addAll(_historyToMessages(cachedPage));
      _isRevalidating = true;            // subtle, not a blocking spinner
    });
  } else {
    setState(() => _isLoadingHistory = true); // cold miss only
  }
  final page = await cache.ensureHistory(selector, forceRefresh: true);
  if (!mounted || selector != _selector) return;
  setState(() {
    _isRevalidating = false;
    _isLoadingHistory = false;
    _historyNextBefore = page?.nextBefore;
    final live = _messages.where((m) => !m.fromHistory).toList(growable: false);
    _messages..clear()..addAll(_historyToMessages(page))..addAll(live);
  });
  ```
- Gate the full-width `LinearProgressIndicator` to the cold-miss case only. For the
  cache-hit case show a subtle affordance (thin low-opacity bar or a small
  "Updating…" chip) driven by `_isRevalidating`.
- `_EmptyChat` condition (`_messages.isEmpty && !_isLoadingHistory`) stays valid — a
  cache hit makes `_messages` non-empty, so no empty-state flash.
- `forceRefresh: true` now means "revalidate in background", not "block with spinner".

---

## Phase 4 — Documentation deliverable

This file (`plan.md`).

---

## Lifecycle & design notes

- **Schema bump:** increment `kCacheSchemaVersion` whenever a persisted model shape
  changes — `readWithMeta` lazily drops mismatched entries on next read. Zero
  migration code.
- **TTL:** intentionally absent (SWR always revalidates). The single optional gate
  is `_shouldRevalidate()` using `readWithMeta(...).savedAt`; ship it as `=> true`
  and document where a max-age comparison would slot in if ever needed:
  ```dart
  bool _shouldRevalidate() => true; // SWR: always. Gate on savedAt for a max-age.
  ```
- **Single box + namespacing** keeps init and lifecycle trivial vs. multiple boxes.

## Critical files

| File | Change |
|------|--------|
| `lib/data/cache/cache_store.dart` | **new** — the framework (`CacheStore`, `CacheEntry`, `kCacheSchemaVersion`) |
| `lib/providers/auth_provider.dart` | SWR integration — largest change |
| `lib/data/services/backend_auth_service.dart` | `toJson` additions + `StudentProfile.toCacheJson` |
| `lib/data/models/learn_assist.dart` | `toJson` additions |
| `lib/providers/core_providers.dart` | `cacheStoreProvider` |
| `lib/main.dart` | Hive bootstrap + override |
| `lib/screens/learn/learn_ai_screen.dart` | cache-first paint, gated spinner |
| `plan.md` | **new** — this doc |

## Verification

1. **Cold start, instant content:** sign in, open Q&A + see the plan badge,
   force-kill, reopen → first frame shows cached history + badge with no
   `LinearProgressIndicator` and no badge "…".
2. **Airplane mode:** enable airplane mode, reopen → last cached
   history/user/profile/usage all visible, no error UI (silent-failure path); only
   *sending* errors.
3. **Sign-out wipe:** sign out → no keys remain under that uid (inspect
   `_box.keys`); sign in with a different account → no prior user's data leaks.
4. **Chat send persists:** send a message online, force-kill, reopen offline → the
   just-sent turn appears (proves write-through in `prependLatestHistoryMessages`).
5. **Revalidate diff:** with cache present, change profile/usage server-side, reopen
   → cache paints first, then UI silently updates once `_loadX` returns changed
   data; no spinner during the swap.
6. **Schema bust:** bump `kCacheSchemaVersion`, reopen → old entries dropped lazily,
   refetched, no crash.
7. `flutter analyze` clean; round-trip unit tests green.
