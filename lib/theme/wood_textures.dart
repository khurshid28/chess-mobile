import 'package:flutter/material.dart';

/// Classic wooden chess design system — wood texture helpers.
///
/// Provides [DecorationImage] factories that apply `wood_panel.jpg`
/// with different darken levels for each element type.
///
/// Asset: `assets/boards/wood_panel.jpg` (CC0, ambientCG WoodFloor040 — uniform straight-grain wood)
abstract final class WoodTextures {
  WoodTextures._();

  static const String _panelAsset = 'assets/boards/wood_panel.jpg';
  static const String _bgAsset    = 'assets/boards/wood_bg.jpg';
  static const String _boardAsset = 'assets/boards/wood.jpg';

  // ─── Background (full-screen) ──────────────────────────────────────
  /// wood_panel texture with warm wood color tint for background.
  static DecorationImage background() => const DecorationImage(
    image: AssetImage(_panelAsset),
    repeat: ImageRepeat.repeat,
    scale: 0.5,
  );

  // ─── Panel / card surface ──────────────────────────────────────────
  /// Standard panel — gentle darken for readability.
  static DecorationImage panel({Alignment alignment = Alignment.center}) =>
      DecorationImage(
        image: const AssetImage(_panelAsset),
        repeat: ImageRepeat.repeat,
        alignment: alignment,
        colorFilter: const ColorFilter.mode(
          Color(0x1AFFD700), // kColorAccent ~10%
          BlendMode.darken,
        ),
      );

  // ─── Dark panel ────────────────────────────────────────────────────
  /// Deeper panel used for backgrounds or darker surfaces.
  static DecorationImage panelDark({Alignment alignment = Alignment.center}) =>
      DecorationImage(
        image: const AssetImage(_panelAsset),
        repeat: ImageRepeat.repeat,
        alignment: alignment,
        colorFilter: const ColorFilter.mode(
          Color(0x33FFD700), // kColorAccent ~20%
          BlendMode.darken,
        ),
      );

  // ─── Button ────────────────────────────────────────────────────────
  /// Resting button face.
  static DecorationImage button({Alignment alignment = Alignment.centerLeft}) =>
      DecorationImage(
        image: const AssetImage(_panelAsset),
        repeat: ImageRepeat.repeat,
        alignment: alignment,
        colorFilter: const ColorFilter.mode(
          Color(0x26FFD700), // kColorAccent ~15%
          BlendMode.darken,
        ),
      );

  /// Pressed button — darker.
  static DecorationImage buttonPressed(
          {Alignment alignment = Alignment.centerLeft}) =>
      DecorationImage(
        image: const AssetImage(_panelAsset),
        repeat: ImageRepeat.repeat,
        alignment: alignment,
        colorFilter: const ColorFilter.mode(
          Color(0x40FFD700), // kColorAccent ~25%
          BlendMode.darken,
        ),
      );

  // ─── Icon container ────────────────────────────────────────────────
  /// Small icon background — quite dark to make gold icons pop.
  static DecorationImage icon({Alignment alignment = Alignment.topLeft}) =>
      DecorationImage(
        image: const AssetImage(_panelAsset),
        repeat: ImageRepeat.repeat,
        alignment: alignment,
        colorFilter: const ColorFilter.mode(
          Color(0x4DFFD700), // kColorAccent ~30%
          BlendMode.darken,
        ),
      );

  // ─── Board frame ───────────────────────────────────────────────────
  /// Board outer frame — lightest darken to show grain clearly.
  static DecorationImage frame({Alignment alignment = Alignment.topLeft}) =>
      DecorationImage(
        image: const AssetImage(_panelAsset),
        repeat: ImageRepeat.repeat,
        alignment: alignment,
        colorFilter: const ColorFilter.mode(
          Color(0x0DFFD700), // kColorAccent ~5%
          BlendMode.darken,
        ),
      );

  // ─── Menu list container ───────────────────────────────────────────
  /// Menu list wrapper — similar to panel but slightly different alignment.
  static DecorationImage menuList(
          {Alignment alignment = Alignment.topCenter}) =>
      DecorationImage(
        image: const AssetImage(_panelAsset),
        repeat: ImageRepeat.repeat,
        alignment: alignment,
        colorFilter: const ColorFilter.mode(
          Color(0x1AFFD700), // kColorAccent ~10%
          BlendMode.darken,
        ),
      );
}
