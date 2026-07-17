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

- **Onboarding** — welcome, "one mission a day" explainer, account creation,
  and an animated welcome celebration straight into the free app. No hard
  paywall gate: the `$1` first-month upgrade is offered as a soft,
  dismissable prompt after the user has completed a few missions (see
  "Monetization" below), plus anytime from Profile.
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
- **`MembershipService`** — mocks the `$1` trial → `$4.99/mo` → `$39.99/yr`
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

The Android app is connected to a real Firebase project (`happy-club-156a5`)
with **real auth and Firestore sync wired in**, not just the SDK plumbing:

- `android/app/google-services.json` is committed, the Google Services
  Gradle plugin is applied, and `Firebase.initializeApp()` runs in
  `main.dart` before the app starts.
- **Auth** (`lib/services/auth_service.dart`): email/password and Google
  Sign-In. `AuthScreen` sits between the onboarding intro and the free home
  screen — every account is now a real Firebase user, not an anonymous
  local profile.
  A signed-in session is re-attached silently on app restart (Firebase Auth
  persists it natively); `attachUser`/`detachUser` in `AppState` wire that
  into the rest of the app. Sign out is in Profile → settings icon.
- **Sync** (`lib/services/firestore_service.dart`): `StorageService`
  (`SharedPreferences`) is still the fast, always-available local cache —
  Firestore is a best-effort mirror on top of it. On first sign-in, if the
  account already has data in Firestore (another device), that data
  replaces local state; otherwise the current local state is pushed up.
  After that, every mutation (`completeTodayMission`, journal entries,
  mood, posts, reactions, comments, profile edits, membership changes)
  fire-and-forget writes to Firestore in addition to saving locally. This
  is "remote wins on sign-in, then last-write-wins per mutation" — not
  proper multi-device conflict resolution, which would be the next step
  for a product meant to be used on multiple devices at once.
- **Security rules** are in `firestore.rules` at the repo root (paste into
  Firebase Console → Firestore Database → Rules → Publish): a user can only
  read/write their own `users/{uid}` doc and subcollections; the shared
  `posts` collection is readable by any signed-in member, but you can only
  create/delete your own posts, and reacting to someone else's post can
  only touch its `reactionCounts` field.

Still to do:

- **Google Sign-In needs two things only you can provide** (see below):
  SHA-1 fingerprints registered in the Firebase console, and the OAuth Web
  client ID dropped into `lib/services/google_sign_in_config.dart`. Without
  these, email/password sign-in works but Google Sign-In will fail.
- iOS isn't configured — only `google-services.json` (Android) exists. Add
  an iOS app in the Firebase console, download `GoogleService-Info.plist`,
  and run `flutterfire configure` to generate `firebase_options.dart` if/when
  iOS needs it.
- Restrict the API key in `google-services.json` (Google Cloud Console →
  Credentials) to this Android package + SHA-1 fingerprint. Low-risk in a
  private repo, worth doing before it's ever made public.
