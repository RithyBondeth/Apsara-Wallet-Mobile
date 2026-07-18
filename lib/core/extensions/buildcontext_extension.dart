import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  // ==================================================
  // Localization
  // ==================================================
  /// Localized strings for the current locale — `context.l10n.loginTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this);

  // ==================================================
  // Theme
  // ==================================================
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get text => theme.textTheme;

  // ==================================================
  // MediaQuery
  // ==================================================
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  EdgeInsets get padding => mediaQuery.padding;

  // ==================================================
  // Brightness
  // ==================================================
  bool get isDarkMode => theme.brightness == Brightness.dark;

  bool get isLightMode => !isDarkMode;

  // ==================================================
  // Keyboard
  // ==================================================
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  // ==================================================
  // Navigation
  // ==================================================
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
