import 'package:flutter/material.dart';
import 'package:chess_park/theme/wood_textures.dart';

/// Premium wooden chess table background — real wood texture.
///
/// Full-screen wood texture that fully covers the page.
/// No circular effects — just clean wood grain.
class WoodBackground extends StatelessWidget {
  const WoodBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Static background layers (never rebuild) ───────────────────
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: WoodTextures.background(),
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x40000000), // ~25% black darken
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x0DFFD700), // kColorAccent ~5% opacity
                ),
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
