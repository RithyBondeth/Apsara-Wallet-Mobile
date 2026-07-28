import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:apsara_wallet_mobile/core/database/app_database.dart';

/// Points [AppDatabase] at a fresh in-memory SQLite database backed by the
/// pure-Dart ffi engine, so persistence-backed screens/repos work under
/// `flutter test` (which has no device sqflite plugin). Call in `setUp` for a
/// clean, re-seeded database per test.
Future<void> initTestDatabase() async {
  sqfliteFfiInit();
  // No-isolate factory: DB futures resolve on the main isolate's microtask
  // queue, so `tester.pump()` settles them in widget tests (the default
  // isolate-backed factory would need `tester.runAsync`).
  databaseFactory = databaseFactoryFfiNoIsolate;
  AppDatabase.overridePath = inMemoryDatabasePath;
  await AppDatabase.instance.reset();
}
