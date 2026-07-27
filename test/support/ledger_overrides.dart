import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/features/auth/data/auth_models.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_mock_data.dart';
import 'package:apsara_wallet_mobile/features/wallets/data/wallet_providers.dart';

/// In-memory replacements for the now API-backed [transactionsProvider] and
/// [walletsProvider], so widget tests keep running against the Phase-1 sample
/// data instead of hitting the network. They mirror the real notifiers'
/// public surface (`add`/`remove`, `add`) with local state.
class _FakeTransactionsNotifier extends TransactionsNotifier {
  _FakeTransactionsNotifier(List<TransactionRecord> seed)
      : _items = [...seed]..sort((a, b) => b.date.compareTo(a.date));

  // Mutated IN PLACE (never reassigned) and returned by reference from
  // build(), so a build() future that resolves *after* an add()/remove()
  // still reflects the change instead of clobbering it with a stale snapshot.
  final List<TransactionRecord> _items;

  @override
  Future<List<TransactionRecord>> build() async => _items;

  @override
  Future<void> add(TransactionRecord record) async {
    _items
      ..removeWhere((t) => t.id == record.id)
      ..insert(0, record)
      ..sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData([..._items]);
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((t) => t.id == id);
    state = AsyncData([..._items]);
  }
}

class _FakeWalletsNotifier extends WalletsNotifier {
  _FakeWalletsNotifier(this._seed);

  final List<Wallet> _seed;

  @override
  Future<List<Wallet>> build() async => [..._seed];

  @override
  Future<void> add(Wallet wallet) async {
    state = AsyncData([...(state.valueOrNull ?? const []), wallet]);
  }
}

/// A fixed, always-authenticated auth controller for tests — supplies a stable
/// user so the dashboard greeting renders a real name in goldens. The mutating
/// methods are unused by widget tests, so they no-op.
class _FixedAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FixedAuthController(AuthUser user)
      : super(AuthState(status: AuthStatus.authenticated, user: user));

  @override
  Future<void> restore() async {}
  @override
  Future<bool> login({required String email, required String password}) async =>
      true;
  @override
  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
    String? phone,
  }) async =>
      true;
  @override
  Future<void> logout() async {}
  @override
  void onSessionExpired([String? message]) {}
  @override
  void clearError() {}
}

/// Provider overrides that seed the ledger + wallets with sample data and a
/// stable signed-in user.
List<Override> sampleLedgerOverrides({
  List<TransactionRecord>? transactions,
  List<Wallet>? wallets,
  AuthUser? user,
}) {
  final txs = transactions ?? sampleTransactions();
  final ws = wallets ?? WalletsData.sample.wallets;
  final u = user ??
      const AuthUser(id: 'sample-user', email: 'sokunthea@example.com', fullName: 'Sokunthea');
  return [
    transactionsProvider.overrideWith(() => _FakeTransactionsNotifier(txs)),
    walletsProvider.overrideWith(() => _FakeWalletsNotifier(ws)),
    authControllerProvider.overrideWith((ref) => _FixedAuthController(u)),
  ];
}
