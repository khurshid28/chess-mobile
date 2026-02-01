import 'package:cloud_firestore/cloud_firestore.dart';

enum TournamentStatus {
  pending,
  registration,
  inProgress,
  completed,
}

enum TournamentCategory {
  a, // 1200-1500
  b, // 1500-1800
  c, // 1800-2000
  d, // 2000+
}

class TournamentModel {
  final String id;
  final TournamentCategory category;
  final int minElo;
  final int maxElo;
  final DateTime scheduledTime;
  final TournamentStatus status;
  final int maxPlayers;
  final int currentPlayers;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? winnerId;
  final String? runnerUpId;
  final String? thirdPlaceId;

  TournamentModel({
    required this.id,
    required this.category,
    required this.minElo,
    required this.maxElo,
    required this.scheduledTime,
    required this.status,
    this.maxPlayers = 16,
    this.currentPlayers = 0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.winnerId,
    this.runnerUpId,
    this.thirdPlaceId,
  });

  factory TournamentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TournamentModel(
      id: doc.id,
      category: TournamentCategory.values.firstWhere(
        (e) => e.name.toUpperCase() == data['category'].toString().toUpperCase(),
      ),
      minElo: data['minElo'] ?? 0,
      maxElo: data['maxElo'] ?? 9999,
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TournamentStatus.pending,
      ),
      maxPlayers: data['maxPlayers'] ?? 16,
      currentPlayers: data['currentPlayers'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      winnerId: data['winnerId'],
      runnerUpId: data['runnerUpId'],
      thirdPlaceId: data['thirdPlaceId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category.name.toUpperCase(),
      'minElo': minElo,
      'maxElo': maxElo,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status.name,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'winnerId': winnerId,
      'runnerUpId': runnerUpId,
      'thirdPlaceId': thirdPlaceId,
    };
  }

  String get categoryLabel {
    switch (category) {
      case TournamentCategory.a:
        return 'Category A (1200-1500)';
      case TournamentCategory.b:
        return 'Category B (1500-1800)';
      case TournamentCategory.c:
        return 'Category C (1800-2000)';
      case TournamentCategory.d:
        return 'Category D (2000+)';
    }
  }

  bool get isFull => currentPlayers >= maxPlayers;
  bool get canJoin => status == TournamentStatus.registration && !isFull;

  TournamentModel copyWith({
    String? id,
    TournamentCategory? category,
    int? minElo,
    int? maxElo,
    DateTime? scheduledTime,
    TournamentStatus? status,
    int? maxPlayers,
    int? currentPlayers,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? winnerId,
    String? runnerUpId,
    String? thirdPlaceId,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      category: category ?? this.category,
      minElo: minElo ?? this.minElo,
      maxElo: maxElo ?? this.maxElo,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      winnerId: winnerId ?? this.winnerId,
      runnerUpId: runnerUpId ?? this.runnerUpId,
      thirdPlaceId: thirdPlaceId ?? this.thirdPlaceId,
    );
  }
}

// Star rewards based on category and placement
class TournamentRewards {
  static Map<TournamentCategory, Map<String, int>> rewards = {
    TournamentCategory.a: {
      'round_of_16': 5,
      'quarter_final': 15,
      'first_place': 80,
      'second_place': 50,
      'third_place': 30,
    },
    TournamentCategory.b: {
      'round_of_16': 7,
      'quarter_final': 20,
      'first_place': 100,
      'second_place': 65,
      'third_place': 40,
    },
    TournamentCategory.c: {
      'round_of_16': 10,
      'quarter_final': 25,
      'first_place': 120,
      'second_place': 80,
      'third_place': 50,
    },
    TournamentCategory.d: {
      'round_of_16': 15,
      'quarter_final': 35,
      'first_place': 150,
      'second_place': 100,
      'third_place': 65,
    },
  };

  static int getReward(TournamentCategory category, String placement) {
    return rewards[category]?[placement] ?? 0;
  }
}
