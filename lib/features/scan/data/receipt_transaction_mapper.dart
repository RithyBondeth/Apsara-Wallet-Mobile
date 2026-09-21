import 'package:apsara_wallet_mobile/core/enums/transaction_enum.dart';
import 'package:apsara_wallet_mobile/core/utils/currency_converter.dart';
import 'package:apsara_wallet_mobile/features/scan/data/receipt_category.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_categories.dart';
import 'package:apsara_wallet_mobile/features/transactions/data/transaction_record.dart';

/// Translates a reviewed [ScannedReceipt] into a ledger [TransactionRecord].
///
/// Turns a reviewed [ScannedReceipt] into a ledger [TransactionRecord]:
/// the receipt's [ReceiptCategory] maps onto the app's [TxCategory] catalog,
/// and the receipt total (which may be in USD) is converted into the stored
/// riel unit.
class ReceiptTransactionMapper {
  ReceiptTransactionMapper._();

  static TxCategory categoryFor(ReceiptCategory category) =>
      categoryById(category.txCategoryId);

  /// Builds an expense record from [receipt]. [id], [walletName] and [date]
  /// are injected so the call site controls identity/clock (and tests stay
  /// deterministic).
  ///
  /// [fallbackTitle] is used when the receipt has no merchant — the caller
  /// passes the localized category label so the ledger never shows an
  /// English placeholder to a Khmer user.
  static TransactionRecord toTransaction(
    ScannedReceipt receipt, {
    required String id,
    required String walletName,
    required DateTime date,
    required String fallbackTitle,
  }) {
    final merchant = receipt.merchant.trim();
    return TransactionRecord(
      id: id,
      title: merchant.isNotEmpty ? merchant : fallbackTitle,
      category: categoryFor(receipt.category),
      walletName: walletName,
      date: date,
      amountKhr: CurrencyConverter.toKhr(receipt.total, receipt.currency),
      type: ETransactionType.expense,
      note: receipt.location,
    );
  }
}
