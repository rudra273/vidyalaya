# UI Upgrade Plan — Claymorphism, Illustrations & Student Avatars

Three independent tracks. Ship in order; each is usable on its own.

---

## Track 1 — Claymorphism (soft, premium depth)

**Goal:** Add subtle clay-style depth without breaking the calm/flat system.
Do it as ONE reusable widget so it stays consistent and easy to tune.

> Note: current cards are flat (`elevation: 0`, hairline border). Don't make
> everything clay — pick "hero" surfaces (avatar, stat cards, primary CTAs,
> tool tiles). Over-using soft shadows looks cheap, not premium.

### Steps
1. **Add clay tokens** to `AppColors` in `lib/app/theme.dart`:
   - Light: `clayShadow = #C9D4C9` (darker sage), `clayHighlight = #FFFFFF`.
   - Dark: `clayShadowDark = #0A0F0C`, `clayHighlightDark = #1F2A23`.
2. **New widget** `lib/widgets/clay_card.dart` → `ClayCard`:
   - Rounded container (reuse `AppSpacing.cardRadius`).
   - Two `BoxShadow`s: bottom-right dark (shadow), top-left light (highlight),
     blur ~16, spread negative, low offsets (~4–6px). Theme-aware.
   - Optional `pressed`/`inset` variant for the neumorphic "pressed in" look.
3. **Apply selectively** (swap existing `Container`/`Card` decoration):
   - `_BigAvatar` + `_StatsStrip` in `profile_screen.dart`.
   - Home tool tiles / hero card.
   - Primary `ElevatedButton` CTAs (or a `ClayButton` variant).
4. Verify in BOTH light + dark. Tune blur/offset until soft, not muddy.

**Acceptance:** Clay surfaces read as gently raised; flat list rows unchanged.

---

## Track 2 — Per-page illustrations

**Goal:** A friendly illustration on key/empty states (home header, empty
bookmarks, empty downloads, onboarding, progress).

### Setup
1. Add `flutter_svg: ^2.0.10+1` to `pubspec.yaml` deps.
2. Create `assets/illustrations/` and register it under `flutter: assets:`.
3. Source SVGs (consistent style + palette to match the sage theme).
   Candidates: unDraw, Storyset, or commissioned. Keep ≤ a handful, on-brand.
4. **New widget** `lib/widgets/app_illustration.dart` → thin `SvgPicture.asset`
   wrapper with sizing + optional caption, so usage is one line per screen.

### Where to place (start small, 2–3 screens)
- `onboarding/welcome_screen.dart` — hero illustration.
- Empty states: `bookmarks/`, `downloads/manage_downloads_screen.dart`.
- `home/home_screen.dart` — small header accent (optional).

**Acceptance:** Illustrations render light + dark, scale cleanly, no layout
shift, assets registered.

---

## Track 3 — Student avatars (boy / girl)

**Goal:** Replace letter-avatar with a chosen boy/girl avatar on the profile.

> Current state: avatars are letter-based (`_BigAvatar`, `_SmallAvatar` in
> `profile_screen.dart`). `StudentProfile` has board/classNo/preferredLanguage/
> schoolName — NO gender/avatar field yet.

### Steps
1. **Assets:** add `assets/avatars/boy.png` (+ girl, + a neutral default).
   Register `assets/avatars/` in pubspec. (SVG also fine via Track 2 setup.)
2. **Model:** add `avatar` (e.g. `'boy' | 'girl' | null`) to `StudentProfile`
   in `lib/data/services/backend_auth_service.dart` — include in
   `toJson`/`fromJson` and the save call in `_saveStudentProfile`.
   - Decide: persist to backend, or local-only via `shared_preferences`?
     (Local-only is faster to ship; backend syncs across devices.)
3. **Picker UI:** in the Student profile card, add an "Avatar" row that opens
   a bottom sheet (reuse the `_showClassPicker` pattern) showing boy/girl
   options; selecting updates state + saves.
4. **Render:** update `_BigAvatar` to show the chosen image (fallback to the
   letter when none chosen). Optionally `_SmallAvatar` too.

**Acceptance:** User picks boy/girl, it persists across restarts, shows on
profile; letter fallback works when unset.

---

## Suggested order
1. Track 1 (ClayCard) — biggest visual lift, self-contained.
2. Track 3 (avatars) — clear user-facing feature.
3. Track 2 (illustrations) — depends on sourcing good SVGs.

## Decisions (locked)
- **Avatar persistence:** LOCAL ONLY via `shared_preferences` (key e.g.
  `student_avatar` = `'boy'|'girl'`). No backend/model changes needed — Track 3
  step 2 simplifies to a prefs read/write.
- **Claymorphism scope:** ACCENT ONLY — clay on avatar, stat cards, primary
  CTAs / tool tiles. List rows + forms stay flat.

## Still open
- Illustration source/style (need a consistent on-brand set).
