import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/screens/bot_selection_screen.dart';
import 'package:chess_park/screens/leaderboard_screen.dart';
import 'package:chess_park/screens/online_games_screen.dart';
import 'package:chess_park/screens/profile_screen.dart';
import 'package:chess_park/screens/puzzle_lobby_screen.dart';
import 'package:chess_park/screens/invite_friends_screen.dart';
import 'package:chess_park/screens/tournaments_screen.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/theme/app_icons.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/widgets/user_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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

                  // Daily Tournament Card
                  const _DailyTournamentCard(),
                  const SizedBox(height: 24),

                  // Play Section
                  _SectionTitle(title: 'Play', icon: AppIcons.play),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: AppIcons.onlineGame,
                    title: 'Online Game',
                    subtitle: 'Play with players worldwide',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnlineGamesScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: AppIcons.playBot,
                    title: 'Play Bot',
                    subtitle: 'Practice against AI',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BotSelectionScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: AppIcons.invite,
                    title: 'Invite Friends',
                    subtitle: 'Play with your friends',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InviteFriendsScreen()),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Puzzles Section
                  _SectionTitle(title: 'Puzzles', icon: AppIcons.puzzles),
                  const SizedBox(height: 12),
                  _MenuListItem(
                    icon: AppIcons.puzzles,
                    title: 'Puzzles',
                    subtitle: 'Daily chess puzzles',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PuzzleLobbyScreen()),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Leaderboard Section
                  _SectionTitle(
                    title: 'Leaderboard',
                    icon: AppIcons.leaderboard,
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
  final VoidCallback onTap;

  const _MenuListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
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
                color: AppTheme.kColorAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.kColorAccent, size: 26),
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
              AppIcons.chevronRight,
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
        return AppTheme.kColorAccent; // Gold/accent for 1st
      case 2:
        return AppTheme.kColorTextSecondary; // Silver
      case 3:
        return AppTheme.kSecondaryColor; // Bronze
      default:
        return AppTheme.kColorTextSecondary;
    }
  }

  IconData? get _rankIcon {
    if (rank <= 3) return AppIcons.crown;
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

/// Daily Tournament Card - Shows upcoming/live tournament info
class _DailyTournamentCard extends StatefulWidget {
  const _DailyTournamentCard();

  @override
  State<_DailyTournamentCard> createState() => _DailyTournamentCardState();
}

class _DailyTournamentCardState extends State<_DailyTournamentCard> {
  Timer? _timer;
  late DateTime _tournamentTime;
  bool _isLive = false;
  Duration _timeRemaining = Duration.zero;

  // Daily tournament time: 11:00 Tashkent time (UTC+5)
  static const int tournamentHour = 11;
  static const int tournamentMinute = 0;

  @override
  void initState() {
    super.initState();
    _calculateTournamentTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTournamentTime() {
    final now = DateTime.now();
    // Tournament at 21:00 local time
    _tournamentTime = DateTime(now.year, now.month, now.day, tournamentHour, tournamentMinute);
    
    // If today's tournament has passed, show tomorrow's
    if (now.isAfter(_tournamentTime.add(const Duration(hours: 2)))) {
      _tournamentTime = _tournamentTime.add(const Duration(days: 1));
    }
    
    _updateStatus();
  }

  void _updateStatus() {
    final now = DateTime.now();
    final tournamentEnd = _tournamentTime.add(const Duration(hours: 2));
    
    if (now.isAfter(_tournamentTime) && now.isBefore(tournamentEnd)) {
      // Tournament is live
      _isLive = true;
      _timeRemaining = tournamentEnd.difference(now);
    } else if (now.isBefore(_tournamentTime)) {
      // Tournament is upcoming
      _isLive = false;
      _timeRemaining = _tournamentTime.difference(now);
    } else {
      // Tournament ended, calculate next one
      _tournamentTime = _tournamentTime.add(const Duration(days: 1));
      _isLive = false;
      _timeRemaining = _tournamentTime.difference(now);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _updateStatus();
      });
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TournamentsScreen()),
        );
      },
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left side - Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isLive 
                    ? Colors.red.withOpacity(0.15) 
                    : AppTheme.kColorAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isLive ? AppIcons.live : AppIcons.tournament,
                color: _isLive ? Colors.red : AppTheme.kColorAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Middle - Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _isLive ? 'LIVE NOW' : 'DAILY TOURNAMENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _isLive ? Colors.red : AppTheme.kColorAccent,
                          letterSpacing: 1,
                        ),
                      ),
                      if (_isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLive 
                        ? 'Tournament in progress!'
                        : 'Daily at $tournamentHour:00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.kColorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isLive 
                        ? 'Ends in: ${_formatDuration(_timeRemaining)}'
                        : 'Starts in: ${_formatDuration(_timeRemaining)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.kColorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Right side - Arrow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.kColorAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                AppIcons.chevronRight,
                color: AppTheme.kColorAccent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
