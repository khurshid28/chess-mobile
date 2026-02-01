class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? countryCode;
  final String? profileImage;
  final int elo;
  final int wins;
  final int losses;
  final int draws;
  final int stars;
  final int monthlyStars;
  final int gamesPlayed;
  final int tournamentsPlayed;
  final int tournamentsWon;
  final String currentCategory;
  final bool emailVerified;
  final List<String> badges;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImage,
    this.countryCode,
    this.elo = 1200,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.stars = 0,
    this.monthlyStars = 0,
    this.gamesPlayed = 0,
    this.tournamentsPlayed = 0,
    this.tournamentsWon = 0,
    this.currentCategory = 'A',
    this.emailVerified = false,
    this.badges = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Guest',
      profileImage: map['profileImage'],
      countryCode: map['countryCode'],
      elo: map['elo'] ?? 1200,
      wins: map['stats']?['wins'] ?? 0,
      losses: map['stats']?['losses'] ?? 0,
      draws: map['stats']?['draws'] ?? 0,
      stars: map['stars'] ?? 0,
      monthlyStars: map['monthlyStars'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      tournamentsPlayed: map['tournamentsPlayed'] ?? 0,
      tournamentsWon: map['tournamentsWon'] ?? 0,
      currentCategory: map['currentCategory'] ?? 'A',
      emailVerified: map['emailVerified'] ?? false,
      badges: (map['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'countryCode': countryCode,
      'elo': elo,
      'stats': {
        'wins': wins,
        'losses': losses,
        'draws': draws,
      },
      'stars': stars,
      'monthlyStars': monthlyStars,
      'gamesPlayed': gamesPlayed,
      'tournamentsPlayed': tournamentsPlayed,
      'tournamentsWon': tournamentsWon,
      'currentCategory': currentCategory,
      'emailVerified': emailVerified,
      'badges': badges,
    };
  }
}