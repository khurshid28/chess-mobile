
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

  LobbyState get state => _state;
  List<PuzzleModel> get puzzles => _puzzles;
  String? get errorMessage => _errorMessage;

  
  final int _randomPuzzleCount = 20;

  

  Future<void> loadPuzzles() async {
    
    if (_state == LobbyState.loaded && _puzzles.isNotEmpty) return;

    await _fetchPuzzles();
  }

  Future<void> refreshPuzzles() async {
    _state = LobbyState.loading;
    notifyListeners();
    await _fetchPuzzles();
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
    _errorMessage = null;

    
    List<Future<PuzzleModel?>> futures = [];

    
    futures.add(_fetchSafely(_puzzleService.getDailyPuzzle, "daily"));

    
    for (int i = 0; i < _randomPuzzleCount; i++) {
      futures.add(_fetchSafely(_puzzleService.getRandomPuzzle, "random"));
    }

    
    final results = await Future.wait(futures);
    
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
      _errorMessage = "Could not load any puzzles. Please check your connection.";
    } else {
      _state = LobbyState.loaded;
    }

    notifyListeners();
  }
}
