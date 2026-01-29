
import 'package:chess_park/models/puzzle_model.dart';
import 'package:chess_park/providers/puzzle_lobby_provider.dart';
import 'package:chess_park/screens/puzzle_screen.dart';
import 'package:chess_park/services/puzzle_service.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PuzzleLobbyScreen extends StatelessWidget {
  const PuzzleLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => PuzzleLobbyProvider(PuzzleService())..loadPuzzles(),
      child: const PuzzleLobbyView(),
    );
  }
}

class PuzzleLobbyView extends StatelessWidget {
  const PuzzleLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final lobbyProvider = context.watch<PuzzleLobbyProvider>();

    return Scaffold(

       body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [

               Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.kColorTextPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text('Puzzles', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.kColorTextPrimary),
                    onPressed: () => lobbyProvider.refreshPuzzles(),
                  ),
                ],
              ),

              Expanded(
                child: _buildBody(context, lobbyProvider),
              ),
            ],
          ),
        ),
       ),
    );
  }

  Widget _buildBody(BuildContext context, PuzzleLobbyProvider provider) {
    switch (provider.state) {
      case LobbyState.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.kColorAccent));
      case LobbyState.error:

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: GlassPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.kColorLoss, size: 48),
                  const SizedBox(height: 16),
                  const Text("Failed to load puzzles.", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(provider.errorMessage ?? "Please try again.", textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      case LobbyState.loaded:

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: provider.puzzles.length,
          itemBuilder: (context, index) {
            final puzzle = provider.puzzles[index];
            final isDaily = index == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: PuzzleTile(puzzle: puzzle, isDaily: isDaily),
            );
          },
        );
    }
  }
}

class PuzzleTile extends StatelessWidget {
  final PuzzleModel puzzle;
  final bool isDaily;

  const PuzzleTile({super.key, required this.puzzle, this.isDaily = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(

      backgroundColor: isDaily ? theme.colorScheme.primary.withAlpha(230) : null,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: Icon(isDaily ? Icons.today : Icons.extension, size: 30, color: AppTheme.kColorTextPrimary),
        title: Text(
          isDaily ? 'Daily Challenge' : 'Featured Puzzle #${puzzle.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.kColorTextPrimary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Rating: ${puzzle.rating}\nThemes: ${puzzle.themes.take(2).join(", ")}${puzzle.themes.length > 2 ? '...' : ''}', style: const TextStyle(color: AppTheme.kColorTextSecondary)),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: AppTheme.kColorTextSecondary),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PuzzleScreen(puzzle: puzzle),
          ));
        },
      ),
    );
  }
}