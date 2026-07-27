import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/routes/app_routes.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Blocks the app's inner (post-login) routes unless a session is active.
///
/// Combined with the router's `reevaluateListenable`, a session that expires
/// mid-use re-runs this guard and bounces the user back to login.
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this.ref);

  /// The app's Riverpod handle. Null only when the router is built without DI
  /// (e.g. widget/navigation tests) — in that case the guard is a no-op so
  /// those tests can drive screens directly without a fake session.
  final WidgetRef? ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final handle = ref;
    if (handle == null) {
      resolver.next(true);
      return;
    }
    final isAuthenticated = handle.read(authControllerProvider).isAuthenticated;
    if (isAuthenticated) {
      resolver.next(true);
    } else {
      // Send them to login, then discard this pending (guarded) route.
      resolver.redirectUntil(const LoginRoute());
    }
  }
}
