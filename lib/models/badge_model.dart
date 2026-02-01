import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeType {
  monthlyChampionA,
  monthlyChampionB,
  monthlyChampionC,
  monthlyChampionD,
  runnerUpA,
  runnerUpB,
  runnerUpC,
  runnerUpD,
  thirdPlaceA,
  thirdPlaceB,
  thirdPlaceC,
  thirdPlaceD,
  grandmaster,
  tournamentWinner,
  perfectScore,
  speedster,
  veteran,
}

class BadgeModel {
  final BadgeType type;
  final String name;
  final String description;
  final DateTime earnedAt;
  final String? tournamentId;
  final String? monthYear; // "2026-01" format

  BadgeModel({
    required this.type,
    required this.name,
    required this.description,
    required this.earnedAt,
    this.tournamentId,
    this.monthYear,
  });

  factory BadgeModel.fromFirestore(Map<String, dynamic> data) {
    return BadgeModel(
      type: BadgeType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BadgeType.tournamentWinner,
      ),
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
      tournamentId: data['tournamentId'],
      monthYear: data['monthYear'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'name': name,
      'description': description,
      'earnedAt': Timestamp.fromDate(earnedAt),
      'tournamentId': tournamentId,
      'monthYear': monthYear,
    };
  }

  String get icon {
    switch (type) {
      case BadgeType.monthlyChampionA:
      case BadgeType.monthlyChampionB:
      case BadgeType.monthlyChampionC:
      case BadgeType.monthlyChampionD:
        return '👑';
      case BadgeType.runnerUpA:
      case BadgeType.runnerUpB:
      case BadgeType.runnerUpC:
      case BadgeType.runnerUpD:
        return '🥈';
      case BadgeType.thirdPlaceA:
      case BadgeType.thirdPlaceB:
      case BadgeType.thirdPlaceC:
      case BadgeType.thirdPlaceD:
        return '🥉';
      case BadgeType.grandmaster:
        return '🎖️';
      case BadgeType.tournamentWinner:
        return '🏆';
      case BadgeType.perfectScore:
        return '💯';
      case BadgeType.speedster:
        return '⚡';
      case BadgeType.veteran:
        return '🎯';
    }
  }

  bool get isMonthly => [
        BadgeType.monthlyChampionA,
        BadgeType.monthlyChampionB,
        BadgeType.monthlyChampionC,
        BadgeType.monthlyChampionD,
        BadgeType.runnerUpA,
        BadgeType.runnerUpB,
        BadgeType.runnerUpC,
        BadgeType.runnerUpD,
        BadgeType.thirdPlaceA,
        BadgeType.thirdPlaceB,
        BadgeType.thirdPlaceC,
        BadgeType.thirdPlaceD,
      ].contains(type);
}

class BadgeFactory {
  static BadgeModel createMonthlyChampion(
    String category,
    int placement,
    String monthYear,
  ) {
    final categoryUpper = category.toUpperCase();
    BadgeType type;
    String name;
    String description;

    if (placement == 1) {
      type = BadgeType.values.firstWhere(
        (e) => e.name == 'monthlyChampion$categoryUpper',
      );
      name = 'Monthly Champion $categoryUpper';
      description = 'Won Category $categoryUpper for $monthYear';
    } else if (placement == 2) {
      type = BadgeType.values.firstWhere(
        (e) => e.name == 'runnerUp$categoryUpper',
      );
      name = 'Runner-up $categoryUpper';
      description = '2nd place in Category $categoryUpper for $monthYear';
    } else {
      type = BadgeType.values.firstWhere(
        (e) => e.name == 'thirdPlace$categoryUpper',
      );
      name = '3rd Place $categoryUpper';
      description = '3rd place in Category $categoryUpper for $monthYear';
    }

    return BadgeModel(
      type: type,
      name: name,
      description: description,
      earnedAt: DateTime.now(),
      monthYear: monthYear,
    );
  }

  static BadgeModel createTournamentWinner(String tournamentId) {
    return BadgeModel(
      type: BadgeType.tournamentWinner,
      name: 'Tournament Winner',
      description: 'Won a daily tournament',
      earnedAt: DateTime.now(),
      tournamentId: tournamentId,
    );
  }

  static BadgeModel createGrandmaster() {
    return BadgeModel(
      type: BadgeType.grandmaster,
      name: 'Grandmaster',
      description: 'Monthly Champion in Category D (2000+)',
      earnedAt: DateTime.now(),
    );
  }
}
