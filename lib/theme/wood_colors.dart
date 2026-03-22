import 'package:flutter/material.dart';

/// Classic wooden chess design system — color palette.
///
/// Every screen, panel, button, and board element must reference
/// these tokens so the whole app feels like a single carved-wood object.
abstract final class WoodColors {
  WoodColors._();

  // ─── Primary wood palette ────────────────────────────────────────────
  /// Warm wood background
  static const Color background = Color(0xFFDEB887);

  /// Primary dark wood (SaddleBrown)
  static const Color woodDark = Color(0xFF8B4513);

  /// Mid-tone wood — containers, nav bar
  static const Color woodMedium = Color(0xFFCD853F);

  /// Light wood — cards, side panels
  static const Color woodLight = Color(0xFFD2B48C);

  /// Highlight grain — raised surfaces, header bars
  static const Color woodHighlight = Color(0xFFF4E4C1);

  // ─── Border / divider ────────────────────────────────────────────────
  /// Carved groove border between elements
  static const Color border = Color(0xFFC4956A);

  /// Thin hairline divider
  static const Color divider = Color(0xFFA0522D);

  // ─── Text ────────────────────────────────────────────────────────────
  /// Primary label colour — white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary / caption — light white
  static const Color textSecondary = Color(0xFFE0E0E0);

  // ─── Accent ──────────────────────────────────────────────────────────
  /// Gold metallic accent — icons, active tabs, highlights
  static const Color gold = Color(0xFFFFD700);

  /// Bright gold hover / pressed
  static const Color goldBright = Color(0xFFFFE44D);

  /// Muted gold for disabled states
  static const Color goldMuted = Color(0xFFBFA54D);

  // ─── Chess board ─────────────────────────────────────────────────────
  /// Light square colour
  static const Color boardLight = Color(0xFFF0D9B5);

  /// Dark square colour
  static const Color boardDark = Color(0xFFB58863);

  /// Last-move / selection highlight on board
  static const Color boardHighlight = Color(0xCCF6F669);

  // ─── Medal colours ───────────────────────────────────────────────────
  static const Color medalGold   = Color(0xFFCD7F32);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFA0522D);

  // ─── Overlay helpers ─────────────────────────────────────────────────
  /// Top-edge highlight — simulates light catching polished wood
  static const Color topHighlight = Color(0x1FFFFFFF); // ~12 % white

  /// Bottom-edge shadow — depth below the board
  static const Color bottomShadow = Color(0x33000000);  // ~20 % black

  /// Button inner highlight
  static const Color buttonHighlight = Color(0x2DFFFFFF); // ~18 % white

  /// Pressed/hover tint overlay
  static const Color pressedOverlay = Color(0x14000000);  //  ~8 % black

  /// Row hover tint
  static const Color rowHover = Color(0x14000000);

  /// Leaderboard row background
  static const Color leaderboardRow = Color(0x14000000); // 8 % black
}
