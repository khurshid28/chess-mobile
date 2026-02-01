import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/tournament_model.dart';
import '../models/badge_model.dart';
import '../services/leaderboard_service.dart';

enum LeaderboardPeriod { daily, monthly }

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();

  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.monthly;
  TournamentCategory _selectedCategory = TournamentCategory.a;
  List<LeaderboardEntryModel> _entries = [];
  List<BadgeModel> _userBadges = [];
  Map<String, dynamic>? _userStats;
  bool _isLoading = false;
  String? _error;
  int? _userRank;

  // Getters
  LeaderboardPeriod get selectedPeriod => _selectedPeriod;
  TournamentCategory get selectedCategory => _selectedCategory;
  List<LeaderboardEntryModel> get entries => _entries;
  List<BadgeModel> get userBadges => _userBadges;
  Map<String, dynamic>? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get userRank => _userRank;

  // Get top 3 entries
  List<LeaderboardEntryModel> get topThree {
    return _entries.take(3).toList();
  }

  // Get remaining entries (4th onwards)
  List<LeaderboardEntryModel> get remainingEntries {
    return _entries.skip(3).toList();
  }

  // Set selected period
  void setSelectedPeriod(LeaderboardPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
    loadLeaderboard();
  }

  // Set selected category
  void setSelectedCategory(TournamentCategory category) {
    _selectedCategory = category;
    notifyListeners();
    loadLeaderboard();
  }

  // Load leaderboard
  void loadLeaderboard() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedPeriod == LeaderboardPeriod.monthly) {
        _leaderboardService
            .getMonthlyLeaderboard(category: _selectedCategory)
            .listen((entries) {
          _entries = entries;
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _leaderboardService.getDailyTopPerformers().listen((entries) {
          _entries = entries;
          _isLoading = false;
          notifyListeners();
        });
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user badges
  void loadUserBadges(String userId) {
    _leaderboardService.getUserBadges(userId).listen((badges) {
      _userBadges = badges;
      notifyListeners();
    });
  }

  // Load user tournament stats
  Future<void> loadUserStats(String userId) async {
    try {
      _userStats = await _leaderboardService.getUserTournamentStats(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load user's current rank
  Future<void> loadUserRank(String userId) async {
    try {
      _userRank = await _leaderboardService.getUserMonthlyRank(
        userId: userId,
        category: _selectedCategory,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get monthly winners
  Future<Map<TournamentCategory, List<LeaderboardEntryModel>>>
      getMonthlyWinners({String? monthYear}) async {
    try {
      return await _leaderboardService.getMonthlyWinners(monthYear: monthYear);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  // Find user in leaderboard
  LeaderboardEntryModel? findUser(String userId) {
    try {
      return _entries.firstWhere((entry) => entry.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Check if user is in top 3
  bool isUserInTop3(String userId) {
    final userEntry = findUser(userId);
    return userEntry != null && userEntry.isPodium;
  }

  // Get user's monthly stars
  int getUserMonthlyStars(String userId) {
    final userEntry = findUser(userId);
    return userEntry?.totalStars ?? 0;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
