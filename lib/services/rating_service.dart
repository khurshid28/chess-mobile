import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament_model.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Calculate K-factor based on number of games played
  int getKFactor(int gamesPlayed) {
    if (gamesPlayed < 30) return 32;
    if (gamesPlayed < 100) return 24;
    return 16;
  }

  // Calculate expected score
  double calculateExpectedScore(int playerRating, int opponentRating) {
    return 1 / (1 + pow(10, (opponentRating - playerRating) / 400));
  }

  // Calculate new rating after a game
  Map<String, int> calculateEloChange({
    required int player1Rating,
    required int player2Rating,
    required int player1GamesPlayed,
    required int player2GamesPlayed,
    required String result, // 'player1', 'player2', or 'draw'
  }) {
    // Get K-factors
    final k1 = getKFactor(player1GamesPlayed);
    final k2 = getKFactor(player2GamesPlayed);

    // Calculate expected scores
    final expected1 = calculateExpectedScore(player1Rating, player2Rating);
    final expected2 = calculateExpectedScore(player2Rating, player1Rating);

    // Calculate actual scores
    double actual1, actual2;
    if (result == 'player1') {
      actual1 = 1.0;
      actual2 = 0.0;
    } else if (result == 'player2') {
      actual1 = 0.0;
      actual2 = 1.0;
    } else {
      // draw
      actual1 = 0.5;
      actual2 = 0.5;
    }

    // Calculate rating changes
    final change1 = (k1 * (actual1 - expected1)).round();
    final change2 = (k2 * (actual2 - expected2)).round();

    // Calculate new ratings (minimum 100)
    final newRating1 = max(100, player1Rating + change1);
    final newRating2 = max(100, player2Rating + change2);

    return {
      'player1NewRating': newRating1,
      'player2NewRating': newRating2,
      'player1Change': change1,
      'player2Change': change2,
    };
  }

  // Update user rating after a ranked game
  Future<void> updateUserRating({
    required String userId,
    required int newRating,
    required int ratingChange,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data()!;
        final oldRating = userData['rating'] ?? 1200;
        final gamesPlayed = (userData['gamesPlayed'] ?? 0) + 1;
        
        // Determine new category
        TournamentCategory oldCategory = _getCategoryByElo(oldRating);
        TournamentCategory newCategory = _getCategoryByElo(newRating);

        Map<String, dynamic> updateData = {
          'rating': newRating,
          'gamesPlayed': gamesPlayed,
          'ratingHistory': FieldValue.arrayUnion([
            {
              'rating': newRating,
              'change': ratingChange,
              'timestamp': FieldValue.serverTimestamp(),
            }
          ]),
        };

        // Update category if it changed
        if (oldCategory != newCategory) {
          updateData['currentCategory'] = newCategory.name.toUpperCase();
          updateData['categoryChangedAt'] = FieldValue.serverTimestamp();
        }

        transaction.update(userRef, updateData);
      });
    } catch (e) {
      print('Error updating user rating: $e');
      rethrow;
    }
  }

  // Get category by ELO
  TournamentCategory _getCategoryByElo(int elo) {
    if (elo < 1500) return TournamentCategory.a;
    if (elo < 1800) return TournamentCategory.b;
    if (elo < 2000) return TournamentCategory.c;
    return TournamentCategory.d;
  }

  // Calculate rating for a match (best of 3)
  Future<void> updateRatingsAfterMatch({
    required String player1Id,
    required String player2Id,
    required String winnerId, // or 'draw'
    required bool isRanked,
  }) async {
    if (!isRanked) {
      return; // Only update ratings for ranked games
    }

    try {
      // Get both players' data
      final player1Doc = await _firestore.collection('users').doc(player1Id).get();
      final player2Doc = await _firestore.collection('users').doc(player2Id).get();

      if (!player1Doc.exists || !player2Doc.exists) {
        throw Exception('Player not found');
      }

      final player1Data = player1Doc.data()!;
      final player2Data = player2Doc.data()!;

      final player1Rating = player1Data['rating'] ?? 1200;
      final player2Rating = player2Data['rating'] ?? 1200;
      final player1Games = player1Data['gamesPlayed'] ?? 0;
      final player2Games = player2Data['gamesPlayed'] ?? 0;

      // Determine result
      String result;
      if (winnerId == player1Id) {
        result = 'player1';
      } else if (winnerId == player2Id) {
        result = 'player2';
      } else {
        result = 'draw';
      }

      // Calculate new ratings
      final ratingChanges = calculateEloChange(
        player1Rating: player1Rating,
        player2Rating: player2Rating,
        player1GamesPlayed: player1Games,
        player2GamesPlayed: player2Games,
        result: result,
      );

      // Update both players
      await Future.wait([
        updateUserRating(
          userId: player1Id,
          newRating: ratingChanges['player1NewRating']!,
          ratingChange: ratingChanges['player1Change']!,
        ),
        updateUserRating(
          userId: player2Id,
          newRating: ratingChanges['player2NewRating']!,
          ratingChange: ratingChanges['player2Change']!,
        ),
      ]);
    } catch (e) {
      print('Error updating ratings after match: $e');
      rethrow;
    }
  }

  // Get user's rating history
  Future<List<Map<String, dynamic>>> getUserRatingHistory(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return [];
      }

      final data = userDoc.data()!;
      final history = data['ratingHistory'] as List<dynamic>? ?? [];
      
      return history.map((h) => {
        'rating': h['rating'] ?? 1200,
        'change': h['change'] ?? 0,
        'timestamp': (h['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      }).toList();
    } catch (e) {
      print('Error getting rating history: $e');
      return [];
    }
  }

  // Calculate provisional rating (for new players)
  Future<int> calculateProvisionalRating(String userId) async {
    try {
      // Get user's recent games
      final gamesSnapshot = await _firestore
          .collection('games')
          .where('players', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      if (gamesSnapshot.docs.isEmpty) {
        return 1200; // Default rating
      }

      int totalOpponentRating = 0;
      int wins = 0;
      int games = 0;

      for (final gameDoc in gamesSnapshot.docs) {
        final gameData = gameDoc.data();
        final players = gameData['players'] as List<dynamic>;
        final winnerId = gameData['winnerId'];
        
        // Find opponent
        final opponentId = players.firstWhere((p) => p != userId);
        final opponentDoc = await _firestore.collection('users').doc(opponentId).get();
        
        if (opponentDoc.exists) {
          final opponentRating = opponentDoc.data()?['rating'] ?? 1200;
          totalOpponentRating += opponentRating as int;
          
          if (winnerId == userId) {
            wins++;
          }
          games++;
        }
      }

      if (games == 0) {
        return 1200;
      }

      // Calculate average opponent rating
      final avgOpponentRating = totalOpponentRating ~/ games;
      final winRate = wins / games;

      // Estimate rating based on win rate against average opponent
      // Using a simplified formula
      int estimatedRating = avgOpponentRating;
      if (winRate > 0.5) {
        estimatedRating += ((winRate - 0.5) * 400).round();
      } else if (winRate < 0.5) {
        estimatedRating -= ((0.5 - winRate) * 400).round();
      }

      return max(100, min(2800, estimatedRating));
    } catch (e) {
      print('Error calculating provisional rating: $e');
      return 1200;
    }
  }
}
