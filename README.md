# Apsara Wallet

Personal finance app for Cambodia: track spending across KHR and USD wallets,
set budgets and savings goals, scan receipts, and get spending insights.
Flutter, backed by the [Apsara Wallet API](../Apsara-Wallet-API).

Bundle ID on both platforms: `com.apsarawallet.app`.

## Requirements

- Flutter 3.44 (stable) — CI pins `3.44.8`
- Xcode for iOS, Android Studio / SDK for Android
- The API running locally on port 3010 (see its README), unless you point
  `API_BASE_URL` somewhere else

## Run it locally

```bash
flutter pub get
flutter gen-l10n                                   # generates lib/l10n/generated/
dart run build_runner build --delete-conflicting-outputs   # auto_route → app_routes.gr.dart
flutter run
```

Without `--dart-define` you get the **dev** environment, which reads
`.env.dev` and talks to `http://localhost:3010/api/v1`. The Android emulator
reaches the host through `10.0.2.2`; `dio_client` rewrites `localhost` for you,
so the one URL works on the iOS Simulator, the Android emulator and web.

Switch environments at build time — it is a compile-time constant, so a
release build can never silently ship pointing at localhost:

```bash
flutter run --dart-define=ENV=staging     # .env.staging
flutter run --dart-define=ENV=prod        # .env.prod
```

## Configuration

`.env.dev`, `.env.staging` and `.env.prod` are bundled as assets and selected by
`ENV`. Keys:

| Key | Purpose |
|---|---|
| `APP_NAME` | Display name shown for that environment |
| `API_BASE_URL` | Backend origin including `/api/v1` |
| `DEBUG_MODE` | Verbose logging |
| `SENTRY_DSN` | Crash reporting. Empty disables Sentry entirely (dev is blank on purpose) |

Feature flags live in `lib/core/constants/app_constant.dart`. Social login and
the 2FA toggle are off because there is no backend for them yet — keep controls
with no backend hidden rather than showing "coming soon"; store reviewers flag
those.

## Project layout

```
lib/
├── main.dart
├── app/                 # MaterialApp, theme, router wiring
├── routes/              # auto_route table (app_routes.gr.dart is generated)
├── l10n/                # app_en.arb, app_km.arb → generated/ (English + Khmer)
├── core/
│   ├── configs/         # Environment + ConfigService (.env loading)
│   ├── constants/       # AppConstants, route paths, feature flags
│   ├── networks/        # Dio client, interceptors, ApiException
│   ├── security/        # PIN codec, biometric unlock, app-lock storage
│   ├── storage(s)/      # secure storage, shared prefs, JSON snapshot cache
│   ├── monitoring/      # Sentry setup (no PII, tracing off)
│   ├── themes/          # design tokens (AppSpacing, colours, typography)
│   └── providers/, utils/, extensions/, enums/
├── shared/widgets/      # cross-feature UI: bottom bar, side menu, cards
└── features/            # one folder per screen group
    ├── auth/            # login, register, forgot/reset password
    ├── dashboard/
    ├── wallets/         # KHR/USD wallets, reorder, transfers
    ├── transactions/    # ledger, add/edit, CSV export
    ├── categories/
    ├── budget/
    ├── recurring/
    ├── scan/            # receipt OCR → transaction
    ├── analytics/
    ├── insights/        # rule-based spending insights
    ├── notifications/   # in-app inbox
    ├── profile/         # settings, security & privacy, change password,
    │                    # savings goals, legal, help & feedback
    └── security/        # app lock: PIN / biometric gate and lock screen
```

Each feature has a `data/` layer (API clients, repositories, Riverpod
providers) and/or `application/` (controllers), plus `presentation/`
(`screens/`, `widgets/`). State is Riverpod; navigation is auto_route.

### Deep links

The app registers the `apsarawallet://` scheme (Android intent-filter, iOS
`CFBundleURLTypes`) and handles links in Dart via `app_links`, so Flutter's
own deep-link routing is switched off in both manifests. Incoming URIs are
parsed by `core/deep_links/app_deep_link.dart` — anything unrecognised is
dropped — and opened on top of the current screen, or, at cold start, on top
of the splash's landing screen. The only link today is the password-reset
email: `apsarawallet://reset-password?token=…`, and its https twin
`https://wallet.apsara.social/reset-password?token=…`. The https form opens in the
app directly once Universal Links / App Links verify against the association
files that `Apsara-Wallet-Web` serves from `/.well-known` — that needs the
Associated Domains capability on the App ID (`ios/Runner/Runner.entitlements`)
and the signing fingerprint published on the web side.

### Receipt OCR

Text recognition runs natively through the `apsara/ocr` method channel —
Apple Vision on iOS (`ios/Runner/OcrPlugin.swift`, works on the Simulator) and
ML Kit on Android (`MainActivity.kt`). The parsing heuristics stay in pure
Dart (`features/scan/data/receipt_parser.dart`) so they are unit-testable.

## Tests

```bash
dart format lib test    # CI fails on unformatted files
flutter analyze
flutter test
```

`test/` mixes unit tests (parsers, repositories, insight engine), widget and
navigation tests, and golden tests. Goldens are rendered on a developer Mac;
`test/flutter_test_config.dart` allows ≤1% pixel drift so other machines and
CI don't fail on font rasterisation. To regenerate after an intentional UI
change:

```bash
flutter test --update-goldens
```

CI (`.github/workflows/ci.yml`) runs two jobs on every PR: `test`
(`gen-l10n`, a `dart format` check, `analyze`, the full suite) and `build`
(a debug Android APK and an unsigned iOS Simulator build), so manifest,
plist, Gradle and plugin-linking breakage is caught before merge.

## Localisation

Strings live in `lib/l10n/app_en.arb` and `lib/l10n/app_km.arb`. Add the key
to both, then run `flutter gen-l10n`. The generated files are committed, so
the app builds without a code-gen step in most editors.

## Release

See [RELEASE.md](RELEASE.md): pointing a build at the deployed API, crash
reporting, the upload keystore, and building the App Bundle / IPA.

## Related

- [Apsara-Wallet-API](../Apsara-Wallet-API) — NestJS backend
- [Apsara-Wallet-Web](../Apsara-Wallet-Web) — marketing site and the store
  compliance pages (`/privacy`, `/terms`, `/delete-account`, `/support`)
