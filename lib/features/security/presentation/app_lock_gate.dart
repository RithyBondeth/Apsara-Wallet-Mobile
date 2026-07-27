import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/features/security/application/app_lock_controller.dart';
import 'package:apsara_wallet_mobile/features/security/presentation/lock_screen.dart';

/// Wraps the whole app (via `MaterialApp.builder`) and, when the session is
/// locked, paints the [LockScreen] over everything. Also the lifecycle hook
/// that re-locks after the app has been backgrounded past the timeout.
///
/// The lock only shows while the user is authenticated — app-lock is
/// meaningless on the signed-out login screens.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(appLockControllerProvider).isLoaded) {
        ref.read(appLockControllerProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(appLockControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        controller.onForegrounded();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        controller.onBackgrounded();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        ref.watch(authControllerProvider.select((s) => s.isAuthenticated));
    final lock = ref.watch(appLockControllerProvider);
    final showLock = isAuthenticated && lock.isPinSet && lock.isLocked;

    return Stack(
      children: [
        widget.child,
        if (showLock) const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}
