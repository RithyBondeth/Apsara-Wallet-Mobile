import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// The coarse category a scanned receipt is filed under.
///
/// Finer than the ledger's catalog on purpose (a supermarket and a café are
/// both "Food & Dining" in the ledger, but read very differently on a review
/// sheet), so each value maps onto a [TxCategory] id for the saved
/// transaction and resolves its own localized label at render time.
enum ReceiptCategory {
  groceries(LucideIcons.shoppingCart, 'food'),
  dining(LucideIcons.utensils, 'food'),
  shopping(LucideIcons.shoppingBag, 'shopping'),
  transport(LucideIcons.car, 'transport'),
  fuel(LucideIcons.fuel, 'transport'),
  health(LucideIcons.pill, 'health'),
  bills(LucideIcons.receiptText, 'bills'),
  uncategorised(LucideIcons.receipt, 'othersExpense');

  const ReceiptCategory(this.icon, this.txCategoryId);

  final IconData icon;

  /// The expense-catalog id the saved transaction lands in.
  final String txCategoryId;

  String labelOf(AppLocalizations l10n) => switch (this) {
    ReceiptCategory.groceries => l10n.receiptCategoryGroceries,
    ReceiptCategory.dining => l10n.receiptCategoryDining,
    ReceiptCategory.shopping => l10n.receiptCategoryShopping,
    ReceiptCategory.transport => l10n.receiptCategoryTransport,
    ReceiptCategory.fuel => l10n.receiptCategoryFuel,
    ReceiptCategory.health => l10n.receiptCategoryHealth,
    ReceiptCategory.bills => l10n.receiptCategoryBills,
    ReceiptCategory.uncategorised => l10n.receiptCategoryUncategorised,
  };
}
