import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle_model.dart';
import '../services/puzzle_service.dart';

enum PuzzleLoadState { initial, loading, loaded, error }

class PuzzleProgressProvider extends ChangeNotifier {
  final PuzzleService _puzzleService;
  
  List<PuzzleModel> _puzzles = [];
  Set<String> _solvedPuzzleIds = {};
  int _unlockedCount = 3; // First 3 puzzles are unlocked
  PuzzleLoadState _state = PuzzleLoadState.initial;
  String? _errorMessage;
  int _loadingProgress = 0; // Current loading progress
  
  static const int totalPuzzleCount = 15;
  static const String _puzzlesCacheKey = 'cached_puzzles';
  static const String _solvedPuzzlesKey = 'solved_puzzle_ids';
  static const String _unlockedCountKey = 'unlocked_puzzle_count';
  static const String _lastCacheDateKey = 'puzzles_cache_date';
  
  PuzzleProgressProvider(this._puzzleService);
  
  List<PuzzleModel> get puzzles => _puzzles;
  Set<String> get solvedPuzzleIds => _solvedPuzzleIds;
  int get unlockedCount => _unlockedCount;
  PuzzleLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  int get loadingProgress => _loadingProgress;
  
  bool isPuzzleUnlocked(int index) => index < _unlockedCount;
  bool isPuzzleSolved(int index) {
    if (index >= _puzzles.length) return false;
    return _solvedPuzzleIds.contains(_puzzles[index].id);
  }
  
  /// Initialize and load puzzles
  Future<void> initialize() async {
    if (_state == PuzzleLoadState.loading) return;
    
    _state = PuzzleLoadState.loading;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load solved puzzles and unlock count
      await _loadProgress(prefs);
      
      // Check if we have cached puzzles and if they're still valid (same day)
      final cachedPuzzlesJson = prefs.getString(_puzzlesCacheKey);
      final lastCacheDate = prefs.getString(_lastCacheDateKey);
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      if (cachedPuzzlesJson != null && lastCacheDate == today) {
        // Use cached puzzles
        _puzzles = _decodePuzzles(cachedPuzzlesJson);
        if (_puzzles.length >= totalPuzzleCount) {
          _state = PuzzleLoadState.loaded;
          notifyListeners();
          return;
        }
      }
      
      // Need to fetch new puzzles
      await _fetchAndCachePuzzles(prefs);
      
      _state = PuzzleLoadState.loaded;
    } catch (e) {
      _state = PuzzleLoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
  
  /// Fetch puzzles from Lichess API and cache them
  Future<void> _fetchAndCachePuzzles(SharedPreferences prefs) async {
    _puzzles = [];
    _loadingProgress = 0;
    notifyListeners();
    
    // First get daily puzzle
    try {
      final daily = await _puzzleService.getDailyPuzzle();
      _puzzles.add(daily);
      _loadingProgress = _puzzles.length;
      notifyListeners();
    } catch (e) {
      // Continue even if daily fails
    }
    
    // Fetch remaining puzzles
    int attempts = 0;
    while (_puzzles.length < totalPuzzleCount && attempts < totalPuzzleCount + 5) {
      attempts++;
      try {
        final puzzle = await _puzzleService.getRandomPuzzle();
        // Avoid duplicates
        if (!_puzzles.any((p) => p.id == puzzle.id)) {
          _puzzles.add(puzzle);
          _loadingProgress = _puzzles.length;
          notifyListeners();
        }
      } catch (e) {
        // If we have at least some puzzles, stop
        if (_puzzles.length >= 5) {
          break;
        }
        // Wait a bit and retry
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    
    // Cache puzzles
    if (_puzzles.isNotEmpty) {
      final puzzlesJson = _encodePuzzles(_puzzles);
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString(_puzzlesCacheKey, puzzlesJson);
      await prefs.setString(_lastCacheDateKey, today);
    }
  }
  
  /// Load progress from SharedPreferences
  Future<void> _loadProgress(SharedPreferences prefs) async {
    final solvedJson = prefs.getStringList(_solvedPuzzlesKey);
    if (solvedJson != null) {
      _solvedPuzzleIds = solvedJson.toSet();
    }
    
    _unlockedCount = prefs.getInt(_unlockedCountKey) ?? 3;
    // Ensure at least 3 are unlocked
    if (_unlockedCount < 3) _unlockedCount = 3;
  }
  
  /// Mark a puzzle as solved and unlock next
  Future<void> markPuzzleSolved(String puzzleId, int puzzleIndex) async {
    if (_solvedPuzzleIds.contains(puzzleId)) return;
    
    _solvedPuzzleIds.add(puzzleId);
    
    // Unlock next puzzle if this was the last unlocked one
    if (puzzleIndex >= _unlockedCount - 1 && _unlockedCount < _puzzles.length) {
      _unlockedCount++;
    }
    
    // Save progress
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_solvedPuzzlesKey, _solvedPuzzleIds.toList());
    await prefs.setInt(_unlockedCountKey, _unlockedCount);
    
    notifyListeners();
  }
  
  /// Refresh puzzles - fetch new set
  Future<void> refreshPuzzles() async {
    if (_state == PuzzleLoadState.loading) return;
    
    _state = PuzzleLoadState.loading;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear cache to force refresh
      await prefs.remove(_puzzlesCacheKey);
      await prefs.remove(_lastCacheDateKey);
      
      await _fetchAndCachePuzzles(prefs);
      _state = PuzzleLoadState.loaded;
    } catch (e) {
      _state = PuzzleLoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
  
  /// Reset progress (for testing or user request)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _solvedPuzzleIds.clear();
    _unlockedCount = 3;
    await prefs.remove(_solvedPuzzlesKey);
    await prefs.setInt(_unlockedCountKey, 3);
    notifyListeners();
  }
  
  String _encodePuzzles(List<PuzzleModel> puzzles) {
    final list = puzzles.map((p) => p.toJson()).toList();
    return jsonEncode(list);
  }
  
  List<PuzzleModel> _decodePuzzles(String json) {
    final list = jsonDecode(json) as List;
    return list.map((p) => PuzzleModel.fromJson(p)).toList();
  }
}
