import 'package:cached_network_image/cached_network_image.dart';
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 60;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: EdgeInsets.fromLTRB(24.0, topPadding, 24.0, 120.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Leaderboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const _LeaderboardList(),
        ],
      ),
    );
  }
}


class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: FirestoreService().getTopPlayers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.kColorAccent),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No players on the leaderboard yet.',
              style: TextStyle(color: AppTheme.kColorTextSecondary),
            ),
          );
        }

        final players = snapshot.data!;

        return GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 8.0),

          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: players.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.white.withAlpha(30), height: 1),
            itemBuilder: (context, index) {
              final player = players[index];
              return _PlayerTile(player: player, rank: index + 1);
            },
          ),
        );
      },
    );
  }
}


class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.rank,
  });

  final UserModel player;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: AppTheme.kColorAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: Colors.white24,
            backgroundImage: player.profileImage != null
                ? CachedNetworkImageProvider(player.profileImage!)
                : null,
            child: player.profileImage == null
                ? const Icon(Icons.person_outline,
                    color: AppTheme.kColorTextSecondary)
                : null,
          ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              player.displayName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.kColorTextPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (player.countryCode != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CountryFlag.fromCountryCode(
                  player.countryCode!,
                  height: 12,
                  width: 18,
                ),
              ),
            ),
        ],
      ),
      trailing: Text(
        player.elo.toString(),
        style: TextStyle(
            color: AppTheme.kColorTextSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}