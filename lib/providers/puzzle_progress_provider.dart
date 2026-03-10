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
  bool _isLoadingMore = false;
  bool _hasMore = true;
  
  static const int initialPuzzleCount = 10; // Initial load
  static const int loadMoreCount = 5; // Load 5 more at a time
  static const int maxPuzzleCount = 50; // Maximum puzzles
  static const String _puzzlesCacheKey = 'cached_puzzles';
  static const String _solvedPuzzlesKey = 'solved_puzzle_ids';
  static const String _unlockedCountKey = 'unlocked_puzzle_count';
  static const String _lastCacheDateKey = 'puzzles_cache_date';
  
  // Keep for backward compatibility
  static const int totalPuzzleCount = initialPuzzleCount;
  
  PuzzleProgressProvider(this._puzzleService);
  
  List<PuzzleModel> get puzzles => _puzzles;
  Set<String> get solvedPuzzleIds => _solvedPuzzleIds;
  int get unlockedCount => _unlockedCount;
  PuzzleLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  int get loadingProgress => _loadingProgress;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore && _puzzles.length < maxPuzzleCount;
  
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
        _hasMore = _puzzles.length < maxPuzzleCount;
        if (_puzzles.length >= initialPuzzleCount) {
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
  Future<void> _fetchAndCachePuzzles(SharedPreferences prefs, {int count = initialPuzzleCount}) async {
    _puzzles = [];
    _loadingProgress = 0;
    _hasMore = true;
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
    while (_puzzles.length < count && attempts < count + 5) {
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
  
  /// Load more puzzles
  Future<void> loadMorePuzzles() async {
    if (_isLoadingMore || !hasMore) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      int loaded = 0;
      int attempts = 0;
      final targetCount = _puzzles.length + loadMoreCount;
      
      while (_puzzles.length < targetCount && attempts < loadMoreCount + 3) {
        attempts++;
        try {
          final puzzle = await _puzzleService.getRandomPuzzle();
          // Avoid duplicates
          if (!_puzzles.any((p) => p.id == puzzle.id)) {
            _puzzles.add(puzzle);
            loaded++;
            notifyListeners();
          }
        } catch (e) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      
      // If we couldn't load any new puzzles, we're out
      if (loaded == 0) {
        _hasMore = false;
      }
      
      // Update cache
      final prefs = await SharedPreferences.getInstance();
      final puzzlesJson = _encodePuzzles(_puzzles);
      await prefs.setString(_puzzlesCacheKey, puzzlesJson);
      
    } catch (e) {
      // Silent fail for load more
    }
    
    _isLoadingMore = false;
    notifyListeners();
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
