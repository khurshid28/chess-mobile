
import 'dart:async';
import 'dart:ui';
import 'package:chess_park/providers/connectivity_provider.dart';
import 'package:chess_park/providers/server_time_provider.dart';

import 'package:chess_park/providers/settings_provider.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:chess_park/models/game_model.dart';
import 'package:chess_park/providers/game_provider.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/chess/export.dart';
import 'package:dartchess/dartchess.dart' as dartchess;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chess_park/services/game_repository.dart';
import 'package:chess_park/screens/game_detail_screen.dart';


class GameScreen extends StatelessWidget {
  final String? gameId;
  final bool isBotGame;
  
  const GameScreen({
    super.key,
    this.gameId,
    this.isBotGame = false,
  });

  @override
  Widget build(BuildContext context) {
    // If it's a bot game, use BotGameProvider which is already created
    if (isBotGame) {
      return GameView(gameId: null, isBotGame: true);
    }

    // For online games, create GameProvider as before
    final userId = context.read<AuthProvider>().userModel?.id;
    final gameRepository = context.read<GameRepository>();
    final connectivityProvider = context.read<ConnectivityProvider>();


    return ChangeNotifierProvider(
      create: (_) => GameProvider(

        currentUserId: userId,
        gameRepository: gameRepository,
        connectivityProvider: connectivityProvider,
      ),
      child: GameView(gameId: gameId!, isBotGame: false),
    );
  }
}

class GameView extends StatefulWidget {
  final String? gameId;
  final bool isBotGame;
  
  const GameView({
    super.key,
    required this.gameId,
    required this.isBotGame,
  });

  @override
  State<GameView> createState() => _GameViewState();
}


class _GameViewState extends State<GameView> with WidgetsBindingObserver {

