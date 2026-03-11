import 'package:flutter/material.dart';

/// Classic wooden chess design system — shadow tokens.
///
/// All shadows use a warm near-black tint so they read as depth
/// cut into polished wood, not flat grey drop-shadows.
abstract final class WoodShadows {
  WoodShadows._();

  static const Color _shadowColor = Color(0x40000000); // 25 % black
  static const Color _deepShadow  = Color(0x55000000); // 33 % black

  // ─── Single-shadow helpers ───────────────────────────────────────────

  /// Micro shadow — inset labels, engraved text
  static const BoxShadow tiny = BoxShadow(
    color: _shadowColor,
    offset: Offset(0, 1),
    blurRadius: 3,
  );

  /// Small shadow — chips, badges, icon containers
  static const BoxShadow small = BoxShadow(
    color: _shadowColor,
    offset: Offset(1, 2),
    blurRadius: 4,
  );

  /// Medium shadow — cards, panels
  static const BoxShadow medium = BoxShadow(
    color: _shadowColor,
    offset: Offset(2, 4),
    blurRadius: 8,
  );

  /// Large shadow — modals, full boards, floating sheets
  static const BoxShadow large = BoxShadow(
    color: _shadowColor,
    offset: Offset(0, 6),
    blurRadius: 12,
  );

  /// Extra-large shadow — hero boards, bottom sheets
  static const BoxShadow xlarge = BoxShadow(
    color: _deepShadow,
    offset: Offset(0, 8),
    blurRadius: 20,
    spreadRadius: -2,
  );

  // ─── Button-specific shadows ─────────────────────────────────────────

  /// Resting 3-D button shadow
  static const BoxShadow buttonRest = BoxShadow(
    color: _deepShadow,
    offset: Offset(0, 3),
    blurRadius: 6,
  );

  /// Pressed button shadow — flatter, simulates depression into wood
  static const BoxShadow buttonPressed = BoxShadow(
    color: _shadowColor,
    offset: Offset(0, 1),
    blurRadius: 2,
  );

  // ─── List convenience getters ────────────────────────────────────────

  /// Deep panel shadow for cinematic wood background (offset 0 8, blur 16, 60 % black)
  static const BoxShadow _panelDeep = BoxShadow(
    color: Color(0x99000000), // rgba(0,0,0,0.60)
    offset: Offset(0, 8),
    blurRadius: 16,
  );

  static List<BoxShadow> get panelShadow  => const [_panelDeep];
  static List<BoxShadow> get boardShadow  => const [large];
  static List<BoxShadow> get buttonShadow => const [buttonRest];
  static List<BoxShadow> get cardShadow   => const [small];
}
