import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chess_park/models/puzzle_model.dart';

class PuzzleService {
    final String _baseUrl = 'https://lichess.org/api/puzzle';
    DateTime? _lastRequestTime;
    static const _requestDelay = Duration(milliseconds: 700);

  
  Future<PuzzleModel> getDailyPuzzle() async {
    return _fetchPuzzle('$_baseUrl/daily');
  }


  
  Future<PuzzleModel> getRandomPuzzle() async {
    // Rate limiting - wait between requests
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _requestDelay) {
        await Future.delayed(_requestDelay - elapsed);
      }
    }
    
    final result = await _fetchPuzzle('$_baseUrl/next');
    _lastRequestTime = DateTime.now();
    return result;
  }

  
  Future<PuzzleModel> _fetchPuzzle(String url) async {
    try {
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        String responseBody = response.body;
        
         if (responseBody.contains('\n')) {
          responseBody = responseBody.split('\n').firstWhere((line) => line.isNotEmpty, orElse: () => '{}');
        }

        final data = json.decode(responseBody);
        return PuzzleModel.fromJson(data);
      } else if (response.statusCode == 429) {
        // Rate limited - throw specific error
        throw Exception('Juda ko\'p so\'rov. Iltimos bir oz kuting.');
      } else {
        
        throw Exception('Puzzle yuklashda xatolik (Status: ${response.statusCode})');
      }
    } catch (e) {
      
      throw Exception('Puzzle yuklashda xatolik: $e');
    }
  }
}
