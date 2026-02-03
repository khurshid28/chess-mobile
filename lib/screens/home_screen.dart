import 'dart:ui';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/screens/game_history_screen.dart';
import 'package:chess_park/screens/leaderboard_screen.dart';
import 'package:chess_park/screens/lobby_screen.dart';
import 'package:chess_park/screens/profile_screen.dart';
import 'package:chess_park/screens/puzzle_lobby_screen.dart';
import 'package:chess_park/screens/settings_screen.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    LobbyScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return _QuickActionsSheet(
          selectedIndex: _selectedIndex,
          onNavigate: (index) => _onItemTapped(index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final double bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom
        : 20;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(

        extendBody: true,
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _widgetOptions,
              ),
              if (_selectedIndex == 0)
                _TopBar(onShowQuickActions: _showQuickActions),


              _GlassyBottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
                bottomPadding: bottomPadding,
              ),
            ],
          ),
        ),

        bottomNavigationBar: null,
      ),
    );
  }
}


class _TopBar extends StatelessWidget {
  const _TopBar({required this.onShowQuickActions});

  final VoidCallback onShowQuickActions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.apps, color: AppTheme.kColorTextPrimary),
              onPressed: onShowQuickActions,
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: AppTheme.kColorTextPrimary),
              onPressed: () => context.read<AuthProvider>().signOut(),
            )
          ],
        ),
      ),
    );
  }
}


class _GlassyBottomNavBar extends StatelessWidget {
  const _GlassyBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.bottomPadding,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: BottomNavigationBar(

              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard),
                  label: 'Leaderboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: selectedIndex,
              onTap: onTap,

             backgroundColor: Colors.white.withAlpha(26),
              elevation: 0,
              selectedItemColor: AppTheme.kColorAccent,
              unselectedItemColor: AppTheme.kColorTextSecondary,

              showSelectedLabels: true,
              showUnselectedLabels: true,
            ),
          ),
        ),
      ),
    );
  }
}


class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({
    required this.selectedIndex,
    required this.onNavigate,
  });

  final int selectedIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().userModel;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(65, 67, 69, 0.8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.kBorderRadius)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quick Actions',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.kColorTextPrimary)),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.kColorTextPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _QuickActionButton(
                icon: Icons.public,
                label: 'Play Online',
                onTap: () {
                  Navigator.pop(context);
                  if (selectedIndex != 0) onNavigate(0);
                },
              ),
              _QuickActionButton(
                icon: Icons.extension,
                label: 'Puzzles',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const PuzzleLobbyScreen()));
                },
              ),
              _QuickActionButton(
                icon: Icons.leaderboard,
                label: 'Leaderboard',
                onTap: () {
                  Navigator.pop(context);
                  if (selectedIndex != 1) onNavigate(1);
                },
              ),
              _QuickActionButton(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              _QuickActionButton(
                icon: Icons.person,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  if (selectedIndex != 2) onNavigate(2);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppTheme.kColorAccent),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.kColorTextPrimary),
            ),
          ],
        ),
      ),
    );
  }
}