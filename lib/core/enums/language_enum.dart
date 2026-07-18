import 'package:flutter/widgets.dart';

/// The languages Apsara Wallet ships in.
///
/// [code] is the ISO-639 language code used for the [Locale] and persisted to
/// storage. [nativeName] is how the language names itself (shown in the
/// switcher); [englishName] is its English exonym.
enum ELanguage {
  english(code: 'en', nativeName: 'English', englishName: 'English'),
  khmer(code: 'km', nativeName: 'ខ្មែរ', englishName: 'Khmer');

  const ELanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  final String code;
  final String nativeName;
  final String englishName;

  Locale get locale => Locale(code);

  bool get isKhmer => this == ELanguage.khmer;

  /// Resolves a stored/system code back to a language, defaulting to English
  /// for anything unrecognised.
  static ELanguage fromCode(String? code) => values.firstWhere(
        (language) => language.code == code,
        orElse: () => ELanguage.english,
      );
}
