import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dartchess/dartchess.dart';
import '../models/bot_personality_model.dart';
import '../services/bot_engine.dart';

class BotGameProvider extends ChangeNotifier {
  final BotEngine _botEngine = BotEngine();
  final Random _random = Random();

  Position _position = Chess.initial;
  BotPersonality? _currentBot;
  BotDifficulty? _currentDifficulty;
  Side _userSide = Side.white;
  bool _isThinking = false;
  String? _gameResult;
  String? _gameResultReason;
  List<String> _moveHistory = [];
  int _timeControlSeconds = 0;
  bool _isGameOver = false;

  // Getters
  Position get position => _position;
  BotPersonality? get currentBot => _currentBot;
  BotDifficulty? get currentDifficulty => _currentDifficulty;
  Side get userSide => _userSide;
  bool get isThinking => _isThinking;
  String? get gameResult => _gameResult;
  String? get gameResultReason => _gameResultReason;
  List<String> get moveHistory => _moveHistory;
  bool get isGameOver => _isGameOver;
  bool get isUserTurn => _position.turn == _userSide;

  String get botDisplayName {
    if (_currentBot == null || _currentDifficulty == null) return 'Computer';

    final levelNames = {
      'easy': 'Oson',
      'medium': 'O\'rtacha',
      'hard': 'Qiyin',
      'maximum': 'Maksimal',
    };

    return '${_currentBot!.nameUz} (${levelNames[_currentDifficulty!.level]})';
  }

  int get botDisplayRating {
    if (_currentDifficulty == null) return 1200;
    return _currentDifficulty!.averageRating;
  }

  String get fen => _position.fen;

  /// Create a new bot game
  Future<void> createBotGame({
    required BotPersonality bot,
    required String difficulty,
    int timeControl = 0,
    Side? userSide,
  }) async {
    _currentBot = bot;
    _currentDifficulty = bot.getDifficulty(difficulty);
    _userSide = userSide ?? (_random.nextBool() ? Side.white : Side.black);
    _timeControlSeconds = timeControl;
    _position = Chess.initial;
    _moveHistory = [];
    _gameResult = null;
    _gameResultReason = null;
    _isGameOver = false;
    notifyListeners();

    // If bot plays white, make the first move
    if (_userSide == Side.black) {
      await _makeBotMove();
    }
  }

  /// Make a user move
  Future<bool> makeUserMove(Move move) async {
    if (_isGameOver) return false;
    if (_position.turn != _userSide) return false;
    
    // Check if move is legal - legalMoves is IMap<Square, SquareSet>
    final legalMoves = _position.legalMoves;
    bool moveExists = false;
    for (final entry in legalMoves.entries) {
      final from = Square(entry.key);
      for (final toInt in entry.value.squares) {
        final to = Square(toInt);
        if ('${from.name}${to.name}' == move.uci) {
          moveExists = true;
          break;
        }
      }
      if (moveExists) break;
    }
    
    if (!moveExists) return false;

    // Apply the move
    _position = _position.playUnchecked(move);
    _moveHistory.add(move.uci);
    notifyListeners();

    // Check game over
    if (_checkGameOver()) {
      return true;
    }

    // Bot's turn
    await _makeBotMove();
    return true;
  }

  /// Make a user move from UCI string
  Future<bool> makeUserMoveUci(String uci) async {
    try {
      final move = Move.parse(uci);
      if (move == null) return false;
      return await makeUserMove(move);
    } catch (e) {
      debugPrint('Invalid UCI move: $uci');
      return false;
    }
  }

