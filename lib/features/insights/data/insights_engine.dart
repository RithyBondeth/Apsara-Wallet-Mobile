import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';

/// The kinds of insight the engine can surface. The presentation layer maps
/// each to an icon, colour and a localized sentence built from the numeric
/// fields on [Insight] — the engine itself holds no display strings.
enum InsightKind {
  topCategory,
  busiestDay,
  categoryUp,
  categoryDown,
  savingsPositive,
  overspend,
}

/// Qualitative band for the health score; drives the gauge label, its colour
/// and the encouragement copy.
enum HealthBand { needsWork, fair, good, excellent }

/// One computed insight: a [kind] plus the numbers/ids it references. Pure
/// data — no strings, no BuildContext — so it stays testable and the screen
/// localizes it through the presenter.
class Insight {
  const Insight({
    required this.kind,
    this.categoryId,
    this.amountKhr,
    this.percent,
    this.weekday,
  });

  final InsightKind kind;

  /// Category this insight is about (a [TxCategory.id]), when relevant.
  final String? categoryId;

  /// A monetary figure in riel, when relevant (always non-negative).
  final int? amountKhr;

  /// A percentage figure (share of spending, change vs last month, …).
  final int? percent;

  /// `DateTime.weekday` (1 = Mon … 7 = Sun) for [InsightKind.busiestDay].
  final int? weekday;
}

/// The full, data-driven report the AI Insights screen renders.
class InsightsReport {
  const InsightsReport({
    required this.healthScore,
    required this.band,
    required this.savingsRatePercent,
    required this.periodMonth,
    required this.headline,
    required this.more,
    required this.hasEnoughData,
  });

  /// 0..100.
  final int healthScore;
  final HealthBand band;

  /// Net savings as a share of income this month; negative when overspending.
  final int savingsRatePercent;

  /// First day of the analysed month (drives the period label).
  final DateTime periodMonth;

  /// The single most salient insight — shown as "Today's Insight".
  final Insight? headline;

  /// Further tips for the "More Insights" list (headline excluded).
  final List<Insight> more;

  /// False when the current month has no expenses to reason about; the screen
  /// then shows a friendly "add some transactions" state instead of a report.
  final bool hasEnoughData;
}

/// Derives an [InsightsReport] from the raw transaction ledger — pure Dart, no
/// I/O, no ML. This is the "AI" the Insights screen shows: deterministic
/// heuristics over the user's own data.
class InsightsEngine {
  InsightsEngine._();

