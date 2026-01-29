import 'dart:async';
import 'package:chess_park/chess/models.dart' show ValidMoves;
import 'package:chess_park/models/game_model.dart';
import 'package:chess_park/providers/connectivity_provider.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/services/game_repository.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:dartchess/dartchess.dart';

enum GameEventType {
  gameOver,
  rematchAccepted,
  opponentDisconnected,
  opponentReconnected,
  moveError,
  actionError,
}

class GameEvent {
  final GameEventType type;
  final String? message;

  GameEvent(this.type, {this.message});
}

class GameProvider with ChangeNotifier {
  final String? currentUserId;
  final FirestoreService _firestoreService;
  final GameRepository _gameRepository;

  final ConnectivityProvider _connectivityProvider;

  GameProvider({
    required this.currentUserId,
    required GameRepository gameRepository,
    required ConnectivityProvider connectivityProvider,
    FirestoreService? firestoreService,
  })  : _gameRepository = gameRepository,
        _connectivityProvider = connectivityProvider,
        _firestoreService = firestoreService ?? FirestoreService() {

    _connectivityProvider.addListener(_onConnectivityChange);
  }

  StreamSubscription? _gameSubscription;
  final StreamController<GameEvent> _eventController =
      StreamController.broadcast();
  Stream<GameEvent> get eventStream => _eventController.stream;
  GameModel? _gameModel;
  Chess _authoritativeChess = Chess.initial;
  Chess _optimisticChess = Chess.initial;
  NormalMove? _localPromotionMove;
  NormalMove? _currentPremove;
  bool _isDisposed = false;
  bool _isMovePending = false;
  bool _isGameOverHandled = false;
  bool _isClaimPending = false;
  bool _isRematchPending = false;
  bool _isAppInForeground = true;
  GameModel? get gameModel => _gameModel;
  Chess get chess => _optimisticChess;
  NormalMove? get localPromotionMove => _localPromotionMove;
  bool get isClaimPending => _isClaimPending;
  bool get isRematchPending => _isRematchPending;
  bool get isMovePending => _isMovePending;
  NormalMove? get currentPremove => _currentPremove;

  void _onConnectivityChange() {
    if (_isDisposed) return;

    _updateCompositeStatus();
  }
  void setAppForegroundState(bool isInForeground) {
    if (_isDisposed) return;
    if (_isAppInForeground != isInForeground) {
      _isAppInForeground = isInForeground;
      _updateCompositeStatus();
    }
  }
  void _updateCompositeStatus() {
    final bool isDisconnected = !_isAppInForeground || !_connectivityProvider.isOnline;
    updatePlayerStatus(isDisconnected ? 'disconnected' : 'online');
  }
  bool get isParticipant {
    final gameModel = _gameModel;
    final userId = currentUserId;

    if (userId == null || gameModel == null) {
      return false;
    }
    return userId == gameModel.playerWhiteId || userId == gameModel.playerBlackId;
  }
  bool get isGameOver {
    final chessGameOver = _optimisticChess.isGameOver;
    final serverStatusCompleted = _gameModel?.status == GameStatus.completed;


    return chessGameOver || serverStatusCompleted;
  }
  ValidMoves get validMoves {
    final gameModel = _gameModel;
    if (!isParticipant || gameModel == null) {
      return IMap();
    }

    if (isGameOver) {
      return IMap();
    }

    if (_currentPremove != null) {
      return IMap();
    }


    if (gameModel.pendingPromotion != null) {
      return IMap();
    }
    if (_localPromotionMove != null) {
      return IMap();
    }

    return makeLegalMoves(_optimisticChess, includeAlternateCastlingMoves: true);
  }

