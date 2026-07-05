import 'package:apsara_wallet_mobile/core/constants/routes_constant.dart';
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
      path: RoutesConstant.splashPath,
    ),
    AutoRoute(page: OnBoardingRoute.page, path: RoutesConstant.onBoardingPath),
    AutoRoute(page: LoginRoute.page, path: RoutesConstant.loginPath),
    AutoRoute(page: RegisterRoute.page, path: RoutesConstant.registerPath),
    AutoRoute(page: OtpRoute.page, path: RoutesConstant.otpPath),
    AutoRoute(
      page: ForgotPasswordRoute.page,
      path: RoutesConstant.forgotPasswordPath,
    ),
    AutoRoute(
      page: ResetPasswordRoute.page,
      path: RoutesConstant.resetPasswordPath,
    ),
    AutoRoute(page: PinSetupRoute.page, path: RoutesConstant.pinSetupPath),
    AutoRoute(page: PinLoginRoute.page, path: RoutesConstant.pinLoginPath),
    AutoRoute(page: BiometricRoute.page, path: RoutesConstant.biometricPath),

    // ==================================================
    // DASHBOARD ROUTES
    // ==================================================
    AutoRoute(page: DashboardRoute.page, path: RoutesConstant.dashboardPath),
  ];
}
