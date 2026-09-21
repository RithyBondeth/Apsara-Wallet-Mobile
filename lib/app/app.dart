import 'dart:async';

import 'package:apsara_wallet_mobile/core/configs/config_service.dart';
import 'package:apsara_wallet_mobile/core/deep_links/app_deep_link.dart';
import 'package:apsara_wallet_mobile/core/deep_links/deep_link_provider.dart';
import 'package:apsara_wallet_mobile/core/providers/locale_provider.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/features/security/presentation/app_lock_gate.dart';
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
  // initial route on every switch. Built in initState because the router now
  // needs `ref` to drive its auth guard.
  late final AppRouter _appRouter = AppRouter(ref);

  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    // Incoming links (the one that cold-started the app is replayed too).
    // Unknown or malformed links parse to null and are dropped.
    _links = ref.read(deepLinkSourceProvider).listen((uri) {
      final link = AppDeepLink.parse(uri);
      if (link != null) ref.read(deepLinkProvider.notifier).set(link);
    });
  }

  @override
  void dispose() {
    _links?.cancel();
    super.dispose();
  }

  /// Opens a pending link now if the app is already running; while the splash
  /// is still up, leave it — the splash consumes it when it hands off, so its
  /// own navigation can't wipe ours.
  void _openPendingLink(AppDeepLink? link) {
    if (link == null) return;
    final top = _appRouter.stack.isEmpty ? null : _appRouter.topRoute.name;
    if (top == null || top == SplashRoute.name) return;
    ref.read(deepLinkProvider.notifier).take();
    _appRouter.push(link.route);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider);

    ref.listen(deepLinkProvider, (_, link) => _openPendingLink(link));

    // When the session ends (logout or an expired/failed refresh), re-run the
    // route guards so any open protected screen is bounced back to login.
    ref.listen(authControllerProvider.select((s) => s.isAuthenticated), (
      previous,
      isAuthenticated,
    ) {
      if (previous == true && isAuthenticated == false) {
        _appRouter.reevaluateGuards();
      }
    });

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

      // App-lock overlay sits above the whole navigator so it can cover any
      // screen and re-lock on resume.
      builder: (context, child) =>
          AppLockGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
