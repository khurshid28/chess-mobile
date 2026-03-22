import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wood_colors.dart';

/// Classic wooden chess design system — typography.
///
/// Uses Cinzel (display / titles) and Playfair Display (body / UI text)
/// to give every word a regal, carved-letter feel.
abstract final class WoodTextStyles {
  WoodTextStyles._();

  static const _textShadow = [
    Shadow(color: Color(0xFF000000), offset: Offset(0, 3), blurRadius: 6),
  ];

  // ─── Display / Hero title ────────────────────────────────────────────
  /// Large screen title — app name, section headers
  static TextStyle get displayTitle => GoogleFonts.cinzel(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: WoodColors.textPrimary,
    letterSpacing: 2.5,
    shadows: _textShadow,
  );

  // ─── Screen title ────────────────────────────────────────────────────
  /// Standard screen / dialog title
  static TextStyle get screenTitle => GoogleFonts.cinzel(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: WoodColors.textPrimary,
    letterSpacing: 1.8,
    shadows: _textShadow,
  );

  // ─── Section heading ─────────────────────────────────────────────────
  /// Sub-section heading — panel labels, category names
  static TextStyle get sectionHeading => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: WoodColors.textPrimary,
    letterSpacing: 1.2,
    shadows: _textShadow,
  );

  // ─── Menu item label ─────────────────────────────────────────────
  /// Main label for menu list tiles
  static TextStyle get menuLabel => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: WoodColors.textPrimary,
    letterSpacing: 0.8,
    shadows: _textShadow,
  );

  // ─── Button label ────────────────────────────────────────────────────
  /// Call-to-action / wooden button text
  static TextStyle get buttonLabel => GoogleFonts.cinzel(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: WoodColors.textPrimary,
    letterSpacing: 2.0,
    shadows: _textShadow,
  );

  // ─── Body / description ──────────────────────────────────────────────
  /// Regular body text
  static TextStyle get body => GoogleFonts.playfairDisplay(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: WoodColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.5,
    shadows: _textShadow,
  );

  // ─── Caption / small label ───────────────────────────────────────────
  /// Timestamps, sub-labels, fine print
  static TextStyle get caption => GoogleFonts.playfairDisplay(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: WoodColors.textSecondary,
    letterSpacing: 0.4,
    shadows: _textShadow,
  );

  // ─── Rating / score chip ─────────────────────────────────────────────
  /// ELO / rating number — bold
  static TextStyle get rating => GoogleFonts.cinzel(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: WoodColors.textPrimary,
    letterSpacing: 0.8,
    shadows: _textShadow,
  );

  // ─── Gold accent label ───────────────────────────────────────────────
  /// Highlighted stat or badge text
  static TextStyle get goldLabel => GoogleFonts.cinzel(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: WoodColors.textPrimary,
    letterSpacing: 1.2,
    shadows: _textShadow,
  );
}
