import 'package:sqflite/sqflite.dart';

import 'package:apsara_wallet_mobile/core/database/app_database.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';

/// Reads and writes [TransactionRecord]s in the local [AppDatabase].
///
/// This is the single source of truth for transaction data — the dashboard,
/// history list and detail all flow through it (via the Riverpod providers)
/// so a save on one surface shows up everywhere.
class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  Future<List<TransactionRecord>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.transactionsTable,
      orderBy: 'dateMillis DESC',
    );
    return rows.map(TransactionRecord.fromDbMap).toList();
  }

  Future<TransactionRecord?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TransactionRecord.fromDbMap(rows.first);
  }

  Future<void> insert(TransactionRecord record) async {
    final db = await _db.database;
    await db.insert(
      AppDatabase.transactionsTable,
      record.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      AppDatabase.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
