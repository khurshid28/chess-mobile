import 'package:flutter/material.dart';
import 'wood_colors.dart';

/// Classic wooden chess design system — gradient tokens.
///
/// Every gradient is derived from the wood palette and simulates
/// natural light hitting a polished, slightly curved wooden surface.
abstract final class WoodGradients {
  WoodGradients._();

  // ─── Panel / card background ─────────────────────────────────────────
  /// Main surface gradient: lighter top (light catch) → darker bottom (depth)
  static const LinearGradient panel = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [WoodColors.woodLight, Color(0xFF5A3319)],
    stops: [0.0, 1.0],
  );

  /// Dark variant for deep backgrounds and full-screen shells
  static const LinearGradient panelDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [WoodColors.woodMedium, WoodColors.woodDark],
    stops: [0.0, 1.0],
  );

  // ─── Button ──────────────────────────────────────────────────────────
  /// Resting 3-D button face — bright top edge fades to dark bottom
  static const LinearGradient button = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [WoodColors.woodLight, Color(0xFF5A3319)],
    stops: [0.0, 1.0],
  );

  /// Pressed button — reversed and much darker
  static const LinearGradient buttonPressed = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A2C18), Color(0xFF3A2010)],
    stops: [0.0, 1.0],
  );

  // ─── App background ──────────────────────────────────────────────────
  /// Full-screen radial — warm core fades to deep periphery
  static const RadialGradient appBackground = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.4,
    colors: [WoodColors.woodMedium, WoodColors.background],
    stops: [0.0, 1.0],
  );

  // ─── Board frame ─────────────────────────────────────────────────────
  /// Wooden border frame around the chess board
  static const LinearGradient boardFrame = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WoodColors.woodHighlight, WoodColors.woodDark],
    stops: [0.0, 1.0],
  );

  // ─── Gold accent ─────────────────────────────────────────────────────
  /// Metallic gold gradient for badges, medals, active indicators
  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0CA50), WoodColors.gold, Color(0xFF8A6A10)],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Top highlight overlay ───────────────────────────────────────────
  /// Apply on top of any wood surface to simulate light reflection
  static const LinearGradient topHighlight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1FFFFFFF), Color(0x00000000)],
    stops: [0.0, 0.4],
  );

  // ─── Navigation bar ──────────────────────────────────────────────────
  static const LinearGradient navBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [WoodColors.woodDark, WoodColors.background],
    stops: [0.0, 1.0],
  );
}
