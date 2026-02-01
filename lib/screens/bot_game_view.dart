import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dartchess/dartchess.dart' as dartchess;
import 'package:chess_park/providers/bot_game_provider.dart';
import 'package:chess_park/providers/settings_provider.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/chess/export.dart';
import 'package:chess_park/widgets/glass_panel.dart';

class BotGameView extends StatefulWidget {
  const BotGameView({super.key});

  @override
  State<BotGameView> createState() => _BotGameViewState();
}

class _BotGameViewState extends State<BotGameView> {
  @override
  Widget build(BuildContext context) {
    final botGameProvider = context.watch<BotGameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

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
    Widget topPlayerWidget;
    Widget bottomPlayerWidget;

    final botPlayerWidget = _buildBotPlayerInfo(
      botGameProvider.botDisplayName,
      botGameProvider.botDisplayRating,
    );

    final userPlayerWidget = _buildUserPlayerInfo('You', 1500); // TODO: Get actual user rating

    if (playerOrientation == dartchess.Side.white) {
      topPlayerWidget = botPlayerWidget;
      bottomPlayerWidget = userPlayerWidget;
    } else {
      topPlayerWidget = userPlayerWidget;
      bottomPlayerWidget = botPlayerWidget;
    }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top section
                Column(
                  children: [
                    _buildAppBar(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: topPlayerWidget,
                    ),
                  ],
                ),

                // Chess board
                LayoutBuilder(
                  builder: (context, constraints) {
                    final boardSize = constraints.maxWidth;
                    
                    // Determine player side for interaction
                    PlayerSide playerSide = PlayerSide.none;
                    if (isUserTurn && !isThinking) {
                      playerSide = playerOrientation == dartchess.Side.white
                          ? PlayerSide.white
                          : PlayerSide.black;
                    }
                    
                    return Chessboard(
                      size: boardSize,
                      orientation: playerOrientation,
                      fen: botGameProvider.fen,
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
                        onMove: (move, {isDrop}) => _handleMove(context, move),
                      ),
                    );
                  },
                ),

                // Bottom section
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: bottomPlayerWidget,
                    ),
                    if (!botGameProvider.isGameOver)
                      _buildActionButtons(context, botGameProvider),
                    const SizedBox(height: 16),
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

  Widget _buildBotPlayerInfo(String name, int rating) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.kColorPrimary.withOpacity(0.3),
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
          ],
        ),
      ),
    );
  }

  Widget _buildUserPlayerInfo(String name, int rating) {
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

  void _handleMove(BuildContext context, Move move) async {
    final provider = context.read<BotGameProvider>();
    final success = await provider.makeUserMove(move);
    
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid move'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }

    // Check if game is over
    if (provider.isGameOver && mounted) {
      _showGameOverDialog(context);
    }
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('The game is still in progress. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit game
            },
            child: const Text('Exit'),
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
              if (provider.isGameOver) {
                _showGameOverDialog(context);
              }
            },
            child: const Text('Resign', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    final provider = context.read<BotGameProvider>();
    
    String title = 'Game Over';
    String message = '';

    if (provider.gameResult == '1-0') {
      title = provider.userSide == dartchess.Side.white ? 'You Won!' : 'Bot Won';
    } else if (provider.gameResult == '0-1') {
      title = provider.userSide == dartchess.Side.black ? 'You Won!' : 'Bot Won';
    } else {
      title = 'Draw';
    }

    message = provider.gameResultReason ?? 'Game ended';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit game
            },
            child: const Text('Exit'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<BotGameProvider>();
              await provider.rematch();
              Navigator.pop(ctx);
            },
            child: const Text('Rematch'),
          ),
        ],
      ),
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
                onTap: () {
                  final provider = context.read<BotGameProvider>();
                  // TODO: Implement copy to clipboard
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PGN copied')),
                  );
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
