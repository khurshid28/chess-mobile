import 'dart:math';
import 'package:dartchess/dartchess.dart';
import '../models/bot_personality_model.dart';
import 'logger_service.dart';

class BotEngine {
  static const int _infinity = 100000;
  final Random _random = Random();

  // Piece values
  static final Map<Role, int> _pieceValues = {
    Role.pawn: 100,
    Role.knight: 320,
    Role.bishop: 330,
    Role.rook: 500,
    Role.queen: 900,
    Role.king: 20000,
  };

  // Piece-square tables for positional bonuses
  static const List<int> _pawnTable = [
    0, 0, 0, 0, 0, 0, 0, 0,
    50, 50, 50, 50, 50, 50, 50, 50,
    10, 10, 20, 30, 30, 20, 10, 10,
    5, 5, 10, 25, 25, 10, 5, 5,
    0, 0, 0, 20, 20, 0, 0, 0,
    5, -5, -10, 0, 0, -10, -5, 5,
    5, 10, 10, -20, -20, 10, 10, 5,
    0, 0, 0, 0, 0, 0, 0, 0
  ];

  static const List<int> _knightTable = [
    -50, -40, -30, -30, -30, -30, -40, -50,
    -40, -20, 0, 0, 0, 0, -20, -40,
    -30, 0, 10, 15, 15, 10, 0, -30,
    -30, 5, 15, 20, 20, 15, 5, -30,
    -30, 0, 15, 20, 20, 15, 0, -30,
    -30, 5, 10, 15, 15, 10, 5, -30,
    -40, -20, 0, 5, 5, 0, -20, -40,
    -50, -40, -30, -30, -30, -30, -40, -50,
  ];

  static const List<int> _bishopTable = [
    -20, -10, -10, -10, -10, -10, -10, -20,
    -10, 0, 0, 0, 0, 0, 0, -10,
    -10, 0, 5, 10, 10, 5, 0, -10,
    -10, 5, 5, 10, 10, 5, 5, -10,
    -10, 0, 10, 10, 10, 10, 0, -10,
    -10, 10, 10, 10, 10, 10, 10, -10,
    -10, 5, 0, 0, 0, 0, 5, -10,
    -20, -10, -10, -10, -10, -10, -10, -20,
  ];

  static const List<int> _rookTable = [
    0, 0, 0, 0, 0, 0, 0, 0,
    5, 10, 10, 10, 10, 10, 10, 5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    0, 0, 0, 5, 5, 0, 0, 0
  ];

  static const List<int> _queenTable = [
    -20, -10, -10, -5, -5, -10, -10, -20,
    -10, 0, 0, 0, 0, 0, 0, -10,
    -10, 0, 5, 5, 5, 5, 0, -10,
    -5, 0, 5, 5, 5, 5, 0, -5,
    0, 0, 5, 5, 5, 5, 0, -5,
    -10, 5, 5, 5, 5, 5, 0, -10,
    -10, 0, 5, 0, 0, 0, 0, -10,
    -20, -10, -10, -5, -5, -10, -10, -20
  ];

  static const List<int> _kingMiddleGameTable = [
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -20, -30, -30, -40, -40, -30, -30, -20,
    -10, -20, -20, -20, -20, -20, -20, -10,
    20, 20, 0, 0, 0, 0, 20, 20,
    20, 30, 10, 0, 0, 10, 30, 20
  ];

  // Common opening moves for quick first-move response
  static const List<String> _openingMoves = [
    'e2e4', 'd2d4', 'g1f3', 'c2c4', 'e2e3', 'd2d3', 'b1c3', 'g2g3',
  ];

  /// Get the best move for the bot
  Future<Move?> getBestMove(
    Position position,
    BotPersonality bot,
  ) async {
    print('🤖 Bot engine: searching for move. Depth: ${bot.searchDepth}');
    AppLogger().debug('🤖 Bot engine: searching for move. Depth: ${bot.searchDepth}, Error rate: ${bot.errorRate}');
    
    final legalMovesCount = position.legalMoves.length;
    print('📊 Legal moves available: $legalMovesCount');
    AppLogger().debug('📊 Legal moves available: $legalMovesCount');
    
    if (legalMovesCount == 0) {
      print('⚠️ No legal moves available!');
      AppLogger().warning('⚠️ No legal moves available!');
      return null;
    }
    
    // Use opening book for first move (much faster, no calculation needed)
    if (position.fen == Chess.initial.fen) {
      final openingMove = _openingMoves[_random.nextInt(_openingMoves.length)];
      final move = Move.parse(openingMove);
      if (move != null) {
        AppLogger().debug('📖 Using opening book move: $openingMove');
        return move;
      }
    }
    
    // Occasionally make a weaker move based on error rate (for realism)
    if (bot.errorRate > 0 &&
        _random.nextDouble() < bot.errorRate) {
      AppLogger().debug('🎲 Making weaker move (error rate triggered)');
      return _makeWeakerMove(position, bot.searchDepth - 1);
    }

    // Find the best move using minimax
    final bestMove = _searchBestMove(position, bot);
    
    if (bestMove != null) {
      AppLogger().debug('✅ Bot engine found move: ${bestMove.uci}');
    } else {
      AppLogger().error('❌ Bot engine returned null move!');
    }
    
    return bestMove;
  }

