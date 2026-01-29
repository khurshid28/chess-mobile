
import 'package:chess_park/models/game_model.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/game_history_tile.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';

class GameHistoryScreen extends StatelessWidget {
  final String userId;
  const GameHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: _GameHistoryList(userId: userId),
        ),
      ),
    );
  }
}


class _GameHistoryList extends StatelessWidget {
  const _GameHistoryList({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameModel>>(
      future: FirestoreService().getUserGames(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.kColorAccent),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No completed games found.',
              style: TextStyle(color: AppTheme.kColorTextSecondary),
            ),
          );
        }

        final games = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: games.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.white.withAlpha(230), height: 1),
              itemBuilder: (context, index) {
                return GameHistoryTile(
                  game: games[index],
                  currentUserId: userId,
                );
              },
            ),
          ),
        );
      },
    );
  }
}