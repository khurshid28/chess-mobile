import 'package:flutter/material.dart';
import '../models/tournament_model.dart';

class CategoryBadge extends StatelessWidget {
  final TournamentCategory category;
  final double size;
  final bool showLabel;

  const CategoryBadge({
    Key? key,
    required this.category,
    this.size = 40,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.3,
        vertical: size * 0.2,
      ),
      decoration: BoxDecoration(
        color: _getCategoryColor(),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.name.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.4,
            ),
          ),
          if (showLabel) ...[
            SizedBox(width: size * 0.1),
            Text(
              _getCategoryRange(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: size * 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category) {
      case TournamentCategory.a:
        return Colors.blue[600]!;
      case TournamentCategory.b:
        return Colors.purple[600]!;
      case TournamentCategory.c:
        return Colors.orange[600]!;
      case TournamentCategory.d:
        return Colors.red[600]!;
    }
  }

  String _getCategoryRange() {
    switch (category) {
      case TournamentCategory.a:
        return '1200-1500';
      case TournamentCategory.b:
        return '1500-1800';
      case TournamentCategory.c:
        return '1800-2000';
      case TournamentCategory.d:
        return '2000+';
    }
  }
}
