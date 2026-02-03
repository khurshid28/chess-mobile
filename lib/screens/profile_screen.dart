
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


const Widget _kVerticalSpacer = SizedBox(height: 24.0);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final topPadding = MediaQuery.of(context).padding.top + 60;

    if (user == null) {
      return const Center(
        child: Text(
          'Not logged in.',
          style: TextStyle(color: AppTheme.kColorTextSecondary),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: EdgeInsets.fromLTRB(24.0, topPadding, 24.0, 120.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          _ProfileHeader(user: user),
          _kVerticalSpacer,
          _StatsGrid(user: user),
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
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                backgroundImage: user.profileImage != null
                    ? CachedNetworkImageProvider(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: AppTheme.kColorTextSecondary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.kColorAccent,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      authProvider.updateUserProfileImage();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.countryCode != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: CountryFlag.fromCountryCode(
                            user.countryCode!,
                            height: 14,
                            width: 21,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.kColorTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GlassPanel(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text(
                  'Chiqish',
                  style: TextStyle(color: AppTheme.kColorTextPrimary),
                ),
                content: const Text(
                  'Haqiqatan ham chiqmoqchimisiz?',
                  style: TextStyle(color: AppTheme.kColorTextSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Yo\'q',
                      style: TextStyle(color: AppTheme.kColorTextSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      authProvider.signOut();
                    },
                    child: const Text(
                      'Ha',
                      style: TextStyle(color: AppTheme.kColorAccent),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              color: Colors.redAccent,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Chiqish',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events,
                label: 'Rating',
                value: user.elo.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline,
                label: 'Wins',
                value: user.wins.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.cancel_outlined,
                label: 'Losses',
                value: user.losses.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                icon: Icons.drag_handle,
                label: 'Draws',
                value: user.draws.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.kColorAccent, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.kColorTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style:TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kColorTextPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}