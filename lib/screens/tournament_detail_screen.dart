import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament_model.dart';
import '../providers/tournament_provider.dart';
import '../widgets/category_badge.dart';
import '../widgets/bracket_view.dart';

class TournamentDetailScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentDetailScreen({
    Key? key,
    required this.tournamentId,
  }) : super(key: key);

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadTournament(widget.tournamentId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TournamentProvider>();
    final tournament = provider.currentTournament;

    if (provider.isLoading || tournament == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Details'),
      ),
      body: Column(
        children: [
          // Tournament header
          _buildTournamentHeader(tournament),
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview', icon: Icon(Icons.info)),
              Tab(text: 'Bracket', icon: Icon(Icons.account_tree)),
              Tab(text: 'Participants', icon: Icon(Icons.people)),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(tournament, provider),
                _buildBracketTab(provider),
                _buildParticipantsTab(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentHeader(TournamentModel tournament) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(tournament.category).withOpacity(0.8),
            _getCategoryColor(tournament.category),
          ],
        ),
      ),
      child: Column(
        children: [
          CategoryBadge(
            category: tournament.category,
            size: 50,
            showLabel: true,
          ),
          const SizedBox(height: 12),
          _buildStatusBadge(tournament.status),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(
                Icons.access_time,
                _formatTime(tournament.scheduledTime),
              ),
              _buildInfoChip(
                Icons.people,
                '${tournament.currentPlayers}/${tournament.maxPlayers}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TournamentStatus status) {
    IconData icon;
    Color color;
    String text;

    switch (status) {
      case TournamentStatus.registration:
        icon = Icons.app_registration;
        color = Colors.blue;
        text = 'Registration Open';
        break;
      case TournamentStatus.inProgress:
        icon = Icons.play_circle;
        color = Colors.green;
        text = 'In Progress';
        break;
      case TournamentStatus.completed:
        icon = Icons.emoji_events;
        color = Colors.amber;
        text = 'Completed';
        break;
      default:
        icon = Icons.schedule;
        color = Colors.grey;
        text = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    TournamentModel tournament,
    TournamentProvider provider,
  ) {
    final rewards = TournamentRewards.rewards[tournament.category]!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          'Tournament Information',
          [
            _buildInfoRow('Category', tournament.categoryLabel),
            _buildInfoRow('ELO Range', '${tournament.minElo} - ${tournament.maxElo}'),
            _buildInfoRow('Format', 'Single Elimination (Best of 3)'),
            _buildInfoRow('Time Control', '10 + 0 (Rapid)'),
            _buildInfoRow('Max Players', '${tournament.maxPlayers}'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Star Rewards',
          [
            _buildInfoRow('1st Place', '${rewards['first_place']} ⭐'),
            _buildInfoRow('2nd Place', '${rewards['second_place']} ⭐'),
            _buildInfoRow('3rd Place', '${rewards['third_place']} ⭐'),
            _buildInfoRow('Quarter Finals', '${rewards['quarter_final']} ⭐'),
            _buildInfoRow('Round of 16', '${rewards['round_of_16']} ⭐'),
          ],
        ),
        if (tournament.status == TournamentStatus.completed) ...[
          const SizedBox(height: 16),
          _buildWinnersCard(tournament),
        ],
      ],
    );
  }

  Widget _buildWinnersCard(TournamentModel tournament) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Winners',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (tournament.winnerId != null)
              _buildWinnerRow('🥇 1st Place', tournament.winnerId!),
            if (tournament.runnerUpId != null)
              _buildWinnerRow('🥈 2nd Place', tournament.runnerUpId!),
            if (tournament.thirdPlaceId != null)
              _buildWinnerRow('🥉 3rd Place', tournament.thirdPlaceId!),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerRow(String label, String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(userId), // TODO: Get actual user name
        ],
      ),
    );
  }

  Widget _buildBracketTab(TournamentProvider provider) {
    if (provider.bracket.isEmpty) {
      return const Center(
        child: Text('Bracket not yet generated'),
      );
    }

    return BracketView(rounds: provider.bracket);
  }

  Widget _buildParticipantsTab(TournamentProvider provider) {
    final participants = provider.participants;

    if (participants.isEmpty) {
      return const Center(
        child: Text('No participants yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: participant.eliminated
                  ? Colors.grey
                  : Colors.green,
              child: Text(
                participant.seed.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              participant.displayName,
              style: TextStyle(
                decoration: participant.eliminated
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text('ELO: ${participant.elo}'),
            trailing: participant.starsEarned > 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        participant.starsEarned.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getCategoryColor(TournamentCategory category) {
    switch (category) {
      case TournamentCategory.a:
        return Colors.blue[600]!;
      case TournamentCategory.b:
        return Colors.purple[600]!;
      case TournamentCategory.c:
        return Colors.orange[600]!;
      case TournamentCategory.d:
        return Colors.red[600]!;
    }
  }
}
