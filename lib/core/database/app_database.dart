import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';

/// The app's local SQLite store (Phase 2 foundation).
///
/// A lazily-opened singleton. On first creation it seeds the Phase-1 sample
/// transactions so the app opens with data instead of an empty ledger. Tests
/// set [overridePath] to `inMemoryDatabasePath` (with the ffi factory) and
/// call [reset] between cases for a fresh, re-seeded database.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  /// When set, opens this path instead of the on-device databases dir.
  static String? overridePath;

  static const String transactionsTable = 'transactions';

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = overridePath ??
        p.join(await getDatabasesPath(), 'apsara_wallet.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        walletName TEXT NOT NULL,
        dateMillis INTEGER NOT NULL,
        amountKhr INTEGER NOT NULL,
        type TEXT NOT NULL,
        note TEXT
      )
    ''');

    // Seed with the Phase-1 sample so the app isn't empty on first launch.
    final batch = db.batch();
    for (final t in sampleTransactions()) {
      batch.insert(transactionsTable, t.toDbMap());
    }
    await batch.commit(noResult: true);
  }

  /// Closes and forgets the cached connection so the next access re-opens
  /// (and, for an in-memory test db, re-seeds) from scratch.
  Future<void> reset() async {
    await _db?.close();
    _db = null;
  }
}
