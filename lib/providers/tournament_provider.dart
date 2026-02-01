import 'package:flutter/foundation.dart';
import '../models/tournament_model.dart';
import '../models/tournament_participant_model.dart';
import '../models/tournament_match_model.dart';
import '../services/tournament_service.dart';

class TournamentProvider with ChangeNotifier {
  final TournamentService _tournamentService = TournamentService();

  List<TournamentModel> _upcomingTournaments = [];
  List<TournamentModel> _activeTournaments = [];
  TournamentModel? _currentTournament;
  List<TournamentParticipantModel> _participants = [];
  List<TournamentRoundModel> _bracket = [];
  TournamentCategory? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TournamentModel> get upcomingTournaments => _upcomingTournaments;
  List<TournamentModel> get activeTournaments => _activeTournaments;
  TournamentModel? get currentTournament => _currentTournament;
  List<TournamentParticipantModel> get participants => _participants;
  List<TournamentRoundModel> get bracket => _bracket;
  TournamentCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set selected category filter
  void setSelectedCategory(TournamentCategory? category) {
    _selectedCategory = category;
    notifyListeners();
    loadUpcomingTournaments();
  }

  // Load upcoming tournaments
  void loadUpcomingTournaments() {
    _tournamentService
        .getUpcomingTournaments(category: _selectedCategory)
        .listen((tournaments) {
      _upcomingTournaments = tournaments;
      notifyListeners();
    });
  }

  // Load active tournaments
  void loadActiveTournaments() {
    _tournamentService
        .getActiveTournaments(category: _selectedCategory)
        .listen((tournaments) {
      _activeTournaments = tournaments;
      notifyListeners();
    });
  }

  // Load tournament details
  void loadTournament(String tournamentId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load tournament
      _tournamentService.getTournament(tournamentId).listen((tournament) {
        _currentTournament = tournament;
        _isLoading = false;
        notifyListeners();
      });

      // Load participants
      _tournamentService
          .getTournamentParticipants(tournamentId)
          .listen((participants) {
        _participants = participants;
        notifyListeners();
      });

      // Load bracket
      _tournamentService.getTournamentBracket(tournamentId).listen((bracket) {
        _bracket = bracket;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join tournament
  Future<bool> joinTournament(String userId, String tournamentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if can join
      final canJoinResult =
          await _tournamentService.canJoinTournament(userId, tournamentId);

      if (!canJoinResult['canJoin']) {
        _error = canJoinResult['reason'];
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Join tournament
      final success =
          await _tournamentService.joinTournament(userId, tournamentId);

      _isLoading = false;
      if (success) {
        _error = null;
        // Reload tournament data
        loadTournament(tournamentId);
      } else {
        _error = 'Failed to join tournament';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user is in tournament
  Future<bool> isUserInTournament(String userId, String tournamentId) async {
    return await _tournamentService.isUserInTournament(userId, tournamentId);
  }

  // Get tournament category by ELO
  TournamentCategory getCategoryByElo(int elo) {
    return _tournamentService.getCategoryByElo(elo);
  }

  // Get tournaments for a specific category
  List<TournamentModel> getUpcomingTournamentsByCategory(
    TournamentCategory category,
  ) {
    return _upcomingTournaments
        .where((t) => t.category == category)
        .toList();
  }

  // Get user's eligible tournaments based on ELO
  List<TournamentModel> getEligibleTournaments(int userElo) {
    return _upcomingTournaments.where((t) {
      return userElo >= t.minElo && userElo <= t.maxElo;
    }).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose streams when provider is disposed
  @override
  void dispose() {
    super.dispose();
  }
}
