import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_models.dart';
import '../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// The single source of truth for whether someone is signed in. `unknown` is
/// the boot state (before [AuthController.restore] runs) so the splash can
/// wait rather than flashing the wrong screen.
class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  /// Boot-time session restore. Called from the splash screen.
  Future<void> restore() async {
    try {
      final user = await _repo.restoreSession();
      state = state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
        clearUser: user == null,
      );
      if (user != null) await _refreshProfile();
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    }
  }

  /// Pulls the authoritative profile (real name, phone) from the backend and
  /// updates state if it succeeds. Best-effort — a failure leaves the
  /// token-derived user in place.
  Future<void> _refreshProfile() async {
    final profile = await _repo.fetchProfile();
    if (profile != null && state.status == AuthStatus.authenticated) {
      state = state.copyWith(user: profile);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final user = await _repo.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      await _refreshProfile();
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final user = await _repo.register(
        email: email,
        fullName: fullName,
        password: password,
        phone: phone,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      await _refreshProfile();
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Updates the signed-in user's name/phone and reflects it in state.
  Future<bool> updateProfile({String? fullName, String? phone}) async {
    try {
      final user = await _repo.updateProfile(fullName: fullName, phone: phone);
      state = state.copyWith(user: user);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Invoked by the network layer when a refresh attempt fails (the session is
  /// no longer valid). Flips state so the router guard bounces to login.
  void onSessionExpired([String? message]) {
    if (state.status == AuthStatus.unauthenticated) return;
    state = AuthState(status: AuthStatus.unauthenticated, errorMessage: message);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