  /// Analyse [transactions] into a report.
  ///
  /// The "current month" is anchored to the most recent transaction rather
  /// than the wall clock, so the report is meaningful whether the ledger holds
  /// live data or the seeded sample, and stays deterministic under test.
  static InsightsReport analyse(List<TransactionRecord> transactions) {
    if (transactions.isEmpty) {
      return InsightsReport(
        healthScore: 0,
        band: HealthBand.fair,
        savingsRatePercent: 0,
        periodMonth: DateTime(2000),
        headline: null,
        more: const [],
        hasEnoughData: false,
      );
    }

    final anchor = transactions
        .map((t) => t.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final monthStart = DateTime(anchor.year, anchor.month);
    final prevMonthStart = DateTime(anchor.year, anchor.month - 1);

    final current = transactions.where((t) => _inMonth(t.date, monthStart));
    final previousExpenses = transactions
        .where((t) => _inMonth(t.date, prevMonthStart))
        .where((t) => t.type == ETransactionType.expense);

    final expenses =
        current.where((t) => t.type == ETransactionType.expense).toList();
    final incomeTotal = current
        .where((t) => t.type == ETransactionType.income)
        .fold<int>(0, (s, t) => s + t.amountKhr);
    final expenseTotal = expenses.fold<int>(0, (s, t) => s + t.amountKhr);
    final prevExpenseTotal =
        previousExpenses.fold<int>(0, (s, t) => s + t.amountKhr);

    final net = incomeTotal - expenseTotal;
    final savingsRate = incomeTotal > 0
        ? net / incomeTotal
        : (expenseTotal > 0 ? -1.0 : 0.0);
    final savingsRatePercent = (savingsRate * 100).round();

    final score = _score(
      savingsRate: savingsRate,
      net: net,
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      prevExpenseTotal: prevExpenseTotal,
    );
    final band = _bandFor(score);

    if (expenses.isEmpty) {
      return InsightsReport(
        healthScore: score,
        band: band,
        savingsRatePercent: savingsRatePercent,
        periodMonth: monthStart,
        headline: null,
        more: const [],
        hasEnoughData: false,
      );
    }

    // --- Build the candidate findings, most-actionable first. ---------------
    final findings = <Insight>[];

    if (net < 0) {
      findings.add(Insight(kind: InsightKind.overspend, amountKhr: -net));
    } else if (incomeTotal > 0 && net > 0) {
      findings.add(Insight(
        kind: InsightKind.savingsPositive,
        amountKhr: net,
        percent: savingsRatePercent,
      ));
    }

    // Top expense category this month.
    final byCategory = <String, int>{};
    for (final e in expenses) {
      byCategory[e.category.id] = (byCategory[e.category.id] ?? 0) + e.amountKhr;
    }
    final topEntry = byCategory.entries
        .reduce((a, b) => a.value >= b.value ? a : b);
    final topShare = ((topEntry.value / expenseTotal) * 100).round();

    // Month-over-month change for that top category.
    if (prevExpenseTotal > 0) {
      final prevForTop = previousExpenses
          .where((t) => t.category.id == topEntry.key)
          .fold<int>(0, (s, t) => s + t.amountKhr);
      if (prevForTop > 0) {
        final change = (((topEntry.value - prevForTop) / prevForTop) * 100)
            .round();
        if (change >= 5) {
          findings.add(Insight(
            kind: InsightKind.categoryUp,
            categoryId: topEntry.key,
            percent: change,
          ));
        } else if (change <= -5) {
          findings.add(Insight(
            kind: InsightKind.categoryDown,
            categoryId: topEntry.key,
            percent: change.abs(),
          ));
        }
      }
    }

    findings.add(Insight(
      kind: InsightKind.topCategory,
      categoryId: topEntry.key,
      amountKhr: topEntry.value,
      percent: topShare,
    ));

    // Busiest spending weekday.
    final byWeekday = <int, int>{};
    for (final e in expenses) {
      byWeekday[e.date.weekday] =
          (byWeekday[e.date.weekday] ?? 0) + e.amountKhr;
    }
    final busiest = byWeekday.entries.reduce((a, b) => a.value >= b.value ? a : b);
    findings.add(Insight(
      kind: InsightKind.busiestDay,
      weekday: busiest.key,
      amountKhr: busiest.value,
    ));

    return InsightsReport(
      healthScore: score,
      band: band,
      savingsRatePercent: savingsRatePercent,
      periodMonth: monthStart,
      headline: findings.first,
      more: findings.skip(1).take(3).toList(),
      hasEnoughData: true,
    );
  }

  // --- helpers --------------------------------------------------------------

  static bool _inMonth(DateTime d, DateTime start) =>
      d.year == start.year && d.month == start.month;

  /// Weighted blend of three signals, each mapped to 0..1:
  ///  - savings rate (55%): a 30%+ savings rate earns full marks;
  ///  - spending trend vs last month (25%): flat/down is good, up is worse;
  ///  - staying in the black (20%): net income >= 0.
  static int _score({
    required double savingsRate,
    required int net,
    required int incomeTotal,
    required int expenseTotal,
    required int prevExpenseTotal,
  }) {
    final savings = (savingsRate / 0.30).clamp(0.0, 1.0);

    final double trend;
    if (prevExpenseTotal <= 0) {
      trend = 0.6; // no baseline yet — neutral-positive
    } else {
      final delta = (prevExpenseTotal - expenseTotal) / prevExpenseTotal;
      trend = (0.5 + delta * 0.5).clamp(0.0, 1.0);
    }

    final double inTheBlack;
    if (net >= 0) {
      inTheBlack = 1.0;
    } else if (incomeTotal > 0) {
      inTheBlack = (1 + net / incomeTotal).clamp(0.0, 1.0);
    } else {
      inTheBlack = 0.0;
    }

    final blended = 0.55 * savings + 0.25 * trend + 0.20 * inTheBlack;
    return (blended * 100).round().clamp(0, 100);
  }

  static HealthBand _bandFor(int score) {
    if (score >= 80) return HealthBand.excellent;
    if (score >= 60) return HealthBand.good;
    if (score >= 40) return HealthBand.fair;
    return HealthBand.needsWork;
  }
}
