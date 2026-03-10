import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';

class StarDisplay extends StatelessWidget {
  final int stars;
  final double size;
  final bool showLabel;

  const StarDisplay({
    Key? key,
    required this.stars,
    this.size = 20,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          AppIcons.rating,
          color: AppTheme.kColorAccent,
          size: size,
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            stars.toString(),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: AppTheme.kColorAccent,
            ),
          ),
        ],
      ],
    );
  }
}

class StarCounter extends StatelessWidget {
  final int stars;
  final String label;

  const StarCounter({
    Key? key,
    required this.stars,
    this.label = 'Total Stars',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.kColorAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.rating,
                color: AppTheme.kColorAccent,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                stars.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.kColorAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.kColorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
