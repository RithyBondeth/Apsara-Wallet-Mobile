import 'package:apsara_wallet_mobile/core/routes/app_routes_constant.dart';
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
import 'package:apsara_wallet_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:auto_route/auto_route.dart';

part 'app_routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // ==================================================
    // AUTH ROUTES
    // ==================================================
    AutoRoute(
      page: SplashRoute.page,
      initial: true,
      path: AppRouteConstant.splashPath,
    ),
    AutoRoute(
      page: OnBoardingRoute.page,
      path: AppRouteConstant.onBoardingPath,
    ),
    AutoRoute(page: LoginRoute.page, path: AppRouteConstant.loginPath),
    AutoRoute(page: RegisterRoute.page, path: AppRouteConstant.registerPath),
    AutoRoute(page: OtpRoute.page, path: AppRouteConstant.otpPath),
    AutoRoute(
      page: ForgotPasswordRoute.page,
      path: AppRouteConstant.forgotPasswordPath,
    ),
    AutoRoute(
      page: ResetPasswordRoute.page,
      path: AppRouteConstant.resetPasswordPath,
    ),
    AutoRoute(page: PinSetupRoute.page, path: AppRouteConstant.pinSetupPath),
    AutoRoute(page: PinLoginRoute.page, path: AppRouteConstant.pinLoginPath),
    AutoRoute(page: BiometricRoute.page, path: AppRouteConstant.biometricPath),

    // ==================================================
    // DASHBOARD ROUTES
    // ==================================================
    AutoRoute(page: DashboardRoute.page, path: AppRouteConstant.dashboardPath),
  ];
}