  StreamSubscription? _gameEventListener;
  bool _isNavigating = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupGameListeners();
        if (widget.gameId != null) {
          context.read<GameProvider>().listenToGame(widget.gameId!);
        }
        final currentState = WidgetsBinding.instance.lifecycleState;
        context.read<GameProvider>().setAppForegroundState(currentState == AppLifecycleState.resumed);
      }
    });
  }

  void _setupGameListeners() {
    final gameProvider = context.read<GameProvider>();
    _gameEventListener = gameProvider.eventStream.listen((event) {

      if (!mounted) return;

      switch (event.type) {
        case GameEventType.gameOver:

          if (gameProvider.gameModel != null) {
              _showGameOverDialog(context, gameProvider.gameModel!);
          }
          break;
        case GameEventType.rematchAccepted:
          final nextGameId = gameProvider.gameModel?.nextGameId;
          if (nextGameId != null) {
            _navigateToRematch(nextGameId);
          }
          break;
        case GameEventType.opponentDisconnected:
        case GameEventType.opponentReconnected:
          break;
        case GameEventType.moveError:

          if (!_isDialogShowing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(event.message ?? "Move failed or rejected by server.")),
            );
          }
          break;
        case GameEventType.actionError:
          if (!_isDialogShowing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(event.message ?? "Action failed.")),
            );
          }
          break;
      }
    });
  }

  void _navigateToRematch(String nextGameId) {
    if (_isNavigating) return;
    _isNavigating = true;


    if (_isDialogShowing) {

       if (Navigator.canPop(context)) {
         Navigator.pop(context);
       }
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => GameScreen(gameId: nextGameId)),
      (Route<dynamic> route) => route.isFirst,
    );
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    final gameProvider = context.read<GameProvider>();

    if (state == AppLifecycleState.resumed) {
      gameProvider.setAppForegroundState(true);
    } else {
      gameProvider.setAppForegroundState(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final gameProvider = context.watch<GameProvider>();

    final settingsProvider = context.watch<SettingsProvider>();
    final serverTimeProvider = context.watch<ServerTimeProvider>();


    if (gameProvider.gameModel == null) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: const Center(child: CircularProgressIndicator(color: AppTheme.kColorAccent,))
        ),
      );
    }

    final game = gameProvider.gameModel!;
    final userId = gameProvider.currentUserId;
    final isParticipant = gameProvider.isParticipant;


    final dartchess.Side playerOrientation;
    if (userId == game.playerWhiteId) {
      playerOrientation = dartchess.Side.white;
    } else if (userId == game.playerBlackId) {
      playerOrientation = dartchess.Side.black;
    } else {

      playerOrientation = dartchess.Side.white;
    }


    final String? myColorName = isParticipant ? (playerOrientation == dartchess.Side.white ? 'white' : 'black') : null;

    final hasDrawOffer = isParticipant && game.drawOfferFrom != null && game.drawOfferFrom != myColorName;

    Widget topPlayerWidget;
    Widget bottomPlayerWidget;
    final whitePlayerDisplay = PlayerDisplayData(
      name: game.playerWhiteName,
      elo: game.playerWhiteElo,
      countryCode: game.playerWhiteCountryCode,
      imageUrl: game.playerWhiteImage,
    );

    final blackPlayerDisplay = PlayerDisplayData(
      name: game.playerBlackName,
      elo: game.playerBlackElo,
      countryCode: game.playerBlackCountryCode,
      imageUrl: game.playerBlackImage,
    );
    final isGameInProgress = game.status == GameStatus.inprogress;
    final isClockPaused = game.pendingPromotion != null;



    if (playerOrientation == dartchess.Side.white) {
      topPlayerWidget = _buildPlayerInfo(blackPlayerDisplay, game.blackTimeLeft, isGameInProgress && game.turn == 'b' && !isClockPaused, game.lastMoveTimestamp, serverTimeProvider);
      bottomPlayerWidget = _buildPlayerInfo(whitePlayerDisplay, game.whiteTimeLeft, isGameInProgress && game.turn == 'w' && !isClockPaused, game.lastMoveTimestamp, serverTimeProvider);
    } else {
      topPlayerWidget = _buildPlayerInfo(whitePlayerDisplay, game.whiteTimeLeft, isGameInProgress && game.turn == 'w' && !isClockPaused, game.lastMoveTimestamp, serverTimeProvider);
      bottomPlayerWidget = _buildPlayerInfo(blackPlayerDisplay, game.blackTimeLeft, isGameInProgress && game.turn == 'b' && !isClockPaused, game.lastMoveTimestamp, serverTimeProvider);
    }


    final bool isOpponentDisconnected = isParticipant && ((playerOrientation == dartchess.Side.white && game.playerBlackStatus == 'disconnected') ||
                                (playerOrientation == dartchess.Side.black && game.playerWhiteStatus == 'disconnected'));

    final opponentDisconnectedAt = isParticipant ? (playerOrientation == dartchess.Side.white ? game.playerBlackDisconnectedAt : game.playerWhiteDisconnectedAt) : null;


    String getAppBarTitle() {
      if (game.status == GameStatus.inprogress) {
        return isParticipant ? 'Game in Progress' : 'Spectating Live Game';
      } else if (game.status == GameStatus.waiting) {
        return 'Waiting for Opponent';
      } else {
        return 'Game Over';
      }
    }


    return PopScope(

      canPop: !isParticipant || gameProvider.isGameOver,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;


        if (isParticipant && !gameProvider.isGameOver) {
          _showResignConfirmationDialog(context);
        }
      },
      child: Scaffold(

        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: SafeArea(
            child: Stack(
              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      children: [
                        _buildAppBar(context, getAppBarTitle()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: topPlayerWidget,
                        ),
                      ],
                    ),


                    LayoutBuilder(builder: (context, constraints) {

                      final bool isMyTurn = isParticipant && ((gameProvider.chess.turn == dartchess.Side.white && userId == game.playerWhiteId) ||
                                  (gameProvider.chess.turn == dartchess.Side.black && userId == game.playerBlackId) ||
                                  (gameProvider.localPromotionMove != null));

                      final bool canInteract = isParticipant && game.status == GameStatus.inprogress && !gameProvider.isGameOver;

                      final bool canPremove = isParticipant && settingsProvider.enablePremove && !isMyTurn;

                      PlayerSide playerSide = PlayerSide.none;
                      if (isParticipant && canInteract && (isMyTurn || canPremove)) {
                          playerSide = (playerOrientation == dartchess.Side.white ? PlayerSide.white : PlayerSide.black);
                      }

                      Premovable? premovableConfig;

                      if (isParticipant && settingsProvider.enablePremove && canInteract) {
                        premovableConfig = (
                          premove: gameProvider.currentPremove,
                          onSetPremove: (move) {
                            context.read<GameProvider>().setPremove(move);
                          },
                        );
                      }


                      final boardSize = constraints.maxWidth;

                      return Chessboard(
                        size: boardSize,
                        orientation: playerOrientation,
                        fen: gameProvider.chess.fen,
                        settings: ChessboardSettings(
                          colorScheme: settingsProvider.currentBoardTheme,
                          pieceAssets: settingsProvider.currentPieceAssets,
                          showValidMoves: true,
                          animationDuration: const Duration(milliseconds: 200),
                        ),
                        game: GameData(
                          playerSide: playerSide,
                          sideToMove: gameProvider.chess.turn,
                          isCheck: gameProvider.chess.isCheck,
                          validMoves: gameProvider.validMoves,
                          promotionMove: gameProvider.localPromotionMove,

                          premovable: premovableConfig,
                          onMove: (move, {isDrop}) {
                            if (canInteract && isMyTurn) {
                                context.read<GameProvider>().makeMove(move);
                            }
                          },
                          onPromotionSelection: (role) {
                            if (canInteract && isMyTurn) {
                              context.read<GameProvider>().selectPromotion(role);
                            }
                          },
                        ),
                      );
                    }),


                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: bottomPlayerWidget,
                        ),


                        if (isParticipant && !gameProvider.isGameOver)
                          _buildActionButtons(context, gameProvider, myColorName!, hasDrawOffer),


                        if (!isParticipant)
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                              child: Text('You are spectating this game.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.kColorTextSecondary), textAlign: TextAlign.center,),
                          ),


                         if (isParticipant && gameProvider.isGameOver) const SizedBox(height: 60),
                      ],
                    ),
                  ],
                ),


                if (isParticipant && isOpponentDisconnected && !gameProvider.isGameOver && opponentDisconnectedAt != null)
                  DisconnectionOverlay(
                    serverTimeProvider: serverTimeProvider,
                    disconnectedAt: opponentDisconnectedAt.toDate(),
                    onClaimAbandonment: () => gameProvider.claimAbandonmentVictory(),
                  ),


                if (isParticipant && gameProvider.isClaimPending)
                  _buildOverlay(
                    child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppTheme.kColorAccent),
                          SizedBox(height: 20),
                          Text("Claiming victory...", style: TextStyle(fontSize: 18, color: AppTheme.kColorTextPrimary)),
                        ],
                      ),
                  ),


                if (isParticipant && game.status == GameStatus.waiting)
                   _buildOverlay(
                     child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppTheme.kColorAccent),
                          SizedBox(height: 20),
                          Text("Waiting for opponent...", style: TextStyle(fontSize: 18, color: AppTheme.kColorTextPrimary)),
                        ],
                      ),
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildOverlay({required Widget child}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
    color: Colors.black.withAlpha(128),
        child: Center(
          child: GlassPanel(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }


  Widget _buildAppBar(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.kColorTextPrimary),
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              ),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
    );
  }



  Widget _buildPlayerInfo(PlayerDisplayData playerDisplay, int timeLeft, bool isActive, Timestamp? lastMoveTimestamp, ServerTimeProvider serverTimeProvider) {

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),

      backgroundColor: isActive ? AppTheme.kColorAccent.withAlpha(51) : null,
      child: Row(
        children: [

          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            backgroundImage: playerDisplay.imageUrl != null
                ? CachedNetworkImageProvider(playerDisplay.imageUrl!)
                : null,
            child: playerDisplay.imageUrl == null
                ? const Icon(Icons.person_outline, size: 20, color: AppTheme.kColorTextSecondary)
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        playerDisplay.name ?? "Waiting...",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.kColorTextPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (playerDisplay.countryCode != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: ClipRRect(
                           borderRadius: BorderRadius.circular(3),
                          child: CountryFlag.fromCountryCode(
                            playerDisplay.countryCode!,
                            height: 14,
                            width: 21,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${playerDisplay.elo ?? '...'}",

                  style: TextStyle(color: AppTheme.kColorTextSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          ClockWidget(
            initialTime: timeLeft,
            lastMoveTimestamp: lastMoveTimestamp,
            isActive: isActive,
            serverTimeProvider: serverTimeProvider,
            onTimeout: () {
              if (context.read<GameProvider>().isParticipant) {
                context.read<GameProvider>().claimTimeoutVictory();
              }
            },
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons(BuildContext context, GameProvider gameProvider, String myColorName, bool hasDrawOffer) {
    if (gameProvider.gameModel?.status == GameStatus.waiting) {
      return const SizedBox(height: 60);
    }


    if (hasDrawOffer) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              ElevatedButton.icon(
                onPressed: () => gameProvider.acceptDraw(),
                icon: const Icon(Icons.check),
                label: const Text('Accept Draw'),

              ),

              ElevatedButton.icon(
                onPressed: () => gameProvider.declineDraw(),
                icon: const Icon(Icons.close),
                label: const Text('Decline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kColorLoss,
                  foregroundColor: AppTheme.kColorTextPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),

      child: ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text("Options"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.kBgColor1,
            foregroundColor: AppTheme.kColorTextPrimary,
          ),
          onPressed: () => _showGameOptionsMenu(context, gameProvider, myColorName),
      ),
    );
  }


  void _showGameOptionsMenu(BuildContext context, GameProvider gameProvider, String myColorName) {
    final bool drawOffered = gameProvider.gameModel?.drawOfferFrom == myColorName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return BackdropFilter(
           filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(

             decoration: BoxDecoration(
              color: AppTheme.kBgColor1.withAlpha(230),
               borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("Game Options", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.kColorTextPrimary)),
                const SizedBox(height: 20),


                ListTile(
                  leading: const Icon(Icons.handshake_outlined, color: AppTheme.kColorAccent),
                  title: Text(drawOffered ? 'Draw Offered (Waiting)' : 'Offer Draw', style: const TextStyle(color: AppTheme.kColorTextPrimary)),
                  enabled: !drawOffered,
                  onTap: () {
                    Navigator.pop(modalContext);
                    if (!drawOffered) {
                      gameProvider.offerDraw();
                    }
                  },
                ),


                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: AppTheme.kColorLoss),
                  title: const Text('Resign Game', style: TextStyle(color: AppTheme.kColorLoss)),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _showResignConfirmationDialog(context);
                  },
                ),
                 const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }



  void _showGameOverDialog(BuildContext gameViewContext, GameModel initialGame) {

    if (_isDialogShowing) return;
    _isDialogShowing = true;

    final gameProvider = gameViewContext.read<GameProvider>();

    final userId = gameProvider.currentUserId;
    final isParticipant = gameProvider.isParticipant;


    final String? myColorName = isParticipant ? (initialGame.playerWhiteId == userId ? 'white' : (initialGame.playerBlackId == userId ? 'black' : null)) : null;

    String title;
    String content;
    final outcome = initialGame.outcome?.replaceAll('_', ' ') ?? 'unknown';


    if (initialGame.winner == null || initialGame.winner == 'draw') {
      title = 'Game Drawn';
      content = 'The game is a draw by $outcome.';
    } else {
        if (isParticipant) {

          if (initialGame.winner == myColorName) {
            title = 'You Won!';
            content = 'You won the game by $outcome.';
          } else {
            title = 'You Lost';
            content = 'You lost the game by $outcome.';
          }
        } else {

            title = initialGame.winner == 'white' ? 'White Wins' : 'Black Wins';
            content = '$title by $outcome.';
        }
    }


    showDialog(
      context: gameViewContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider.value(
          value: gameProvider,
          child: Consumer<GameProvider>(
            builder: (consumerContext, provider, child) {
              final latestGame = provider.gameModel;
              if (latestGame == null) {
                return const AlertDialog(content: Center(child: CircularProgressIndicator(color: AppTheme.kColorAccent)));
              }

              Widget? rematchButton;


              final bool isPending = provider.isRematchPending;

              if (isParticipant) {
                  final offerFromId = latestGame.rematchOfferFrom;

                  if (offerFromId != null && offerFromId != userId) {

                    rematchButton = ElevatedButton(
                      onPressed: isPending ? null : () async {
                        try {
                          await provider.acceptRematch();

                        } catch (e) {
                          if (consumerContext.mounted) {
                            ScaffoldMessenger.of(consumerContext).showSnackBar(
                              SnackBar(content: Text("$e")),
                            );
                          }
                        }
                      },
                      child: isPending

                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.black,))
                          : const Text('Accept Rematch'),
                    );
                  } else if (offerFromId == userId) {

                    rematchButton = const ElevatedButton(
                      onPressed: null,
                      child: Text('Rematch Offered'),
                    );
                  } else {

                    rematchButton = TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppTheme.kColorAccent),
                      onPressed: isPending ? null : () {
                        provider.offerRematch();
                      },

                      child: isPending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: AppTheme.kColorAccent,))
                          : const Text('Rematch'),
                    );
                  }
              }

              return AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  // View Game button
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: AppTheme.kColorAccent),
                    child: const Text('View Game'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.push(
                        gameViewContext,
                        MaterialPageRoute(
                          builder: (context) => GameDetailScreen(
                            game: latestGame,
                            currentUserId: userId ?? '',
                          ),
                        ),
                      );
                    },
                  ),

                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: AppTheme.kColorTextSecondary),
                    child: const Text('Back to Lobby'),
                    onPressed: () {

                      if (_isNavigating) return;

                      Navigator.of(dialogContext).pop();
                      if (Navigator.of(gameViewContext).canPop()) {
                         Navigator.of(gameViewContext).pop();
                      }
                    },
                  ),

                  if (rematchButton != null) rematchButton,
                ],
              );
            },
          ),
        );
      },
    ).then((_) => _isDialogShowing = false);
  }



  void _showResignConfirmationDialog(BuildContext context) {
    final gameStatus = context.read<GameProvider>().gameModel?.status;
    final isWaiting = gameStatus == GameStatus.waiting;


    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isWaiting ? 'Abort Game?' : 'Resign Game?'),
          content: Text(isWaiting ? 'Are you sure you want to cancel the game request?' : 'If you go back, you will resign the game. Are you sure?'),
          actions: <Widget>[

            TextButton(

              style: TextButton.styleFrom(foregroundColor: AppTheme.kColorAccent),
              child: Text(isWaiting ? 'Continue Waiting' : 'Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),

            TextButton(

              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(isWaiting ? 'Abort' : 'Resign'),
              onPressed: () {
                context.read<GameProvider>().resign();
                Navigator.of(dialogContext).pop();

                if (isWaiting) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && Navigator.of(context).canPop()) {
                       Navigator.of(context).pop();
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
class PlayerDisplayData {
  final String? name;
  final int? elo;
  final String? countryCode;
  final String? imageUrl;

  PlayerDisplayData({this.name, this.elo, this.countryCode, this.imageUrl});
}


class ClockWidget extends StatefulWidget {

  final int initialTime;
  final Timestamp? lastMoveTimestamp;
  final bool isActive;
  final VoidCallback? onTimeout;
  final ServerTimeProvider serverTimeProvider;

  const ClockWidget({
    super.key,
    required this.initialTime,
    required this.isActive,
    this.lastMoveTimestamp,
    this.onTimeout,
    required this.serverTimeProvider,
  });

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {

  Timer? _timer;
  int _displayTime = 0;
  bool _timeoutReported = false;

  @override
  void initState() {
    super.initState();
    _displayTime = _calculateDisplayTime();
    _startOrStopTimer();
  }

  @override
  void didUpdateWidget(ClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialTime != oldWidget.initialTime ||
        widget.lastMoveTimestamp != oldWidget.lastMoveTimestamp ||
        widget.isActive != oldWidget.isActive) {

        if (widget.initialTime != oldWidget.initialTime) {
          _timeoutReported = false;
        }

        final newTime = _calculateDisplayTime();
        if (newTime != _displayTime) {
           _displayTime = newTime;
           _checkTimeout(_displayTime);
        }

        if (widget.isActive != oldWidget.isActive) {
          _startOrStopTimer();
        }
    }
  }

  void _startOrStopTimer() {
    _timer?.cancel();
    if (widget.isActive) {
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _tick();
      });
    }
  }

  void _tick() {
    final newTime = _calculateDisplayTime();
    if (newTime != _displayTime) {
      if (mounted) {
        setState(() {
          _displayTime = newTime;
        });
      }
    }
    _checkTimeout(newTime);
  }

  int _calculateDisplayTime() {
    int calculatedTime = widget.initialTime;
    if (widget.isActive && widget.lastMoveTimestamp != null) {
      final DateTime now = widget.serverTimeProvider.serverNow;
      final DateTime startTime = widget.lastMoveTimestamp!.toDate();
      final Duration elapsed = now.difference(startTime);
      calculatedTime = widget.initialTime - elapsed.inSeconds;
    }

    if (calculatedTime < 0) {
      calculatedTime = 0;
    }
    return calculatedTime;
  }

  void _checkTimeout(int currentTime) {
     if (currentTime == 0 && widget.isActive && !_timeoutReported) {
        _timer?.cancel();
        _timeoutReported = true;
        widget.onTimeout?.call();
      }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {

    final Color iconColor = widget.isActive ? AppTheme.kColorAccent : AppTheme.kColorTextSecondary;
    final Color textColor = widget.isActive ? AppTheme.kColorTextPrimary : AppTheme.kColorTextSecondary;


    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(_displayTime),

          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
          ),
        ),
      ],
    );
  }
}


