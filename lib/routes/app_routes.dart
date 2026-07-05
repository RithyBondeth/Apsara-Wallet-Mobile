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
import 'package:apsara_wallet_mobile/shared/constants/route_constant.dart';
import 'package:auto_route/auto_route.dart';
part 'app_routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashRoute.page,
      initial: true,
      path: AuthRouteConstant.splashPath,
    ),
    AutoRoute(
      page: OnBoardingRoute.page,
      path: AuthRouteConstant.onBoardingPath,
    ),
    AutoRoute(page: LoginRoute.page, path: AuthRouteConstant.loginPath),
    AutoRoute(page: RegisterRoute.page, path: AuthRouteConstant.registerPath),
    AutoRoute(page: OtpRoute.page, path: AuthRouteConstant.otpPath),
    AutoRoute(
      page: ForgotPasswordRoute.page,
      path: AuthRouteConstant.forgotPasswordPath,
    ),
    AutoRoute(
      page: ResetPasswordRoute.page,
      path: AuthRouteConstant.resetPasswordPath,
    ),
    AutoRoute(page: PinSetupRoute.page, path: AuthRouteConstant.pinSetupPath),
    AutoRoute(page: PinLoginRoute.page, path: AuthRouteConstant.pinLoginPath),
    AutoRoute(page: BiometricRoute.page, path: AuthRouteConstant.biometricPath),
  ];
}
