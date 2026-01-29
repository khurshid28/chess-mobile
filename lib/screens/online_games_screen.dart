

import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/providers/lobby_provider.dart';
import 'package:chess_park/screens/game_screen.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/services/game_repository.dart';



class OnlineGamesScreen extends StatelessWidget {
  const OnlineGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final userId = context.watch<AuthProvider>().userModel?.id;
    final gameRepository = context.read<GameRepository>();
    final firestoreService = context.read<FirestoreService>();

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Error: User not found.")));
    }



    return ChangeNotifierProvider(
      create: (_) => LobbyProvider(
        gameRepository: gameRepository,
        firestoreService: firestoreService,
        userId: userId,
      ),

      child: const OnlineGamesView(),
    );
  }
}


class OnlineGamesView extends StatefulWidget {
  const OnlineGamesView({super.key});

  @override
  State<OnlineGamesView> createState() => _OnlineGamesViewState();
}

class _OnlineGamesViewState extends State<OnlineGamesView> {


  LobbyProvider? _lobbyProvider;

  @override
  void initState() {
    super.initState();
    _lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    _lobbyProvider?.addListener(_onLobbyProviderUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _lobbyProvider != null) {
        _handleMatchmakingUpdate(_lobbyProvider!);
      }
    });
  }

  void _onLobbyProviderUpdate() {
    if (mounted && _lobbyProvider != null) {
      _handleMatchmakingUpdate(_lobbyProvider!);
    }
  }

  @override
  void dispose() {
    _lobbyProvider?.removeListener(_onLobbyProviderUpdate);
    super.dispose();
  }

  void _handleMatchmakingUpdate(LobbyProvider lobbyProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (lobbyProvider.matchmakingState) {
        case MatchmakingState.matched:
          final gameId = lobbyProvider.matchedGameId;


          lobbyProvider.acknowledgeMatch();

          if (gameId != null) {

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GameScreen(gameId: gameId)),
            );
          }
          break;
        case MatchmakingState.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(lobbyProvider.errorMessage ?? "Matchmaking failed.")),
          );

          if (lobbyProvider.errorMessage == null || !lobbyProvider.errorMessage!.contains("Failed to cancel")) {
            lobbyProvider.acknowledgeMatch();
          }
          break;
        case MatchmakingState.idle:
        case MatchmakingState.searching:
          break;
      }
    });
  }


  Future<void> _confirmCancelAndPop(LobbyProvider lobbyProvider) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Search?'),
          content: const Text('Are you sure you want to stop searching for a game and go back?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Searching'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Cancel Search'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await lobbyProvider.cancelMatchmaking();

      if (lobbyProvider.matchmakingState == MatchmakingState.idle && mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;
    final lobbyProvider = context.watch<LobbyProvider>();
    final bool canPop = lobbyProvider.matchmakingState != MatchmakingState.searching;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (lobbyProvider.matchmakingState == MatchmakingState.searching) {
          _confirmCancelAndPop(lobbyProvider);
        }
      },
      child: Scaffold(

        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              if (canPop) {
                                Navigator.of(context).pop();
                              } else {
                                _confirmCancelAndPop(lobbyProvider);
                              }
                            },
                          ),
                          Text('Play Online', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _buildQuickPlayContent(context, lobbyProvider, user?.elo ?? 1200),
                    ),
                  ],
                ),
              ),

              if (lobbyProvider.matchmakingState == MatchmakingState.searching)
                _buildSearchingOverlay(context, lobbyProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPlayContent(BuildContext context, LobbyProvider lobbyProvider, int currentElo) {
    final bool isSearching = lobbyProvider.matchmakingState == MatchmakingState.searching;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.leaderboard, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Your Rating: $currentElo',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kColorTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text('Select Time Control', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('We will automatically find an opponent close to your rating (±150 Elo).', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.kColorTextSecondary), textAlign: TextAlign.center,),
          const SizedBox(height: 30),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.5,
            children: [
              _buildTimeButton(context, '1 Minute', 'Bullet', 60, lobbyProvider, isSearching),
              _buildTimeButton(context, '3 Minutes', 'Blitz', 180, lobbyProvider, isSearching),
              _buildTimeButton(context, '5 Minutes', 'Blitz', 300, lobbyProvider, isSearching),
              _buildTimeButton(context, '10 Minutes', 'Rapid', 600, lobbyProvider, isSearching),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context, String label, String type, int timeInSeconds, LobbyProvider lobbyProvider, bool isSearching) {
    final bool isActive = isSearching && lobbyProvider.currentTimeControl == timeInSeconds;
    final theme = Theme.of(context);
    final bool hasCancellationError = lobbyProvider.matchmakingState == MatchmakingState.error &&
                                      lobbyProvider.errorMessage != null &&
                                      lobbyProvider.errorMessage!.contains("Failed to cancel") &&
                                      lobbyProvider.currentTimeControl == timeInSeconds;

    Color backgroundColor = Colors.transparent;
    Color foregroundColor = AppTheme.kColorTextPrimary;

    if (hasCancellationError) {
      backgroundColor = theme.colorScheme.error.withAlpha(230);
      foregroundColor = theme.colorScheme.onErrorContainer;
    } else if (isActive) {
      backgroundColor = theme.colorScheme.primary.withAlpha(230);
      foregroundColor = AppTheme.kColorTextPrimary;
    }

    return GestureDetector(
      onTap: isSearching && !isActive ? null : () {
        if (isActive || hasCancellationError) {
          lobbyProvider.cancelMatchmaking();
        } else {
          lobbyProvider.startMatchmaking(timeInSeconds);
        }
      },
      child: GlassPanel(
        backgroundColor: backgroundColor == Colors.transparent ? null : backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: foregroundColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hasCancellationError ? '(Retry Cancel)' : (isActive ? '(Tap to Stop)' : type),
              style: TextStyle(fontSize: 14, color: foregroundColor.withAlpha(230)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingOverlay(BuildContext context, LobbyProvider lobbyProvider) {

    return Container(
      color: Colors.black.withAlpha(230),
      child: Center(

        child: GlassPanel(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.kColorAccent),
              const SizedBox(height: 24),
              const Text("Searching for opponent...", style: TextStyle(fontSize: 18, color: AppTheme.kColorTextPrimary)),
              const SizedBox(height: 8),
              Text("Time Control: ${(lobbyProvider.currentTimeControl ?? 0) ~/ 60} min", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => lobbyProvider.cancelMatchmaking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text("Cancel Search"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}