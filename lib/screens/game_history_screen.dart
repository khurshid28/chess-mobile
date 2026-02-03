
import 'package:chess_park/models/game_model.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/services/bot_game_database.dart';
import 'package:chess_park/models/bot_game_history_model.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/game_history_tile.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:chess_park/screens/game_review_screen.dart';

class GameHistoryScreen extends StatelessWidget {
  final String userId;
  const GameHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: _GameHistoryList(userId: userId),
        ),
      ),
    );
  }
}


class _GameHistoryList extends StatelessWidget {
  const _GameHistoryList({required this.userId});

  final String userId;

  Future<List<dynamic>> _fetchAllGames() async {
    final List<dynamic> allGames = [];
    
    // Fetch online games
    try {
      final onlineGames = await FirestoreService().getUserGames(userId);
      allGames.addAll(onlineGames);
    } catch (e) {
      print('Error fetching online games: $e');
    }
    
    // Fetch bot games
    try {
      final botGames = await BotGameDatabase.instance.getGamesByUser(userId);
      allGames.addAll(botGames);
    } catch (e) {
      print('Error fetching bot games: $e');
    }
    
    // Sort by date (newest first)
    allGames.sort((a, b) {
      final aDate = a is GameModel ? (a.completedAt ?? a.lastMoveTimestamp)?.toDate() ?? DateTime.now() : (a as BotGameHistory).createdAt;
      final bDate = b is GameModel ? (b.completedAt ?? b.lastMoveTimestamp)?.toDate() ?? DateTime.now() : (b as BotGameHistory).createdAt;
      return bDate.compareTo(aDate);
    });
    
    return allGames;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchAllGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.kColorAccent),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'O\'yin tarixi yo\'q.',
              style: TextStyle(color: AppTheme.kColorTextSecondary),
            ),
          );
        }

        final games = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: games.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.white.withAlpha(230), height: 1),
              itemBuilder: (context, index) {
                final game = games[index];
                
                if (game is GameModel) {
                  return GameHistoryTile(
                    game: game,
                    currentUserId: userId,
                  );
                } else if (game is BotGameHistory) {
                  return _BotGameHistoryTile(
                    game: game,
                    userId: userId,
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

class _BotGameHistoryTile extends StatelessWidget {
  final BotGameHistory game;
  final String userId;

  const _BotGameHistoryTile({
    required this.game,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    String result;
    Color resultColor;
    IconData resultIcon;
    
    if (game.isDraw) {
      result = 'Durang';
      resultColor = Colors.orange;
      resultIcon = Icons.handshake;
    } else if (game.isWin) {
      result = 'G\'alaba';
      resultColor = Colors.green;
      resultIcon = Icons.emoji_events;
    } else {
      result = 'Mag\'lubiyat';
      resultColor = Colors.red;
      resultIcon = Icons.close;
    }

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameReviewScreen(
              moveHistory: game.moveHistory,
              playerName: 'Siz',
              opponentName: game.botName,
              result: result,
              resultReason: game.resultReason,
              playerAccuracy: game.accuracy.toDouble(),
              opponentAccuracy: 75.0,
              playerRating: null,
              opponentRating: game.botRating,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
      title: Text(
        game.botName,
        style: const TextStyle(color: AppTheme.kColorTextPrimary),
      ),
      subtitle: Text(
        '${game.botRating} • ${game.movesPlayed} yurish',
        style: const TextStyle(color: AppTheme.kColorTextSecondary, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(resultIcon, color: resultColor, size: 16),
              const SizedBox(width: 4),
              Text(
                result,
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (game.ratingChange != 0)
            Text(
              '${game.ratingChange > 0 ? '+' : ''}${game.ratingChange}',
              style: TextStyle(
                color: game.ratingChange > 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}