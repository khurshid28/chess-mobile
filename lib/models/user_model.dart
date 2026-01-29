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
    };
  }
}