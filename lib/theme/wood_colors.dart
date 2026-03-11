import 'package:flutter/material.dart';

/// Classic wooden chess design system — color palette.
///
/// Every screen, panel, button, and board element must reference
/// these tokens so the whole app feels like a single carved-wood object.
abstract final class WoodColors {
  WoodColors._();

  // ─── Primary wood palette ────────────────────────────────────────────
  /// Deepest background — like the underside of a heavy board
  static const Color background = Color(0xFF2B1A0F);

  /// Default dark wood surface (app background panels)
  static const Color woodDark = Color(0xFF4A2C18);

  /// Mid-tone wood — containers, nav bar
  static const Color woodMedium = Color(0xFF6B3E1F);

  /// Light wood — cards, side panels
  static const Color woodLight = Color(0xFF8C5A2B);

  /// Highlight grain — raised surfaces, header bars
  static const Color woodHighlight = Color(0xFFA8733A);

  // ─── Border / divider ────────────────────────────────────────────────
  /// Carved groove border between elements
  static const Color border = Color(0xFF7A4F22);

  /// Thin hairline divider
  static const Color divider = Color(0xFF5A3A18);

  // ─── Text ────────────────────────────────────────────────────────────
  /// Primary label colour — cream parchment
  static const Color textPrimary = Color(0xFFF5E6C8);

  /// Secondary / caption — warm tan
  static const Color textSecondary = Color(0xFFD1B38C);

  // ─── Accent ──────────────────────────────────────────────────────────
  /// Gold metallic accent — icons, active tabs, highlights
  static const Color gold = Color(0xFFD4AF37);

  /// Bright gold hover / pressed
  static const Color goldBright = Color(0xFFF0CA50);

  /// Muted gold for disabled states
  static const Color goldMuted = Color(0xFF8A6A10);

  // ─── Chess board ─────────────────────────────────────────────────────
  /// Light square colour
  static const Color boardLight = Color(0xFFF0D9B5);

  /// Dark square colour
  static const Color boardDark = Color(0xFFB58863);

  /// Last-move / selection highlight on board
  static const Color boardHighlight = Color(0xCCF6F669);

  // ─── Medal colours ───────────────────────────────────────────────────
  static const Color medalGold   = Color(0xFFD4AF37);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFCD7F32);

  // ─── Overlay helpers ─────────────────────────────────────────────────
  /// Top-edge highlight — simulates light catching polished wood
  static const Color topHighlight = Color(0x1FFFFFFF); // ~12 % white

  /// Bottom-edge shadow — depth below the board
  static const Color bottomShadow = Color(0x59000000);  // ~35 % black

  /// Button inner highlight
  static const Color buttonHighlight = Color(0x2DFFFFFF); // ~18 % white

  /// Pressed/hover tint overlay
  static const Color pressedOverlay = Color(0x0FFFFFFF);  //  ~6 % white

  /// Row hover tint
  static const Color rowHover = Color(0x0FFFFFFF);

  /// Leaderboard row background
  static const Color leaderboardRow = Color(0x33000000); // 20 % black
}
