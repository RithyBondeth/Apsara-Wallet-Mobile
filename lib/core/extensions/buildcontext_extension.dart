import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
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
