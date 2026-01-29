import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chess_park/models/puzzle_model.dart';

class PuzzleService {
    final String _baseUrl = 'https://lichess.org/api/puzzle';

  
  Future<PuzzleModel> getDailyPuzzle() async {
    return _fetchPuzzle('$_baseUrl/daily');
  }


  
  Future<PuzzleModel> getRandomPuzzle() async {
    return _fetchPuzzle('$_baseUrl/next');
  }

  
  Future<PuzzleModel> _fetchPuzzle(String url) async {
    try {
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        String responseBody = response.body;
        
         if (responseBody.contains('\n')) {
          responseBody = responseBody.split('\n').firstWhere((line) => line.isNotEmpty, orElse: () => '{}');
        }

        final data = json.decode(responseBody);
        return PuzzleModel.fromJson(data);
      } else {
        
        throw Exception('Failed to load puzzle (Status: ${response.statusCode})');
      }
    } catch (e) {
      
      throw Exception('Error fetching puzzle: $e');
    }
  }
}
