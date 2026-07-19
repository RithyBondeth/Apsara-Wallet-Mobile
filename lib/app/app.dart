import 'package:apsara_wallet_mobile/core/configs/config_service.dart';
import 'package:apsara_wallet_mobile/core/providers/locale_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Created once and kept stable: rebuilding MyApp on a language change must
  // NOT recreate the router, or the navigation stack would reset to the
  // initial route on every switch.
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConfigService.appName,
      theme: AppTheme.lightTheme,
      // Light-only by design: the app's premium emerald/ivory look is a
      // single appearance; no dark mode (and no following the OS setting).
      themeMode: ThemeMode.light,

      // Localization — changing `locale` rebuilds the whole tree (incl. every
      // pushed route) in the new language.
      locale: language.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      routerConfig: _appRouter.config(),
    );
  }
}
