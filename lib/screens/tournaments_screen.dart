import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament_model.dart';
import '../providers/tournament_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/tournament_card.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
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
      backgroundColor: AppTheme.isWoodClassic ? Colors.transparent : AppTheme.kBgColor2,
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(AppIcons.back, color: AppTheme.kColorTextPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Tournaments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.kColorTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (user != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.kColorAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppIcons.rating, color: AppTheme.kColorAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${user.elo}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.kColorAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.kBgColor1.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.kColorAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppTheme.kButtonTextColor,
                  unselectedLabelColor: AppTheme.kColorTextSecondary,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(AppIcons.timer, size: 18),
                          const SizedBox(width: 8),
                          const Text('Upcoming'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(AppIcons.live, size: 18),
                          const SizedBox(width: 8),
                          const Text('Live'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : category;
        });
        tournamentProvider.setSelectedCategory(_selectedCategory);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.kColorAccent 
              : AppTheme.kBgColor1.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.kColorAccent 
                : AppTheme.kColorTextSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.kButtonTextColor : AppTheme.kColorTextPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab(TournamentProvider provider, String? userId) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.kColorAccent));
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
      return Center(child: CircularProgressIndicator(color: AppTheme.kColorAccent));
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
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppTheme.kColorAccent),
      ),
    );

    final success = await tournamentProvider.joinTournament(userId, tournament.id);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined tournament!'),
          backgroundColor: AppTheme.kColorWin,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tournamentProvider.error ?? 'Failed to join tournament'),
          backgroundColor: AppTheme.kColorError,
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
