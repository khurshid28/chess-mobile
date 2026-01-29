
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';

class UserHeader extends StatelessWidget {
  final UserModel user;

  const UserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {

    final double ratingProgress = (user.elo % 100) / 100.0;

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            backgroundImage: user.profileImage != null
                ? CachedNetworkImageProvider(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? const Icon(
                    Icons.person_outline,
                    size: 28,
                    color: AppTheme.kColorTextSecondary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, ${user.displayName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.kColorTextPrimary,
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
                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Rating: ',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.kColorTextSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      user.elo.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.kColorTextPrimary,
                          fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratingProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.kColorAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}