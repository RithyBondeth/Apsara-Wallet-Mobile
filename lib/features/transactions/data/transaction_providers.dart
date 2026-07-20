import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/database/app_database.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(appDatabaseProvider)),
);

/// The live list of transactions, newest first. Screens watch this; the
/// [add]/[remove] methods mutate the database and refresh the state so every
/// surface updates at once.
class TransactionsNotifier extends AsyncNotifier<List<TransactionRecord>> {
  TransactionRepository get _repo => ref.read(transactionRepositoryProvider);

  @override
  Future<List<TransactionRecord>> build() => _repo.getAll();

  Future<void> add(TransactionRecord record) async {
    await _repo.insert(record);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.getAll());
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionRecord>>(
  TransactionsNotifier.new,
);
