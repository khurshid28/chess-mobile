import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dartchess/dartchess.dart' as dartchess;
import 'package:dartchess/dartchess.dart' show Move;
import 'package:chess_park/providers/bot_game_provider.dart';
import 'package:chess_park/providers/settings_provider.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/chess/export.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/screens/game_review_screen.dart';

class BotGameView extends StatefulWidget {
  const BotGameView({super.key});

  @override
  State<BotGameView> createState() => _BotGameViewState();
}

class _BotGameViewState extends State<BotGameView> {
  dartchess.Role? _pendingPromotionRole;
  bool _gameOverDialogShown = false;
  
  @override
  void dispose() {
    // Stop timer when leaving screen
    final provider = context.read<BotGameProvider>();
    provider.pauseTimer();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if game is over and show dialog
    final botGameProvider = context.watch<BotGameProvider>();
    if (botGameProvider.isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      // Use post frame callback to avoid building during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog(context);
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final botGameProvider = context.watch<BotGameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Check if game has been initialized
    if (botGameProvider.currentBot == null) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.kColorAccent),
          ),
        ),
      );
    }

    final playerOrientation = botGameProvider.userSide;
    final isUserTurn = botGameProvider.isUserTurn;
    final isThinking = botGameProvider.isThinking;

    // Player display info
    final botPlayerWidget = _buildBotPlayerInfo(
      botGameProvider.botDisplayName,
      botGameProvider.botDisplayRating,
    );

    final userRating = authProvider.userModel?.elo ?? 1200;
    final userName = authProvider.userModel?.displayName ?? 'You';
    final userPlayerWidget = _buildUserPlayerInfo(userName, userRating);

    // User ALWAYS at bottom, bot ALWAYS at top
    final topPlayerWidget = botPlayerWidget;
    final bottomPlayerWidget = userPlayerWidget;

    return PopScope(
      canPop: botGameProvider.isGameOver,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;
        if (!botGameProvider.isGameOver) {
          _showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: SafeArea(
            child: Column(
              children: [
                // Top section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBar(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      child: topPlayerWidget,
                    ),
                  ],
                ),

                // Chess board - full width and height
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boardSize = constraints.maxWidth;
                              
                              // Determine player side for interaction
                              PlayerSide playerSide = PlayerSide.none;
                              if (isUserTurn && !isThinking) {
                                playerSide = playerOrientation == dartchess.Side.white
                                    ? PlayerSide.white
                                    : PlayerSide.black;
                              }
                              
                              // Get last move for highlighting
                              Move? lastMove;
                              if (botGameProvider.moveHistory.isNotEmpty) {
                                final lastMoveUci = botGameProvider.moveHistory.last;
                                try {
                                  lastMove = Move.parse(lastMoveUci);
                                } catch (e) {
                                  // Invalid move UCI, skip highlighting
                                  debugPrint('Invalid move UCI: $lastMoveUci');
                                }
                              }
                              
                              return Chessboard(
                                size: boardSize,
                              orientation: playerOrientation,
                              fen: botGameProvider.fen,
                              lastMove: lastMove,
                              settings: ChessboardSettings(
                                colorScheme: settingsProvider.currentBoardTheme,
                                pieceAssets: settingsProvider.currentPieceAssets,
                                showValidMoves: true,
                                animationDuration: const Duration(milliseconds: 250),
                              ),
                              game: GameData(
                                playerSide: playerSide,
                                sideToMove: botGameProvider.position.turn,
                                isCheck: botGameProvider.position.isCheck,
                              validMoves: botGameProvider.validMoves,
                              promotionMove: _pendingPromotionRole != null ? null : null,
                              onMove: (move, {isDrop}) => _handleMove(context, move),
                              onPromotionSelection: (role) {
                                setState(() {
                                  _pendingPromotionRole = role;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Bottom section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      child: bottomPlayerWidget,
                    ),
                    // Move history at bottom - flexible height
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          maxHeight: 55,
                        ),
                        child: _buildMoveHistory(botGameProvider),
                      ),
                    ),
                    if (!botGameProvider.isGameOver)
                      _buildActionButtons(context, botGameProvider),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final botGameProvider = context.watch<BotGameProvider>();
    String title = 'Bot Game';
    
    if (botGameProvider.isGameOver) {
      title = 'Game Over';
    } else if (botGameProvider.isThinking) {
      title = 'Bot is thinking...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (botGameProvider.isGameOver) {
                Navigator.pop(context);
              } else {
                _showExitConfirmationDialog(context);
              }
            },
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showGameMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveHistory(BotGameProvider provider) {
    final moves = provider.moveHistory;
    final lastMoveIndex = moves.length - 1;
    
    return GlassPanel(
      child: moves.isEmpty
          ? const Center(
              child: Text(
                'Hali yurishlar yo\'q',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: moves.length,
              itemBuilder: (context, index) {
                final isLastMove = index == lastMoveIndex;
                final isWhite = index % 2 == 0;
                final moveNumber = (index ~/ 2) + 1;
                
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLastMove
                        ? AppTheme.kColorAccent.withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: isLastMove
                        ? Border.all(color: AppTheme.kColorAccent, width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isWhite)
                        Text(
                          '$moveNumber. ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        moves[index],
                        style: TextStyle(
                          color: isLastMove ? AppTheme.kColorAccent : Colors.white,
                          fontSize: 14,
                          fontWeight: isLastMove ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBotPlayerInfo(String name, int rating) {
    final botGameProvider = context.watch<BotGameProvider>();
    final timeLeft = botGameProvider.botTimeLeft;
    final minutes = timeLeft ~/ 60;
    final seconds = timeLeft % 60;
    final isBotTurn = !botGameProvider.isUserTurn;
    
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.kColorAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppTheme.kColorAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rating: $rating',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Turn indicator
            if (isBotTurn && !botGameProvider.isGameOver)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Icon(
                  Icons.circle,
                  color: Colors.orange,
                  size: 12,
                ),
              ),
            // Timer display with border when it's bot's turn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timeLeft < 60 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: isBotTurn && !botGameProvider.isGameOver
                    ? Border.all(color: Colors.orange, width: 3)
                    : null,
              ),
              child: Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: timeLeft < 60 ? Colors.red : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPlayerInfo(String name, int rating) {
    final botGameProvider = context.watch<BotGameProvider>();
    final timeLeft = botGameProvider.userTimeLeft;
    final minutes = timeLeft ~/ 60;
    final seconds = timeLeft % 60;
    final isUserTurn = botGameProvider.isUserTurn;
    
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.kColorAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.kColorAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rating: $rating',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Turn indicator
            if (isUserTurn && !botGameProvider.isGameOver)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 12,
                ),
              ),
            // Timer display with border when it's user's turn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timeLeft < 60 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: isUserTurn && !botGameProvider.isGameOver
                    ? Border.all(color: Colors.green, width: 3)
                    : null,
              ),
              child: Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: timeLeft < 60 ? Colors.red : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BotGameProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showResignConfirmation(context),
              icon: const Icon(Icons.flag),
              label: const Text('Resign'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                provider.offerDraw();
              },
              icon: const Icon(Icons.handshake),
              label: const Text('Draw'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.2),
                foregroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMove(BuildContext context, dartchess.NormalMove move) async {
    final provider = context.read<BotGameProvider>();
    
    // Check if this is a pawn promotion move
    final from = dartchess.Square(move.from);
    final to = dartchess.Square(move.to);
    final piece = provider.position.board.pieceAt(from);
    
    bool isPromotion = false;
    if (piece != null && piece.role == dartchess.Role.pawn) {
      final toRank = to.rank;
      if ((piece.color == dartchess.Side.white && toRank == dartchess.Rank.eighth) ||
          (piece.color == dartchess.Side.black && toRank == dartchess.Rank.first)) {
        isPromotion = true;
      }
    }
    
    if (isPromotion) {
      // Show promotion dialog
      final selectedRole = await _showPromotionDialog(context);
      if (selectedRole == null) return; // User cancelled
      
      // Create promotion move with the selected role
      final promotionMove = dartchess.Move.parse('${move.uci}${_roleToChar(selectedRole)}');
      if (promotionMove != null) {
        final success = await provider.makeUserMove(promotionMove);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Noto\'g\'ri yurish'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xatolik yuz berdi'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      final success = await provider.makeUserMove(move);
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Noto\'g\'ri yurish'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _roleToChar(dartchess.Role role) {
    switch (role) {
      case dartchess.Role.queen:
        return 'q';
      case dartchess.Role.rook:
        return 'r';
      case dartchess.Role.bishop:
        return 'b';
      case dartchess.Role.knight:
        return 'n';
      default:
        return 'q';
    }
  }

  Future<dartchess.Role?> _showPromotionDialog(BuildContext context) async {
    final provider = context.read<BotGameProvider>();
    final isWhite = provider.userSide == dartchess.Side.white;
    
    return showDialog<dartchess.Role>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Figurani tanlang',
          style: TextStyle(color: Colors.white),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPromotionPiece(ctx, dartchess.Role.queen, isWhite ? '♕' : '♛'),
            _buildPromotionPiece(ctx, dartchess.Role.rook, isWhite ? '♖' : '♜'),
            _buildPromotionPiece(ctx, dartchess.Role.bishop, isWhite ? '♗' : '♝'),
            _buildPromotionPiece(ctx, dartchess.Role.knight, isWhite ? '♘' : '♞'),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionPiece(BuildContext ctx, dartchess.Role role, String symbol) {
    return InkWell(
      onTap: () => Navigator.pop(ctx, role),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[600]!, width: 2),
        ),
        child: Center(
          child: Text(
            symbol,
            style: const TextStyle(
              fontSize: 42,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Taslim bo\'lasizmi?'),
        content: const Text('O\'yindan chiqsangiz, siz taslim bo\'lgan hisoblanasiz va o\'yin yutqaziladi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<BotGameProvider>();
              provider.resign(); // Auto resign on exit
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit game
            },
            child: const Text('Taslim bo\'lish', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResignConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resign?'),
        content: const Text('Are you sure you want to resign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<BotGameProvider>();
              provider.resign();
              Navigator.pop(ctx);
            },
            child: const Text('Resign', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    final provider = context.read<BotGameProvider>();
    final authProvider = context.read<AuthProvider>();
    
    String title = 'O\'yin tugadi';
    String result = '';
    Color resultColor = Colors.grey;
    IconData resultIcon = Icons.sports_esports;

    if (provider.gameResult == '1-0') {
      if (provider.userSide == dartchess.Side.white) {
        title = '🎉 Siz yutdingiz!';
        result = 'G\'alaba';
        resultColor = Colors.green;
        resultIcon = Icons.emoji_events;
      } else {
        title = '😔 Bot yutdi';
        result = 'Mag\'lubiyat';
        resultColor = Colors.red;
        resultIcon = Icons.sentiment_dissatisfied;
      }
    } else if (provider.gameResult == '0-1') {
      if (provider.userSide == dartchess.Side.black) {
        title = '🎉 Siz yutdingiz!';
        result = 'G\'alaba';
        resultColor = Colors.green;
        resultIcon = Icons.emoji_events;
      } else {
        title = '😔 Bot yutdi';
        result = 'Mag\'lubiyat';
        resultColor = Colors.red;
        resultIcon = Icons.sentiment_dissatisfied;
      }
    } else {
      title = '🤝 Durang';
      result = 'Durang';
      resultColor = Colors.orange;
      resultIcon = Icons.handshake;
    }

    // Calculate statistics
    final totalMoves = provider.moveHistory.length;
    final userMoves = (totalMoves / 2).ceil();
    
    // More realistic accuracy calculation (60-80 range) with decimals
    double userAccuracyBase = 70.0;
    if (result == 'G\'alaba') {
      userAccuracyBase = 75.0 + (totalMoves > 40 ? 5.0 : 0.0); // 75-80 for wins
    } else if (result == 'Mag\'lubiyat') {
      userAccuracyBase = 60.0 - (totalMoves < 20 ? 5.0 : 0.0); // 55-60 for losses
    } else {
      userAccuracyBase = 68.0; // 68 for draws
    }
    // Add decimal variation based on move count
    final decimalPart = (totalMoves % 10) * 0.1;
    final userAccuracy = (userAccuracyBase + decimalPart - 0.5).clamp(55.0, 82.0);
    final accuracy = userAccuracy;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Column(
          children: [
            Icon(resultIcon, size: 48, color: resultColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: resultColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.gameResultReason ?? 'Game ended',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Yurishlar', userMoves.toString(), Icons.timeline),
                _buildStatItem('Aniqlik', '${accuracy.toStringAsFixed(1)}%', Icons.analytics),
              ],
            ),
            const SizedBox(height: 12),
            if (result == 'G\'alaba')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '+${(provider.currentDifficulty?.averageRating ?? 1200) ~/ 50} rating',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (result == 'Mag\'lubiyat')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '-${(provider.currentDifficulty?.averageRating ?? 1200) ~/ 50} rating',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit game
            },
            child: const Text('Chiqish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              final botAccuracy = provider.currentDifficulty?.averageRating != null 
                  ? ((provider.currentDifficulty!.averageRating - 400) / 20).clamp(60.0, 99.0)
                  : 80.0;
              
              // Navigate to review screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameReviewScreen(
                    moveHistory: provider.moveHistory,
                    playerName: authProvider.userModel?.displayName ?? 'Siz',
                    opponentName: provider.botDisplayName,
                    result: result,
                    resultReason: provider.gameResultReason ?? 'O\'yin tugadi',
                    playerAccuracy: userAccuracy,
                    opponentAccuracy: botAccuracy,
                    playerRating: authProvider.userModel?.elo ?? 1200,
                    opponentRating: provider.botDisplayRating,
                  ),
                ),
              );
            },
            child: const Text('Tahlil'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<BotGameProvider>();
              await provider.rematch();
              Navigator.pop(ctx);
            },
            child: const Text('Qayta o\'ynash'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showGameMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('Copy PGN'),
                onTap: () async {
                  final provider = context.read<BotGameProvider>();
                  final pgn = provider.getPgn();
                  await Clipboard.setData(ClipboardData(text: pgn));
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PGN copied to clipboard')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Exit Game'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (context.read<BotGameProvider>().isGameOver) {
                    Navigator.pop(context);
                  } else {
                    _showExitConfirmationDialog(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
