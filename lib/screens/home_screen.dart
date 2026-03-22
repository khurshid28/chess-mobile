import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/screens/bot_selection_screen.dart';
import 'package:chess_park/screens/leaderboard_screen.dart';
import 'package:chess_park/screens/online_games_screen.dart';
import 'package:chess_park/screens/profile_screen.dart';
import 'package:chess_park/screens/puzzle_lobby_screen.dart';
import 'package:chess_park/screens/invite_friends_screen.dart';
import 'package:chess_park/screens/settings_screen.dart';
import 'package:chess_park/screens/tournaments_screen.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/theme/app_icons.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_textures.dart';
import 'package:chess_park/theme/wood_text_styles.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.refreshUser();
    setState(() {
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: !AppTheme.isLight
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // User Header - pinned app bar
              if (user != null)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _UserHeaderDelegate(
                    user: user,
                    onTap: _goToProfile,
                    onSettingsTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Daily Tournament Card
                    const _DailyTournamentCard(),
                    const SizedBox(height: 40),

                    // 2x2 Grid
                    Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: _MenuGridItem(
                              icon: AppIcons.onlineGame,
                              title: 'Online Game',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const OnlineGamesScreen()),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: _MenuGridItem(
                              icon: AppIcons.playBot,
                              title: 'Play Bot',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const BotSelectionScreen()),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: _MenuGridItem(
                              icon: AppIcons.invite,
                              title: 'Invite',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const InviteFriendsScreen()),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: _MenuGridItem(
                              icon: AppIcons.puzzles,
                              title: 'Puzzles',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PuzzleLobbyScreen()),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _MenuListItem(
                        icon: AppIcons.leaderboard,
                        title: 'Leaderboard',
                        subtitle: '',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      );
  }
}

class _UserHeaderDelegate extends SliverPersistentHeaderDelegate {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onSettingsTap;

  _UserHeaderDelegate({required this.user, this.onTap, this.onSettingsTap});

  @override
  double get maxExtent => _headerHeight;
  @override
  double get minExtent => _headerHeight;

  // status bar + avatar(52) + vertical padding(28)
  double get _headerHeight {
    final statusBar = WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return statusBar + 80;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return UserHeader(user: user, onTap: onTap, onSettingsTap: onSettingsTap);
  }

  @override
  bool shouldRebuild(covariant _UserHeaderDelegate oldDelegate) =>
      user != oldDelegate.user;
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
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.kColorTextPrimary)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MenuListItem extends StatefulWidget {
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
  State<_MenuListItem> createState() => _MenuListItemState();
}

class _MenuListItemState extends State<_MenuListItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isWood = AppTheme.isWoodClassic;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isWood ? null : AppTheme.kColorAccent.withOpacity(0.15),
                  image: isWood ? WoodTextures.icon() : null,
                  borderRadius: BorderRadius.circular(isWood ? 8 : 10),
                  border: isWood ? Border.all(color: WoodColors.border, width: 1.5) : null,
                ),
                child: Icon(widget.icon, color: isWood ? Colors.white : AppTheme.kColorAccent, size: isWood ? 20 : 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(widget.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isWood ? Colors.white : AppTheme.kColorTextPrimary, shadows: isWood ? WoodTextStyles.woodShadow : null)),
              ),
              Icon(Icons.chevron_right_rounded, color: isWood ? Colors.white70 : AppTheme.kColorTextSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuGridItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuGridItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_MenuGridItem> createState() => _MenuGridItemState();
}

class _MenuGridItemState extends State<_MenuGridItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isWood = AppTheme.isWoodClassic;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: GlassPanel(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isWood ? null : AppTheme.kColorAccent.withOpacity(0.15),
                    image: isWood ? WoodTextures.icon() : null,
                    borderRadius: BorderRadius.circular(isWood ? 12 : 14),
                    border: isWood ? Border.all(color: WoodColors.border, width: 1.5) : null,
                  ),
                  child: Icon(widget.icon, color: isWood ? Colors.white : AppTheme.kColorAccent, size: isWood ? 24 : 26),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isWood ? Colors.white : AppTheme.kColorTextPrimary, shadows: isWood ? WoodTextStyles.woodShadow : null),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
            child: Center(child: CircularProgressIndicator(color: AppTheme.kColorAccent, strokeWidth: 2)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GlassPanel(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text('No players yet', style: TextStyle(color: AppTheme.kColorTextSecondary))),
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
      case 1: return AppTheme.kColorAccent;
      case 2: return AppTheme.kColorTextSecondary;
      case 3: return AppTheme.kSecondaryColor;
      default: return AppTheme.kColorTextSecondary;
    }
  }

  IconData? get _rankIcon => rank <= 3 ? AppIcons.crown : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: _rankIcon != null
                ? Icon(_rankIcon, color: _rankColor, size: 22)
                : Text('$rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _rankColor), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(player.displayName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.kColorTextPrimary),
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.kColorAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${player.elo}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.kColorAccent)),
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
    final isWood = AppTheme.isWoodClassic;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TournamentsScreen()),
        );
      },
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isLive
                    ? AppTheme.kColorLoss.withOpacity(0.15)
                    : (isWood ? null : AppTheme.kColorAccent.withOpacity(0.15)),
                image: isWood ? WoodTextures.icon() : null,
                borderRadius: BorderRadius.circular(isWood ? 10 : 12),
                border: isWood ? Border.all(
                    color: _isLive ? const Color(0x66CC3333) : WoodColors.border,
                    width: 1.5,
                  ) : null,
              ),
              child: Icon(
                _isLive ? AppIcons.live : AppIcons.tournament,
                color: _isLive ? AppTheme.kColorLoss : (isWood ? Colors.white : AppTheme.kColorAccent),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLive ? 'LIVE NOW' : 'Daily Tournament',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isWood ? Colors.white : AppTheme.kColorTextPrimary, shadows: isWood ? WoodTextStyles.woodShadow : null),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isLive ? 'Ends in: ${_formatDuration(_timeRemaining)}' : 'Starts at $tournamentHour:00',
                    style: TextStyle(fontSize: 13, color: isWood ? Colors.white70 : AppTheme.kColorTextSecondary, shadows: isWood ? WoodTextStyles.woodShadow : null),
                  ),
                ],
              ),
            ),
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: isWood ? null : AppTheme.kColorAccent.withOpacity(0.15),
                image: isWood ? WoodTextures.icon() : null,
                borderRadius: BorderRadius.circular(isWood ? 8 : 10),
                border: isWood ? Border.all(color: WoodColors.border, width: 1.5) : null,
              ),
              child: Icon(Icons.chevron_right_rounded, color: isWood ? Colors.white : AppTheme.kColorAccent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
