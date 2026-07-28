import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable brand gradients for the Apsara Wallet design system.
///
/// Kept intentionally small and semantic — every gradient here maps to a
/// specific surface (brand background, gold foil, legibility scrim, etc.)
/// so screens never hand-roll ad-hoc [LinearGradient]s.
class AppGradients {
  AppGradients._();

  // ==================================================
  // GOLD PALETTE (foil highlights / accents)
  // ==================================================
  static const Color goldLight = Color(0xFFF6E7A8);
  static const Color goldCore = Color(0xFFD4AF37);
  static const Color goldDeep = Color(0xFF9C7A1E);

  // ==================================================
  // EMERALD PALETTE (brand surfaces)
  // ==================================================
  static const Color emeraldDeep = Color(0xFF063D28);
  static const Color emeraldCore = AppColors.primary;
  static const Color emeraldGlow = Color(0xFF127A52);

  // ==================================================
  // BRAND BACKGROUND — deep emerald, top-lit
  // ==================================================
  static const LinearGradient emerald = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [emeraldGlow, emeraldCore, emeraldDeep],
    stops: [0.0, 0.5, 1.0],
  );

  // ==================================================
  // GOLD FOIL — diagonal sheen for the brand mark & wordmark
  // ==================================================
  static const LinearGradient goldFoil = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, goldCore, goldDeep],
    stops: [0.0, 0.5, 1.0],
  );

  // ==================================================
  // LEGIBILITY SCRIM — darkens image tops/bottoms for text
  // ==================================================
  static const LinearGradient scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x66042318),
      Color(0x00063D28),
      Color(0x99042318),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  // ==================================================
  // RADIAL GLOW — soft halo behind the brand mark
  // ==================================================
  static const RadialGradient emblemGlow = RadialGradient(
    colors: [Color(0x33F6E7A8), Color(0x00F6E7A8)],
    stops: [0.0, 1.0],
  );

  /// Moving highlight band used for shimmer sweeps across text/skeletons.
  /// [t] is a 0..1 animation value; the band travels left → right.
  static LinearGradient shimmer(double t) {
    return LinearGradient(
      begin: Alignment(-1.0 - 2.0 * (1 - t), 0),
      end: Alignment(1.0 - 2.0 * (1 - t), 0),
      colors: const [
        Color(0x00FFFFFF),
        Color(0xB3FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: const [0.35, 0.5, 0.65],
    );
  }
}
