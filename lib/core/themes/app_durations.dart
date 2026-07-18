import 'package:flutter/animation.dart';

/// Motion design tokens for Apsara Wallet.
///
/// Centralising durations & curves keeps every animation on the same
/// rhythm — entrances, page transitions and micro-interactions all read
/// as one product rather than a patchwork of magic numbers.
class AppDurations {
  AppDurations._();

  // ==================================================
  // DURATIONS
  // ==================================================
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration splashIntro = Duration(milliseconds: 1900);
  static const Duration splashHold = Duration(milliseconds: 750);
  static const Duration shimmerLoop = Duration(milliseconds: 2600);
  static const Duration pulseLoop = Duration(milliseconds: 3200);
}

/// Curve tokens — [AppCurves.entrance] is the house easing for arrivals.
class AppCurves {
  AppCurves._();

  static const Curve entrance = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve gentle = Curves.easeInOut;
  static const Curve decelerate = Curves.easeOut;
}
