import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/screens/bot_selection_screen.dart';
import 'package:chess_park/screens/leaderboard_screen.dart';
import 'package:chess_park/screens/online_games_screen.dart';
import 'package:chess_park/screens/profile_screen.dart';
import 'package:chess_park/screens/puzzle_lobby_screen.dart';
import 'package:chess_park/screens/invite_friends_screen.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/widgets/user_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<UserModel>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = FirestoreService().getTopPlayers(limit: 5);
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.refreshUser();
    setState(() {
      _leaderboardFuture = FirestoreService().getTopPlayers(limit: 5);
    });
  }

  void _goToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.isLight 
          ? SystemUiOverlayStyle.dark 
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.kBgColor2,
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.kColorAccent,
            backgroundColor: AppTheme.kBgColor1,
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, topPadding, 20, 40),
              children: [
                  // User Header - tappable to go to profile
                  if (user != null)
                    UserHeader(user: user, onTap: _goToProfile),
                  const SizedBox(height: 24),

                  // Play Section
                  _SectionTitle(title: 'Play', icon: Icons.play_arrow_rounded),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: Icons.public_rounded,
                    title: 'Online Game',
                    subtitle: 'Play with players worldwide',
                    color: Colors.blue,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnlineGamesScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: Icons.smart_toy_rounded,
                    title: 'Play Bot',
                    subtitle: 'Practice against AI',
                    color: Colors.purple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BotSelectionScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: Icons.person_add_rounded,
                    title: 'Invite Friends',
                    subtitle: 'Play with your friends',
                    color: Colors.green,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InviteFriendsScreen()),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Puzzles Section
                  _SectionTitle(title: 'Puzzles', icon: Icons.extension_rounded),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: Icons.extension_rounded,
                    title: 'Puzzles',
                    subtitle: 'Daily chess puzzles',
                    color: Colors.orange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PuzzleLobbyScreen()),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Leaderboard Section
                  _SectionTitle(
                    title: 'Leaderboard',
                    icon: Icons.emoji_events_rounded,
                    trailing: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      ),
                      child: Text(
                        'See All',
                        style: TextStyle(color: AppTheme.kColorAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MiniLeaderboard(future: _leaderboardFuture),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.kColorAccent, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.kColorTextPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.kColorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.kColorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.kColorTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniLeaderboard extends StatelessWidget {
  final Future<List<UserModel>> future;

  const _MiniLeaderboard({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlassPanel(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.kColorAccent,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GlassPanel(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No players yet',
                style: TextStyle(color: AppTheme.kColorTextSecondary),
              ),
            ),
          );
        }

        final players = snapshot.data!;
        return GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              for (int i = 0; i < players.length; i++) ...[
                _LeaderboardRow(player: players[i], rank: i + 1),
                if (i < players.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: AppTheme.kColorTextSecondary.withOpacity(0.1),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final UserModel player;
  final int rank;

  const _LeaderboardRow({required this.player, required this.rank});

  Color get _rankColor {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return AppTheme.kColorTextSecondary;
    }
  }

  IconData? get _rankIcon {
    if (rank <= 3) return Icons.emoji_events_rounded;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: _rankIcon != null
                ? Icon(_rankIcon, color: _rankColor, size: 22)
                : Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _rankColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              player.displayName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.kColorTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.kColorAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${player.elo}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.kColorAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