class DisconnectionOverlay extends StatefulWidget {

  final DateTime disconnectedAt;
  final VoidCallback onClaimAbandonment;
  final ServerTimeProvider serverTimeProvider;
  final int gracePeriodSeconds = 30;

  const DisconnectionOverlay({
    super.key,
    required this.disconnectedAt,
    required this.onClaimAbandonment,
    required this.serverTimeProvider,
  });

  @override
  State<DisconnectionOverlay> createState() => _DisconnectionOverlayState();
}
class _DisconnectionOverlayState extends State<DisconnectionOverlay> {

  Timer? _timer;
  int _secondsRemaining = 0;
  bool _canClaim = false;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _updateCountdownValues();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _tick() {
    _updateCountdownValues();
    if (mounted) {
      setState(() {});
    }
  }

  void _updateCountdownValues() {
    final now = widget.serverTimeProvider.serverNow;
    final elapsed = now.difference(widget.disconnectedAt).inSeconds;
    final remaining = widget.gracePeriodSeconds - elapsed;

    if (remaining <= 0) {
      _secondsRemaining = 0;
      _canClaim = true;
    } else {
      _secondsRemaining = remaining;
      _canClaim = false;
    }
  }

  void _handleClaim() {
    if (_isClaiming) return;
    setState(() {
      _isClaiming = true;
    });
    widget.onClaimAbandonment();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withAlpha(179),
        child: Center(

          child: GlassPanel(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Opponent Disconnected', style: TextStyle(fontSize: 24, color: Colors.white)),
                const SizedBox(height: 20),
                if (_isClaiming) ...[
                   const Text('Claiming victory...', style: TextStyle(fontSize: 16, color: AppTheme.kColorTextSecondary)),
                   const SizedBox(height: 10),
                   const CircularProgressIndicator(color: AppTheme.kColorAccent),
                ]
                else if (!_canClaim) ...[
                   const Text('Claim victory in:', style: TextStyle(fontSize: 16, color: AppTheme.kColorTextSecondary)),

                   Text('$_secondsRemaining', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
                ] else ...[
                   const Text('Opponent failed to reconnect.', style: TextStyle(fontSize: 16, color: AppTheme.kColorTextSecondary)),
                   const SizedBox(height: 20),

                   ElevatedButton(
                     onPressed: _handleClaim,
                     child: const Text("Claim Victory"),
                   ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}