import 'package:flutter/material.dart';

/// Icon with a drop shadow — matches WoodTextStyles shadow.
class WoodIcon extends StatelessWidget {
  const WoodIcon(
    this.icon, {
    super.key,
    required this.color,
    this.size = 24,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Shadow layer
          Transform.translate(
            offset: const Offset(0, 3),
            child: Icon(icon, size: size, color: Colors.black54),
          ),
          // Actual icon
          Icon(icon, size: size, color: color),
        ],
      ),
    );
  }
}
