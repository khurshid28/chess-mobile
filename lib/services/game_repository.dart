import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';


class MatchmakingResult {
  final String status;
  final String? gameId;

  MatchmakingResult({required this.status, this.gameId});

  factory MatchmakingResult.fromMap(Map<String, dynamic> map) {
    return MatchmakingResult(
      status: map['status'] ?? 'error',
      gameId: map['gameId'],
    );
  }
}

class GameRepository {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;


  Future<T> _callFunction<T>(String name, Map<String, dynamic> data) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(name);
      final result = await callable.call(data);
      return result.data as T;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function Error ($name): ${e.code} - ${e.message}');

      throw Exception(e.message ?? 'An unknown server error occurred.');
    } catch (e) {
      debugPrint('General Error calling $name: $e');
      throw Exception('Failed to execute action. Please check your connection.');
    }
  }




  Future<MatchmakingResult> enqueueForMatchmaking(int timeControl) async {
    final result = await _callFunction<Map<String, dynamic>>('enqueueForMatchmaking', {
      'timeControl': timeControl,
    });
    return MatchmakingResult.fromMap(result);
  }


  Future<void> dequeueFromMatchmaking() async {
    await _callFunction<Map<String, dynamic>>('dequeueFromMatchmaking', {});
  }





  Future<void> sendMove(String gameId, String uci) async {
    await _callFunction<Map<String, dynamic>>('makeMove', {
      'gameId': gameId,
      'moveUci': uci,
    });
  }

  Future<void> finalizePromotion(String gameId, String promotionPiece) async {
    await _callFunction<Map<String, dynamic>>('makeMove', {
      'gameId': gameId,
      'promotion': promotionPiece,
    });
  }

  Future<void> claimTimeout(String gameId) async {
    await _callFunction<Map<String, dynamic>>('claimTimeout', {
      'gameId': gameId,
    });
  }

  Future<void> claimAbandonment(String gameId) async {
    await _callFunction<Map<String, dynamic>>('claimAbandonment', {
      'gameId': gameId,
    });
  }

  Future<void> handleGameAction(String gameId, String action, {String? value}) async {
   await _callFunction('handleGameAction', {
      'gameId': gameId,
      'action': action,
      'value': value,
    });
  }


  Future<String> acceptRematch(String gameId) async {
    final result = await _callFunction<Map<String, dynamic>>('acceptRematch', {
      'gameId': gameId,
    });
    return result['newGameId'];
  }
}
