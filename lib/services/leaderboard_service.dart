import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/tournament_model.dart';
import '../models/badge_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current month-year string
  String getCurrentMonthYear() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // Get monthly leaderboard for a category
  Stream<List<LeaderboardEntryModel>> getMonthlyLeaderboard({
    required TournamentCategory category,
    String? monthYear,
  }) {
    final targetMonth = monthYear ?? getCurrentMonthYear();
    final categoryKey = 'category_${category.name.toUpperCase()}';

    return _firestore
        .collection('monthly_leaderboard')
        .doc(targetMonth)
        .collection(categoryKey)
        .orderBy('totalStars', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final entries = <LeaderboardEntryModel>[];
      int rank = 1;
      
      for (final doc in snapshot.docs) {
        final entry = LeaderboardEntryModel.fromFirestore(doc.id, doc.data());
        entries.add(entry.copyWith(rank: rank));
        rank++;
      }
      
      return entries;
    });
  }

  // Get all monthly leaderboards (all categories)
  Future<Map<TournamentCategory, List<LeaderboardEntryModel>>>
      getAllMonthlyLeaderboards({String? monthYear}) async {
    final targetMonth = monthYear ?? getCurrentMonthYear();
    final result = <TournamentCategory, List<LeaderboardEntryModel>>{};

    for (final category in TournamentCategory.values) {
      final categoryKey = 'category_${category.name.toUpperCase()}';
      
      final snapshot = await _firestore
          .collection('monthly_leaderboard')
          .doc(targetMonth)
          .collection(categoryKey)
          .orderBy('totalStars', descending: true)
          .limit(100)
          .get();

      final entries = <LeaderboardEntryModel>[];
      int rank = 1;
      
      for (final doc in snapshot.docs) {
        final entry = LeaderboardEntryModel.fromFirestore(doc.id, doc.data());
        entries.add(entry.copyWith(rank: rank));
        rank++;
      }
      
      result[category] = entries;
    }

    return result;
  }

  // Update monthly leaderboard for a user
  Future<void> updateMonthlyLeaderboard({
    required String userId,
    required TournamentCategory category,
    required int starsEarned,
    required bool isWin,
  }) async {
    try {
      final monthYear = getCurrentMonthYear();
      final categoryKey = 'category_${category.name.toUpperCase()}';

      final leaderboardRef = _firestore
          .collection('monthly_leaderboard')
          .doc(monthYear)
          .collection(categoryKey)
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(leaderboardRef);

        if (doc.exists) {
          // Update existing entry
          transaction.update(leaderboardRef, {
            'totalStars': FieldValue.increment(starsEarned),
            'tournamentsPlayed': FieldValue.increment(1),
            'wins': isWin ? FieldValue.increment(1) : doc.data()!['wins'],
          });
        } else {
          // Create new entry - get user data
          final userDoc =
              await _firestore.collection('users').doc(userId).get();
          
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            transaction.set(leaderboardRef, {
              'displayName': userData['displayName'] ?? 'Unknown',
              'totalStars': starsEarned,
              'tournamentsPlayed': 1,
              'wins': isWin ? 1 : 0,
              'rank': 0, // Will be calculated
              'elo': userData['rating'] ?? 1200,
              'avatarUrl': userData['photoURL'],
            });
          }
        }
      });

      // Recalculate ranks for this category
      await _recalculateRanks(monthYear, categoryKey);
    } catch (e) {
      print('Error updating monthly leaderboard: $e');
    }
  }

  // Recalculate ranks for a category
  Future<void> _recalculateRanks(String monthYear, String categoryKey) async {
    try {
      final snapshot = await _firestore
          .collection('monthly_leaderboard')
          .doc(monthYear)
          .collection(categoryKey)
          .orderBy('totalStars', descending: true)
          .get();

      final batch = _firestore.batch();
      int rank = 1;

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'rank': rank});
        rank++;
      }

      await batch.commit();
    } catch (e) {
      print('Error recalculating ranks: $e');
    }
  }

  // Get top 3 for each category at month end
  Future<Map<TournamentCategory, List<LeaderboardEntryModel>>>
      getMonthlyWinners({String? monthYear}) async {
    final targetMonth = monthYear ?? getCurrentMonthYear();
    final winners = <TournamentCategory, List<LeaderboardEntryModel>>{};

    for (final category in TournamentCategory.values) {
      final categoryKey = 'category_${category.name.toUpperCase()}';
      
      final snapshot = await _firestore
          .collection('monthly_leaderboard')
          .doc(targetMonth)
          .collection(categoryKey)
          .orderBy('totalStars', descending: true)
          .limit(3)
          .get();

      final topPlayers = <LeaderboardEntryModel>[];
      int rank = 1;
      
      for (final doc in snapshot.docs) {
        final entry = LeaderboardEntryModel.fromFirestore(doc.id, doc.data());
        topPlayers.add(entry.copyWith(rank: rank));
        rank++;
      }
      
      winners[category] = topPlayers;
    }

    return winners;
  }

  // Distribute monthly prizes and badges
  Future<void> distributeMonthlyPrizes({String? monthYear}) async {
    final targetMonth = monthYear ?? getCurrentMonthYear();
    final winners = await getMonthlyWinners(monthYear: targetMonth);

    final batch = _firestore.batch();

    for (final entry in winners.entries) {
      final category = entry.key;
      final topPlayers = entry.value;

      for (int i = 0; i < topPlayers.length && i < 3; i++) {
        final player = topPlayers[i];
        final placement = i + 1;

        // Calculate bonus stars
        int bonusStars = 0;
        if (category == TournamentCategory.a) {
          bonusStars = [500, 300, 200][i];
        } else if (category == TournamentCategory.b) {
          bonusStars = [750, 450, 300][i];
        } else if (category == TournamentCategory.c) {
          bonusStars = [1000, 600, 400][i];
        } else if (category == TournamentCategory.d) {
          bonusStars = [1500, 900, 600][i];
        }

        // Update user stars
        final userRef = _firestore.collection('users').doc(player.userId);
        batch.update(userRef, {
          'stars': FieldValue.increment(bonusStars),
        });

        // Add badge
        final badge = BadgeFactory.createMonthlyChampion(
          category.name.toUpperCase(),
          placement,
          targetMonth,
        );

        batch.set(
          userRef.collection('badges').doc(),
          badge.toFirestore(),
        );

        // Add Grandmaster title for Category D winner
        if (category == TournamentCategory.d && placement == 1) {
          final gmBadge = BadgeFactory.createGrandmaster();
          batch.set(
            userRef.collection('badges').doc(),
            gmBadge.toFirestore(),
          );
        }
      }
    }

    await batch.commit();

    // Reset monthly stars for all users
    await _resetMonthlyStars();
  }

  // Reset monthly stars for all users
  Future<void> _resetMonthlyStars() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('monthlyStars', isGreaterThan: 0)
          .get();

      final batch = _firestore.batch();

      for (final doc in usersSnapshot.docs) {
        batch.update(doc.reference, {'monthlyStars': 0});
      }

      await batch.commit();
    } catch (e) {
      print('Error resetting monthly stars: $e');
    }
  }

  // Get user's current monthly rank
  Future<int?> getUserMonthlyRank({
    required String userId,
    required TournamentCategory category,
    String? monthYear,
  }) async {
    try {
      final targetMonth = monthYear ?? getCurrentMonthYear();
      final categoryKey = 'category_${category.name.toUpperCase()}';

      final doc = await _firestore
          .collection('monthly_leaderboard')
          .doc(targetMonth)
          .collection(categoryKey)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()?['rank'] as int?;
      }
      return null;
    } catch (e) {
      print('Error getting user monthly rank: $e');
      return null;
    }
  }

  // Get daily top performers (users with most stars earned today)
  Stream<List<LeaderboardEntryModel>> getDailyTopPerformers({
    int limit = 10,
  }) {
    return _firestore
        .collection('users')
        .orderBy('monthlyStars', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final entries = <LeaderboardEntryModel>[];
      int rank = 1;
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        entries.add(LeaderboardEntryModel(
          userId: doc.id,
          displayName: data['displayName'] ?? 'Unknown',
          totalStars: data['monthlyStars'] ?? 0,
          tournamentsPlayed: data['tournamentsPlayed'] ?? 0,
          wins: data['tournamentsWon'] ?? 0,
          rank: rank,
          elo: data['rating'],
          avatarUrl: data['photoURL'],
        ));
        rank++;
      }
      
      return entries;
    });
  }

  // Get user's badges
  Stream<List<BadgeModel>> getUserBadges(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('badges')
        .orderBy('earnedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BadgeModel.fromFirestore(doc.data()))
            .toList());
  }

  // Get user's tournament history
  Future<Map<String, dynamic>> getUserTournamentStats(String userId) async {
    try {
      final historyDoc =
          await _firestore.collection('tournament_history').doc(userId).get();

      if (!historyDoc.exists) {
        return {
          'totalStars': 0,
          'totalTournaments': 0,
          'wins': 0,
          'topThreeFinishes': 0,
          'averagePlacement': 0.0,
        };
      }

      final data = historyDoc.data()!;
      final tournaments = data['tournaments'] as List<dynamic>? ?? [];
      
      int wins = 0;
      int topThreeFinishes = 0;
      int totalPlacement = 0;

      for (final tournament in tournaments) {
        final placement = tournament['placement'] ?? 0;
        if (placement == 1) wins++;
        if (placement <= 3) topThreeFinishes++;
        if (placement > 0) totalPlacement += placement as int;
      }

      return {
        'totalStars': data['totalStars'] ?? 0,
        'totalTournaments': tournaments.length,
        'wins': wins,
        'topThreeFinishes': topThreeFinishes,
        'averagePlacement': tournaments.isNotEmpty
            ? totalPlacement / tournaments.length
            : 0.0,
      };
    } catch (e) {
      print('Error getting user tournament stats: $e');
      return {
        'totalStars': 0,
        'totalTournaments': 0,
        'wins': 0,
        'topThreeFinishes': 0,
        'averagePlacement': 0.0,
      };
    }
  }
}