  void setPremove(NormalMove? move) {
    final gameModel = _gameModel;
    final userId = currentUserId;
    if (_isDisposed || !isParticipant || gameModel == null || userId == null || isGameOver) return;
    final isMyTurn = (_optimisticChess.turn == Side.white &&
            userId == gameModel.playerWhiteId) ||
        (_optimisticChess.turn == Side.black &&
            userId == gameModel.playerBlackId);

    if (isMyTurn && move != null) {
      if (_currentPremove != null) {
        _currentPremove = null;
        notifyListeners();
      }
      return;
    }
    if (_currentPremove != move) {
      _currentPremove = move;
      notifyListeners();
    }
  }
  void listenToGame(String gameId) {
    _updateCompositeStatus();

    _gameSubscription =
        _firestoreService.getGameStream(gameId).listen((snapshot) async {
      if (_isDisposed) return;

      if (!snapshot.exists) {
        return;
      }
      final GameModel? oldGameModel = _gameModel;
      final GameModel newGameModel = GameModel.fromSnapshot(snapshot);
      _gameModel = newGameModel;

      try {

        final setup = Setup.parseFen(newGameModel.fen);
        _authoritativeChess = Chess.fromSetup(setup);
      } catch (e) {

        debugPrint(
            "CRITICAL ERROR: Invalid FEN or Setup received from server: ${newGameModel.fen}. Error: $e");
        _eventController.add(GameEvent(GameEventType.moveError,
            message: "Game synchronization error (Invalid FEN)."));
        return;
      }
      _reconcileState();

      if (!isGameOver) {
         _attemptPremoveApplication();
      }
      _reconcileState();
      _handleStateChanges(oldGameModel, newGameModel);
      notifyListeners();
    });
  }
  bool _isAuthoritativePromotion(NormalMove move) {
    final role = _authoritativeChess.board.roleAt(move.from);
    if (role == null) return false;

    return role == Role.pawn &&
        (move.to.rank == Rank.first || move.to.rank == Rank.eighth);
  }
  void _attemptPremoveApplication() {
    final premove = _currentPremove;
    final game = _gameModel;
    final userId = currentUserId;

    if (premove == null ||
        _isMovePending ||
        game == null ||
        userId == null ||
        !isParticipant ||
        isGameOver) {
      return;
    }

    final isMyTurnNow = (_authoritativeChess.turn == Side.white &&
            userId == game.playerWhiteId) ||
        (_authoritativeChess.turn == Side.black &&
            userId == game.playerBlackId);

    if (isMyTurnNow) {
      _currentPremove = null;
      NormalMove moveForValidation = premove;
      if (_isAuthoritativePromotion(premove) && premove.promotion == null) {

          moveForValidation = premove.withPromotion(Role.queen);
      }
      final normalizedPremove =
          _authoritativeChess.normalizeMove(moveForValidation);

      if (normalizedPremove is NormalMove) {
        makeMove(normalizedPremove);
      } else {

        debugPrint("Premove ${premove.uci} normalization resulted in unexpected type. Discarding.");
        if (!_isDisposed) notifyListeners();
      }
    }
  }

  void _handleStateChanges(GameModel? oldModel, GameModel newModel) {
    if (isGameOver) {
      _currentPremove = null;

      if (_isClaimPending) {
        _isClaimPending = false;
      }
    }

    if (isGameOver && !_isGameOverHandled) {
      _isGameOverHandled = true;
      _isRematchPending = false;
      _eventController.add(GameEvent(GameEventType.gameOver));
      _updateCompositeStatus();
    }
    if (newModel.nextGameId != null && oldModel?.nextGameId == null) {
      _eventController.add(GameEvent(GameEventType.rematchAccepted));
    }

    final userId = currentUserId;
    if (!isParticipant || userId == null) return;

    final isWhite = userId == newModel.playerWhiteId;
    final oldOpponentStatus =
        isWhite ? oldModel?.playerBlackStatus : oldModel?.playerWhiteStatus;
    final newOpponentStatus =
        isWhite ? newModel.playerBlackStatus : newModel.playerWhiteStatus;

    if (oldOpponentStatus != newOpponentStatus && !isGameOver) {
      if (newOpponentStatus == 'disconnected') {
        _eventController.add(GameEvent(GameEventType.opponentDisconnected));
      } else if (newOpponentStatus == 'online' &&
          oldOpponentStatus == 'disconnected') {
        _eventController.add(GameEvent(GameEventType.opponentReconnected));
      }
    }

    final pending = newModel.pendingPromotion;
    if (pending != null && oldModel?.pendingPromotion == null) {
      final isMyPromotion = (pending.color == 'w' &&
              userId == newModel.playerWhiteId) ||
          (pending.color == 'b' && userId == newModel.playerBlackId);

      if (isMyPromotion) {
        final fromSquare = Square.parse(pending.from);
        final toSquare = Square.parse(pending.to);

        if (fromSquare == null || toSquare == null) {
          debugPrint(
              "CRITICAL ERROR: Failed to parse squares from pending promotion data: ${pending.from}, ${pending.to}");
          _optimisticChess = _authoritativeChess;
          _isMovePending = false;
          _eventController.add(GameEvent(GameEventType.moveError,
              message: "Synchronization error occurred (Promotion)."));
          return;
        }
        _localPromotionMove = NormalMove(
          from: fromSquare,
          to: toSquare,
        );
        _isMovePending = false;
      }
    }
  }

