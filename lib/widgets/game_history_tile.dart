
import 'package:chess_park/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:chess_park/models/game_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chess_park/screens/game_detail_screen.dart';

class GameHistoryTile extends StatelessWidget {
  final GameModel game;
  final String currentUserId;

  const GameHistoryTile({
    super.key,
    required this.game,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isUserWhite = game.playerWhiteId == currentUserId;
    final isTournament = game.tournamentId != null;

    final opponentName = isUserWhite ? game.playerBlackName : game.playerWhiteName;
    final opponentRating = isUserWhite ? game.playerBlackElo : game.playerWhiteElo;
    final opponentImage = isUserWhite ? game.playerBlackImage : game.playerWhiteImage;

    String resultText;
    Color resultColor;

    if (game.winner == 'draw') {
      resultText = 'Draw';
      resultColor = AppTheme.kColorTextSecondary;
    } else if ((game.winner == 'white' && isUserWhite) || (game.winner == 'black' && !isUserWhite)) {
      resultText = 'Win';
      resultColor = AppTheme.kColorWin;
    } else {
      resultText = 'Loss';
      resultColor = AppTheme.kColorLoss;
    }

    final String opponentDisplay = "${opponentName ?? 'Opponent'} (${opponentRating ?? '...'})";


    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailScreen(
              game: game,
              currentUserId: currentUserId,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white24,
        backgroundImage: opponentImage != null
            ? CachedNetworkImageProvider(opponentImage)
            : null,
        child: opponentImage == null
            ? const Icon(
                Icons.person_outline,
                size: 24,
                color: AppTheme.kColorTextSecondary,
              )
            : null,
      ),
      title: Text(
        opponentDisplay,
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.kColorTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: isTournament
          ? Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tournament',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            resultText,
            style: TextStyle(
              fontSize: 14,
              color: resultColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.kColorTextSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}