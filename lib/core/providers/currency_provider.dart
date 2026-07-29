import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/currency_enum.dart';
import 'package:apsara_wallet_mobile/core/storages/shared_prefs_service.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';

/// Holds the user's chosen display currency and persists changes to SharedPrefs
/// so the choice survives restarts.
///
/// Amounts are always stored in riel (KHR); this only affects how money is
/// *displayed*. When USD is selected, the money formatter converts using the
/// live exchange rate (see `fxRateProvider`). Seeded in [main] from storage via
/// a provider override so the first frame already shows the right currency.
class CurrencyNotifier extends StateNotifier<ECurrencyType> {
  CurrencyNotifier(super.initial, {SharedPrefsService? prefs})
      : _prefs = prefs ?? SharedPrefsService();

  final SharedPrefsService _prefs;

  /// Reads the persisted currency code, defaulting to KHR (base currency).
  static Future<ECurrencyType> loadSaved([SharedPrefsService? prefs]) async {
    final service = prefs ?? SharedPrefsService();
    final code = await service.getString(StorageKeys.selectedCurrency);
    return ECurrencyType.fromCode(code);
  }

  Future<void> set(ECurrencyType currency) async {
    if (currency == state) return;
    state = currency;
    await _prefs.setString(StorageKeys.selectedCurrency, currency.code);
  }
}

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, ECurrencyType>(
  (ref) => CurrencyNotifier(ECurrencyType.khr),
);
