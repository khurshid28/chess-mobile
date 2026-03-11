import 'package:flutter/material.dart';

/// Premium wooden chess table background.
///
/// Layers (back → front):
///   1. Base dark wood vertical gradient  (#2B1A0F → #1E140D → #120B07)
///   2. Center warm lamp glow             (rgba 255,220,150 @ 8 %)
///   3. Cinematic vignette — 4 edges      (rgba 0,0,0 @ 55 %, LinearGradient per side)
class WoodBackground extends StatelessWidget {
  const WoodBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1: Base dark polished wood gradient ─────────────────────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2B1A0F),
                  Color(0xFF1E140D),
                  Color(0xFF120B07),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // ── 2: Center warm lamp glow  rgba(255,220,150,0.08) ────────────
        // Uses a RadialGradient with large radius so the falloff is very
        // gradual — no visible circle edge on any screen size.
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 2.0,
                colors: [Color(0x14FFDC96), Color(0x00000000)],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),

        // ── 3a: Vignette — top edge ──────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0, height: 200,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x8C000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // ── 3b: Vignette — bottom edge ───────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0, height: 200,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x8C000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // ── 3c: Vignette — left edge ─────────────────────────────────────
        Positioned(
          top: 0, bottom: 0, left: 0, width: 120,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x8C000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // ── 3d: Vignette — right edge ────────────────────────────────────
        Positioned(
          top: 0, bottom: 0, right: 0, width: 120,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0x8C000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────────
        child,
      ],
    );
  }
}
