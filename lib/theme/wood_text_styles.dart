import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wood_colors.dart';

/// Classic wooden chess design system — typography.
///
/// Uses Cinzel (display / titles) and Playfair Display (body / UI text)
/// to give every word a regal, carved-letter feel.
abstract final class WoodTextStyles {
  WoodTextStyles._();

  // ─── Display / Hero title ────────────────────────────────────────────
  /// Large screen title — app name, section headers
  static TextStyle get displayTitle => GoogleFonts.cinzel(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: WoodColors.textPrimary,
    letterSpacing: 2.0,
    shadows: const [
      Shadow(
        color: Color(0x99000000),
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  // ─── Screen title ────────────────────────────────────────────────────
  /// Standard screen / dialog title
  static TextStyle get screenTitle => GoogleFonts.cinzel(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: WoodColors.textPrimary,
    letterSpacing: 1.2,
    shadows: const [
      Shadow(
        color: Color(0x80000000),
        offset: Offset(0, 1),
        blurRadius: 3,
      ),
    ],
  );

  // ─── Section heading ─────────────────────────────────────────────────
  /// Sub-section heading — panel labels, category names
  static TextStyle get sectionHeading => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: WoodColors.textPrimary,
    letterSpacing: 0.8,
  );

  // ─── Menu item label ─────────────────────────────────────────────────
  /// Main label for menu list tiles
  static TextStyle get menuLabel => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: WoodColors.textPrimary,
    letterSpacing: 0.4,
  );

  // ─── Button label ────────────────────────────────────────────────────
  /// Call-to-action / wooden button text
  static TextStyle get buttonLabel => GoogleFonts.cinzel(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: WoodColors.textPrimary,
    letterSpacing: 1.5,
  );

  // ─── Body / description ──────────────────────────────────────────────
  /// Regular body text
  static TextStyle get body => GoogleFonts.playfairDisplay(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: WoodColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // ─── Caption / small label ───────────────────────────────────────────
  /// Timestamps, sub-labels, fine print
  static TextStyle get caption => GoogleFonts.playfairDisplay(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: WoodColors.textSecondary,
    letterSpacing: 0.1,
  );

  // ─── Rating / score chip ─────────────────────────────────────────────
  /// ELO / rating number — bold, gold
  static TextStyle get rating => GoogleFonts.cinzel(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: WoodColors.gold,
    letterSpacing: 0.5,
  );

  // ─── Gold accent label ───────────────────────────────────────────────
  /// Highlighted stat or badge text drawn in gold
  static TextStyle get goldLabel => GoogleFonts.cinzel(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: WoodColors.gold,
    letterSpacing: 0.8,
  );
}
