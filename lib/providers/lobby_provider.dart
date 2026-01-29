
import 'dart:async';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/services/game_repository.dart';
import 'package:flutter/foundation.dart';

enum MatchmakingState { idle, searching, matched, error }

class LobbyProvider with ChangeNotifier {
  final GameRepository _gameRepository;
  final FirestoreService _firestoreService;
  final String? _userId;

  LobbyProvider({required GameRepository gameRepository, required FirestoreService firestoreService, String? userId})
    : _gameRepository = gameRepository,
      _firestoreService = firestoreService,
      _userId = userId;

  MatchmakingState _matchmakingState = MatchmakingState.idle;
  String? _matchedGameId;
  String? _errorMessage;

  StreamSubscription? _queueSubscription;
  int? _currentTimeControl;
  bool _isCancelling = false;
  DateTime? _listenStartTime;
  MatchmakingState get matchmakingState => _matchmakingState;
  String? get matchedGameId => _matchedGameId;
  String? get errorMessage => _errorMessage;
  int? get currentTimeControl => _currentTimeControl;
  String? get userId => _userId;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;


  Future<void> startMatchmaking(int timeControl) async {
    if (_isDisposed) return;

    final userId = _userId;
    if (userId == null) {
      _setState(MatchmakingState.error, error: "User not authenticated.");
      return;
    }
    if (_matchmakingState == MatchmakingState.searching) {
      if (_currentTimeControl == timeControl) return;
      await cancelMatchmaking();
      if (_matchmakingState != MatchmakingState.idle) {

        debugPrint("Cannot start new search. Current state: $_matchmakingState.");
        return;
      }
    }
    _setState(MatchmakingState.searching);
    _currentTimeControl = timeControl;
    _isCancelling = false;

    try {
      final result = await _gameRepository.enqueueForMatchmaking(timeControl);

      if (_isDisposed) return;



      final bool wasCancelledLocally = _isCancelling || _matchmakingState != MatchmakingState.searching || _currentTimeControl != timeControl;

      if (result.status == 'matched' && result.gameId != null) {

        if (wasCancelledLocally) {
          debugPrint("Locally cancelled search but backend returned 'matched'. Proceeding to game.");
        }
        _firestoreService.deleteMatchmakingQueueEntry(userId).catchError((e) {
           debugPrint("Warning: Failed to delete matchmaking queue entry after immediate match/reconnect: $e");
        });

        _setState(MatchmakingState.matched, gameId: result.gameId);
        return;
      }
      if (wasCancelledLocally) {
        if (result.status == 'waiting') {

           debugPrint("Locally cancelled search after backend returned 'waiting'. Dequeueing now.");
           _gameRepository.dequeueFromMatchmaking().catchError((e) {
             debugPrint("Failed to dequeue after cancellation during enqueue: $e");
           });
        }

        if (_matchmakingState == MatchmakingState.searching) {
          _setState(MatchmakingState.idle);
        }
        return;
      }
      if (result.status == 'waiting') {
        _listenToQueue(userId);
      } else {
        _setState(MatchmakingState.error, error: "Unexpected matchmaking status: ${result.status}");
      }
    } catch (e) {
      if (_isDisposed) return;


      if ((_matchmakingState == MatchmakingState.searching && _currentTimeControl == timeControl) && !_isCancelling) {
        _setState(MatchmakingState.error, error: e.toString());
      }
    }
  }
  void _listenToQueue(String userId) {
    if (_isDisposed) return;

    _cancelQueueSubscription();
    _listenStartTime = DateTime.now();

    final int? activeSearchTimeControl = _currentTimeControl;
    _queueSubscription = _firestoreService.getMatchmakingQueueStream(userId).listen((snapshot) {
      if (_isDisposed) return;


      if (snapshot.exists && snapshot.data() != null) {

        final data = snapshot.data() as Map<String, dynamic>;
        final gameId = data['matchedGameId'];

        if (gameId != null) {

          _cancelQueueSubscription();


          if (_matchmakingState != MatchmakingState.matched) {
             if (_isCancelling || _matchmakingState != MatchmakingState.searching) {
               debugPrint("Match found during cancellation or unexpected state. Accepting match.");
             }

             if (_currentTimeControl == null || _currentTimeControl == activeSearchTimeControl) {
                _setState(MatchmakingState.matched, gameId: gameId);
             } else {
                debugPrint("Match found for stale time control. Ignoring.");
             }
          }
          _firestoreService.deleteMatchmakingQueueEntry(userId).catchError((e) {
            debugPrint("Warning: Failed to delete matchmaking queue entry after match found via stream: $e");
          });
          return;
        }
      }
      if (_matchmakingState != MatchmakingState.searching || _currentTimeControl != activeSearchTimeControl || _isCancelling) {

        return;
      }


      if (!snapshot.exists) {


        if (_listenStartTime != null && DateTime.now().difference(_listenStartTime!).inSeconds < 2) {
          debugPrint("Queue entry not found immediately after starting listener. Waiting for synchronization.");
          return;
        }


        if (_matchmakingState == MatchmakingState.searching && _currentTimeControl == activeSearchTimeControl) {
          _setState(MatchmakingState.error, error: "Search cancelled unexpectedly. Please try again.");
        }
        _cancelQueueSubscription();
      }
    }, onError: (e) {

      if (_isDisposed) return;
      debugPrint("Error listening to matchmaking queue: $e");

      if (_matchmakingState == MatchmakingState.searching && _currentTimeControl == activeSearchTimeControl && !_isCancelling) {
        _setState(MatchmakingState.error, error: "Error monitoring queue.");
      }
      _cancelQueueSubscription();
    });
  }


