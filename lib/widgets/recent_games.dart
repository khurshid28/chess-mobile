
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/services/bot_game_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chess_park/screens/game_review_screen.dart';
import 'package:chess_park/screens/game_history_screen.dart';
import 'package:intl/intl.dart';

class UnifiedGameItem {
  final String id;
  final String opponentName;
  final int opponentRating;
  final String? opponentImage;
  final String result; // 'win', 'loss', 'draw'
  final DateTime createdAt;
  final bool isBotGame;
  final int? accuracy;
  final int? ratingChange;
  final List<String> moveHistory;
  final String playerName;
  
  UnifiedGameItem({
    required this.id,
    required this.opponentName,
    required this.opponentRating,
    this.opponentImage,
    required this.result,
    required this.createdAt,
    required this.isBotGame,
    this.accuracy,
    this.ratingChange,
    required this.moveHistory,
    required this.playerName,
  });
}

class RecentGames extends StatelessWidget {
  final String userId;
  const RecentGames({super.key, required this.userId});

  List<String> _pgnToMoveHistory(String pgn) {
    if (pgn.isEmpty) return [];
    
    // Extract moves from PGN
    // Remove move numbers and result
    final movePattern = RegExp(r'\d+\.');
    final resultPattern = RegExp(r'(1-0|0-1|1/2-1/2|\*)\s*$');
    
    String movesText = pgn.replaceAll(movePattern, '').replaceAll(resultPattern, '').trim();
    
    // Split by whitespace and filter empty strings
    List<String> moves = movesText.split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    
    return moves;
  }

  Future<List<UnifiedGameItem>> _fetchAllGames() async {
    final List<UnifiedGameItem> allGames = [];
    
    // Fetch online games
    try {
      final onlineGames = await FirestoreService().getUserGames(userId, limit: 10);
      for (final game in onlineGames) {
        final isUserWhite = game.playerWhiteId == userId;
        String result;
        if (game.winner == 'draw') {
          result = 'draw';
        } else if ((game.winner == 'white' && isUserWhite) || (game.winner == 'black' && !isUserWhite)) {
          result = 'win';
        } else {
          result = 'loss';
        }
        
        allGames.add(UnifiedGameItem(
          id: game.id,
          opponentName: isUserWhite ? (game.playerBlackName ?? 'Opponent') : (game.playerWhiteName ?? 'Opponent'),
          opponentRating: isUserWhite ? (game.playerBlackElo ?? 1200) : (game.playerWhiteElo ?? 1200),
          opponentImage: isUserWhite ? game.playerBlackImage : game.playerWhiteImage,
          result: result,
          createdAt: (game.completedAt ?? game.lastMoveTimestamp ?? Timestamp.now()).toDate(),
          isBotGame: false,
          moveHistory: _pgnToMoveHistory(game.pgn),
          playerName: isUserWhite ? (game.playerWhiteName ?? 'You') : (game.playerBlackName ?? 'You'),
        ));
      }
    } catch (e) {
      print('Error fetching online games: $e');
    }
    
    // Fetch bot games from database
    try {
      final botGames = await BotGameDatabase.instance.getGamesByUser(userId, limit: 10);
      print('🎮 Bot games fetched: ${botGames.length}');
      
      for (final botGame in botGames) {
        print('🎮 Bot game: ${botGame.id}, bot: ${botGame.botName}, result: ${botGame.result}');
        String result;
        if (botGame.isDraw) {
          result = 'draw';
        } else if (botGame.isWin) {
          result = 'win';
        } else {
          result = 'loss';
        }
        
        allGames.add(UnifiedGameItem(
          id: botGame.id,
          opponentName: botGame.botName,
          opponentRating: botGame.botRating,
          opponentImage: null,
          result: result,
          createdAt: botGame.createdAt,
          isBotGame: true,
          accuracy: botGame.accuracy,
          ratingChange: botGame.ratingChange,
          moveHistory: botGame.moveHistory,
          playerName: 'You',
        ));
      }
      print('🎮 Total games after bot games: ${allGames.length}');
    } catch (e) {
      print('Error fetching bot games: $e');
    }
    
    // Sort by date and return top 5
    allGames.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allGames.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UnifiedGameItem>>(
      future: _fetchAllGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          print('Error loading recent games: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final games = snapshot.data!;

        return GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: games.length,
                separatorBuilder: (context, index) => Divider(color: Colors.white.withAlpha(50), height: 1),
                itemBuilder: (context, index) {
                  return _buildGameTile(context, games[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGameTile(BuildContext context, UnifiedGameItem game) {
    Color resultColor;
    String resultText;
    
    switch (game.result) {
      case 'win':
        resultColor = AppTheme.kColorWin;
        resultText = 'Win';
        break;
      case 'loss':
        resultColor = AppTheme.kColorLoss;
        resultText = 'Loss';
        break;
      case 'draw':
        resultColor = AppTheme.kColorTextSecondary;
        resultText = 'Draw';
        break;
      default:
        resultColor = AppTheme.kColorTextSecondary;
        resultText = 'Unknown';
    }
    
    final dateStr = DateFormat('MMM d, HH:mm').format(game.createdAt);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      onTap: () {
        if (game.moveHistory.isNotEmpty) {
          // Navigate to game review for games with move history
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameReviewScreen(
                moveHistory: game.moveHistory,
                playerName: game.playerName,
                opponentName: game.opponentName,
                result: resultText,
                resultReason: game.isBotGame ? 'Bot o\'yin' : 'Online o\'yin',
              ),
            ),
          );
        }
      },
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: game.isBotGame ? Colors.purple.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
        child: Icon(
          game.isBotGame ? Icons.smart_toy : Icons.public,
          size: 20,
          color: game.isBotGame ? Colors.purple : Colors.blue,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              game.opponentName,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.kColorTextPrimary,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '(${game.opponentRating})',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.kColorTextSecondary,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.kColorTextSecondary,
            ),
          ),
          if (game.accuracy != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.analytics, size: 12, color: Colors.blue),
            const SizedBox(width: 2),
            Text(
              '${game.accuracy}%',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (game.ratingChange != null && game.ratingChange != 0) ...[
            const SizedBox(width: 8),
            Icon(
              game.ratingChange! > 0 ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: game.ratingChange! > 0 ? Colors.green : Colors.red,
            ),
            Text(
              '${game.ratingChange! > 0 ? '+' : ''}${game.ratingChange}',
              style: TextStyle(
                fontSize: 11,
                color: game.ratingChange! > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      trailing: Text(
        resultText,
        style: TextStyle(
          fontSize: 13,
          color: resultColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => GameHistoryScreen(userId: userId),
          ));
      },
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.history, color: AppTheme.kColorAccent, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Oxirgi o\'yinlar',
              style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.kColorTextPrimary,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'Hammasini ko\'rish',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.kColorAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios, color: AppTheme.kColorAccent, size: 14),
        ],
      ),
    );
  }
}