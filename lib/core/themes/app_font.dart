import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFont {
  AppFont._();

  // ==================================================
  // HEADINGS
  // ==================================================
  static TextStyle headingLarge = GoogleFonts.ubuntu(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headingMedium = GoogleFonts.ubuntu(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headingSmall = GoogleFonts.ubuntu(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // ==================================================
  // TITLES
  // ==================================================
  static TextStyle titleLarge = GoogleFonts.ubuntu(
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleMedium = GoogleFonts.ubuntu(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleSmall = GoogleFonts.ubuntu(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // ==================================================
  // BODY
  // ==================================================
  static TextStyle bodyLarge = GoogleFonts.ubuntu(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.ubuntu(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.ubuntu(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // ==================================================
  // LABELS
  // ==================================================
  static TextStyle labelLarge = GoogleFonts.ubuntu(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelMedium = GoogleFonts.ubuntu(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelSmall = GoogleFonts.ubuntu(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
