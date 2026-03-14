import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../theme/app_theme.dart';

class BadgeDisplay extends StatelessWidget {
  final BadgeModel badge;
  final double size;

  const BadgeDisplay({
    Key? key,
    required this.badge,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${badge.name}\n${badge.description}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getBadgeGradient(),
          boxShadow: [
            BoxShadow(
              color: _getBadgeColor().withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            badge.icon,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }

  LinearGradient _getBadgeGradient() {
    final color = _getBadgeColor();
    return LinearGradient(
      colors: [color.withOpacity(0.8), color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getBadgeColor() {
    if (badge.isMonthly) {
      if (badge.type.toString().contains('Champion')) {
        return AppTheme.kGoldColor;
      } else if (badge.type.toString().contains('RunnerUp')) {
        return const Color(0xFFC0C0C0);
      } else {
        return const Color(0xFFCD7F32);
      }
    }
    
    switch (badge.type) {
      case BadgeType.grandmaster:
        return Colors.purple[600]!;
      case BadgeType.tournamentWinner:
        return AppTheme.kGoldColor;
      case BadgeType.perfectScore:
        return AppTheme.kColorInfo;
      case BadgeType.speedster:
        return AppTheme.kColorWarning;
      case BadgeType.veteran:
        return AppTheme.kColorWin;
      default:
        return AppTheme.kColorTextSecondary;
    }
  }
}

class BadgeGrid extends StatelessWidget {
  final List<BadgeModel> badges;
  final int maxDisplay;

  const BadgeGrid({
    Key? key,
    required this.badges,
    this.maxDisplay = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayBadges = badges.take(maxDisplay).toList();
    final remaining = badges.length - maxDisplay;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayBadges.map((badge) => BadgeDisplay(badge: badge, size: 50)),
        if (remaining > 0)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.kColorTextSecondary.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                '+$remaining',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.kColorTextSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
