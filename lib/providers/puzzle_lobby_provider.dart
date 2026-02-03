
import 'package:flutter/material.dart';
import 'package:chess_park/models/puzzle_model.dart';
import 'package:chess_park/services/puzzle_service.dart';

enum LobbyState { loading, error, loaded }

class PuzzleLobbyProvider with ChangeNotifier {
  final PuzzleService _puzzleService;
  PuzzleLobbyProvider(this._puzzleService);

  LobbyState _state = LobbyState.loading;
  List<PuzzleModel> _puzzles = [];
  String? _errorMessage;
  bool _isDisposed = false;
  DateTime? _lastFetchTime;
  static const _fetchCooldown = Duration(seconds: 10);

  LobbyState get state => _state;
  List<PuzzleModel> get puzzles => _puzzles;
  String? get errorMessage => _errorMessage;

  Future<void> loadPuzzles() async {
    if (_isDisposed) return;
    
    if (_state == LobbyState.loaded && _puzzles.isNotEmpty) return;

    // Check cooldown to prevent rate limiting
    if (_lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _fetchCooldown) {
      debugPrint('Puzzle fetch cooldown active, skipping...');
      return;
    }

    await _fetchPuzzles();
  }

  Future<void> refreshPuzzles() async {
    if (_isDisposed) return;
    
    // Check cooldown
    if (_lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _fetchCooldown) {
      debugPrint('Please wait before refreshing puzzles again');
      return;
    }
    
    _state = LobbyState.loading;
    _safeNotifyListeners();
    await _fetchPuzzles();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  
  
  Future<PuzzleModel?> _fetchSafely(Future<PuzzleModel> Function() fetchFunc, String type) async {
    try {
      return await fetchFunc();
    } catch (e) {
      
      debugPrint("Failed to load $type puzzle: $e");
      return null;
    }
  }

  Future<void> _fetchPuzzles() async {
    if (_isDisposed) return;
    
    _errorMessage = null;
    _lastFetchTime = DateTime.now();

    List<PuzzleModel?> results = [];

    // Load daily puzzle first
    final dailyPuzzle = await _fetchSafely(_puzzleService.getDailyPuzzle, "daily");
    results.add(dailyPuzzle);
    
    if (_isDisposed) return;

    // Load random puzzles one by one with delays to avoid rate limiting
    final puzzleCount = 3; // Load only 3 random puzzles
    for (int i = 0; i < puzzleCount; i++) {
      if (_isDisposed) return;
      
      // Wait before each request
      await Future.delayed(const Duration(milliseconds: 800));
      
      final puzzle = await _fetchSafely(_puzzleService.getRandomPuzzle, "random");
      if (puzzle != null) {
        results.add(puzzle);
      }
    }
    
    if (_isDisposed) return;
    
    var loadedPuzzles = results.whereType<PuzzleModel>().toList();

    
    if (loadedPuzzles.isNotEmpty) {
      
      final String? dailyId = results.first?.id;

      
      
      final Map<String, PuzzleModel> uniquePuzzlesMap = {for (var p in loadedPuzzles) p.id: p};
      loadedPuzzles = uniquePuzzlesMap.values.toList();

      
      if (dailyId != null && uniquePuzzlesMap.containsKey(dailyId)) {
        loadedPuzzles.sort((a, b) {
          if (a.id == dailyId) return -1;
          if (b.id == dailyId) return 1;
          
          return b.rating.compareTo(a.rating);
        });
      } else {
         
        loadedPuzzles.sort((a, b) => b.rating.compareTo(a.rating));
      }
    }

    _puzzles = loadedPuzzles;

    if (_puzzles.isEmpty) {
      _state = LobbyState.error;
      _errorMessage = "Puzzlelarni yuklashda xatolik. Internetni tekshiring.";
    } else {
      _state = LobbyState.loaded;
    }

    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
