import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/providers/puzzle_lobby_provider.dart';
import 'package:chess_park/screens/online_games_screen.dart';
import 'package:chess_park/screens/puzzle_lobby_screen.dart';
import 'package:chess_park/screens/bot_selection_screen.dart';
import 'package:chess_park/screens/puzzle_screen.dart';
import 'package:chess_park/screens/invite_friends_screen.dart';
import 'package:chess_park/services/puzzle_service.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/widgets/live_top_players_widget.dart';
import 'package:chess_park/widgets/user_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LobbyScreen extends StatelessWidget {
  final VoidCallback? onProfileTap;
  
  const LobbyScreen({super.key, this.onProfileTap});

  Future<void> _refreshData(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.refreshUser();
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final topPadding = MediaQuery.of(context).padding.top + 70;


    return RefreshIndicator(
      onRefresh: () => _refreshData(context),
      color: AppTheme.kColorAccent,
      backgroundColor: Colors.grey[900],
      child: ChangeNotifierProvider(
        create: (_) => PuzzleLobbyProvider(PuzzleService())..loadPuzzles(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.0, topPadding, 24.0, 120.0),
          children: [
            if (user != null) UserHeader(user: user, onTap: onProfileTap),
            const SizedBox(height: 24),
            const _ActionButtonsSection(),
            const SizedBox(height: 24),
            const LiveTopPlayersWidget(),
          ],
        ),
      ),
    );
  }
}


class _ActionButtonsSection extends StatelessWidget {
  const _ActionButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.public,
                text: 'Online\nGame',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const OnlineGamesScreen())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionButton(
                icon: Icons.smart_toy,
                text: 'Play\nBot',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BotSelectionScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Puzzles section - two buttons in one row
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.extension,
                text: 'Daily\nPuzzles',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PuzzleLobbyScreen())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: const _DailyPuzzleButton(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Invite friends button
        _InviteFriendsButton(),
      ],
    );
  }
}

class _InviteFriendsButton extends StatelessWidget {
  const _InviteFriendsButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const InviteFriendsScreen(),
        ));
      },
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.kColorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Play with your friends',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.kColorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.kColorTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GlassPanel(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.kColorTextPrimary, size: 48),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.kColorTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _DailyPuzzleButton extends StatelessWidget {
  const _DailyPuzzleButton();

  @override
  Widget build(BuildContext context) {
    final puzzleProvider = context.watch<PuzzleLobbyProvider>();

    String text = 'Daily\nPuzzle';
    IconData icon = Icons.calendar_today_outlined;
    VoidCallback? onTap;
    bool isLoading = false;

    switch (puzzleProvider.state) {
      case LobbyState.loading:
        text = 'Loading...';
        isLoading = true;
        onTap = null;
        break;
      case LobbyState.loaded:
        if (puzzleProvider.puzzles.isNotEmpty) {
          final dailyPuzzle = puzzleProvider.puzzles.first;
          onTap = () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PuzzleScreen(puzzle: dailyPuzzle),
            ));
          };
        } else {
          text = 'Tap to\nRetry';
          icon = Icons.refresh;
          onTap = () => puzzleProvider.refreshPuzzles();
        }
        break;
      case LobbyState.error:
        text = 'Tap to\nRetry';
        icon = Icons.refresh;
        onTap = () => puzzleProvider.refreshPuzzles();
        break;
    }

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GlassPanel(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              else
                Icon(icon, color: AppTheme.kColorTextPrimary, size: 48),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.kColorTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}