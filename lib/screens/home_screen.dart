import 'dart:ui';
import 'package:chess_park/screens/leaderboard_screen.dart';
import 'package:chess_park/screens/lobby_screen.dart';
import 'package:chess_park/screens/profile_screen.dart';

import 'package:chess_park/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToProfile() {
    _onItemTapped(2); // Profile tab is index 2
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      LobbyScreen(onProfileTap: _goToProfile),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

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
                children: widgetOptions,
              ),
              if (_selectedIndex == 0)
                const _TopBar(),

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
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            // Settings moved to Profile screen
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
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events_rounded),
                  label: 'Leaderboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
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