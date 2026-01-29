
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:chess_park/models/game_model.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/widgets/game_history_tile.dart';
import 'package:chess_park/screens/game_history_screen.dart';

class RecentGames extends StatelessWidget {
  final String userId;
  const RecentGames({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameModel>>(
      future: FirestoreService().getUserGames(userId, limit: 5),
      builder: (context, snapshot) {


         if (snapshot.connectionState == ConnectionState.waiting) {
           return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final games = snapshot.data!;


        return GlassPanel(

          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: games.length,
                separatorBuilder: (context, index) => Divider(color: Colors.white.withAlpha(50), height: 1),
                itemBuilder: (context, index) {

                  return GameHistoryTile(game: games[index], currentUserId: userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => GameHistoryScreen(userId: userId),
          ));
      },
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Recent Games',
              style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.kColorTextPrimary,
                  fontWeight: FontWeight.bold),
            ),
          ),

          Icon(Icons.arrow_forward_ios, color: AppTheme.kColorTextSecondary, size: 16),
        ],
      ),
    );
  }
}