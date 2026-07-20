import 'package:apsara_wallet_mobile/core/constants/route_path_constant.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/biometric_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/pin_login_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:apsara_wallet_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:apsara_wallet_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:apsara_wallet_mobile/features/budget/presentation/screens/budget_screen.dart';
import 'package:apsara_wallet_mobile/features/categories/presentation/screens/categories_screen.dart';
import 'package:apsara_wallet_mobile/features/insights/presentation/screens/ai_insights_screen.dart';
import 'package:apsara_wallet_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:apsara_wallet_mobile/features/scan/presentation/screens/scan_receipt_screen.dart';
import 'package:apsara_wallet_mobile/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/about_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/help_support_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/rewards_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/security_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/settings_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_durations.dart';

part 'app_routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  /// House transitions — three moves, matched to what the navigation means:
  ///
  /// * **Shared-axis slide** (default): the new page slides in from the right
  ///   while the old one drifts left and dims underneath — pushes/pops read
  ///   as travelling forward/back through a flow. Popping plays it in
  ///   reverse automatically.
  /// * **Fade-through lift** (bottom-bar tabs): sibling screens cross-fade
  ///   with a soft rise, so tab hops don't imply a direction.
  /// * **Modal slide-up** (scan): the camera rises over the app like a sheet.
  @override
  RouteType get defaultRouteType => RouteType.custom(
        transitionsBuilder: _sharedAxisSlide,
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 340),
      );

  static final RouteType _tabTransition = RouteType.custom(
    transitionsBuilder: _fadeThroughLift,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 320),
  );

  static final RouteType _modalTransition = RouteType.custom(
    transitionsBuilder: _modalSlideUp,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 340),
  );

  static Widget _sharedAxisSlide(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(
      parent: animation,
      curve: AppCurves.entrance,
      reverseCurve: Curves.easeInCubic,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppCurves.gentle,
    );
    return SlideTransition(
      // This page while it is on top: enters from the right, exits back out.
      position: Tween<Offset>(
        begin: const Offset(0.28, 0),
        end: Offset.zero,
      ).animate(incoming),
      child: FadeTransition(
        opacity: incoming,
        child: SlideTransition(
          // This page while another is pushed over it: drift left and dim.
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.12, 0),
          ).animate(outgoing),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.55).animate(outgoing),
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget _fadeThroughLift(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppCurves.entrance,
      reverseCurve: Curves.easeIn,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
          child: child,
        ),
      ),
    );
  }

  static Widget _modalSlideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppCurves.entrance,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }

  @override
  List<AutoRoute> get routes => [
    // ==================================================
    // AUTH ROUTES
    // ==================================================
    AutoRoute(page: SplashRoute.page, path: RoutePathConstant.splashPath),
    AutoRoute(
      page: WelcomeRoute.page,
      path: RoutePathConstant.welcomePath,
      // Splash hands off with a calm cross-fade, not a lateral push.
      type: _tabTransition,
    ),
    AutoRoute(
      page: OnBoardingRoute.page,
      path: RoutePathConstant.onBoardingPath,
    ),
    AutoRoute(page: LoginRoute.page, path: RoutePathConstant.loginPath),
    AutoRoute(page: RegisterRoute.page, path: RoutePathConstant.registerPath),
    AutoRoute(page: OtpRoute.page, path: RoutePathConstant.otpPath),
    AutoRoute(
      page: ForgotPasswordRoute.page,
      path: RoutePathConstant.forgotPasswordPath,
    ),
    AutoRoute(
      page: ResetPasswordRoute.page,
      path: RoutePathConstant.resetPasswordPath,
    ),
    AutoRoute(page: PinSetupRoute.page, path: RoutePathConstant.pinSetupPath),
    AutoRoute(page: PinLoginRoute.page, path: RoutePathConstant.pinLoginPath),
    AutoRoute(page: BiometricRoute.page, path: RoutePathConstant.biometricPath),

    // ==================================================
    // DASHBOARD ROUTES
    // ==================================================
    AutoRoute(
      page: DashboardRoute.page,
      path: RoutePathConstant.dashboardPath,
      initial: true,
      type: _tabTransition,
    ),
    AutoRoute(
      page: AnalyticsRoute.page,
      path: RoutePathConstant.analyticsPath,
      type: _tabTransition,
    ),
    AutoRoute(
      page: ScanReceiptRoute.page,
      path: RoutePathConstant.scanReceiptPath,
      type: _modalTransition,
    ),
    AutoRoute(
      page: AddTransactionRoute.page,
      path: RoutePathConstant.addTransactionPath,
      type: _modalTransition,
    ),
    AutoRoute(page: BudgetRoute.page, path: RoutePathConstant.budgetPath),
    AutoRoute(
      page: CategoriesRoute.page,
      path: RoutePathConstant.categoriesPath,
    ),
    AutoRoute(
      page: AiInsightsRoute.page,
      path: RoutePathConstant.aiInsightsPath,
    ),
    AutoRoute(
      page: WalletsRoute.page,
      path: RoutePathConstant.walletsPath,
      type: _tabTransition,
    ),

    // ==================================================
    // PROFILE ROUTES
    // ==================================================
    AutoRoute(
      page: ProfileRoute.page,
      path: RoutePathConstant.profilePath,
      type: _tabTransition,
    ),
    AutoRoute(
      page: EditProfileRoute.page,
      path: RoutePathConstant.editProfilePath,
    ),
    AutoRoute(
      page: NotificationsRoute.page,
      path: RoutePathConstant.notificationsPath,
    ),
    AutoRoute(page: SecurityRoute.page, path: RoutePathConstant.securityPath),
    AutoRoute(page: RewardsRoute.page, path: RoutePathConstant.rewardsPath),
    AutoRoute(page: HelpSupportRoute.page, path: RoutePathConstant.helpPath),
    AutoRoute(page: AboutRoute.page, path: RoutePathConstant.aboutPath),
    AutoRoute(page: SettingsRoute.page, path: RoutePathConstant.settingsPath),
  ];
}
