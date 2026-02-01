import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament_model.dart';
import '../providers/tournament_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/tournament_card.dart';
import '../widgets/star_display.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({Key? key}) : super(key: key);

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TournamentCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tournamentProvider = context.read<TournamentProvider>();
      tournamentProvider.loadUpcomingTournaments();
      tournamentProvider.loadActiveTournaments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final tournamentProvider = context.watch<TournamentProvider>();
    final user = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'Live', icon: Icon(Icons.play_circle)),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: StarCounter(
                  stars: user.stars,
                  label: 'Stars',
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(tournamentProvider, user?.id),
                _buildLiveTab(tournamentProvider, user?.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryChip(null, 'All'),
            const SizedBox(width: 8),
            ...TournamentCategory.values.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(category, category.name.toUpperCase()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(TournamentCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    final tournamentProvider = context.read<TournamentProvider>();

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
        tournamentProvider.setSelectedCategory(_selectedCategory);
      },
      selectedColor: category != null
          ? _getCategoryColor(category)
          : Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildUpcomingTab(TournamentProvider provider, String? userId) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadUpcomingTournaments(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final tournaments = provider.upcomingTournaments;

    if (tournaments.isEmpty) {
      return const Center(
        child: Text('No upcoming tournaments'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.loadUpcomingTournaments();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index];
          return FutureBuilder<bool>(
            future: userId != null
                ? provider.isUserInTournament(userId, tournament.id)
                : Future.value(false),
            builder: (context, snapshot) {
              final isJoined = snapshot.data ?? false;
              return TournamentCard(
                tournament: tournament,
                isUserJoined: isJoined,
                onTap: () => _navigateToTournament(tournament.id),
                onJoin: userId != null && tournament.canJoin
                    ? () => _joinTournament(tournament, userId)
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLiveTab(TournamentProvider provider, String? userId) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tournaments = provider.activeTournaments;

    if (tournaments.isEmpty) {
      return const Center(
        child: Text('No live tournaments'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.loadActiveTournaments();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index];
          return FutureBuilder<bool>(
            future: userId != null
                ? provider.isUserInTournament(userId, tournament.id)
                : Future.value(false),
            builder: (context, snapshot) {
              final isJoined = snapshot.data ?? false;
              return TournamentCard(
                tournament: tournament,
                isUserJoined: isJoined,
                onTap: () => _navigateToTournament(tournament.id),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToTournament(String tournamentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(tournamentId: tournamentId),
      ),
    );
  }

  Future<void> _joinTournament(TournamentModel tournament, String userId) async {
    final tournamentProvider = context.read<TournamentProvider>();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Tournament'),
        content: Text(
          'Do you want to join ${tournament.categoryLabel}?\n\n'
          'This tournament starts at ${_formatTime(tournament.scheduledTime)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await tournamentProvider.joinTournament(userId, tournament.id);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined tournament!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tournamentProvider.error ?? 'Failed to join tournament'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
