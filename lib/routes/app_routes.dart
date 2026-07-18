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
      path: RoutePathConstant.splashPath,
    ),
    AutoRoute(page: WelcomeRoute.page, path: RoutePathConstant.welcomePath),
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
    AutoRoute(page: DashboardRoute.page, path: RoutePathConstant.dashboardPath),
  ];
}
