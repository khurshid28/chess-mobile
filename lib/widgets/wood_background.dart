import 'package:flutter/material.dart';

/// Premium wooden chess table background — light warm wood.
///
/// Layers (back → front):
///   1. Base warm wood vertical gradient  (#DEB887 → #D2B48C → #C4956A)
///   2. Center warm lamp glow             (rgba 255,220,150 @ 8 %)
///   3. Subtle edge vignette              (light shadow for depth)
class WoodBackground extends StatelessWidget {
  const WoodBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1: Base warm wood gradient ──────────────────────────────────
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFDEB887), // BurlyWood
                  Color(0xFFD2B48C), // Tan
                  Color(0xFFC4956A), // Darker wood
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ── 2: Center warm lamp glow ────────────────────────────────────
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 2.0,
                colors: [Color(0x14FFDC96), Color(0x00000000)],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),

        // ── 3: Subtle top vignette ──────────────────────────────────────
        const Positioned(
          top: 0, left: 0, right: 0, height: 150,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x18000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // ── 4: Subtle bottom vignette ───────────────────────────────────
        const Positioned(
          bottom: 0, left: 0, right: 0, height: 100,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x14000000), Color(0x00000000)],
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
