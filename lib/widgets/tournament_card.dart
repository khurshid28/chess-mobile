import 'package:flutter/material.dart';
import '../models/tournament_model.dart';

class TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final bool isUserJoined;
  final VoidCallback onTap;
  final VoidCallback? onJoin;

  const TournamentCard({
    Key? key,
    required this.tournament,
    required this.isUserJoined,
    required this.onTap,
    this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeUntilStart = tournament.scheduledTime.difference(DateTime.now());
    final isStartingSoon = timeUntilStart.inMinutes <= 30 && timeUntilStart.inMinutes > 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(tournament.category),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tournament.categoryLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 12),
              
              // Time and players info
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isStartingSoon ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeDisplay(timeUntilStart),
                    style: TextStyle(
                      color: isStartingSoon ? Colors.orange : Colors.grey[700],
                      fontWeight: isStartingSoon ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.people, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${tournament.currentPlayers}/${tournament.maxPlayers}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Progress bar
              LinearProgressIndicator(
                value: tournament.currentPlayers / tournament.maxPlayers,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  tournament.isFull ? Colors.green : theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Rewards info
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Rewards: ${_getRewardsText()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Join button or status
              if (onJoin != null && tournament.canJoin && !isUserJoined)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onJoin,
                      icon: const Icon(Icons.login),
                      label: const Text('Join Tournament'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              
              if (isUserJoined)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Joined',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    IconData icon;
    Color color;
    String text;

    switch (tournament.status) {
      case TournamentStatus.registration:
        icon = Icons.app_registration;
        color = Colors.blue;
        text = 'Open';
        break;
      case TournamentStatus.inProgress:
        icon = Icons.play_circle;
        color = Colors.green;
        text = 'Live';
        break;
      case TournamentStatus.completed:
        icon = Icons.emoji_events;
        color = Colors.amber;
        text = 'Finished';
        break;
      default:
        icon = Icons.schedule;
        color = Colors.grey;
        text = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(TournamentCategory category) {
    switch (category) {
      case TournamentCategory.a:
        return Colors.blue;
      case TournamentCategory.b:
        return Colors.purple;
      case TournamentCategory.c:
        return Colors.orange;
      case TournamentCategory.d:
        return Colors.red;
    }
  }

  String _getTimeDisplay(Duration timeUntil) {
    if (timeUntil.isNegative) {
      return 'Started';
    }
    
    if (timeUntil.inDays > 0) {
      return 'Starts in ${timeUntil.inDays}d';
    }
    
    if (timeUntil.inHours > 0) {
      return 'Starts in ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m';
    }
    
    return 'Starts in ${timeUntil.inMinutes}m';
  }

  String _getRewardsText() {
    final rewards = TournamentRewards.rewards[tournament.category]!;
    return '1st: ${rewards['first_place']}⭐';
  }
}
