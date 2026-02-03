import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament_model.dart';
import '../models/tournament_participant_model.dart';
import '../models/tournament_match_model.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get tournament category based on ELO
  TournamentCategory getCategoryByElo(int elo) {
    if (elo < 1500) return TournamentCategory.a;
    if (elo < 1800) return TournamentCategory.b;
    if (elo < 2000) return TournamentCategory.c;
    return TournamentCategory.d;
  }

  // Get ELO range for category
  Map<String, int> getCategoryEloRange(TournamentCategory category) {
    switch (category) {
      case TournamentCategory.a:
        return {'min': 1200, 'max': 1500};
      case TournamentCategory.b:
        return {'min': 1500, 'max': 1800};
      case TournamentCategory.c:
        return {'min': 1800, 'max': 2000};
      case TournamentCategory.d:
        return {'min': 2000, 'max': 9999};
    }
  }

  // Check if user can join tournament
  Future<Map<String, dynamic>> canJoinTournament(
    String userId,
    String tournamentId,
  ) async {
    try {
      // Get tournament
      final tournamentDoc =
          await _firestore.collection('tournaments').doc(tournamentId).get();
      if (!tournamentDoc.exists) {
        return {'canJoin': false, 'reason': 'Tournament not found'};
      }

      final tournament = TournamentModel.fromFirestore(tournamentDoc);

      // Check tournament status
      if (tournament.status != TournamentStatus.registration) {
        return {
          'canJoin': false,
          'reason': 'Registration is closed',
        };
      }

      // Check if full
      if (tournament.isFull) {
        return {'canJoin': false, 'reason': 'Tournament is full'};
      }

      // Check if already joined
      final participantDoc = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(userId)
          .get();

      if (participantDoc.exists) {
        return {
          'canJoin': false,
          'reason': 'Already registered',
        };
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {'canJoin': false, 'reason': 'User not found'};
      }

      final userData = userDoc.data()!;
      final userElo = userData['rating'] ?? 1200;

      // Check ELO eligibility
      if (userElo < tournament.minElo || userElo > tournament.maxElo) {
        return {
          'canJoin': false,
          'reason':
              'Your rating (${userElo}) is not in this tournament\'s range (${tournament.minElo}-${tournament.maxElo})',
        };
      }

      // Check email verification
      final emailVerified = userData['emailVerified'] ?? false;
      if (!emailVerified) {
        return {
          'canJoin': false,
          'reason': 'Email must be verified',
        };
      }

      // Check minimum games played
      final gamesPlayed = userData['gamesPlayed'] ?? 0;
      if (gamesPlayed < 10) {
        return {
          'canJoin': false,
          'reason': 'Must have played at least 10 games',
        };
      }

      // Check daily tournament limit (max 5 per day)
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final userTournamentHistory = await _firestore
          .collection('tournament_history')
          .doc(userId)
          .get();

      if (userTournamentHistory.exists) {
        final tournaments =
            userTournamentHistory.data()?['tournaments'] as List<dynamic>? ??
                [];
        final todayTournaments = tournaments.where((t) {
          final date = (t['date'] as Timestamp).toDate();
          return date.isAfter(startOfDay) && date.isBefore(endOfDay);
        }).length;

        if (todayTournaments >= 5) {
          return {
            'canJoin': false,
            'reason': 'Daily tournament limit reached (5)',
          };
        }
      }

      return {'canJoin': true};
    } catch (e) {
      return {'canJoin': false, 'reason': 'Error: $e'};
    }
  }

  // Join tournament
  Future<bool> joinTournament(String userId, String tournamentId) async {
    try {
      final canJoinResult = await canJoinTournament(userId, tournamentId);
      if (!canJoinResult['canJoin']) {
        throw Exception(canJoinResult['reason']);
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data()!;

      // Create participant
      final participant = TournamentParticipantModel(
        userId: userId,
        displayName: userData['displayName'] ?? 'Unknown',
        elo: userData['rating'] ?? 1200,
        seed: 0, // Will be assigned when bracket is generated
        joinedAt: DateTime.now(),
      );

      // Add participant and increment currentPlayers atomically
      await _firestore.runTransaction((transaction) async {
        final tournamentRef =
            _firestore.collection('tournaments').doc(tournamentId);
        final tournamentDoc = await transaction.get(tournamentRef);

        if (!tournamentDoc.exists) {
          throw Exception('Tournament not found');
        }

        final currentPlayers = tournamentDoc.data()?['currentPlayers'] ?? 0;
        if (currentPlayers >= 16) {
          throw Exception('Tournament is full');
        }

        // Add participant
        final participantRef = tournamentRef
            .collection('participants')
            .doc(userId);
        transaction.set(participantRef, participant.toFirestore());

        // Increment currentPlayers
        transaction.update(tournamentRef, {
          'currentPlayers': FieldValue.increment(1),
        });
      });

      return true;
    } catch (e) {
      print('Error joining tournament: $e');
      return false;
    }
  }

  // Generate bracket (called when tournament starts)
  Future<void> generateBracket(String tournamentId) async {
    try {
      // Get all participants
      final participantsSnapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .get();

      final participants = participantsSnapshot.docs
          .map((doc) => TournamentParticipantModel.fromFirestore(doc))
          .toList();

      // Sort by ELO (descending) for seeding
      participants.sort((a, b) => b.elo.compareTo(a.elo));

      // Assign seeds
      for (int i = 0; i < participants.length; i++) {
        await _firestore
            .collection('tournaments')
            .doc(tournamentId)
            .collection('participants')
            .doc(participants[i].userId)
            .update({'seed': i + 1});
      }

      // Create Round 1 matches (Round of 16)
      final round1Matches = <TournamentMatchModel>[];

      // If less than 16 players, add byes
      final totalPlayers = participants.length;

      // Standard bracket pairing: 1 vs 16, 2 vs 15, 3 vs 14, etc.
      final pairings = [
        [1, 16], [8, 9], [4, 13], [5, 12],
        [2, 15], [7, 10], [3, 14], [6, 11]
      ];

      for (int i = 0; i < 8; i++) {
        final seed1 = pairings[i][0];
        final seed2 = pairings[i][1];

        // Find players by seed
        final player1 = seed1 <= totalPlayers
            ? participants.firstWhere((p) => p.seed == seed1)
            : null;
        final player2 = seed2 <= totalPlayers
            ? participants.firstWhere((p) => p.seed == seed2)
            : null;

        if (player1 != null && player2 != null) {
          // Both players present
          round1Matches.add(TournamentMatchModel(
            matchId: 'r1_m${i + 1}',
            player1Id: player1.userId,
            player2Id: player2.userId,
            player1Name: player1.displayName,
            player2Name: player2.displayName,
          ));
        } else if (player1 != null) {
          // Player 1 gets BYE
          round1Matches.add(TournamentMatchModel(
            matchId: 'r1_m${i + 1}',
            player1Id: player1.userId,
            player2Id: 'BYE',
            player1Name: player1.displayName,
            player2Name: 'BYE',
            player1Score: 2,
            player2Score: 0,
            winnerId: player1.userId,
            status: MatchStatus.completed,
          ));
        }
      }

      // Save Round 1
      final round1 = TournamentRoundModel(round: 1, matches: round1Matches);
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('brackets')
          .doc('round_1')
          .set(round1.toFirestore());

      // Update tournament status
      await _firestore.collection('tournaments').doc(tournamentId).update({
        'status': TournamentStatus.inProgress.name,
        'startedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error generating bracket: $e');
      rethrow;
    }
  }

  // Calculate stars earned based on placement and category
  int calculateStars(TournamentCategory category, String placement) {
    return TournamentRewards.getReward(category, placement);
  }

  // Award stars to participant
  Future<void> awardStars(
    String userId,
    String tournamentId,
    int stars,
    String placement,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Update user's total stars
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'stars': FieldValue.increment(stars),
          'monthlyStars': FieldValue.increment(stars),
        });

        // Update participant's stars earned
        final participantRef = _firestore
            .collection('tournaments')
            .doc(tournamentId)
            .collection('participants')
            .doc(userId);
        transaction.update(participantRef, {
          'stars_earned': FieldValue.increment(stars),
        });

        // Add to tournament history
        final historyRef =
            _firestore.collection('tournament_history').doc(userId);
        final historyDoc = await transaction.get(historyRef);

        if (historyDoc.exists) {
          transaction.update(historyRef, {
            'tournaments': FieldValue.arrayUnion([
              {
                'tournamentId': tournamentId,
                'date': FieldValue.serverTimestamp(),
                'stars_earned': stars,
                'placement': placement,
              }
            ]),
            'totalStars': FieldValue.increment(stars),
          });
        } else {
          transaction.set(historyRef, {
            'tournaments': [
              {
                'tournamentId': tournamentId,
                'date': FieldValue.serverTimestamp(),
                'stars_earned': stars,
                'placement': placement,
              }
            ],
            'totalStars': stars,
          });
        }
      });
    } catch (e) {
      print('Error awarding stars: $e');
    }
  }

  // Get upcoming tournaments
  Stream<List<TournamentModel>> getUpcomingTournaments({
    TournamentCategory? category,
  }) {
    Query query = _firestore
        .collection('tournaments')
        .where('status', whereIn: [
          TournamentStatus.pending.name,
          TournamentStatus.registration.name,
        ])
        .orderBy('scheduledTime');

    if (category != null) {
      query = query.where('category', isEqualTo: category.name.toUpperCase());
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TournamentModel.fromFirestore(doc))
        .toList());
  }

  // Get active tournaments
  Stream<List<TournamentModel>> getActiveTournaments({
    TournamentCategory? category,
  }) {
    Query query = _firestore
        .collection('tournaments')
        .where('status', isEqualTo: TournamentStatus.inProgress.name)
        .orderBy('startedAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name.toUpperCase());
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TournamentModel.fromFirestore(doc))
        .toList());
  }

  // Get tournament participants
  Stream<List<TournamentParticipantModel>> getTournamentParticipants(
    String tournamentId,
  ) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .orderBy('seed')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TournamentParticipantModel.fromFirestore(doc))
            .toList());
  }

  // Get tournament bracket
  Stream<List<TournamentRoundModel>> getTournamentBracket(
    String tournamentId,
  ) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('brackets')
        .orderBy('round')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TournamentRoundModel.fromFirestore(doc))
            .toList());
  }

  // Get specific tournament
  Stream<TournamentModel> getTournament(String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .snapshots()
        .map((doc) => TournamentModel.fromFirestore(doc));
  }

  // Check if user is in tournament
  Future<bool> isUserInTournament(String userId, String tournamentId) async {
    final doc = await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .doc(userId)
        .get();
    return doc.exists;
  }

  // Create tournament game
  // This should be called by Cloud Functions or triggered when players are ready
  // Returns the gameId
  Future<String> createTournamentGame({
    required String tournamentId,
    required String matchId,
    required String player1Id,
    required String player2Id,
    required int timeControl,
  }) async {
    try {
      // Get player data
      final player1Doc = await _firestore.collection('users').doc(player1Id).get();
      final player2Doc = await _firestore.collection('users').doc(player2Id).get();

      if (!player1Doc.exists || !player2Doc.exists) {
        throw Exception('Player not found');
      }

      final player1Data = player1Doc.data()!;
      final player2Data = player2Doc.data()!;

      // Randomly assign colors
      final whiteIndex = DateTime.now().millisecondsSinceEpoch % 2;
      final isPlayer1White = whiteIndex == 0;

      final whiteId = isPlayer1White ? player1Id : player2Id;
      final blackId = isPlayer1White ? player2Id : player1Id;
      final whiteData = isPlayer1White ? player1Data : player2Data;
      final blackData = isPlayer1White ? player2Data : player1Data;

      // Create game document
      final gameRef = _firestore.collection('games').doc();
      await gameRef.set({
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'pgn': '',
        'status': 'inprogress',
        'participants': [whiteId, blackId],
        'playerWhiteId': whiteId,
        'playerWhiteName': whiteData['displayName'] ?? 'Player',
        'playerWhiteElo': whiteData['rating'] ?? 1200,
        'playerWhiteCountryCode': whiteData['countryCode'],
        'playerWhiteImage': whiteData['profileImage'],
        'playerWhiteStatus': 'online',
        'playerBlackId': blackId,
        'playerBlackName': blackData['displayName'] ?? 'Player',
        'playerBlackElo': blackData['rating'] ?? 1200,
        'playerBlackCountryCode': blackData['countryCode'],
        'playerBlackImage': blackData['profileImage'],
        'playerBlackStatus': 'online',
        'turn': 'w',
        'createdAt': FieldValue.serverTimestamp(),
        'initialTime': timeControl,
        'whiteTimeLeft': timeControl,
        'blackTimeLeft': timeControl,
        'lastMoveTimestamp': FieldValue.serverTimestamp(),
        'eloCalculated': false,
        'isRanked': true,
        'tournamentId': tournamentId,
        'tournamentMatchId': matchId,
        'maxElo': [
          whiteData['rating'] ?? 1200,
          blackData['rating'] ?? 1200
        ].reduce((a, b) => a > b ? a : b),
      });

      return gameRef.id;
    } catch (e) {
      print('Error creating tournament game: $e');
      rethrow;
    }
  }
}
