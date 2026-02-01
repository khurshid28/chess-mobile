import 'package:flutter/material.dart';
import '../models/badge_model.dart';

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
              color: _getBadgeColor().withOpacity(0.4),
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
        return Colors.amber[600]!;
      } else if (badge.type.toString().contains('RunnerUp')) {
        return Colors.grey[400]!;
      } else {
        return Colors.brown[400]!;
      }
    }
    
    switch (badge.type) {
      case BadgeType.grandmaster:
        return Colors.purple[600]!;
      case BadgeType.tournamentWinner:
        return Colors.amber[600]!;
      case BadgeType.perfectScore:
        return Colors.blue[600]!;
      case BadgeType.speedster:
        return Colors.orange[600]!;
      case BadgeType.veteran:
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
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
              color: Colors.grey[300],
            ),
            child: Center(
              child: Text(
                '+$remaining',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
