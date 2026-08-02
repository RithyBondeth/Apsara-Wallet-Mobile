import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// Latin-grouped KHR formatting to match the design ("KHR 1,265,700"), not the
/// ៛ symbol.
final NumberFormat _khr = NumberFormat.decimalPattern('en_US');

/// `442000` -> `"442,000"`.
String formatKhr(num value) => _khr.format(value);

/// The window the Analytics screen aggregates over.
enum AnalyticsRange { week, month, year }

/// One slice of the expense breakdown donut / category list.
class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.amountKhr,
    required this.fraction,
    required this.color,
    required this.icon,
  });

  final String name;
  final int amountKhr;

  /// Share of total expense, 0..1.
  final double fraction;
  final Color color;
  final IconData icon;

  int get percent => (fraction * 100).round();
}

/// Everything the Analytics tabs render.
class AnalyticsData {
  const AnalyticsData({
    required this.totalExpenseKhr,
    required this.categories,
    required this.dailyTrend,
    required this.trendMax,
    required this.trendAxisLabels,
  });

  final int totalExpenseKhr;
  final List<ExpenseCategory> categories;

  /// Per-day expense values (KHR) driving the trend line.
  final List<double> dailyTrend;

  /// Upper bound for the trend Y axis (KHR).
  final double trendMax;

  /// Sparse X labels, evenly distributed across [dailyTrend].
  final List<String> trendAxisLabels;

  /// True when there are no expenses in the selected window.
  bool get isEmpty => totalExpenseKhr == 0;

  /// Derives the analytics for [range] around [anchor] from the real expense
  /// ledger — category breakdown (top 4 + "Others"), a per-bucket spend trend
  /// (daily for week/month, monthly for year) and sparse axis labels.
  factory AnalyticsData.fromLedger({
    required List<TransactionRecord> ledger,
    required DateTime anchor,
    required AnalyticsRange range,
    required AppLocalizations l10n,
    required String localeTag,
  }) {
    final (start, buckets, byMonth) = _window(anchor, range);
    final startDay = DateTime(start.year, start.month, start.day);
    final end = byMonth
        ? DateTime(start.year + 1, 1, 1)
        : startDay.add(Duration(days: buckets));

    final expenses = ledger.where((t) =>
        t.type == ETransactionType.expense &&
        !t.date.isBefore(start) &&
        t.date.isBefore(end));

    var total = 0;
    final amountBySlug = <String, int>{};
    final catBySlug = <String, TxCategory>{};
    final trend = List<double>.filled(buckets, 0);

    for (final t in expenses) {
      total += t.amountKhr;
      amountBySlug.update(t.category.id, (v) => v + t.amountKhr,
          ifAbsent: () => t.amountKhr);
      catBySlug.putIfAbsent(t.category.id, () => t.category);

      final idx = byMonth
          ? t.date.month - 1
          : DateTime(t.date.year, t.date.month, t.date.day)
              .difference(startDay)
              .inDays;
      if (idx >= 0 && idx < buckets) trend[idx] += t.amountKhr.toDouble();
    }

    final ranked = amountBySlug.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    const topN = 4;
    final categories = <ExpenseCategory>[];
    for (var i = 0; i < ranked.length && i < topN; i++) {
      final cat = catBySlug[ranked[i].key]!;
      categories.add(ExpenseCategory(
        name: cat.labelOf(l10n),
        amountKhr: ranked[i].value,
        fraction: total > 0 ? ranked[i].value / total : 0,
        color: cat.color,
        icon: cat.icon,
      ));
    }
    if (ranked.length > topN) {
      final restAmt =
          ranked.skip(topN).fold<int>(0, (s, e) => s + e.value);
      final others = categoryById('othersExpense');
      categories.add(ExpenseCategory(
        name: others.labelOf(l10n),
        amountKhr: restAmt,
        fraction: total > 0 ? restAmt / total : 0,
        color: others.color,
        icon: others.icon,
      ));
    }

    final maxVal = trend.fold<double>(0, (m, v) => v > m ? v : m);
    return AnalyticsData(
      totalExpenseKhr: total,
      categories: categories,
      dailyTrend: trend,
      trendMax: _niceCeil(maxVal),
      trendAxisLabels: _axisLabels(startDay, range, buckets, localeTag),
    );
  }
}

/// Window start, bucket count, and whether buckets are months (year) vs days.
(DateTime, int, bool) _window(DateTime anchor, AnalyticsRange range) {
  switch (range) {
    case AnalyticsRange.week:
      // Monday of the anchor's week (weekday: Mon=1 … Sun=7).
      final monday = DateTime(anchor.year, anchor.month, anchor.day)
          .subtract(Duration(days: anchor.weekday - 1));
      return (monday, 7, false);
    case AnalyticsRange.month:
      final start = DateTime(anchor.year, anchor.month, 1);
      final days = DateTime(anchor.year, anchor.month + 1, 1)
          .difference(start)
          .inDays;
      return (start, days, false);
    case AnalyticsRange.year:
      return (DateTime(anchor.year, 1, 1), 12, true);
  }
}

/// Rounds [v] up to a "nice" axis ceiling (1/1.5/2/2.5/3/4/5/7.5 × 10ⁿ), with a
/// floor of 1 so the line chart never divides by zero.
double _niceCeil(double v) {
  if (v <= 0) return 1;
  final mag = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
  final norm = v / mag; // 1 … 10
  const ladder = [1, 1.5, 2, 2.5, 3, 4, 5, 7.5, 10];
  final step = ladder.firstWhere((s) => norm <= s + 1e-9, orElse: () => 10);
  return step * mag;
}

/// Sparse, evenly spaced X labels for the trend chart.
List<String> _axisLabels(
  DateTime start,
  AnalyticsRange range,
  int buckets,
  String locale,
) {
  if (range == AnalyticsRange.week) {
    final fmt = DateFormat.E(locale);
    return [for (var i = 0; i < 7; i++) fmt.format(start.add(Duration(days: i)))];
  }
  final fmt =
      range == AnalyticsRange.year ? DateFormat.MMM(locale) : DateFormat('d MMM', locale);
  const count = 5;
  final indices = <int>{
    for (var k = 0; k < count; k++) ((buckets - 1) * k / (count - 1)).round(),
  }.toList()
    ..sort();
  return [
    for (final i in indices)
      fmt.format(
        range == AnalyticsRange.year
            ? DateTime(start.year, 1 + i)
            : start.add(Duration(days: i)),
      ),
  ];
}
