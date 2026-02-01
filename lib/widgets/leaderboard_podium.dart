import 'package:flutter/material.dart';
import '../models/leaderboard_entry_model.dart';
import 'star_display.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntryModel> topThree;

  const LeaderboardPodium({
    Key? key,
    required this.topThree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) {
      return const Center(
        child: Text('No winners yet'),
      );
    }

    // Arrange for podium display: 2nd, 1st, 3rd
    final first = topThree.length > 0 ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          if (second != null)
            Expanded(
              child: _buildPodiumPlace(
                context,
                second,
                2,
                140,
                Colors.grey[400]!,
              ),
            ),
          const SizedBox(width: 8),
          // First place (center, tallest)
          if (first != null)
            Expanded(
              child: _buildPodiumPlace(
                context,
                first,
                1,
                180,
                Colors.amber[400]!,
              ),
            ),
          const SizedBox(width: 8),
          // Third place
          if (third != null)
            Expanded(
              child: _buildPodiumPlace(
                context,
                third,
                3,
                120,
                Colors.brown[400]!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    BuildContext context,
    LeaderboardEntryModel entry,
    int place,
    double height,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar/Icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              place == 1 ? '🥇' : place == 2 ? '🥈' : '🥉',
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Name
        Text(
          entry.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Stars
        StarDisplay(
          stars: entry.totalStars,
          size: 16,
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.6),
                color,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$place',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
