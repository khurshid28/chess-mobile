import 'package:cached_network_image/cached_network_image.dart';
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<UserModel>> _playersFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _playersFuture = FirestoreService().getTopPlayers();
  }

  void _refresh() {
    setState(() {
      _isRefreshing = true;
      _playersFuture = FirestoreService().getTopPlayers();
    });
    _playersFuture.whenComplete(() {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isWoodClassic ? Colors.transparent : AppTheme.kBgColor2,
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppTheme.kColorTextPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.kGoldColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: AppTheme.kGoldColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Leaderboard',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isRefreshing ? null : _refresh,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.kColorAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isRefreshing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.kColorAccent,
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                color: AppTheme.kColorAccent,
                                size: 20,
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              // Leaderboard list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    _LeaderboardList(playersFuture: _playersFuture),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.playersFuture});
  
  final Future<List<UserModel>> playersFuture;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.userModel;
    
    return FutureBuilder<List<UserModel>>(
      future: playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppTheme.kColorAccent),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GlassPanel(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: AppTheme.kColorTextSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No players yet',
                  style: TextStyle(color: AppTheme.kColorTextSecondary),
                ),
              ],
            ),
          );
        }

        final players = snapshot.data!;
        final top10 = players.take(10).toList();
        
        // Check if current user is in top 10
        int? userRank;
        UserModel? userInList;
        if (currentUser != null) {
          for (int i = 0; i < players.length; i++) {
            if (players[i].id == currentUser.id) {
              userRank = i + 1;
              userInList = players[i];
              break;
            }
          }
        }
        
        final showUserAtBottom = userRank != null && userRank > 10;

        return Column(
          children: [
            GlassPanel(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top10.length,
                separatorBuilder: (context, index) =>
                    Divider(color: AppTheme.dividerColor, height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final player = top10[index];
                  final isCurrentUser = currentUser != null && player.id == currentUser.id;
                  return _PlayerTile(player: player, rank: index + 1, isCurrentUser: isCurrentUser);
                },
              ),
            ),
            if (showUserAtBottom && userInList != null) ...[
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.person_pin, color: AppTheme.kColorAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Your Position',
                            style: TextStyle(
                              color: AppTheme.kColorAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppTheme.dividerColor, height: 1, indent: 16, endIndent: 16),
                    _PlayerTile(player: userInList, rank: userRank, isCurrentUser: true),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}


class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.rank,
    this.isCurrentUser = false,
  });

  final UserModel player;
  final int rank;
  final bool isCurrentUser;

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return AppTheme.kGoldColor;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppTheme.kColorTextSecondary;
    }
  }

  IconData _getRankIcon() {
    switch (rank) {
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.workspace_premium_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.tag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();
    final isTopThree = rank <= 3;

    return Container(
      decoration: isCurrentUser
          ? BoxDecoration(
              color: AppTheme.kColorAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(isTopThree ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isTopThree
                    ? Icon(_getRankIcon(), color: rankColor, size: 22)
                    : Text(
                        rank.toString(),
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isTopThree
                    ? Border.all(color: rankColor.withOpacity(0.5), width: 2)
                    : null,
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.kColorAccent.withOpacity(0.1),
                backgroundImage: player.profileImage != null
                    ? CachedNetworkImageProvider(player.profileImage!)
                    : null,
                child: player.profileImage == null
                    ? Icon(Icons.person_rounded,
                        color: AppTheme.kColorAccent.withOpacity(0.7), size: 22)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.displayName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.kColorTextPrimary),
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.kColorAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: AppTheme.kColorAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  player.elo.toString(),
                  style: TextStyle(
                      color: AppTheme.kColorAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}