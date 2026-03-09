
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/screens/settings_screen.dart';
import 'package:chess_park/theme/app_constants.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/widgets/recent_games.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';


const Widget _kVerticalSpacer = SizedBox(height: 20.0);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final topPadding = MediaQuery.of(context).padding.top + 60;

    if (user == null) {
      return Center(
        child: Text(
          'Not logged in',
          style: TextStyle(color: AppTheme.kColorTextSecondary),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.0, topPadding, 20.0, 120.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.kColorAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppTheme.kColorAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                // Settings button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.containerBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.settings_rounded, color: AppTheme.kColorTextPrimary),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
          _ProfileHeader(user: user),
          _kVerticalSpacer,
          _QuickStatsRow(user: user),
          _kVerticalSpacer,
          // Game History Section
          RecentGames(userId: user.id),
          _kVerticalSpacer,
          _DetailedStats(user: user),
          _kVerticalSpacer,
          _LogoutButton(),
        ],
      ),
    );
  }
}


class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GlassPanel(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.kColorAccent.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.kColorAccent.withOpacity(0.1),
                  backgroundImage: user.profileImage != null
                      ? CachedNetworkImageProvider(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppTheme.kColorAccent,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => authProvider.updateUserProfileImage(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.kColorAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.kColorAccent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (user.countryCode != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CountryFlag.fromCountryCode(
                      user.countryCode!,
                      height: 16,
                      width: 24,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 14,
                color: AppTheme.kColorTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                user.email,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.kColorTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Share Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareProfile(user),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.kColorAccent,
                side: BorderSide(color: AppTheme.kColorAccent.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareProfile(UserModel user) {
    final wins = user.wins;
    final losses = user.losses;
    final draws = user.draws;
    final totalGames = wins + losses + draws;
    final winRate = totalGames > 0 ? (wins / totalGames * 100).toStringAsFixed(1) : '0';
    
    Share.share(
      '🏆 Check out my chess profile!\n\n'
      '👤 ${user.displayName}\n'
      '📊 Rating: ${user.elo}\n'
      '🎮 Games: $totalGames\n'
      '✅ Win Rate: $winRate%\n\n'
      'Play chess with me!\n'
      '📱 ${AppConstants.playStoreUrl}',
    );
  }
}
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GlassPanel(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: AppTheme.kBgColor1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.all(24),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppTheme.kColorTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Are you sure you want to sign out of your account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.kColorTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppTheme.kColorTextPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                authProvider.signOut();
                              },
                              child: const Text('Sign Out'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final totalGames = user.wins + user.losses + user.draws;
    final winRate = totalGames > 0 ? (user.wins / totalGames * 100).toStringAsFixed(1) : '0';

    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickStatItem(
            icon: Icons.star_rounded,
            value: user.elo.toString(),
            label: 'Rating',
            color: AppTheme.kColorAccent,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.dividerColor,
          ),
          _QuickStatItem(
            icon: Icons.games_rounded,
            value: totalGames.toString(),
            label: 'Games',
            color: Colors.blueAccent,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.dividerColor,
          ),
          _QuickStatItem(
            icon: Icons.percent_rounded,
            value: '$winRate%',
            label: 'Win Rate',
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  const _QuickStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.kColorTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.kColorTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _DetailedStats extends StatelessWidget {
  const _DetailedStats({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: AppTheme.kColorAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detailed Statistics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.kColorTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          _DetailStatTile(
            icon: Icons.emoji_events_rounded,
            iconColor: Colors.amber,
            label: 'Wins',
            value: user.wins.toString(),
          ),
          Divider(color: AppTheme.dividerColor, height: 1),
          _DetailStatTile(
            icon: Icons.close_rounded,
            iconColor: Colors.redAccent,
            label: 'Losses',
            value: user.losses.toString(),
          ),
          Divider(color: AppTheme.dividerColor, height: 1),
          _DetailStatTile(
            icon: Icons.handshake_rounded,
            iconColor: Colors.blueGrey,
            label: 'Draws',
            value: user.draws.toString(),
          ),
        ],
      ),
    );
  }
}

class _DetailStatTile extends StatelessWidget {
  const _DetailStatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.kColorTextPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.kColorTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}