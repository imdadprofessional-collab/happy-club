# Happy Club: Depression Killer

A daily positive-habit, gratitude, and personal-growth community app. The app
does **not** diagnose, treat, or claim to cure depression or any mental
health condition — it's a habit-formation and community product inspired by
positive psychology (gratitude, kindness, consistency, connection).

Built with Flutter so a single codebase targets both Android and iOS, as
allowed by the product brief.

## What's implemented

A fully working, polished app experience running entirely offline against
local device storage:

- **Onboarding** — welcome, "one mission a day" explainer, `$1` first-month
  paywall, and an animated payment-success celebration.
- **Home** — today's mission, streak flame, happiness score, XP/level bar,
  mood check-in, daily quote, and community highlights.
- **200+ hand-written daily missions** across all 20 categories from the
  brief (`lib/data/missions_data.dart`), selected by `MissionEngine`, which
  avoids recently-repeated missions and rotates categories.
- **Mission completion flow** — confetti, haptics, XP/coins/streak/badge
  rewards, occasional surprise bonuses, and a one-tap editable auto-post into
  the community feed.
- **Happy Feed** — X/Twitter-style feed with only positive reactions (Love,
  Care, Applaud, Inspired, Keep Going, Smile), encouraging comments, and
  client-side kindness moderation on posts/comments.
- **Grow hub** — gratitude journal (private or shared to the feed, with
  search), evening reflection journal, an annual happiness calendar
  (completed days light up in their mission's category color), and weekly /
  monthly / community challenges.
- **Gamification** — XP curve, levels with a title ladder ("Positive
  Beginner" → "Happiness Master"), streak milestones (7/14/30/60/100/180/365),
  a private happiness score, and an achievement/badge collection.
- **AI Happiness Coach** — a chat-style coach with daily encouragement,
  reflection prompts, mission suggestions, and weekly summaries.
- **Profile** — level, streak, happiness score, membership status, mission
  history, recent posts, and light/dark/system theme control.
- Material 3, light & dark themes, glassmorphism cards, gradient hero
  surfaces, and micro-animations throughout.

## Architecture

```
lib/
  theme/        Design system: colors, Material 3 light/dark ThemeData
  widgets/       Reusable UI: glass cards, gradient cards, buttons, XP bar…
  models/        Plain data classes (Mission, Post, JournalEntry, …)
  data/          Static content: 200+ missions, quotes, achievements, seed posts
  services/      Business logic, each with a narrow, swappable interface
  state/         AppState — single ChangeNotifier the whole UI reads/writes
  screens/       Feature screens, grouped by flow (onboarding/home/feed/…)
```

`AppState` (`lib/state/app_state.dart`) is the single source of truth. It's
intentionally structured so the local-only implementation can be swapped for
a real backend without changing the UI layer:

- **`StorageService`** — the only thing touching on-device storage today
  (`SharedPreferences`). In production this becomes a repository backed by
  **Firebase Auth** (identity) + **Firestore** (synced documents), with this
  class's shape mostly unchanged — see the doc comment in
  `storage_service.dart`. Firebase itself is now wired into the app (see
  below) but `AppState` doesn't read/write Firestore yet — that repository
  swap is the next step.
- **`MembershipService`** — mocks the `$1` trial → `$4.99/mo` → `$49.99/yr`
  purchase flow. Swap for Google Play Billing / StoreKit (or a wrapper like
  RevenueCat), mirroring entitlement state server-side.
- **`AiCoachService`** — ships fully offline with curated response
  templates so coaching always works with zero setup. To upgrade to a real
  LLM, replace the method bodies with calls to a backend endpoint that
  proxies a model API — never embed a model API key in the client.
- **`ModerationService`** — a client-side first line of defense (instant
  typing feedback). A real deployment must also run server-side moderation
  before content becomes publicly visible.

## Firebase

The Android app is connected to a real Firebase project (`happy-club-156a5`):
`android/app/google-services.json` is committed, the Google Services Gradle
plugin is applied (`android/settings.gradle.kts` + `android/app/build.gradle.kts`),
and `Firebase.initializeApp()` runs in `main.dart` before the app starts.
`firebase_core` and `cloud_firestore` are in `pubspec.yaml`.

That's the plumbing, not the wiring: no screen reads or writes Firestore
yet, and there's no Firebase Auth — the app still runs entirely on local
`SharedPreferences` via `StorageService`. Still to do:

- Enable a sign-in method in the Firebase console (Authentication tab) and
  add a real `AuthService` + sign-in screen — right now every install is an
  anonymous, unlinked local profile.
- Write a `FirestoreRepository` behind the same shape as `StorageService`
  and swap it into `AppState` (missions, posts, journals, gamification
  state) so data syncs across devices instead of staying on-device.
- Set real Firestore security rules once there's an auth model — Firestore
  starts locked down (or wide open in test mode) by default; don't ship
  either extreme.
- iOS isn't configured — only `google-services.json` (Android) exists. Add
  an iOS app in the Firebase console, download `GoogleService-Info.plist`,
  and run `flutterfire configure` to generate `firebase_options.dart` if/when
  iOS needs it.
- Restrict the API key in `google-services.json` (Google Cloud Console →
  Credentials) to this Android package + SHA-1 fingerprint. It's low-risk in
  a private repo, but worth doing before the repo is ever made public.

## Running it

```bash
flutter pub get
flutter run            # launches on a connected device/emulator
flutter analyze        # static analysis
flutter test           # widget + data tests
```

This sandbox has no Android SDK/emulator or iOS toolchain, so the app was
verified with `flutter analyze` (full static type-check across the entire
codebase) and `flutter test` (a widget test that boots the real app —
Provider, routing, storage bootstrap — through to the onboarding screen,
plus a data test asserting the mission library covers 200+ missions across
every category). Both are clean. Running on an actual device/emulator is the
next step before shipping.

## Before shipping to production

- Wire `StorageService`/`AppState` to Firebase Auth + Firestore for real
  accounts and cross-device sync.
- Replace `MembershipService`'s mock purchase with real platform billing and
  server-side receipt validation.
- Add server-side content moderation for the Happy Feed.
- Replace `AiCoachService`'s templates with a real model call through a
  backend proxy.
- Wire push notifications (positive nudges: "today's mission is waiting",
  "someone celebrated your achievement", streak reminders).
- Add crash reporting/analytics and an accessibility pass (screen reader
  labels, dynamic type, contrast checks) before release.
