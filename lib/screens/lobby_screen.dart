import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/providers/puzzle_lobby_provider.dart';
import 'package:chess_park/screens/online_games_screen.dart';
import 'package:chess_park/screens/puzzle_lobby_screen.dart';
import 'package:chess_park/screens/bot_selection_screen.dart';
import 'package:chess_park/screens/puzzle_screen.dart';
import 'package:chess_park/services/puzzle_service.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/widgets/live_top_players_widget.dart';
import 'package:chess_park/widgets/recent_games.dart';
import 'package:chess_park/widgets/user_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final topPadding = MediaQuery.of(context).padding.top + 70;


    return ChangeNotifierProvider(
      create: (_) => PuzzleLobbyProvider(PuzzleService())..loadPuzzles(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(24.0, topPadding, 24.0, 120.0),
        children: [
          if (user != null) UserHeader(user: user),
          const SizedBox(height: 24),
          const _ActionButtonsSection(),
          const SizedBox(height: 24),
          const LiveTopPlayersWidget(),
          const SizedBox(height: 24),
          if (user != null) RecentGames(userId: user.id),
        ],
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
                text: 'Play\nOnline',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const OnlineGamesScreen())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionButton(
                icon: Icons.smart_toy,
                text: 'Play\nComputer',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BotSelectionScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.lightbulb_outline,
                text: 'Puzzles',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PuzzleLobbyScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const _DailyPuzzleButton(),
      ],
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
                style: const TextStyle(
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

    String text = 'Daily Puzzle';
    IconData icon = Icons.calendar_today_outlined;
    VoidCallback? onTap;
    Widget? leadingWidget;

    switch (puzzleProvider.state) {
      case LobbyState.loading:
        text = 'Loading Puzzle...';
        leadingWidget = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.kColorTextPrimary,
          ),
        );
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
          text = 'Puzzle Unavailable';
          icon = Icons.refresh;
          onTap = () => puzzleProvider.refreshPuzzles();
        }
        break;
      case LobbyState.error:
        text = 'Tap to Retry';
        icon = Icons.refresh;
        onTap = () => puzzleProvider.refreshPuzzles();
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leadingWidget ?? Icon(icon, color: AppTheme.kColorTextPrimary),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.kColorTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}