

import 'package:chess_park/models/puzzle_model.dart';
import 'package:chess_park/providers/puzzle_provider.dart';
import 'package:chess_park/providers/settings_provider.dart';
import 'package:chess_park/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_park/chess/export.dart';
import 'package:dartchess/dartchess.dart' as dartchess;

class PuzzleScreen extends StatelessWidget {

  final PuzzleModel puzzle;

  const PuzzleScreen({super.key, required this.puzzle});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(

      create: (_) => PuzzleProvider(puzzle),
      child: const PuzzleView(),
    );
  }
}

class PuzzleView extends StatelessWidget {
  const PuzzleView({super.key});

  @override
  Widget build(BuildContext context) {
    final puzzleProvider = context.watch<PuzzleProvider>();
    final settingsProvider = context.watch<SettingsProvider>();


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Puzzle: ${puzzleProvider.puzzle.id}'),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,

        child: SafeArea(
          child: _buildBody(context, puzzleProvider, settingsProvider),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PuzzleProvider provider, SettingsProvider settingsProvider) {

    if (provider.state == PuzzleState.loading) {
      return const Center(child: CircularProgressIndicator());
    }


    if (provider.state == PuzzleState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
              const SizedBox(height: 16),
              const Text("Failed to initialize the puzzle.", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(provider.errorMessage ?? "An unknown error occurred.", textAlign: TextAlign.center,),
              const SizedBox(height: 24),
               ElevatedButton(

                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }


     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // This is the new, updated header section
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Find the best move for ${provider.playerSide == dartchess.Side.white ? "White" : "Black"}.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Rating: ${provider.puzzle.rating}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppTheme.kColorAccent),
          ),
          if (provider.state == PuzzleState.inProgress)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                provider.isPlayerTurn ? "Your move" : "Opponent moving...",
                style: const TextStyle(
                    color: AppTheme.kColorAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    ),
    const SizedBox(height: 24),

    // The rest of the screen layout remains the same
    Expanded(
      child: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          final double boardSize = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;

          final bool canInteract =
              provider.state == PuzzleState.inProgress && provider.isPlayerTurn;
          final dartchess.Side orientation = provider.playerSide;

          final playerSide = canInteract
              ? (orientation == dartchess.Side.white
                  ? PlayerSide.white
                  : PlayerSide.black)
              : PlayerSide.none;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chessboard(
              size: boardSize - 16,
              orientation: orientation,
              fen: provider.chess.fen,
              settings: ChessboardSettings(
                colorScheme: settingsProvider.currentBoardTheme,
                pieceAssets: settingsProvider.currentPieceAssets,
                showValidMoves: true,
                animationDuration: const Duration(milliseconds: 300),
              ),
              game: GameData(
                playerSide: playerSide,
                sideToMove: provider.chess.turn,
                isCheck: provider.chess.isCheck,
                validMoves: provider.validMoves,
                promotionMove: null,
                onPromotionSelection: (role) {},
                onMove: (move, {isDrop}) {
                  if (canInteract) {
                    provider.makeMove(move);
                  }
                },
              ),
            ),
          );
        }),
      ),
    ),
    const SizedBox(height: 24),
    _buildStatus(context, provider),
    const SizedBox(height: 16),
    _buildThemes(context, provider),
  ],
)
    );
  }

  Widget _buildStatus(BuildContext context, PuzzleProvider provider) {
    switch (provider.state) {
      case PuzzleState.solved:
        return Card(
          color: AppTheme.kColorWin,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.black),
                SizedBox(width: 10),
                Text("Puzzle Solved!", style: TextStyle(color: Colors.black, fontSize: 18)),
              ],
            ),
          ),
        );
      case PuzzleState.failed:
        return Card(
          color: Colors.red[800],
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Wrong Move!", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => provider.retryPuzzle(),
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
        );
      case PuzzleState.inProgress:
        return const SizedBox(height: 68);
      default:
        return Container();
    }
  }

  Widget _buildThemes(BuildContext context, PuzzleProvider provider) {
    if (provider.state != PuzzleState.solved) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Themes:", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: provider.puzzle.themes.map((theme) => Chip(
              label: Text(theme),
            backgroundColor: AppTheme.kColorAccent.withAlpha(230),
labelStyle: const TextStyle(color: AppTheme.kColorTextPrimary),
side: BorderSide(color: AppTheme.kColorAccent.withAlpha(230)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}