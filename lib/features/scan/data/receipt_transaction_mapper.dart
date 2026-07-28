import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/utils/currency_converter.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_history_mock_data.dart';

/// Translates a reviewed [ScannedReceipt] into a ledger [TransactionRecord].
///
/// The receipt's inferred category is a free-text label produced by
/// `ReceiptParser` (Groceries, Dining, …); this maps it onto the app's
/// [TxCategory] catalog, and converts the receipt total (which may be in USD)
/// into the stored riel unit.
class ReceiptTransactionMapper {
  ReceiptTransactionMapper._();

  /// Receipt category label → [TxCategory] id in the expense catalog.
  static const Map<String, String> _categoryIdByLabel = {
    'Groceries': 'food',
    'Dining': 'food',
    'Health': 'health',
    'Fuel': 'transport',
    'Shopping': 'shopping',
  };

  static TxCategory categoryFor(String label) =>
      categoryById(_categoryIdByLabel[label] ?? 'othersExpense');

  /// Builds an expense record from [receipt]. [id], [walletName] and [date]
  /// are injected so the call site controls identity/clock (and tests stay
  /// deterministic).
  static TransactionRecord toTransaction(
    ScannedReceipt receipt, {
    required String id,
    required String walletName,
    required DateTime date,
  }) {
    final merchant = receipt.merchant.trim();
    final title = merchant.isNotEmpty
        ? merchant
        : (receipt.categoryLabel.isNotEmpty ? receipt.categoryLabel : 'Receipt');
    return TransactionRecord(
      id: id,
      title: title,
      category: categoryFor(receipt.categoryLabel),
      walletName: walletName,
      date: date,
      amountKhr: CurrencyConverter.toKhr(receipt.total, receipt.currency),
      type: ETransactionType.expense,
      note: receipt.location,
    );
  }
}
