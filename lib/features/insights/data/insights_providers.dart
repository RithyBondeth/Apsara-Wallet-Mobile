import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/features/insights/data/insights_engine.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_providers.dart';

/// The data-driven AI Insights report, derived from the live transaction
/// ledger. Recomputes automatically whenever a transaction is added or
/// removed, so the Insights screen always reflects the current data.
final insightsReportProvider = Provider<AsyncValue<InsightsReport>>((ref) {
  return ref
      .watch(transactionsProvider)
      .whenData(InsightsEngine.analyse);
});
