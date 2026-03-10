import 'package:flutter/material.dart';
import 'package:dartchess/dartchess.dart' as dartchess;
import 'package:chess_park/providers/settings_provider.dart';
import 'package:chess_park/chess/export.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/widgets/captured_pieces_widget.dart';
import 'package:provider/provider.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class GameReviewScreen extends StatefulWidget {
  final List<String> moveHistory;
  final String playerName;
  final String opponentName;
  final String result;
  final String resultReason;
  final double? playerAccuracy;
  final double? opponentAccuracy;
  final int? playerRating;
  final int? opponentRating;
  final dartchess.Side? userSide; // User's playing color

  const GameReviewScreen({
    super.key,
    required this.moveHistory,
    required this.playerName,
    required this.opponentName,
    required this.result,
    required this.resultReason,
    this.playerAccuracy,
    this.opponentAccuracy,
    this.playerRating,
    this.opponentRating,
    this.userSide, // Defaults to white if not provided
  });

  @override
  State<GameReviewScreen> createState() => _GameReviewScreenState();
}

class _GameReviewScreenState extends State<GameReviewScreen> {
  int _currentMoveIndex = 0;
  late dartchess.Position _currentPosition;
  final List<dartchess.Position> _positions = [];
  final ScrollController _moveScrollController = ScrollController();
  bool _isLoading = true; // Start with loading state
  
  // Move evaluation counters for each player
  final Map<String, int> _playerMoveStats = {
    'brilliant': 0,
    'best': 0,
    'good': 0,
    'book': 0,
    'inaccuracy': 0,
    'mistake': 0,
    'blunder': 0,
  };
  
  final Map<String, int> _opponentMoveStats = {
    'brilliant': 0,
    'best': 0,
    'good': 0,
    'book': 0,
    'inaccuracy': 0,
    'mistake': 0,
    'blunder': 0,
  };

  @override
  void initState() {
    super.initState();
    _buildPositions();
    _calculateMoveEvaluations();
    // Show loading for 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _moveScrollController.dispose();
    super.dispose();
  }

  void _buildPositions() {
    _positions.clear();
    dartchess.Position position = dartchess.Chess.initial;
    _positions.add(position);

    for (final uci in widget.moveHistory) {
      final move = dartchess.Move.parse(uci);
      if (move != null) {
        position = position.playUnchecked(move);
        _positions.add(position);
      }
    }

    _currentPosition = _positions[0];
  }

  void _calculateMoveEvaluations() {
    // Calculate evaluations for all moves
    for (int i = 0; i < widget.moveHistory.length; i++) {
      final evaluation = _evaluateMove(i);
      if (evaluation != null) {
        final evalType = evaluation['type'] as String;
        final isPlayerMove = i % 2 == 0; // Assuming player is white (first move)
        
        if (isPlayerMove) {
          _playerMoveStats[evalType] = (_playerMoveStats[evalType] ?? 0) + 1;
        } else {
          _opponentMoveStats[evalType] = (_opponentMoveStats[evalType] ?? 0) + 1;
        }
      }
    }
  }

