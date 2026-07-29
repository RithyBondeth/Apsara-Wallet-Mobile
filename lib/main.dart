import 'package:apsara_wallet_mobile/app/app.dart';
import 'package:apsara_wallet_mobile/core/configs/config_service.dart';
import 'package:apsara_wallet_mobile/core/enums/environment_enum.dart';
import 'package:apsara_wallet_mobile/core/providers/currency_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/locale_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/notification_prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfigService.initialize(EEnvironmentType.dev);

  // Seed persisted preferences from storage before the first frame so the app
  // opens in the user's saved language / currency / notification settings.
  final savedLanguage = await LocaleNotifier.loadSaved();
  final savedCurrency = await CurrencyNotifier.loadSaved();
  final savedNotifPrefs = await NotificationPrefsNotifier.loadSaved();

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => LocaleNotifier(savedLanguage)),
        currencyProvider.overrideWith((ref) => CurrencyNotifier(savedCurrency)),
        notificationPrefsProvider
            .overrideWith((ref) => NotificationPrefsNotifier(savedNotifPrefs)),
      ],
      child: const MyApp(),
    ),
  );
}
