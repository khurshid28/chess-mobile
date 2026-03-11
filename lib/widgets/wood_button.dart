import 'package:flutter/material.dart';
import 'package:chess_park/theme/wood_borders.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_gradients.dart';
import 'package:chess_park/theme/wood_shadows.dart';
import 'package:chess_park/theme/wood_text_styles.dart';

/// Classic wooden chess design system — tactile 3-D wooden button.
///
/// The button changes its gradient and shadow on press to simulate
/// being physically pushed into the wood surface.
///
/// ```dart
/// WoodButton(
///   label: 'Play Online',
///   onPressed: () {},
/// )
/// ```
class WoodButton extends StatefulWidget {
  const WoodButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 52.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.textStyle,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;

  @override
  State<WoodButton> createState() => _WoodButtonState();
}

class _WoodButtonState extends State<WoodButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _)     => setState(() => _pressed = false);
  void _onTapCancel()               => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? WoodBorders.buttonRadius;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: _pressed
              ? WoodGradients.buttonPressed
              : WoodGradients.button,
          border: WoodBorders.button,
          boxShadow: _pressed
              ? [WoodShadows.buttonPressed]
              : WoodShadows.buttonShadow,
        ),
        child: Stack(
          children: [
            // Top-edge specular highlight
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: _pressed
                        ? null
                        : WoodGradients.topHighlight,
                  ),
                ),
              ),
            ),
            // Label row
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: widget.textStyle ?? WoodTextStyles.buttonLabel,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon-only circular wooden button (e.g. resign, hint)
class WoodIconButton extends StatefulWidget {
  const WoodIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48.0,
    this.iconColor = WoodColors.gold,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color iconColor;
  final String? tooltip;

  @override
  State<WoodIconButton> createState() => _WoodIconButtonState();
}

class _WoodIconButtonState extends State<WoodIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_)   => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _pressed
              ? WoodGradients.buttonPressed
              : WoodGradients.button,
          border: WoodBorders.button,
          boxShadow: _pressed
              ? [WoodShadows.buttonPressed]
              : WoodShadows.buttonShadow,
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: widget.size * 0.45,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}
