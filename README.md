<div align="center">

# Apsara Wallet — Mobile

**A personal finance app for Cambodia: track spending across KHR and USD wallets, set budgets and savings goals, scan receipts, and get spending insights.**

![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-0175C2?style=for-the-badge&logo=flutter&logoColor=white)

</div>

---

## Overview

Apsara Wallet is a cross-platform Flutter app for iOS and Android that helps people in Cambodia manage their money in both riel (KHR) and US dollars. It is backed by the [Apsara Wallet API](https://github.com/RithyBondeth/Apsara-Wallet-API) and is fully localized in English and Khmer.

## Features

- **KHR and USD wallets,** reordering, and transfers between wallets.
- **Transactions:** add and edit, categories, and CSV export.
- **Budgets, savings goals, and recurring transactions.**
- **Receipt scanning:** on-device OCR (Apple Vision on iOS, ML Kit on Android) that turns a receipt into a transaction.
- **Analytics and insights:** donut and line charts, daily trends, category breakdowns, and rule-based spending insights.
- **In-app notifications** inbox.
- **App lock:** PIN and biometric unlock.
- **Deep links** (`apsarawallet://` and Universal Links / App Links) for password reset.
- **Profile:** settings, security and privacy, legal documents, and help and feedback.
- **English and Khmer localization,** with offline caching and crash reporting through Sentry.

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter 3.44, Dart |
| State management | Riverpod |
| Navigation | auto_route |
| Networking | Dio, with auth, retry, and logging interceptors |
| Storage | Secure storage, shared preferences, JSON cache |
| OCR | Apple Vision (iOS), Google ML Kit (Android) |
| Monitoring | Sentry |
| Localization | Flutter gen-l10n (ARB) |
| CI | GitHub Actions (tests, golden tests, Android and iOS builds) |

## Getting Started

### Prerequisites

- Flutter 3.44 (stable)
- Xcode for iOS, and Android Studio or the Android SDK for Android
- The [Apsara Wallet API](https://github.com/RithyBondeth/Apsara-Wallet-API) running on port 3010, or another `API_BASE_URL`

### Installation

```bash
git clone https://github.com/RithyBondeth/Apsara-Wallet-Mobile.git
cd Apsara-Wallet-Mobile
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Choose an environment at build time:

```bash
flutter run --dart-define=ENV=staging   # .env.staging
flutter run --dart-define=ENV=prod      # .env.prod
```

### Environment Variables

| Key | Purpose |
| --- | --- |
| `APP_NAME` | Display name for the environment |
| `API_BASE_URL` | Backend origin, including `/api/v1` |
| `DEBUG_MODE` | Verbose logging |
| `SENTRY_DSN` | Crash reporting (blank disables it) |

### Testing

```bash
dart format lib test
flutter analyze
flutter test
```

## Project Structure

```text
Apsara-Wallet-Mobile/
└── lib/
    ├── app/              # MaterialApp, theme, router wiring
    ├── routes/           # auto_route table
    ├── l10n/             # app_en.arb, app_km.arb
    ├── core/             # configs, networking, security, storage, themes, utils
    ├── shared/widgets/   # Cross-feature UI
    └── features/
        ├── auth/  dashboard/  wallets/  transactions/  categories/
        ├── budget/  recurring/  scan/  analytics/  insights/
        └── notifications/  profile/  security/
```

## Release

See [RELEASE.md](RELEASE.md) for pointing a build at the deployed API, crash reporting, signing, and building the App Bundle and IPA.

## Related Repositories

- [Apsara-Wallet-API](https://github.com/RithyBondeth/Apsara-Wallet-API): the NestJS backend
- [Apsara-Wallet-Web](https://github.com/RithyBondeth/Apsara-Wallet-Web): the marketing site and app-store compliance pages

## Author

**Rithy Bondeth** — Full Stack Developer & AI Engineer

[![Portfolio](https://img.shields.io/badge/Portfolio-0A0A0A?style=for-the-badge&logo=vercel&logoColor=white)](https://bondeth.dev)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/RithyBondeth)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/rithy-bondeth-484073282/)