- No password-reset UI yet (`AuthService.sendPasswordResetEmail` exists,
  just isn't wired to a button).
- The Happy Feed only pulls remote posts once, on sign-in — it's not a live
  stream, so you won't see other users' new posts appear in real time
  without restarting/re-signing-in. Swapping `loadRecentPosts` for a
  Firestore `.snapshots()` stream is the natural upgrade.

### Google Sign-In setup (you need to do this in the console)

1. **SHA-1 fingerprints** — Firebase Console → Project settings → your
   Android app → "Add fingerprint":
   - Release: `B5:30:0A:79:1B:6D:7B:FA:C2:BF:6E:FE:C8:F7:D4:0A:E0:CB:E8:6C`
     (from the upload keystore generated earlier in this conversation)
   - Debug (needed for local `flutter run` testing): get yours with
     `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
     on whatever machine you run/debug the app from — every developer
     machine has a different debug keystore, so add each one that needs it.
2. **Web client ID** — Firebase Console → Authentication → Sign-in method →
   Google → expand it → copy the "Web client ID" (or Google Cloud Console →
   APIs & Services → Credentials → the OAuth client named "Web client (auto
   created by Google Service)"). Paste it into
   `googleSignInServerClientId` in `lib/services/google_sign_in_config.dart`.
   Without this, Firebase can't verify the Google ID token's audience and
   sign-in will fail even though the button works.

## AI Coach: Gemini via a Cloud Function

`AiCoachScreen`'s free-text chat now tries a real Gemini-backed reply before
falling back to `AiCoachService`'s offline templates (which still power the
daily greeting and the three quick-action buttons, since those are
deterministic and driven by local app data rather than open conversation).

The API key never ships in the app. `functions/index.js` is a Firebase
Cloud Function (`coachChat`, 2nd gen, callable) that holds the Gemini key
server-side, checks the caller is signed in, and proxies the request. The
Flutter side is `lib/services/ai_backend_service.dart`, called via the
`cloud_functions` package — any failure (not deployed yet, offline, quota)
just falls through to the offline coach, so the feature degrades gracefully
rather than erroring.

**Deploying the function** (needs the Firebase CLI logged into an account
with access to `happy-club-156a5`, which isn't something I can do from
here):

```bash
npm install -g firebase-tools   # if you don't have it
firebase login
firebase functions:secrets:set GEMINI_API_KEY
# ^ paste your Gemini API key from https://aistudio.google.com/apikey
#   when prompted. This is a Firebase/Google Secret Manager secret — a
#   separate thing from the GEMINI_API_KEY you added to GitHub Actions
#   secrets, which Cloud Functions can't see.
firebase deploy --only functions
```

Requirements before that works:
- The Firebase project must be on the **Blaze (pay-as-you-go) plan** —
  Cloud Functions' free Spark plan can't make outbound network calls, which
  calling the Gemini API needs. Firebase Console → upgrade project.
- The account running `firebase login` needs Owner/Editor on the project.

Nothing on the Flutter side needs to change after deploying — the app calls
the function by name (`coachChat`) via the Firebase SDK, not a URL, so it
resolves automatically once the function exists.

## Monetization

The app is free-first: `AuthScreen` → an animated welcome screen →
straight into `RootShell`, no purchase gate in between. This matters most
before the app has real download/review numbers to lean on — a cold paywall
in front of zero social proof converts poorly, so the pitch is only shown
once the user has actually felt the habit loop work.

- **Soft, engagement-triggered upgrade offer**: `AppState.shouldShowUpgradeOffer`
  goes true once the user has completed `upgradeOfferMissionThreshold` (3)
  missions and isn't already a member; `home_screen.dart` then pushes
  `MembershipScreen` once, with a contextual strap-line ("You've completed 3
  missions — real momentum!"). `markUpgradeOfferShown` persists that it was
  shown so it never interrupts again — after that, upgrading is opt-in only,
  from the "Free Explorer" badge on Profile.
- **Plans**: `$1` first month → `$4.99/mo` → `$39.99/yr` (anchored as the
  better deal against monthly). Premium unlocks the real Gemini AI Coach,
  happiness trend analytics, exclusive cosmetics, early event access, and a
  Founding Member badge — see `MembershipScreen`'s benefit list.
- **Streak Freeze** (`AppState.streakFreezes`): a loss-aversion mechanic —
  missing exactly one day no longer resets the streak if a freeze is
  available (`GamificationService.nextStreak`, consumed automatically).
  Every membership purchase grants one; free users can buy one with coins
  (`AppState.buyStreakFreeze`, `AppState.streakFreezeCoinCost` = 150) via the
  snowflake chip next to the streak flame on Home.

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

- Auth (email/password + Google) and Firestore sync are wired — see the
  **Firebase** section above for what's done vs. what's still
  console-side setup (SHA-1s, web client ID).
- The Gemini-backed AI Coach is wired — see **AI Coach: Gemini via a Cloud
  Function** above; it just needs the Cloud Function deployed.
- Replace `MembershipService`'s mock purchase with real platform billing and
  server-side receipt validation.
- Add server-side content moderation for the Happy Feed (the current
  `ModerationService` is client-side only, a first line of defense that can
  be bypassed).
- Make the Happy Feed a live stream (`Firestore.snapshots()`) instead of a
  fetch-once-on-sign-in list.
- Wire push notifications (positive nudges: "today's mission is waiting",
  "someone celebrated your achievement", streak reminders).
- Add crash reporting/analytics and an accessibility pass (screen reader
  labels, dynamic type, contrast checks) before release.
