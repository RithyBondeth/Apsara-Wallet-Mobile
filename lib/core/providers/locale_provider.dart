import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsara_wallet_mobile/core/enums/language_enum.dart';
import 'package:apsara_wallet_mobile/core/storages/shared_prefs_service.dart';
import 'package:apsara_wallet_mobile/core/storages/storage_keys.dart';

/// Holds the app's current [ELanguage] and persists changes to SharedPrefs so
/// the choice survives restarts.
///
/// The initial value is seeded in [main] (from the stored language code) via a
/// provider override, so the very first frame already paints in the right
/// language — no English flash before Khmer loads.
class LocaleNotifier extends StateNotifier<ELanguage> {
  LocaleNotifier(super.initial, {SharedPrefsService? prefs})
      : _prefs = prefs ?? SharedPrefsService();

  final SharedPrefsService _prefs;

  /// Reads the persisted language code, defaulting to English.
  static Future<ELanguage> loadSaved([SharedPrefsService? prefs]) async {
    final service = prefs ?? SharedPrefsService();
    final code = await service.getString(StorageKeys.language);
    return ELanguage.fromCode(code);
  }

  Future<void> setLanguage(ELanguage language) async {
    if (language == state) return;
    state = language;
    await _prefs.setString(StorageKeys.language, language.code);
  }

  /// Flips between the two supported languages.
  Future<void> toggle() => setLanguage(
        state.isKhmer ? ELanguage.english : ELanguage.khmer,
      );
}

final localeProvider = StateNotifierProvider<LocaleNotifier, ELanguage>(
  (ref) => LocaleNotifier(ELanguage.english),
);
