import 'package:flutter/material.dart';
import '../models/tournament_match_model.dart';

class MatchTile extends StatelessWidget {
  final TournamentMatchModel match;
  final VoidCallback? onTap;

  const MatchTile({
    Key? key,
    required this.match,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Player 1
              Expanded(
                child: _buildPlayer(
                  match.player1Name ?? 'Player 1',
                  match.player1Score,
                  match.winnerId == match.player1Id,
                  true,
                ),
              ),
              // Score divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      match.displayScore,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (match.isArmageddon)
                      const Text(
                        'Armageddon',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              // Player 2
              Expanded(
                child: _buildPlayer(
                  match.player2Name ?? 'Player 2',
                  match.player2Score,
                  match.winnerId == match.player2Id,
                  false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(
    String name,
    int score,
    bool isWinner,
    bool alignLeft,
  ) {
    return Column(
      crossAxisAlignment:
          alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWinner && !alignLeft)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            Flexible(
              child: Text(
                name == 'BYE' ? 'BYE' : name,
                style: TextStyle(
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                  color: name == 'BYE' ? Colors.grey : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isWinner && alignLeft)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