  void _reconcileState() {
    if (_localPromotionMove != null) {
      if (_optimisticChess.fen != _authoritativeChess.fen) {
        _optimisticChess = _authoritativeChess;
      }
      return;
    }

    if (!_isMovePending) {
      _optimisticChess = _authoritativeChess;
    } else {
      if (_optimisticChess.fen == _authoritativeChess.fen) {
        _isMovePending = false;
      } else if (_gameModel?.pendingPromotion != null) {

      } else {
        debugPrint(
            "Reconciliation: State diverged. Resetting to server state.");
        _optimisticChess = _authoritativeChess;
        _isMovePending = false;
      }
    }
  }

  @visibleForTesting
  void setGameModelForTest(GameModel model) {
    _gameModel = model;
  }

  bool _isPromotionPawnMove(NormalMove move) {
    final role = _optimisticChess.board.roleAt(move.from);
    if (role == null) return false;

    return role == Role.pawn &&
        (move.to.rank == Rank.first || move.to.rank == Rank.eighth);
  }
  String _moveToStandardUci(NormalMove move) {
    String uci = move.uci;
    final role = _optimisticChess.board.roleAt(move.from);

    if (role == Role.king) {
      final int fromFileIndex = move.from.file.value;
      final int toFileIndex = move.to.file.value;

      bool isCastling = (fromFileIndex - toFileIndex).abs() > 1 ||
          (_optimisticChess.board.pieceAt(move.to)?.color ==
                  _optimisticChess.turn &&
              _optimisticChess.board.roleAt(move.to) == Role.rook);

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

  Future<void> makeMove(NormalMove move) async {
    final gameModel = _gameModel;
    final userId = currentUserId;
    if (gameModel == null || isGameOver || _isMovePending || !isParticipant || userId == null) return;

    if (gameModel.status == GameStatus.waiting ||
        gameModel.playerBlackId == null) {
      _eventController.add(GameEvent(GameEventType.moveError,
          message: "Waiting for opponent to join."));
      return;
    }

    final isMyTurn = (_optimisticChess.turn == Side.white &&
            userId == gameModel.playerWhiteId) ||
        (_optimisticChess.turn == Side.black &&
            userId == gameModel.playerBlackId);

    if (!isMyTurn) return;

    if (_currentPremove != null) {
      _currentPremove = null;
    }

    final Chess previousOptimisticState = _optimisticChess;
    final normalizedMove = _optimisticChess.normalizeMove(move);
    if (normalizedMove is! NormalMove) {
      _rollbackMove(previousOptimisticState, "Invalid move attempt (unexpected move type).");
      return;
    }
    final String standardUci = _moveToStandardUci(normalizedMove);
    try {
      final isPromotion = _isPromotionPawnMove(normalizedMove);
      final promotionPieceProvided = normalizedMove.promotion != null;
      if (isPromotion && !promotionPieceProvided) {
        _isMovePending = true;
        notifyListeners();
        await _gameRepository.sendMove(gameModel.id, standardUci);
      } else {
        final newChessState = _optimisticChess.play(normalizedMove);

        if (newChessState is Chess) {
          _optimisticChess = newChessState;
        } else {
          throw Exception("Game state resulted in an unsupported variant.");
        }

        _isMovePending = true;
        notifyListeners();

        await _gameRepository.sendMove(gameModel.id, standardUci);
      }
    } catch (e) {



       debugPrint('STATE MISMATCH: App tried move from its FEN "${previousOptimisticState.fen}". The server, which holds the true state, rejected it.');

  debugPrint("Move failed (local validation or server rejection): $e");
  _rollbackMove(previousOptimisticState, "Invalid or illegal move.");
    }
  }

  Future<void> selectPromotion(Role? role) async {
    final localPromoMove = _localPromotionMove;
    final gameModel = _gameModel;

    if (localPromoMove == null || !isParticipant || gameModel == null) return;

    final move = localPromoMove;

    if (role == null) {
      return;
    }

    _localPromotionMove = null;
    final Chess previousStateForRollback = _authoritativeChess;

    try {
      final completeMove = move.withPromotion(role);

      _optimisticChess = _authoritativeChess;
      final newChessState = _optimisticChess.play(completeMove);

      if (newChessState is Chess) {
        _optimisticChess = newChessState;
      } else {
        throw Exception("Promotion resulted in an unsupported variant.");
      }

      _isMovePending = true;
      notifyListeners();

      await _gameRepository.finalizePromotion(gameModel.id, role.letter);
    } catch (e) {
      debugPrint("Promotion finalization failed: $e");
      _rollbackMove(
          previousStateForRollback, "Promotion failed: ${e.toString()}");
    }
  }

  void _rollbackMove(Chess previousState, String errorMessage) {
    _optimisticChess = previousState;
    _isMovePending = false;
    _localPromotionMove = null;

    if (_optimisticChess.fen != _authoritativeChess.fen) {
      _optimisticChess = _authoritativeChess;
    }

   /* final cleanMessage = errorMessage.replaceFirst('Exception: ', '');
    _eventController .add(GameEvent(GameEventType.moveError, message: cleanMessage));*/
    notifyListeners();
  }

  Future<void> claimTimeoutVictory() async {

    final gameModel = _gameModel;
    final userId = currentUserId;

    if (gameModel == null || isGameOver || _isClaimPending || !isParticipant || userId == null) return;
    final isMyTurn = (_optimisticChess.turn == Side.white &&
            userId == gameModel.playerWhiteId) ||
        (_optimisticChess.turn == Side.black &&
            userId == gameModel.playerBlackId);

    if (isMyTurn) {
      debugPrint("Cannot claim timeout on my own turn.");
      return;
    }

    debugPrint("Attempting to claim victory by timeout...");
    _isClaimPending = true;
    notifyListeners();

    try {

      await _gameRepository.claimTimeout(gameModel.id);
    } catch (e) {
      debugPrint("Timeout claim rejected: $e");
      _eventController.add(GameEvent(GameEventType.actionError,
          message:
              "Timeout claim rejected: ${e.toString().replaceFirst('Exception: ', '')}"));

      _isClaimPending = false;
      notifyListeners();
    }
  }

  Future<void> updatePlayerStatus(String status) async {
    final gameModel = _gameModel;
    if (gameModel == null || isGameOver || !isParticipant || currentUserId == null) return;

    String? currentStatus;
    if (currentUserId == gameModel.playerWhiteId) {
      currentStatus = gameModel.playerWhiteStatus;
    } else if (currentUserId == gameModel.playerBlackId) {
      currentStatus = gameModel.playerBlackStatus;
    }
    if (currentStatus == status) return;
    _sendAction('update_status', value: status).catchError((e) {
      debugPrint("Status update failed, ignoring: $e");
    });
  }

  Future<void> claimAbandonmentVictory() async {
    final gameModel = _gameModel;
    if (gameModel == null || isGameOver || !isParticipant) return;
    debugPrint("Attempting to claim victory by abandonment...");
    try {
      await _gameRepository.claimAbandonment(gameModel.id);
    } catch (e) {
      debugPrint("Abandonment claim rejected: $e");

      _eventController.add(GameEvent(GameEventType.actionError,
          message:
              "Abandonment claim rejected: ${e.toString().replaceFirst('Exception: ', '')}"));
    }
  }
  Future<void> _sendAction(String action, {String? value}) async {

    final gameModel = _gameModel;
    if (gameModel == null) return;
    try {

      await _gameRepository.handleGameAction(gameModel.id, action,
          value: value);
    } catch (e) {
      debugPrint("Failed to perform action $action: $e");
      _eventController.add(GameEvent(GameEventType.actionError,
          message:
              "Action failed: ${e.toString().replaceFirst('Exception: ', '')}"));
      rethrow;
    }
  }

  Future<void> offerDraw() async {
    if (isGameOver || !isParticipant) return;
    await _sendAction('offer_draw');
  }

  Future<void> acceptDraw() async {

    if (isGameOver || !isParticipant) return;
    await _sendAction('accept_draw');
  }

  Future<void> declineDraw() async {
    if (isGameOver || !isParticipant) return;
    await _sendAction('decline_draw');
  }

  Future<void> resign() async {
    if (!isParticipant) return;
    await _sendAction('resign');
  }

  Future<void> offerRematch() async {
    if (!isGameOver || !isParticipant || _isRematchPending) return;
    _isRematchPending = true;
    notifyListeners();

    try {
      await _sendAction('offer_rematch');
    } catch (e) {
    // handled by the UI
    } finally {

       _isRematchPending = false;
       if (!_isDisposed) notifyListeners();
    }
  }
  Future<void> acceptRematch() async {
    final gameModel = _gameModel;
    final userId = currentUserId;
    if (gameModel == null || !isGameOver || !isParticipant || userId == null || _isRematchPending) return;
    if (gameModel.rematchOfferFrom == null ||
        gameModel.rematchOfferFrom == userId) {
      throw Exception("No valid offer to accept.");
    }
    _isRematchPending = true;
    notifyListeners();

    try {
      await _gameRepository.acceptRematch(gameModel.id);
    } catch (e) {
      debugPrint("Failed to accept rematch: $e");

      _isRematchPending = false;
      if (!_isDisposed) notifyListeners();
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectivityProvider.removeListener(_onConnectivityChange);
    _gameSubscription?.cancel();
    _eventController.close();
    super.dispose();
  }
}