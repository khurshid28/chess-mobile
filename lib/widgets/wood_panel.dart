import 'package:flutter/material.dart';
import 'package:chess_park/theme/wood_borders.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_gradients.dart';
import 'package:chess_park/theme/wood_shadows.dart';

/// Classic wooden chess design system — carved wood panel container.
///
/// Drop [WoodPanel] anywhere you need a surface that looks like a
/// polished, carved piece of wood with realistic depth and grain.
///
/// ```dart
/// WoodPanel(
///   child: Text('Hello'),
/// )
/// ```
class WoodPanel extends StatelessWidget {
  const WoodPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.gradient,
    this.showTopHighlight = true,
    this.shadows,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  /// Override the default panel gradient, e.g. [WoodGradients.panelDark]
  final Gradient? gradient;

  /// Draw a subtle white highlight strip along the top edge (simulates light)
  final bool showTopHighlight;

  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? WoodBorders.normalRadius;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: gradient ?? WoodGradients.panel,
        border: WoodBorders.panel,
        boxShadow: shadows ?? WoodShadows.panelShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Main content
            Padding(padding: padding, child: child),

            // Top-edge highlight — simulates light catching the raised rim
            if (showTopHighlight)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: WoodGradients.topHighlight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Darker, deeper variant used for full-screen background shells.
class WoodPanelDark extends StatelessWidget {
  const WoodPanelDark({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return WoodPanel(
      padding: padding,
      margin: margin,
      gradient: WoodGradients.panelDark,
      borderRadius: WoodBorders.normalRadius,
      shadows: WoodShadows.cardShadow,
      child: child,
    );
  }
}

/// Thin horizontal divider that looks like a groove cut into wood.
class WoodDivider extends StatelessWidget {
  const WoodDivider({super.key, this.height = 1.0, this.indent = 0.0});

  final double height;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: indent),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            WoodColors.border,
            WoodColors.border,
            Colors.transparent,
          ],
          stops: [0.0, 0.1, 0.9, 1.0],
        ),
      ),
    );
  }
}
