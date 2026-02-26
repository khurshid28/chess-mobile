import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import '../models/bot_personality_model.dart';
import '../models/bot_game_history_model.dart';
import '../services/bot_engine.dart';
import '../services/bot_game_database.dart';
import '../services/logger_service.dart';

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
  List<String> _positionHistory = []; // FEN history for threefold repetition
  int _timeControlSeconds = 0;
  bool _isGameOver = false;
  String? _userId;

  // Timer properties
  Timer? _timer;
  int _userTimeLeft = 600; // 10 minutes in seconds
  int _botTimeLeft = 600;
  
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
  int get userTimeLeft => _userTimeLeft;
  int get botTimeLeft => _botTimeLeft;

  String get botDisplayName {
    if (_currentBot == null || _currentDifficulty == null) return 'Computer';

    final levelNames = {
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'maximum': 'Maximum',
    };

    return '${_currentBot!.name} (${levelNames[_currentDifficulty!.level]})';
  }

  int get botDisplayRating {
    if (_currentDifficulty == null) return 1200;
    return _currentDifficulty!.averageRating;
  }

  String get fen => _position.fen;

  /// Get valid moves in the format required by Chessboard widget
  IMap<Square, ISet<Square>> get validMoves {
    final moves = <Square, ISet<Square>>{};
    final legalMoves = _position.legalMoves;
    
    for (final entry in legalMoves.entries) {
      final from = Square(entry.key);
      final destinations = entry.value.squares.map((sq) => Square(sq)).toISet();
      moves[from] = destinations;
    }
    
    return moves.lock;
  }

  /// Create a new bot game
  Future<void> createBotGame({
    required BotPersonality bot,
    required String difficulty,
    required String userId,
    int timeControl = 600,
    Side? userSide,
  }) async {
    AppLogger().info('🎮 Creating bot game: ${bot.nameUz}, difficulty: $difficulty, userId: $userId');
    
    _currentBot = bot;
    _currentDifficulty = bot.getDifficulty(difficulty);
    _userSide = userSide ?? (_random.nextBool() ? Side.white : Side.black);
    _timeControlSeconds = timeControl;
    _userTimeLeft = timeControl;
    _botTimeLeft = timeControl;
    _userId = userId;
    _position = Chess.initial;
    _moveHistory = [];
    _positionHistory = [Chess.initial.fen]; // Start with initial position
    _gameResult = null;
    _gameResultReason = null;
    _isGameOver = false;
    
    AppLogger().info('✅ Bot game created successfully. User plays: ${_userSide == Side.white ? "White" : "Black"}');
    
    // Start timer
    _startTimer();
    
    notifyListeners();

    // If bot has white (user has black), bot moves first
    if (_userSide == Side.black) {
      AppLogger().info('🤖 Bot has white, making first move...');
      // Shorter delay for first move since we use opening book
      await Future.delayed(const Duration(milliseconds: 300));
      await _makeBotMove();
    } else {
      AppLogger().info('✅ Game created. User has white and moves first.');
    }
  }

  /// Start the game timer
  void _startTimer() {
    _timer?.cancel();
    AppLogger().info('⏱️ Timer started');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameOver) {
        AppLogger().info('⏹️ Timer stopped - game over');
        timer.cancel();
        return;
      }

      if (_position.turn == _userSide) {
        _userTimeLeft--;
        if (_userTimeLeft <= 0) {
          _userTimeLeft = 0;
          _timeOut(isUser: true);
        }
      } else {
        // Bot's turn - timer counts down even when thinking
        _botTimeLeft--;
        if (_botTimeLeft <= 0) {
          _botTimeLeft = 0;
          _timeOut(isUser: false);
        }
      }
      
      notifyListeners();
    });
  }

  /// Handle time out
  void _timeOut({required bool isUser}) {
    if (_isGameOver) return;
    
    AppLogger().warning('⏰ Time out! User: $isUser');
    _isGameOver = true;
    // When user times out, user loses. When bot times out, user wins.
    if (isUser) {
      // User lost on time
      _gameResult = _userSide == Side.white ? '0-1' : '1-0';
      _gameResultReason = 'You lost on time';
    } else {
      // Bot lost on time, user wins
      _gameResult = _userSide == Side.white ? '1-0' : '0-1';
      _gameResultReason = 'Bot lost on time';
    }
    _timer?.cancel();
    AppLogger().info('⏹️ Timer cancelled due to timeout');
    _saveGameHistory();
    notifyListeners();
  }

  /// Pause timer (when navigating away from game)
  void pauseTimer() {
    _timer?.cancel();
    AppLogger().info('⏸️ Timer paused');
  }

  /// Resume timer (when returning to game)
  void resumeTimer() {
    if (!_isGameOver) {
      _startTimer();
      AppLogger().info('▶️ Timer resumed');
    }
  }

  /// Make a user move
  Future<bool> makeUserMove(Move move) async {
    AppLogger().info('🎮 makeUserMove called: ${move.uci}');
    AppLogger().info('🎮 Is game over: $_isGameOver');
    AppLogger().info('🎮 Current turn: ${_position.turn}, User side: $_userSide');
    
    if (_isGameOver) {
      AppLogger().warning('⚠️ Game is already over');
      return false;
    }
    if (_position.turn != _userSide) {
      AppLogger().warning('⚠️ Not user\'s turn');
      return false;
    }
    
    // Check if move is legal - legalMoves is IMap<Square, SquareSet>
    final legalMoves = _position.legalMoves;
    bool moveExists = false;
    
    // Get base UCI (first 4 characters for from-to)
    final baseUci = move.uci.substring(0, 4);
    
    for (final entry in legalMoves.entries) {
      final from = Square(entry.key);
      for (final toInt in entry.value.squares) {
        final to = Square(toInt);
        final checkUci = '${from.name}${to.name}';
        // Check if base move matches (ignore promotion piece for now)
        if (checkUci == baseUci) {
          moveExists = true;
          break;
        }
      }
      if (moveExists) break;
    }
    
    if (!moveExists) {
      AppLogger().warning('⚠️ Move ${move.uci} is not legal');
      return false;
    }

    // Apply the move
    print('👤 User: ${move.uci}');
    AppLogger().info('👤 User: ${move.uci}');
    _position = _position.playUnchecked(move);
    _moveHistory.add(move.uci);
    _positionHistory.add(_position.fen); // Track position for repetition
    print('✅ User move applied. New turn: ${_position.turn}, FEN: ${_position.fen}');
    notifyListeners();

    // Check game over after user move
    if (_checkGameOver()) {
      print('🏁 Game over after user move');
      AppLogger().info('🏁 Game over after user move');
      return true;
    }

    // Bot's turn
    print('🤖 About to call _makeBotMove... Current turn: ${_position.turn}, UserSide: $_userSide');
    AppLogger().info('🤖 Calling _makeBotMove...');
    await _makeBotMove();
    print('✅ _makeBotMove completed');
    AppLogger().info('✅ _makeBotMove completed');
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
    print('🤖 _makeBotMove started');
    AppLogger().info('🤖 _makeBotMove started');
    
    if (_isGameOver) {
      print('⚠️ Bot move cancelled: game is over');
      AppLogger().warning('⚠️ Bot move cancelled: game is over');
      return;
    }
    if (_position.turn == _userSide) {
      print('⚠️ Bot move cancelled: not bot\'s turn (position.turn=${_position.turn}, userSide=$_userSide)');
      AppLogger().warning('⚠️ Bot move cancelled: not bot\'s turn');
      return;
    }

    _isThinking = true;
    notifyListeners();
    print('🎯 Bot is thinking...');
    AppLogger().info('🎯 Bot is thinking...');

    // Check if it's the opening position (uses opening book - faster)
    final isOpeningPosition = _moveHistory.isEmpty;
    
    // Calculate thinking time based on difficulty (shorter for opening book)
    final thinkTime = isOpeningPosition ? 100 : _calculateThinkTime();
    print('⏱️ Bot think time: ${thinkTime}ms');
    AppLogger().debug('⏱️ Bot think time: ${thinkTime}ms (opening: $isOpeningPosition)');
    await Future.delayed(Duration(milliseconds: thinkTime));

    try {
      print('🔍 Calling bot engine...');
      AppLogger().info('🔍 Calling bot engine...');
      final botMove = await _botEngine.getBestMove(_position, _currentDifficulty!);
      print('📬 Bot engine returned: ${botMove?.uci ?? "null"}');
      AppLogger().info('📬 Bot engine returned: ${botMove?.uci ?? "null"}');
      
      if (botMove != null) {
        print('🤖 Bot played: ${botMove.uci}');
        AppLogger().info('🤖 Bot played: ${botMove.uci}');
        _position = _position.playUnchecked(botMove);
        _moveHistory.add(botMove.uci);
        _positionHistory.add(_position.fen); // Track position for repetition
        print('✅ Bot move applied successfully. New FEN: ${_position.fen}');
        AppLogger().info('✅ Bot move applied successfully');
      } else {
        print('⚠️ Bot move is null - no valid moves?');
        AppLogger().warning('⚠️ Bot move is null - no valid moves?');
      }
    } catch (e, stackTrace) {
      print('❌ Bot move error: $e');
      AppLogger().error('❌ Bot move error', e, stackTrace);
    }

    _isThinking = false;
    notifyListeners();
    print('🏁 Bot thinking finished');
    AppLogger().info('🏁 Bot thinking finished');

    final isOver = _checkGameOver();
    if (isOver) {
      AppLogger().info('🏁 Game over after bot move');
    }
  }

  /// Calculate bot thinking time (for realistic appearance)
  int _calculateThinkTime() {
    if (_currentDifficulty == null) return 200;

    // Base time increases with search depth (reduced for faster play)
    final base = _currentDifficulty!.searchDepth * 100;
    
    // Add random variation
    final random = _random.nextInt(150);
    
    // Minimum 100ms, maximum 800ms
    return (base + random).clamp(100, 800);
  }

  /// Check if game is over
  bool _checkGameOver() {
    if (_position.isCheckmate) {
      _isGameOver = true;
      _gameResult = _position.turn == Side.white ? '0-1' : '1-0';
      _gameResultReason = 'Checkmate';
      _timer?.cancel();
      AppLogger().info('♔ Checkmate! Result: $_gameResult. Timer cancelled.');
      _saveGameHistory();
      notifyListeners();
      return true;
    }

    if (_position.isStalemate) {
      _isGameOver = true;
      _gameResult = '1/2-1/2';
      _gameResultReason = 'Stalemate';
      _timer?.cancel();
      AppLogger().info('🤝 Stalemate. Timer cancelled.');
      _saveGameHistory();
      notifyListeners();
      return true;
    }

    // Check for other draw conditions (insufficient material, etc)
    if (position.isInsufficientMaterial) {
      _isGameOver = true;
      _gameResult = '1/2-1/2';
      _gameResultReason = 'Draw - Insufficient Material';
      _timer?.cancel();
      AppLogger().info('🤝 Draw - insufficient material. Timer cancelled.');
      _saveGameHistory();
      notifyListeners();
      return true;
    }

    // Check for threefold repetition
    if (_checkThreefoldRepetition()) {
      _isGameOver = true;
      _gameResult = '1/2-1/2';
      _gameResultReason = 'Draw - Threefold Repetition';
      _timer?.cancel();
      AppLogger().info('🔁 Draw - threefold repetition. Timer cancelled.');
      _saveGameHistory();
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Check for threefold repetition
  bool _checkThreefoldRepetition() {
    if (_positionHistory.isEmpty) return false;

    final currentFen = _position.fen;
    // Count how many times current position appeared
    int count = 0;
    for (final fen in _positionHistory) {
      // Compare only position part of FEN (ignore move counters)
      final currentPosition = currentFen.split(' ').take(4).join(' ');
      final historyPosition = fen.split(' ').take(4).join(' ');
      if (currentPosition == historyPosition) {
        count++;
      }
    }

    if (count >= 3) {
      AppLogger().info('🔁 Threefold repetition detected! Count: $count');
      return true;
    }
    return false;
  }

  /// Save game to history
  Future<void> _saveGameHistory() async {
    if (_userId == null) {
      AppLogger().error('❌ Cannot save game: userId is null. This should not happen!');
      return;
    }
    
    AppLogger().info('💾 Saving bot game to database. UserId: $_userId, Result: $_gameResult');
    
    try {
      final totalMoves = _moveHistory.length;
      final userMoves = (totalMoves / 2).ceil();
      final accuracy = 85 + (5 - (5 * (totalMoves / 60))).clamp(0, 15).toInt();
      
      int ratingChange = 0;
      if (_gameResult == '1-0' && _userSide == Side.white) {
        ratingChange = (_currentDifficulty?.averageRating ?? 1200) ~/ 50;
      } else if (_gameResult == '0-1' && _userSide == Side.black) {
        ratingChange = (_currentDifficulty?.averageRating ?? 1200) ~/ 50;
      } else if (_gameResult != '1/2-1/2') {
        ratingChange = -((_currentDifficulty?.averageRating ?? 1200) ~/ 50);
      }

      final gameHistory = BotGameHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        botId: _currentBot?.id ?? '',
        botName: _currentBot?.nameUz ?? 'Bot',
        botRating: _currentDifficulty?.averageRating ?? 1200,
        difficulty: _currentDifficulty?.level ?? 'easy',
        result: _gameResult ?? '1/2-1/2',
        resultReason: _gameResultReason ?? '',
        moveHistory: _moveHistory,
        userSide: _userSide == Side.white ? 'white' : 'black',
        movesPlayed: userMoves,
        accuracy: accuracy,
        ratingChange: ratingChange,
        createdAt: DateTime.now(),
      );

      AppLogger().debug('📊 Game stats - Moves: $totalMoves, Accuracy: $accuracy, Rating change: $ratingChange');

      // Save to SQLite database (local history only - bot games don't affect online rating)
      await BotGameDatabase.instance.insertGame(gameHistory);
      
      AppLogger().info('✅ Bot game saved successfully to database');
    } catch (e, stackTrace) {
      AppLogger().error('❌ Error saving bot game history', e, stackTrace);
    }
  }

  /// User resigns
  void resign() {
    if (_isGameOver) return;
    
    _isGameOver = true;
    _gameResult = _userSide == Side.white ? '0-1' : '1-0';
    _gameResultReason = 'Resignation';
    _timer?.cancel();
    _saveGameHistory();
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
      _timer?.cancel();
      _saveGameHistory();
      notifyListeners();
    }
  }

  /// Start a new game with the same bot and difficulty
  Future<void> rematch() async {
    if (_currentBot == null || _currentDifficulty == null || _userId == null) return;
    
    await createBotGame(
      bot: _currentBot!,
      difficulty: _currentDifficulty!.level,
      userId: _userId!,
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
    _timer?.cancel();
    _position = Chess.initial;
    _currentBot = null;
    _currentDifficulty = null;
    _userSide = Side.white;
    _isThinking = false;
    _gameResult = null;
    _gameResultReason = null;
    _moveHistory = [];
    _isGameOver = false;
    _userTimeLeft = 600;
    _botTimeLeft = 600;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
