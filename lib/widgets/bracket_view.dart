import 'package:flutter/material.dart';
import '../models/tournament_match_model.dart';

class BracketView extends StatelessWidget {
  final List<TournamentRoundModel> rounds;

  const BracketView({
    Key? key,
    required this.rounds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rounds.isEmpty) {
      return const Center(
        child: Text('Bracket not yet generated'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rounds.map((round) {
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: _buildRoundColumn(round),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoundColumn(TournamentRoundModel round) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Round title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            round.roundName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Matches
        ...round.matches.map((match) => _buildMatchCard(match)),
      ],
    );
  }

  Widget _buildMatchCard(TournamentMatchModel match) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: match.isCompleted ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Player 1
          _buildPlayerRow(
            match.player1Name ?? 'Player 1',
            match.player1Score,
            match.winnerId == match.player1Id,
            true,
          ),
          // Divider
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          // Player 2
          _buildPlayerRow(
            match.player2Name ?? 'Player 2',
            match.player2Score,
            match.winnerId == match.player2Id,
            false,
          ),
          // Match status
          if (match.status == MatchStatus.inProgress)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.green[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(
    String name,
    int score,
    bool isWinner,
    bool isTop,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isWinner ? Colors.green[50] : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              name == 'BYE' ? 'BYE' : name,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: name == 'BYE' ? Colors.grey : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isWinner ? Colors.green : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                score.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isWinner ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
