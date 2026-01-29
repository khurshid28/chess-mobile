import 'dart:async';
import 'package:chess_park/models/game_model.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:flutter/material.dart';


class LivePlayer {
  final String id;
  final String name;
  final int elo;
  final String? countryCode;
  final String gameId;

  LivePlayer({required this.id, required this.name, required this.elo, this.countryCode, required this.gameId});
}

class LiveGamesProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _liveGamesSubscription;

  List<LivePlayer> _topPlayers = [];
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;

  List<LivePlayer> get topPlayers => _topPlayers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LiveGamesProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    _subscribeToLiveGames();
  }

  void _subscribeToLiveGames() {
    _isLoading = true;
    _error = null;

    _liveGamesSubscription = _firestoreService.streamLiveHighEloGames(limit: 15).listen(
      (games) {

        _processLiveGames(games);
        _isLoading = false;
        if (!_isDisposed) notifyListeners();
      },
      onError: (e) {
        debugPrint("Error streaming live games: $e");
        _error = "Failed to load live games.";
        _isLoading = false;
        if (!_isDisposed) notifyListeners();
      },
    );
  }


  void _processLiveGames(List<GameModel> games) {
    final Map<String, LivePlayer> playerMap = {};

    for (var game in games) {
      _addPlayerToMap(playerMap, game.playerWhiteId, game.playerWhiteName, game.playerWhiteElo, game.playerWhiteCountryCode, game.id);
      _addPlayerToMap(playerMap, game.playerBlackId, game.playerBlackName, game.playerBlackElo, game.playerBlackCountryCode, game.id);
    }

    final List<LivePlayer> allPlayers = playerMap.values.toList();

    allPlayers.sort((a, b) => b.elo.compareTo(a.elo));

    _topPlayers = allPlayers.take(5).toList();
  }

  void _addPlayerToMap(Map<String, LivePlayer> map, String? id, String? name, int? elo, String? country, String gameId) {
    if (id != null && name != null && elo != null) {

      if (!map.containsKey(id)) {
        map[id] = LivePlayer(id: id, name: name, elo: elo, countryCode: country, gameId: gameId);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _liveGamesSubscription?.cancel();
    super.dispose();
  }
}