  Future<void> cancelMatchmaking() async {

    if (_matchmakingState != MatchmakingState.searching) {
      if (_matchmakingState == MatchmakingState.error && _errorMessage != null && _errorMessage!.contains("Failed to cancel")) {

      } else {
        return;
      }
    }


    _isCancelling = true;
    final int? activeTimeControl = _currentTimeControl;


    _cancelQueueSubscription();

    try {
      await _gameRepository.dequeueFromMatchmaking();

      if (_isDisposed) return;


      if (_isCancelling) {
         _setState(MatchmakingState.idle);
      }


    } catch (e) {
      debugPrint("Error cancelling matchmaking on backend: $e");

      if (_isDisposed) return;


      if (_isCancelling) {

        _currentTimeControl = activeTimeControl;
        _setState(MatchmakingState.error, error: "Failed to cancel search. You might still be in the queue. Please try again.");
      }
    } finally {
       if (!_isDisposed) {
         _isCancelling = false;
       }
    }
  }

  void _setState(MatchmakingState state, {String? gameId, String? error}) {
    if (_isDisposed) return;
    _matchmakingState = state;

    if (gameId != null) {
      _matchedGameId = gameId;
    } else if (state != MatchmakingState.matched) {

      if (state != MatchmakingState.error) {
         _matchedGameId = null;
      }
    }

    if (state == MatchmakingState.idle) {
      _currentTimeControl = null;
    }


    if (state != MatchmakingState.searching) {
      _isCancelling = false;
    }

    _errorMessage = error;
    notifyListeners();
  }

  void _cancelQueueSubscription() {
    _queueSubscription?.cancel();
    _queueSubscription = null;
  }

  @override
  void dispose() {
    if (!_isDisposed) {

        if (_matchmakingState == MatchmakingState.searching) {
          debugPrint("LobbyProvider disposed while searching. Attempting to cancel on backend.");

          _gameRepository.dequeueFromMatchmaking().catchError((e) {
             debugPrint("Failed to dequeue during dispose: $e");
           });
        }

        _isDisposed = true;
        _cancelQueueSubscription();
        super.dispose();
    }
  }

  void acknowledgeMatch() {
    if (_matchmakingState == MatchmakingState.matched || _matchmakingState == MatchmakingState.error) {
      _setState(MatchmakingState.idle);
    }
  }
}
