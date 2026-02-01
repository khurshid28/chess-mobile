import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentParticipantModel {
  final String userId;
  final String displayName;
  final int elo;
  final int seed;
  final DateTime joinedAt;
  final bool isActive;
  final int currentRound;
  final bool eliminated;
  final int starsEarned;

  TournamentParticipantModel({
    required this.userId,
    required this.displayName,
    required this.elo,
    required this.seed,
    required this.joinedAt,
    this.isActive = true,
    this.currentRound = 0,
    this.eliminated = false,
    this.starsEarned = 0,
  });

  factory TournamentParticipantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TournamentParticipantModel(
      userId: data['userId'] ?? doc.id,
      displayName: data['displayName'] ?? 'Unknown',
      elo: data['elo'] ?? 1200,
      seed: data['seed'] ?? 1,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      currentRound: data['currentRound'] ?? 0,
      eliminated: data['eliminated'] ?? false,
      starsEarned: data['stars_earned'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'elo': elo,
      'seed': seed,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
      'currentRound': currentRound,
      'eliminated': eliminated,
      'stars_earned': starsEarned,
    };
  }

  TournamentParticipantModel copyWith({
    String? userId,
    String? displayName,
    int? elo,
    int? seed,
    DateTime? joinedAt,
    bool? isActive,
    int? currentRound,
    bool? eliminated,
    int? starsEarned,
  }) {
    return TournamentParticipantModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      elo: elo ?? this.elo,
      seed: seed ?? this.seed,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      currentRound: currentRound ?? this.currentRound,
      eliminated: eliminated ?? this.eliminated,
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }
}
