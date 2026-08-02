# Releasing Apsara Wallet

## Identity (fixed — do not change after publishing)

| | |
|---|---|
| Android `applicationId` | `com.apsarawallet.app` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.apsarawallet.app` |
| Display name | Apsara Wallet |

## 1. Point the app at a deployed backend

The API must be reachable over HTTPS from a real device. Deploy it first —
see `apsara-wallet-api/DEPLOYMENT.md` — then replace the `TODO(deploy)`
placeholder in `.env.staging` (and `.env.prod`) with the real domain:

```
API_BASE_URL=https://<your-railway-domain>/api/v1
```

## 2. Pick the environment at build time

The environment is a compile-time constant, so a release build can never
silently ship pointing at `localhost`:

```bash
flutter build appbundle --release --dart-define=ENV=staging
```

`ENV` accepts `dev` (default), `staging`, and `prod`, selecting `.env.dev`,
`.env.staging`, and `.env.prod` respectively. **Omitting `--dart-define` gives
you a dev build pointing at localhost** — always pass it for anything you hand
to a tester.

## 3. Turn on crash reporting (recommended)

Without this you learn about field crashes from store reviews. Create a project
at sentry.io (Flutter platform), copy the DSN from *Project → Settings → Client
Keys*, and paste it into `SENTRY_DSN` in `.env.staging` and `.env.prod`.

An empty `SENTRY_DSN` disables reporting completely, so a build with the key
left blank still works — it just reports nothing. Dev is blank on purpose.

The SDK is configured in `lib/core/monitoring/crash_reporting.dart`: no PII, no
print breadcrumbs, tracing off, and production events sampled at 50% so a crash
loop cannot burn the quota.

## 4. Create the upload keystore (once)

Release builds are signed from `android/key.properties`, which is gitignored
along with the keystore itself. Without it the build falls back to the debug
key and prints a warning — such an artifact **cannot** be uploaded to Play.

```bash
keytool -genkey -v -keystore ~/apsara-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then copy `android/key.properties.example` to `android/key.properties` and fill
in the four values.

> Back the `.jks` file and its passwords up somewhere durable. If you lose
> them you can never ship an update to the same Play listing again.

## 5. Build

Android (Play uses App Bundles — per-device delivery keeps downloads small):

```bash
flutter build appbundle --release --dart-define=ENV=staging
```

For sideloading to a tester's device directly, split by ABI so each APK carries
one architecture instead of all three:

```bash
flutter build apk --release --split-per-abi --dart-define=ENV=staging
```

iOS:

```bash
flutter build ipa --release --dart-define=ENV=staging
```

## 6. Distribute

- **Android** — Play Console → *Testing* → *Internal testing*. Up to 100
  testers by email, no review wait.
- **iOS** — Xcode/Transporter → App Store Connect → TestFlight. Internal
  testers are immediate; external testers need a short review.

## Store listing prerequisites

Both stores block submission without a **publicly reachable privacy-policy
URL**. The `apsara-wallet-web` repo serves `/privacy` and `/terms` (and
`/support`, `/delete-account`) — deploy it and use those URLs on the listing.

Play additionally requires the **Data safety** form. The app collects account
details (name, email, phone) and financial records, transmits them over HTTPS,
and offers in-app deletion via *Security & Privacy → Delete account* — the
answer to "can users request data deletion?" is yes.

## Known gaps

- **Push notifications** are backend-only. The server records device tokens and
  can send via FCM, but the Flutter client has no Firebase dependency and no
  `google-services.json` / `GoogleService-Info.plist`. Notifications appear in
  the in-app inbox only. Wiring the client needs a Firebase project first —
  the Android Gradle plugin fails the build if the dependency is added without
  `google-services.json`, so this cannot be staged ahead of that project.
- **`AppConstants.iosAppId`** is still `000000000`. The rate sheet now detects
  this and skips the store link rather than opening a dead page, so it is safe
  to ship; replace the constant once App Store Connect assigns the real ID.
- **Support domain is inconsistent** — the app uses `support@apsarawallet.app`
  (`AppConstants.supportEmail`) while the website's `.env.example` defaults to
  `apsarawallet.com`. Pick one before the listing goes live; whichever you
  choose has to be a mailbox you actually read.
- **Khmer font** (Koh Santepheap) is fetched at runtime by `google_fonts`, so a
  first launch in Khmer with no network falls back to the default font.
