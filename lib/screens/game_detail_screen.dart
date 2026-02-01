import 'package:flutter/material.dart';
import 'package:dartchess/dartchess.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chess/widgets/board.dart';
import '../chess/board_settings.dart';

class GameDetailScreen extends StatefulWidget {
  final GameModel game;
  final String currentUserId;

  const GameDetailScreen({
    Key? key,
    required this.game,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  Position _position = Chess.initial;
  List<String> _moveHistory = [];
  int _currentMoveIndex = -1;

  @override
  void initState() {
    super.initState();
    _parseMoves();
  }

  void _parseMoves() {
    if (widget.game.pgn.isEmpty) {
      return;
    }

    // Parse moves from FEN changes
    // For now, just use empty history - this is a display-only screen
    _moveHistory = [];
    
    // Start at the end position
    _currentMoveIndex = _moveHistory.length - 1;
    _updateBoardToMove(_currentMoveIndex);
  }

  void _updateBoardToMove(int moveIndex) {
    _position = Chess.initial;
    
    if (moveIndex >= 0) {
      for (int i = 0; i <= moveIndex; i++) {
        final move = Move.parse(_moveHistory[i]);
        if (move != null) {
          _position = _position.playUnchecked(move);
        }
      }
    }
    
    setState(() {
      _currentMoveIndex = moveIndex;
    });
  }

  void _firstMove() {
    _updateBoardToMove(-1);
  }

  void _previousMove() {
    if (_currentMoveIndex > -1) {
      _updateBoardToMove(_currentMoveIndex - 1);
    }
  }

  void _nextMove() {
    if (_currentMoveIndex < _moveHistory.length - 1) {
      _updateBoardToMove(_currentMoveIndex + 1);
    }
  }

  void _lastMove() {
    _updateBoardToMove(_moveHistory.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final isUserWhite = widget.game.playerWhiteId == widget.currentUserId;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Game Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Players info
                  _buildPlayersCard(),
                  const SizedBox(height: 16),
                  
                  // Chess board
                  _buildChessBoard(isUserWhite),
                  const SizedBox(height: 16),
                  
                  // Move navigation
                  if (_moveHistory.isNotEmpty) _buildMoveNavigation(),
                  const SizedBox(height: 16),
                  
                  // Move history
                  _buildMoveHistoryCard(),
                  const SizedBox(height: 16),
                  
                  // Game info
                  _buildGameInfoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersCard() {
    final isUserWhite = widget.game.playerWhiteId == widget.currentUserId;

    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Black player (top)
            _buildPlayerRow(
              name: widget.game.playerBlackName ?? 'Black',
              elo: widget.game.playerBlackElo,
              image: widget.game.playerBlackImage,
              isWinner: widget.game.winner == 'black',
              color: 'black',
              isCurrentUser: !isUserWhite,
            ),
            const SizedBox(height: 12),
            
            // Result
            _buildResultDisplay(),
            const SizedBox(height: 12),
            
            // White player (bottom)
            _buildPlayerRow(
              name: widget.game.playerWhiteName ?? 'White',
              elo: widget.game.playerWhiteElo,
              image: widget.game.playerWhiteImage,
              isWinner: widget.game.winner == 'white',
              color: 'white',
              isCurrentUser: isUserWhite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow({
    required String name,
    required int? elo,
    required String? image,
    required bool isWinner,
    required String color,
    required bool isCurrentUser,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white24,
          backgroundImage: image != null ? CachedNetworkImageProvider(image) : null,
          child: image == null
              ? const Icon(Icons.person_outline, color: AppTheme.kColorTextSecondary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.kColorTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (isCurrentUser)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.kColorAccent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          color: AppTheme.kColorAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                'ELO: ${elo ?? "..."}',
                style: const TextStyle(
                  color: AppTheme.kColorTextSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (isWinner)
          const Icon(
            Icons.emoji_events,
            color: AppTheme.kColorWin,
            size: 28,
          ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    String resultText;
    Color resultColor;
    IconData resultIcon;

    if (widget.game.winner == 'draw') {
      resultText = 'DRAW';
      resultColor = AppTheme.kColorTextSecondary;
      resultIcon = Icons.handshake;
    } else {
      final isUserWhite = widget.game.playerWhiteId == widget.currentUserId;
      final userWon = (widget.game.winner == 'white' && isUserWhite) ||
          (widget.game.winner == 'black' && !isUserWhite);
      
      if (userWon) {
        resultText = 'YOU WON';
        resultColor = AppTheme.kColorWin;
        resultIcon = Icons.emoji_events;
      } else {
        resultText = 'YOU LOST';
        resultColor = AppTheme.kColorLoss;
        resultIcon = Icons.close;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resultColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(resultIcon, color: resultColor, size: 20),
          const SizedBox(width: 8),
          Text(
            resultText,
            style: TextStyle(
              color: resultColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard(bool isUserWhite) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            color: Colors.white.withOpacity(0.1),
            child: Center(
              child: Text(
                'Game completed\nFinal position: ${widget.game.fen}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.kColorTextSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoveNavigation() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _currentMoveIndex > -1 ? _firstMove : null,
              icon: const Icon(Icons.first_page),
              color: AppTheme.kColorAccent,
            ),
            IconButton(
              onPressed: _currentMoveIndex > -1 ? _previousMove : null,
              icon: const Icon(Icons.chevron_left),
              color: AppTheme.kColorAccent,
            ),
            Text(
              _currentMoveIndex < 0 
                  ? 'Start' 
                  : 'Move ${_currentMoveIndex + 1} / ${_moveHistory.length}',
              style: const TextStyle(
                color: AppTheme.kColorTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _currentMoveIndex < _moveHistory.length - 1 ? _nextMove : null,
              icon: const Icon(Icons.chevron_right),
              color: AppTheme.kColorAccent,
            ),
            IconButton(
              onPressed: _currentMoveIndex < _moveHistory.length - 1 ? _lastMove : null,
              icon: const Icon(Icons.last_page),
              color: AppTheme.kColorAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveHistoryCard() {
    if (_moveHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Move History',
              style: TextStyle(
                color: AppTheme.kColorTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    (_moveHistory.length / 2).ceil(),
                    (index) {
                      final moveNumber = index + 1;
                      final whiteMove = _moveHistory[index * 2];
                      final blackMove = index * 2 + 1 < _moveHistory.length
                          ? _moveHistory[index * 2 + 1]
                          : null;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$moveNumber. $whiteMove${blackMove != null ? " $blackMove" : ""}',
                          style: const TextStyle(
                            color: AppTheme.kColorTextPrimary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfoCard() {
    final isTournament = widget.game.tournamentId != null;
    
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Information',
              style: TextStyle(
                color: AppTheme.kColorTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (isTournament) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.3), Colors.orange.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tournament Match',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildInfoRow('Type', isTournament ? 'Tournament' : (widget.game.isRanked ? 'Ranked' : 'Casual')),
            _buildInfoRow('Result', _getOutcomeText()),
            _buildInfoRow('Time Control', _formatTimeControl()),
            _buildInfoRow('Total Moves', '${_moveHistory.length}'),
            if (widget.game.completedAt != null)
              _buildInfoRow(
                'Completed',
                _formatDate(widget.game.completedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.kColorTextSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.kColorTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getOutcomeText() {
    if (widget.game.winner == 'draw') {
      return widget.game.outcome ?? 'Draw';
    } else if (widget.game.winner == 'white') {
      return 'White wins - ${widget.game.outcome ?? "Checkmate"}';
    } else if (widget.game.winner == 'black') {
      return 'Black wins - ${widget.game.outcome ?? "Checkmate"}';
    }
    return 'Unknown';
  }

  String _formatTimeControl() {
    final minutes = widget.game.initialTime ~/ 60;
    return '$minutes + 0';
  }

  String _formatDate(dynamic timestamp) {
    final date = timestamp is DateTime 
        ? timestamp 
        : (timestamp as Timestamp).toDate();
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}