  /// Search for the best move using minimax algorithm
  Move? _searchBestMove(Position position, BotPersonality bot) {
    final legalMoves = position.legalMoves;
    print('🔍 _searchBestMove: legalMoves.length = ${legalMoves.length}');
    if (legalMoves.isEmpty) {
      print('⚠️ _searchBestMove: no legal moves');
      AppLogger().warning('⚠️ _searchBestMove: no legal moves');
      return null;
    }

    // Collect all legal moves first
    final allMoves = <Move>[];
    for (final entry in legalMoves.entries) {
      final from = Square(entry.key);
      for (final toInt in entry.value.squares) {
        final to = Square(toInt);
        final move = Move.parse('${from.name}${to.name}');
        if (move != null) {
          allMoves.add(move);
        }
      }
    }

    if (allMoves.isEmpty) {
      print('⚠️ No moves collected');
      return null;
    }

    // For speed: just use simple evaluation without deep search
    Move? bestMove;
    int bestScore = -_infinity;
    final isWhite = position.turn == Side.white;
    
    print('🔍 Evaluating ${allMoves.length} moves...');
    
    final stopwatch = Stopwatch()..start();
    const maxTimeMs = 500; // Maximum 500ms for search
    
    for (final move in allMoves) {
      // Timeout check
      if (stopwatch.elapsedMilliseconds > maxTimeMs) {
        print('⏰ Search timeout after ${stopwatch.elapsedMilliseconds}ms');
        break;
      }
      
      try {
        final newPos = position.playUnchecked(move);
        
        // Simple 1-ply evaluation for speed
        int score = _evaluatePosition(newPos, bot.usePieceSquareTables);
        
        // Flip score for black
        if (!isWhite) {
          score = -score;
        }
        
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      } catch (e) {
        continue;
      }
    }
    
    stopwatch.stop();

    // If no best move found, return random
    if (bestMove == null && allMoves.isNotEmpty) {
      bestMove = allMoves[_random.nextInt(allMoves.length)];
      print('🎲 Returning random move: ${bestMove.uci}');
    }

    print('📈 Evaluated in ${stopwatch.elapsedMilliseconds}ms. Best move: ${bestMove?.uci ?? "null"}, score: $bestScore');
    AppLogger().debug('📈 Evaluated in ${stopwatch.elapsedMilliseconds}ms. Best score: $bestScore');
    return bestMove;
  }

  /// Make a deliberately weaker move (for beginner bots)
  Move? _makeWeakerMove(Position position, int depth) {
    final legalMoves = position.legalMoves;
    if (legalMoves.isEmpty) return null;

    // Always make random move for weaker bots - faster and simpler
    final moves = <Move>[];
    for (final entry in legalMoves.entries) {
      final from = Square(entry.key);
      for (final toInt in entry.value.squares) {
        final to = Square(toInt);
        final move = Move.parse('${from.name}${to.name}');
        if (move != null) {
          moves.add(move);
        }
      }
    }
    
    if (moves.isEmpty) return null;
    return moves[_random.nextInt(moves.length)];
  }

  /// Minimax algorithm with alpha-beta pruning
  int _minimax(
    Position position,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    bool usePieceSquareTables,
  ) {
    if (depth == 0 || position.isGameOver) {
      return _evaluatePosition(position, usePieceSquareTables);
    }

    final legalMoves = position.legalMoves;
    if (legalMoves.isEmpty) {
      return _evaluatePosition(position, usePieceSquareTables);
    }

    if (isMaximizing) {
      int maxEval = -_infinity;
      for (final entry in legalMoves.entries) {
        final from = Square(entry.key);
        for (final toInt in entry.value.squares) {
          final to = Square(toInt);
          final move = Move.parse('${from.name}${to.name}')!;
          
          final newPos = position.playUnchecked(move);
          final eval = _minimax(
            newPos,
            depth - 1,
            alpha,
            beta,
            false,
            usePieceSquareTables,
          );
          maxEval = max(maxEval, eval);
          alpha = max(alpha, eval);
          if (beta <= alpha) break; // Beta cutoff
        }
      }
      return maxEval;
    } else {
      int minEval = _infinity;
      for (final entry in legalMoves.entries) {
        final from = Square(entry.key);
        for (final toInt in entry.value.squares) {
          final to = Square(toInt);
          final move = Move.parse('${from.name}${to.name}')!;
          
          final newPos = position.playUnchecked(move);
          final eval = _minimax(
            newPos,
            depth - 1,
            alpha,
            beta,
            true,
            usePieceSquareTables,
          );
          minEval = min(minEval, eval);
          beta = min(beta, eval);
          if (beta <= alpha) break; // Alpha cutoff
        }
      }
      return minEval;
    }
  }

  /// Evaluate the current position
  int _evaluatePosition(Position position, bool usePieceSquareTables) {
    if (position.isCheckmate) {
      return position.turn == Side.white ? -_infinity : _infinity;
    }

    if (position.isStalemate) {
      return 0;
    }

    int score = 0;

    // Evaluate all pieces
    for (int square = 0; square < 64; square++) {
      final piece = position.board.pieceAt(Square(square));
      if (piece == null) continue;

      final pieceValue = _pieceValues[piece.role] ?? 0;
      final positionBonus = usePieceSquareTables
          ? _getPieceSquareValue(piece, square)
          : 0;

      final totalValue = pieceValue + positionBonus;
      score += piece.color == Side.white ? totalValue : -totalValue;
    }

    return score;
  }

  /// Get positional bonus from piece-square tables
  int _getPieceSquareValue(Piece piece, int square) {
    // Mirror square for black pieces
    final adjustedSquare =
        piece.color == Side.white ? square : 63 - square;

    switch (piece.role) {
      case Role.pawn:
        return _pawnTable[adjustedSquare];
      case Role.knight:
        return _knightTable[adjustedSquare];
      case Role.bishop:
        return _bishopTable[adjustedSquare];
      case Role.rook:
        return _rookTable[adjustedSquare];
      case Role.queen:
        return _queenTable[adjustedSquare];
      case Role.king:
        return _kingMiddleGameTable[adjustedSquare];
    }
  }
}
