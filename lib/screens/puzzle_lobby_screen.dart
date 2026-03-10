
import 'package:chess_park/providers/puzzle_progress_provider.dart';
import 'package:chess_park/screens/puzzle_screen.dart';
import 'package:chess_park/services/puzzle_service.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/theme/app_icons.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PuzzleLobbyScreen extends StatelessWidget {
  const PuzzleLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PuzzleProgressProvider(PuzzleService())..initialize(),
      child: const PuzzleLobbyView(),
    );
  }
}

class PuzzleLobbyView extends StatelessWidget {
  const PuzzleLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PuzzleProgressProvider>();

    return Scaffold(
      backgroundColor: AppTheme.kBgColor2,
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(AppIcons.back, color: AppTheme.kColorTextPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text('Puzzles', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    if (provider.state != PuzzleLoadState.loading)
                      IconButton(
                        icon: Icon(AppIcons.refresh, color: AppTheme.kColorTextPrimary),
                        onPressed: () => provider.refreshPuzzles(),
                      ),
                  ],
                ),
              ),
              
              // Progress info
              if (provider.state == PuzzleLoadState.loaded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.kColorAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(AppIcons.puzzles, color: AppTheme.kColorAccent, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${provider.solvedPuzzleIds.length}/${provider.puzzles.length}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${provider.unlockedCount} unlocked',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.kColorTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Progress indicator
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    value: provider.puzzles.isEmpty 
                                        ? 0 
                                        : provider.solvedPuzzleIds.length / provider.puzzles.length,
                                    strokeWidth: 5,
                                    backgroundColor: AppTheme.containerBgColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.kColorAccent),
                                  ),
                                ),
                                Text(
                                  '${((provider.solvedPuzzleIds.length / (provider.puzzles.isEmpty ? 1 : provider.puzzles.length)) * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Puzzle grid
              Expanded(
                child: _buildBody(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PuzzleProgressProvider provider) {
    switch (provider.state) {
      case PuzzleLoadState.initial:
      case PuzzleLoadState.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.kColorAccent),
              const SizedBox(height: 16),
              Text(
                'Loading puzzles... ${provider.loadingProgress}/${PuzzleProgressProvider.totalPuzzleCount}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.kColorTextSecondary),
              ),
            ],
          ),
        );
      case PuzzleLoadState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    const Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage ?? 'Please try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.kColorTextSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => provider.refreshPuzzles(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case PuzzleLoadState.loaded:
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: provider.puzzles.length,
                itemBuilder: (context, index) {
                  return _buildPuzzleTile(context, provider, index);
                },
              ),
            ),
            // Load More Button
            if (provider.hasMore)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoadingMore ? null : () => provider.loadMorePuzzles(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.kColorAccent,
                      foregroundColor: AppTheme.kButtonTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoadingMore
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.kButtonTextColor,
                            ),
                          )
                        : const Text(
                            'Load More Puzzles',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
          ],
        );
    }
  }

  Widget _buildPuzzleTile(BuildContext context, PuzzleProgressProvider provider, int index) {
    final puzzle = provider.puzzles[index];
    final isUnlocked = provider.isPuzzleUnlocked(index);
    final isSolved = provider.isPuzzleSolved(index);
    final isDaily = index == 0;
    
    // Icon for each puzzle
    IconData puzzleIcon;
    Color iconColor;
    Color bgColor;
    
    if (isSolved) {
      puzzleIcon = Icons.check_circle;
      iconColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.15);
    } else if (isUnlocked) {
      if (isDaily) {
        puzzleIcon = Icons.today;
        iconColor = Colors.amber;
        bgColor = Colors.amber.withOpacity(0.15);
      } else {
        puzzleIcon = Icons.extension;
        iconColor = AppTheme.kColorAccent;
        bgColor = AppTheme.kColorAccent.withOpacity(0.15);
      }
    } else {
      puzzleIcon = Icons.lock;
      iconColor = Colors.grey;
      bgColor = Colors.grey.withOpacity(0.1);
    }
    
    return GestureDetector(
      onTap: isUnlocked ? () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PuzzleScreen(
            puzzle: puzzle,
            puzzleIndex: index,
            onSolved: () {
              provider.markPuzzleSolved(puzzle.id, index);
            },
          ),
        ));
      } : () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solve puzzle #$index first'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSolved 
                ? Colors.green.withOpacity(0.5) 
                : (isUnlocked ? AppTheme.kColorAccent.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
            width: 2,
          ),
          boxShadow: isUnlocked && !isSolved ? [
            BoxShadow(
              color: AppTheme.kColorAccent.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            // Puzzle number
            Positioned(
              top: 4,
              left: 6,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? AppTheme.kColorTextPrimary.withOpacity(0.9) : Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
            // Icon
            Center(
              child: Icon(
                puzzleIcon,
                size: 28,
                color: iconColor,
              ),
            ),
            // Rating badge for unlocked puzzles
            if (isUnlocked && !isSolved)
              Positioned(
                bottom: 4,
                right: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${puzzle.rating}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}