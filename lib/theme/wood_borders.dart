import 'package:flutter/material.dart';
import 'wood_colors.dart';

/// Classic wooden chess design system — border tokens.
///
/// All borders simulate carved grooves or raised wooden lips.
abstract final class WoodBorders {
  WoodBorders._();

  // ─── Border widths ───────────────────────────────────────────────────
  static const double thin    = 1.0;
  static const double regular = 2.0;
  static const double thick   = 3.0;
  static const double frame   = 6.0; // board outer frame

  // ─── Border colours ──────────────────────────────────────────────────
  static const Color color        = WoodColors.border;
  static const Color colorHighlight = Color(0xFF5A3A1A); // lighter for top edge

  // ─── Border radii ────────────────────────────────────────────────────
  static const double radiusSmall  = 6.0;
  static const double radiusNormal = 12.0;
  static const double radiusLarge  = 18.0;
  static const double radiusButton = 8.0;
  static const double radiusPill   = 100.0;

  static BorderRadius get smallRadius  => BorderRadius.circular(radiusSmall);
  static BorderRadius get normalRadius => BorderRadius.circular(radiusNormal);
  static BorderRadius get largeRadius  => BorderRadius.circular(radiusLarge);
  static BorderRadius get buttonRadius => BorderRadius.circular(radiusButton);

  // ─── Pre-built Border objects ────────────────────────────────────────

  /// Standard carved panel border — uniform warm brown (required for borderRadius support)
  static Border get panel => Border.all(
    color: WoodColors.border,
    width: regular,
  );

  /// Thin divider border
  static Border get divider => Border(
    bottom: BorderSide(color: WoodColors.divider, width: thin),
  );

  /// Chess board outer-frame border
  static Border get boardFrame => Border.all(
    color: WoodColors.woodDark,
    width: 8.0,
  );

  /// Button border — slightly raised
  static Border get button => Border.all(
    color: const Color(0xFF9E6B35),
    width: thin,
  );

  /// Gold accent border for selected / active elements
  static Border get goldAccent => Border.all(
    color: WoodColors.gold,
    width: regular,
  );

  // ─── Pre-built BoxDecoration borders ────────────────────────────────

  /// Full carved panel BoxDecoration (use with gradient separately)
  static BoxDecoration panelDecoration({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) => BoxDecoration(
    borderRadius: borderRadius ?? normalRadius,
    border: panel,
    boxShadow: boxShadow,
  );
}
