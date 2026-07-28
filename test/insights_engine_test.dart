import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/insights/data/insights_engine.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';

/// Pure-Dart tests for the on-device insights engine — no DB, no widgets.
void main() {
  TransactionRecord tx(
    String id,
    String categoryId,
    int amountKhr,
    ETransactionType type,
    DateTime date,
  ) => TransactionRecord(
    id: id,
    title: id,
    category: categoryById(categoryId),
    walletName: 'Cash Wallet',
    date: date,
    amountKhr: amountKhr,
    type: type,
  );

  test('empty ledger reports no data', () {
    final report = InsightsEngine.analyse(const []);
    expect(report.hasEnoughData, isFalse);
    expect(report.headline, isNull);
    expect(report.more, isEmpty);
  });

  test('a month with income but no expenses is not enough data', () {
    final report = InsightsEngine.analyse([
      tx(
        'sal',
        'salary',
        1000000,
        ETransactionType.income,
        DateTime(2024, 5, 1),
      ),
    ]);
    expect(report.hasEnoughData, isFalse);
  });

  test('computes savings rate and a healthy score', () {
    final report = InsightsEngine.analyse([
      tx(
        'sal',
        'salary',
        1000000,
        ETransactionType.income,
        DateTime(2024, 5, 1),
      ),
      tx(
        'food',
        'food',
        200000,
        ETransactionType.expense,
        DateTime(2024, 5, 2),
      ),
    ]);

    expect(report.hasEnoughData, isTrue);
    // net 800,000 / income 1,000,000 = 80%.
    expect(report.savingsRatePercent, 80);
    // 80% savings saturates the savings term; no prior month → neutral trend.
    expect(report.healthScore, 90);
    expect(report.band, HealthBand.excellent);
    expect(report.headline!.kind, InsightKind.savingsPositive);
  });

  test('overspending surfaces a warning and drags the score down', () {
    final report = InsightsEngine.analyse([
      tx(
        'sal',
        'salary',
        100000,
        ETransactionType.income,
        DateTime(2024, 5, 1),
      ),
      tx(
        'rent',
        'bills',
        300000,
        ETransactionType.expense,
        DateTime(2024, 5, 2),
      ),
    ]);

    expect(report.savingsRatePercent, lessThan(0));
    expect(report.headline!.kind, InsightKind.overspend);
    expect(report.headline!.amountKhr, 200000); // 300k spent - 100k earned
    expect(report.band, HealthBand.needsWork);
  });

  test('identifies the top expense category and its share', () {
    final report = InsightsEngine.analyse([
      tx(
        'sal',
        'salary',
        1000000,
        ETransactionType.income,
        DateTime(2024, 5, 1),
      ),
      tx(
        'a',
        'shopping',
        300000,
        ETransactionType.expense,
        DateTime(2024, 5, 2),
      ),
      tx('b', 'food', 100000, ETransactionType.expense, DateTime(2024, 5, 3)),
    ]);

    final top = report.more.firstWhere(
      (i) => i.kind == InsightKind.topCategory,
    );
    expect(top.categoryId, 'shopping');
    expect(top.amountKhr, 300000);
    expect(top.percent, 75); // 300k of 400k total
  });

  test('flags a month-over-month rise in the top category', () {
    final report = InsightsEngine.analyse([
      // Previous month.
      tx(
        'p1',
        'shopping',
        100000,
        ETransactionType.expense,
        DateTime(2024, 4, 5),
      ),
      // Current month (anchored to latest tx).
      tx(
        'sal',
        'salary',
        1000000,
        ETransactionType.income,
        DateTime(2024, 5, 1),
      ),
      tx(
        'c1',
        'shopping',
        200000,
        ETransactionType.expense,
        DateTime(2024, 5, 6),
      ),
    ]);

    final up = report.headline!.kind == InsightKind.categoryUp
        ? report.headline!
        : report.more.firstWhere((i) => i.kind == InsightKind.categoryUp);
    expect(up.categoryId, 'shopping');
    expect(up.percent, 100); // doubled vs last month
  });

  test('anchors the period to the latest transaction, ignoring the clock', () {
    // All dated in 2024 — far from the real "now" — yet still analysed.
    final report = InsightsEngine.analyse(sampleTransactions());
    expect(report.hasEnoughData, isTrue);
    expect(report.periodMonth.year, 2024);
    expect(report.periodMonth.month, 5);
    expect(report.healthScore, 90);
  });
}
