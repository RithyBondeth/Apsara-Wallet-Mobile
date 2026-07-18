import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography.
///
/// Latin text uses **Ubuntu** (the brand face). Khmer script falls back to
/// **Koh Santepheap** — a bilingual Khmer typeface by Danh Hong (OFL) — so any
/// Khmer glyphs render in the proper Khmer face while Latin stays Ubuntu, in
/// either app language. Instantiating [GoogleFonts.kohSantepheap] once also
/// registers the family so the fallback resolves at render time (it loads from
/// assets/google_fonts when bundled, otherwise fetches at runtime).
class AppFont {
  AppFont._();

  /// Khmer fallback family, evaluated lazily on first text style access (after
  /// the binding is initialised).
  static final List<String> _khmerFallback = <String>[
    GoogleFonts.kohSantepheap().fontFamily!,
  ];

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
  }) =>
      GoogleFonts.ubuntu(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ).copyWith(fontFamilyFallback: _khmerFallback);

  // ==================================================
  // HEADINGS
  // ==================================================
  static TextStyle headingLarge = _base(fontSize: 32, fontWeight: FontWeight.w700);

  static TextStyle headingMedium =
      _base(fontSize: 28, fontWeight: FontWeight.w600);

  static TextStyle headingSmall =
      _base(fontSize: 24, fontWeight: FontWeight.w600);

  // ==================================================
  // TITLES
  // ==================================================
  static TextStyle titleLarge = _base(fontSize: 22, fontWeight: FontWeight.w500);

  static TextStyle titleMedium = _base(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle titleSmall = _base(fontSize: 14, fontWeight: FontWeight.w500);

  // ==================================================
  // BODY
  // ==================================================
  static TextStyle bodyLarge = _base(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle bodyMedium = _base(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle bodySmall = _base(fontSize: 12, fontWeight: FontWeight.w400);

  // ==================================================
  // LABELS
  // ==================================================
  static TextStyle labelLarge = _base(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle labelMedium = _base(fontSize: 12, fontWeight: FontWeight.w500);

  static TextStyle labelSmall = _base(fontSize: 11, fontWeight: FontWeight.w500);
}