  /// Make a bot move
  Future<void> _makeBotMove() async {
    if (_isGameOver) return;
    if (_position.turn == _userSide) return;

    _isThinking = true;
    notifyListeners();

    // Calculate thinking time based on difficulty
    final thinkTime = _calculateThinkTime();
    await Future.delayed(Duration(milliseconds: thinkTime));

    try {
      final botMove = await _botEngine.getBestMove(_position, _currentDifficulty!);
      
      if (botMove != null) {
        _position = _position.playUnchecked(botMove);
        _moveHistory.add(botMove.uci);
      }
    } catch (e) {
      debugPrint('Bot move error: $e');
    }

    _isThinking = false;
    notifyListeners();

    _checkGameOver();
  }

  /// Calculate bot thinking time (for realistic appearance)
  int _calculateThinkTime() {
    if (_currentDifficulty == null) return 500;

    // Base time increases with search depth
    final base = _currentDifficulty!.searchDepth * 250;
    
    // Add random variation
    final random = _random.nextInt(300);
    
    // Minimum 200ms, maximum 3000ms
    return (base + random).clamp(200, 3000);
  }

  /// Check if game is over
  bool _checkGameOver() {
    if (_position.isCheckmate) {
      _isGameOver = true;
      _gameResult = _position.turn == Side.white ? '0-1' : '1-0';
      _gameResultReason = 'Checkmate';
      notifyListeners();
      return true;
    }

    if (_position.isStalemate) {
      _isGameOver = true;
      _gameResult = '1/2-1/2';
      _gameResultReason = 'Stalemate';
      notifyListeners();
      return true;
    }

    // Check for other draw conditions (insufficient material, etc)
    if (position.isInsufficientMaterial) {
      _isGameOver = true;
      _gameResult = '1/2-1/2';
      _gameResultReason = 'Draw';
      notifyListeners();
      return true;
    }

    return false;
  }

  /// User resigns
  void resign() {
    if (_isGameOver) return;
    
    _isGameOver = true;
    _gameResult = _userSide == Side.white ? '0-1' : '1-0';
    _gameResultReason = 'Resignation';
    notifyListeners();
  }

  /// Offer/accept draw (bot auto-decides)
  void offerDraw() {
    if (_isGameOver) return;

    // Bot evaluates position and decides
    // Simple logic: accept if evaluation is close to 0
    final shouldAccept = _random.nextDouble() < 0.3; // 30% chance to accept
    
    if (shouldAccept) {
      _isGameOver = true;
      _gameResult = '1/2-1/2';
      _gameResultReason = 'Draw by agreement';
      notifyListeners();
    }
  }

  /// Start a new game with the same bot and difficulty
  Future<void> rematch() async {
    if (_currentBot == null || _currentDifficulty == null) return;
    
    await createBotGame(
      bot: _currentBot!,
      difficulty: _currentDifficulty!.level,
      timeControl: _timeControlSeconds,
      userSide: _userSide.opposite,
    );
  }

  /// Get PGN string of the game
  String getPgn() {
    final buffer = StringBuffer();
    buffer.writeln('[Event "Bot Game"]');
    buffer.writeln('[Site "Chess Mobile"]');
    buffer.writeln('[Date "${DateTime.now().toString().substring(0, 10)}"]');
    buffer.writeln('[White "${_userSide == Side.white ? 'Player' : botDisplayName}"]');
    buffer.writeln('[Black "${_userSide == Side.black ? 'Player' : botDisplayName}"]');
    buffer.writeln('[Result "$_gameResult"]');
    buffer.writeln();

    // Add moves
    for (int i = 0; i < _moveHistory.length; i++) {
      if (i % 2 == 0) {
        buffer.write('${i ~/ 2 + 1}. ');
      }
      buffer.write('${_moveHistory[i]} ');
    }
    
    if (_gameResult != null) {
      buffer.write(_gameResult);
    }

    return buffer.toString();
  }

  /// Reset the provider
  void reset() {
    _position = Chess.initial;
    _currentBot = null;
    _currentDifficulty = null;
    _userSide = Side.white;
    _isThinking = false;
    _gameResult = null;
    _gameResultReason = null;
    _moveHistory = [];
    _isGameOver = false;
    notifyListeners();
  }
}
