
import 'package:chess_park/providers/live_game_provider.dart';
import 'package:chess_park/screens/game_screen.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_flags/country_flags.dart';

class LiveTopPlayersWidget extends StatelessWidget {
  const LiveTopPlayersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LiveGamesProvider>();


    if (provider.isLoading || provider.error != null || provider.topPlayers.isEmpty) {
      return const SizedBox.shrink();
    }


    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.topPlayers.length,
            itemBuilder: (context, index) {

              return Padding(

                padding: EdgeInsets.only(bottom: index == provider.topPlayers.length - 1 ? 0 : 12.0),
                child: _PlayerInfoRow(player: provider.topPlayers[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Top Players',
          style: TextStyle(
              fontSize: 20,
              color: AppTheme.kColorTextPrimary,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),

        const CircleAvatar(backgroundColor: AppTheme.kColorAccent, radius: 5),
        const SizedBox(width: 6),
        Text(
          'LIVE',

          style: TextStyle(
            fontSize: 12,
            color: AppTheme.kColorAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),

        const Icon(Icons.arrow_forward_ios, color: AppTheme.kColorTextSecondary, size: 16),
      ],
    );
  }
}


class _PlayerInfoRow extends StatelessWidget {
  final LivePlayer player;

  const _PlayerInfoRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => GameScreen(gameId: player.gameId),
        ));
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      player.name,

                      style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.kColorTextPrimary,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (player.countryCode != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: CountryFlag.fromCountryCode(
                          player.countryCode!,
                          height: 14,
                          width: 21,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            Text(
              player.elo.toString(),
              style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.kColorTextSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}