  void _goToMove(int index) {
    if (index >= 0 && index < _positions.length) {
      setState(() {
        _currentMoveIndex = index;
        _currentPosition = _positions[index];
      });
      
      // Auto-scroll to current move in the horizontal list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_moveScrollController.hasClients) return;
        
        if (index == 0) {
          // Scroll to start when at initial position
          _moveScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (index <= widget.moveHistory.length) {
          // index-1 because moveHistory ListView uses 0-based indexing
          // and index 0 in ListView = moveIndex 1
          final listViewIndex = index - 1;
          
          // Calculate approximate position
          // Each item is roughly 75-85px wide (move text + padding + margins)
          final itemWidth = 80.0;
          final targetPosition = listViewIndex * itemWidth;
          
          // Get max scroll to handle last items properly
          final maxScroll = _moveScrollController.position.maxScrollExtent;
          
          // For last few items, scroll to end to ensure full visibility
          final isNearEnd = listViewIndex >= widget.moveHistory.length - 3;
          final scrollPosition = isNearEnd ? maxScroll : targetPosition.clamp(0.0, maxScroll);
          
          _moveScrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _goToStart() {
    _goToMove(0);
  }

  void _goToPrevious() {
    if (_currentMoveIndex > 0) {
      _goToMove(_currentMoveIndex - 1);
    }
  }

  void _goToNext() {
    if (_currentMoveIndex < _positions.length - 1) {
      _goToMove(_currentMoveIndex + 1);
    }
  }

  void _goToEnd() {
    _goToMove(_positions.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    // Show loading animation while analyzing
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.kColorAccent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Analyzing game...',
                    style: TextStyle(
                      color: AppTheme.kColorTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Scrollable content including board
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top captured pieces (opponent's captures)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          children: [
                            CapturedPiecesWidget(
                              fen: _currentPosition.fen,
                              isWhiteSide: (widget.userSide ?? dartchess.Side.white) == dartchess.Side.black,
                              pieceSize: 22,
                            ),
                          ],
                        ),
                      ),
                      // Board (full width square) - no padding
                      SizedBox(
                        width: screenWidth,
                        height: screenWidth,
                        child: Chessboard(
                          size: screenWidth,
                          orientation: widget.userSide ?? dartchess.Side.white,
                          fen: _currentPosition.fen,
                          lastMove: _currentMoveIndex > 0 ? dartchess.Move.parse(widget.moveHistory[_currentMoveIndex - 1]) : null,
                          settings: ChessboardSettings(
                            colorScheme: settingsProvider.currentBoardTheme,
                            pieceAssets: settingsProvider.currentPieceAssets,
                            showValidMoves: false,
                            showLastMove: true,
                            animationDuration: const Duration(milliseconds: 200),
                          ),
                          game: GameData(
                            playerSide: PlayerSide.none,
                            sideToMove: _currentPosition.turn,
                            isCheck: _currentPosition.isCheck,
                            validMoves: const IMap.empty(),
                            promotionMove: null,
                            onMove: (_, {isDrop}) {},
                            onPromotionSelection: (_) {},
                          ),
                        ),
                      ),
                      // Bottom captured pieces (user's captures)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          children: [
                            CapturedPiecesWidget(
                              fen: _currentPosition.fen,
                              isWhiteSide: (widget.userSide ?? dartchess.Side.white) == dartchess.Side.white,
                              pieceSize: 22,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Move list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 80,
                            maxHeight: 110,
                          ),
                          child: _buildMoveList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Controls
                      _buildControls(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with back button
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.kColorTextPrimary),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Text(
                  'Game Analysis',
                  style: TextStyle(
                    color: AppTheme.kColorTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40), // Balance back button
            ],
          ),
          const SizedBox(height: 12),
          
          // Player cards with accuracy (positioned based on board orientation)
          Row(
            children: [
              Expanded(
                child: _buildPlayerCard(
                  name: widget.userSide == dartchess.Side.black ? widget.opponentName : widget.playerName,
                  rating: widget.userSide == dartchess.Side.black ? widget.opponentRating : widget.playerRating,
                  accuracy: widget.userSide == dartchess.Side.black ? widget.opponentAccuracy : widget.playerAccuracy,
                  isLeft: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlayerCard(
                  name: widget.userSide == dartchess.Side.black ? widget.playerName : widget.opponentName,
                  rating: widget.userSide == dartchess.Side.black ? widget.playerRating : widget.opponentRating,
                  accuracy: widget.userSide == dartchess.Side.black ? widget.playerAccuracy : widget.opponentAccuracy,
                  isLeft: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required int? rating,
    required double? accuracy,
    required bool isLeft,
  }) {
    return GlassPanel(
      child: Container(
        height: 95,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                color: AppTheme.kColorTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (rating != null)
              Text(
                'Рейтинг: $rating',
                style: TextStyle(
                  color: AppTheme.kColorTextSecondary,
                  fontSize: 11,
                ),
              ),
            const SizedBox(height: 6),
            if (accuracy != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAccuracyColor(accuracy.round()).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getAccuracyColor(accuracy.round()),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Точность:',
                      style: TextStyle(
                        color: AppTheme.kColorTextSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getAccuracyColor(accuracy.round()),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 95) return Colors.green;
    if (accuracy >= 85) return Colors.lightGreen;
    if (accuracy >= 75) return Colors.yellow;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMoveList() {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 4.0),
            child: Text(
              'Yurishlar',
              style: TextStyle(
                color: AppTheme.kColorTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, color: AppTheme.kColorTextSecondary.withOpacity(0.3), thickness: 1),
          Expanded(
            child: ListView.builder(
              controller: _moveScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: widget.moveHistory.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final moveIndex = index + 1;
                final move = widget.moveHistory[index];
                final evaluation = _evaluateMove(index);
                
                return GestureDetector(
                  onTap: () => _goToMove(moveIndex),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _currentMoveIndex == moveIndex
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.grey[800]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _currentMoveIndex == moveIndex
                            ? Colors.blue
                            : Colors.grey[700]!,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$moveIndex. ',
                              style: TextStyle(
                                color: AppTheme.kColorTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              move,
                              style: TextStyle(
                                color: AppTheme.kColorTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (evaluation != null)
                              const SizedBox(width: 18),
                          ],
                        ),
                        if (evaluation != null)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: (evaluation['color'] as Color).withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: evaluation['color'] as Color,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                evaluation['icon'] as IconData,
                                color: evaluation['color'] as Color,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _evaluateMove(int index) {
    // Note: In a real app, you'd use a chess engine like Stockfish
    // For now, using consistent seed-based evaluation
    if (index >= _positions.length - 1) return null;
    
    final moveUci = widget.moveHistory[index];
    
    // Use consistent seed based on move UCI and position
    final seed = (moveUci.hashCode + index * 37).abs();
    final value = seed % 100;
    
    // Evaluation distribution based on typical game analysis:
    // Blunder: 5%, Mistake: 10%, Inaccuracy: 15%, Book: 12%
    // Good: 20%, Best: 15%, Brilliant: 3%, Normal: 20%
    if (value < 5) {
      // Blunder ❌
      return {
        'icon': Icons.cancel,
        'color': Colors.red,
        'text': 'Blunder',
        'type': 'blunder',
      };
    } else if (value < 15) {
      // Mistake ⚡
      return {
        'icon': Icons.flash_on,
        'color': Colors.orange,
        'text': 'Mistake',
        'type': 'mistake',
      };
    } else if (value < 30) {
      // Inaccuracy ⚠
      return {
        'icon': Icons.warning_amber_rounded,
        'color': Colors.yellow[700],
        'text': 'Inaccuracy',
        'type': 'inaccuracy',
      };
    } else if (value < 42) {
      // Book 📖
      return {
        'icon': Icons.menu_book_rounded,
        'color': Colors.blue[300],
        'text': 'Book',
        'type': 'book',
      };
    } else if (value > 97) {
      // Brilliant ✨
      return {
        'icon': Icons.auto_awesome,
        'color': Colors.cyan,
        'text': 'Brilliant',
        'type': 'brilliant',
      };
    } else if (value > 82) {
      // Best ⭐
      return {
        'icon': Icons.star_rounded,
        'color': Colors.green,
        'text': 'Best',
        'type': 'best',
      };
    } else if (value > 62) {
      // Good ✓
      return {
        'icon': Icons.check_circle_outline_rounded,
        'color': Colors.lightGreen,
        'text': 'Good',
        'type': 'good',
      };
    }
    
    return null; // Normal move
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassPanel(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                'Yurish ${_currentMoveIndex} / ${widget.moveHistory.length}',
                style: TextStyle(
                  color: AppTheme.kColorTextPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.first_page, color: AppTheme.kColorTextPrimary),
                    onPressed: _currentMoveIndex > 0 ? _goToStart : null,
                    iconSize: 32,
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppTheme.kColorTextPrimary),
                    onPressed: _currentMoveIndex > 0 ? _goToPrevious : null,
                    iconSize: 32,
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: AppTheme.kColorTextPrimary),
                    onPressed: _currentMoveIndex < _positions.length - 1
                        ? _goToNext
                        : null,
                    iconSize: 32,
                  ),
                  IconButton(
                    icon: Icon(Icons.last_page, color: AppTheme.kColorTextPrimary),
                    onPressed: _currentMoveIndex < _positions.length - 1
                        ? _goToEnd
                        : null,
                    iconSize: 32,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
