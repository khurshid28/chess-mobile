import 'package:chess_park/models/puzzle_model.dart';

import 'package:flutter/material.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:chess_park/chess/models.dart' show ValidMoves;

enum PuzzleState { loading, error, inProgress, failed, solved }

class PuzzleProvider with ChangeNotifier {
  
  final PuzzleModel _puzzle;

  
  PuzzleProvider(this._puzzle) {
    _initializePuzzle();
  }

  

  Position _chess = Chess.initial;
  PuzzleState _state = PuzzleState.loading; 
  String? _errorMessage;

  int _solutionIndex = 0;
  Side _playerSide = Side.white;
  bool _isDisposed = false;

  
  PuzzleModel get puzzle => _puzzle;
  Position get chess => _chess;
  PuzzleState get state => _state;
  Side get playerSide => _playerSide;
  String? get errorMessage => _errorMessage;

  bool get isPlayerTurn => _chess.turn == _playerSide;

  ValidMoves get validMoves {
    if (_state != PuzzleState.inProgress || !isPlayerTurn) {
      return IMap();
    }
    return makeLegalMoves(_chess, includeAlternateCastlingMoves: true);
  }

  

  void _initializePuzzle() {
    _solutionIndex = 0;
    
    _state = PuzzleState.loading;
    _errorMessage = null;
    
    if (_solutionIndex != 0 && !_isDisposed) notifyListeners(); 


    
    PgnGame pgn;
    try {
      
      pgn = PgnGame.parsePgn(_puzzle.initialPgn, initHeaders: PgnGame.emptyHeaders);
    } catch (e) {
      _handleError("Failed to initialize puzzle (PGN Syntax Error).", e);
      return;
    }

    
    Position position;
    try {
      position = PgnGame.startingPosition(pgn.headers);
    } catch (e) {
      _handleError("Failed to initialize puzzle (Invalid Setup/FEN in PGN).", e);
      return;
    }

    if (position.rule != Rule.chess) {
       _handleError("Failed to initialize puzzle (Unsupported variant: ${position.rule.name}).");
       return;
    }
    _chess = position;


    
    for (final PgnNodeData nodeData in pgn.moves.mainline()) {
      final Move? move = _chess.parseSan(nodeData.san);

      if (move == null) {
        _handleError("Failed to initialize puzzle (Invalid SAN in PGN: ${nodeData.san}). FEN: ${_chess.fen}");
        return;
      }
      _chess = _chess.playUnchecked(move);
    }

    
    _playerSide = _chess.turn;

    _state = PuzzleState.inProgress;
    if (!_isDisposed) notifyListeners();
  }

  
  

    
  String _moveToUci(NormalMove move) {
    String uci = move.uci;
    final role = _chess.board.roleAt(move.from);

    
    if (role == Role.king) {
      final int fromFileIndex = move.from.file.value;
      final int toFileIndex = move.to.file.value;

      
      bool isCastling = (fromFileIndex - toFileIndex).abs() > 1 ||
          (_chess.board.pieceAt(move.to)?.color == _chess.turn && _chess.board.roleAt(move.to) == Role.rook);

      if (isCastling) {
        File destFile = toFileIndex > fromFileIndex ? File.g : File.c;
        uci = move.from.name + Square.fromCoords(destFile, move.from.rank).name;
      }
    }

    if (move.promotion != null) {
      return uci.toLowerCase();
    }

    return uci;
  }


  void makeMove(NormalMove move) {
    if (_state != PuzzleState.inProgress || !isPlayerTurn) return;

    final String userUci = _moveToUci(move);

    if (_solutionIndex >= _puzzle.solution.length) return;
    final String expectedUci = _puzzle.solution[_solutionIndex];

    if (userUci == expectedUci) {
      final NormalMove normalizedMove = _chess.normalizeMove(move) as NormalMove;

      _applyMove(normalizedMove);
      _solutionIndex++;

      if (_solutionIndex >= _puzzle.solution.length) {
        _state = PuzzleState.solved;
        if (!_isDisposed) notifyListeners();
      } else {
        _playCounterMove();
      }
    } else {
      _state = PuzzleState.failed;
      if (!_isDisposed) notifyListeners();
    }
  }

  void _applyMove(Move move) {
    _chess = _chess.playUnchecked(move);
    if (!_isDisposed) notifyListeners();
  }

  void _playCounterMove() {
    if (_solutionIndex >= _puzzle.solution.length) return;

    final String counterUci = _puzzle.solution[_solutionIndex];

    Future.delayed(const Duration(milliseconds: 600), () {
      if (_isDisposed) return;
      if (_state != PuzzleState.inProgress) return;

      final Move? move = Move.parse(counterUci);

      if (move != null && _chess.isLegal(move)) {
        Move moveToApply = move;
        if (move is NormalMove) {
            moveToApply = _chess.normalizeMove(move);
        }

        _applyMove(moveToApply);
        _solutionIndex++;
      } else {
        _handleError("CRITICAL ERROR: Invalid or illegal counter move UCI: $counterUci. FEN: ${_chess.fen}");
      }
    });
  }

  void _handleError(String message, [Object? detail]) {
    debugPrint("PuzzleProvider Error: $message ${detail ?? ''}");
    _errorMessage = message;
    _state = PuzzleState.error;
    if (!_isDisposed) notifyListeners();
  }

  void retryPuzzle() {
    if (_state == PuzzleState.failed) {
      _initializePuzzle();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}