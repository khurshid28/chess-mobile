import 'package:flutter/material.dart';
import 'wood_colors.dart';

/// Classic wooden chess design system — gradient tokens.
///
/// Every gradient is derived from the wood palette and simulates
/// natural light hitting a polished, slightly curved wooden surface.
abstract final class WoodGradients {
  WoodGradients._();

  // ─── Panel / card background ─────────────────────────────────────────
  /// Main surface gradient: lighter top → slightly darker bottom
  static const LinearGradient panel = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [WoodColors.woodHighlight, WoodColors.woodLight],
    stops: [0.0, 1.0],
  );

  /// Deeper variant for full backgrounds
  static const LinearGradient panelDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [WoodColors.woodLight, WoodColors.background],
    stops: [0.0, 1.0],
  );

  // ─── Button ──────────────────────────────────────────────────────────
  /// Resting button face — warm wood gradient
  static const LinearGradient button = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9A5B2F), Color(0xFF7A3F15)],
    stops: [0.0, 1.0],
  );

  /// Pressed button — darker
  static const LinearGradient buttonPressed = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7A3F15), Color(0xFF5E2E10)],
    stops: [0.0, 1.0],
  );

  // ─── App background ──────────────────────────────────────────────────
  /// Full-screen radial — warm center to edges
  static const RadialGradient appBackground = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.4,
    colors: [WoodColors.woodHighlight, WoodColors.background],
    stops: [0.0, 1.0],
  );

  // ─── Board frame ─────────────────────────────────────────────────────
  /// Wooden border frame around the chess board
  static const LinearGradient boardFrame = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [WoodColors.woodMedium, WoodColors.woodDark],
    stops: [0.0, 1.0],
  );

  // ─── Gold accent ─────────────────────────────────────────────────────
  /// Metallic gold gradient for badges, medals, active indicators
  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDAA520), WoodColors.gold, Color(0xFFA67B3D)],
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
    colors: [WoodColors.background, WoodColors.woodLight],
    stops: [0.0, 1.0],
  );
}
