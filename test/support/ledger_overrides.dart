import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/features/auth/application/auth_controller.dart';
import 'package:apsara_wallet_mobile/features/auth/data/auth_models.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_mock_data.dart';
import 'package:apsara_wallet_mobile/features/budget/data/budget_providers.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_api.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_providers.dart';
import 'package:apsara_wallet_mobile/features/recurring/data/recurring_rule.dart';
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
  Future<void> edit(TransactionRecord record) async {
    final i = _items.indexWhere((t) => t.id == record.id);
    if (i >= 0) {
      _items[i] = record;
    } else {
      _items.insert(0, record);
    }
    _items.sort((a, b) => b.date.compareTo(a.date));
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
  Future<bool> updateProfile({String? fullName, String? phone}) async => true;
  @override
  Future<void> logout() async {}
  @override
  void onSessionExpired([String? message]) {}
  @override
  void clearError() {}
}

/// Serves fixed [BudgetData] to the Budget screen without hitting the network.
class _FakeBudgetNotifier extends BudgetNotifier {
  _FakeBudgetNotifier(this._data);
  final BudgetData _data;
  @override
  Future<BudgetData> build() async => _data;
}

/// In-memory recurring rules so the Recurring screen (and the dashboard's
/// auto-post trigger) run against sample data instead of the network.
class _FakeRecurringNotifier extends RecurringNotifier {
  _FakeRecurringNotifier(List<RecurringRule> seed) : _items = [...seed];

  final List<RecurringRule> _items;

  @override
  Future<List<RecurringRule>> build() async => _items;

  @override
  Future<void> add(RecurringRule rule) async {
    _items
      ..removeWhere((r) => r.id == rule.id)
      ..add(rule);
    state = AsyncData([..._items]);
  }

  @override
  Future<void> edit(RecurringRule rule) async {
    final i = _items.indexWhere((r) => r.id == rule.id);
    if (i >= 0) _items[i] = rule;
    state = AsyncData([..._items]);
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((r) => r.id == id);
    state = AsyncData([..._items]);
  }

  @override
  Future<RunDueResult> runDue() async =>
      const RunDueResult(posted: 0, rulesRun: 0);
}

/// Override the Budget screen's provider with sample (or given) budget data.
List<Override> sampleBudgetOverride([BudgetData? data]) {
  final d = data ?? BudgetData.sample();
  return [budgetDataProvider.overrideWith(() => _FakeBudgetNotifier(d))];
}

/// Provider overrides that seed the ledger + wallets with sample data and a
/// stable signed-in user.
List<Override> sampleLedgerOverrides({
  List<TransactionRecord>? transactions,
  List<Wallet>? wallets,
  AuthUser? user,
  BudgetData? budget,
  List<RecurringRule>? recurring,
}) {
  final txs = transactions ?? sampleTransactions();
  final ws = wallets ?? WalletsData.sample.wallets;
  final u = user ??
      const AuthUser(id: 'sample-user', email: 'sokunthea@example.com', fullName: 'Sokunthea');
  // Default to an empty budget so the dashboard keeps its income fallback
  // (goldens unchanged) and nothing hits the network.
  final b = budget ??
      BudgetData(
        monthLabel: '',
        totalBudgetKhr: 0,
        spentKhr: 0,
        categories: const [],
      );
  return [
    transactionsProvider.overrideWith(() => _FakeTransactionsNotifier(txs)),
    walletsProvider.overrideWith(() => _FakeWalletsNotifier(ws)),
    authControllerProvider.overrideWith((ref) => _FixedAuthController(u)),
    budgetDataProvider.overrideWith(() => _FakeBudgetNotifier(b)),
    recurringProvider
        .overrideWith(() => _FakeRecurringNotifier(recurring ?? const [])),
    // The dashboard fires this on load; keep it off the network in tests.
    recurringAutoPostProvider
        .overrideWith((ref) async => const RunDueResult(posted: 0, rulesRun: 0)),
  ];
}
