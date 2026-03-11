
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/theme_provider.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_text_styles.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:chess_park/widgets/wood_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:provider/provider.dart';

class UserHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const UserHeader({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isWood = context.watch<ThemeProvider>().currentThemeType == AppThemeType.woodClassic;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      child: isWood ? _buildWood() : _buildGlass(),
    );
  }

  Widget _buildWood() {
    return WoodPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WoodColors.border, width: 2),
              boxShadow: const [BoxShadow(color: Color(0x66000000), offset: Offset(1, 2), blurRadius: 4)],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: WoodColors.woodDark,
              backgroundImage: user.profileImage != null ? CachedNetworkImageProvider(user.profileImage!) : null,
              child: user.profileImage == null
                  ? const Icon(Icons.person_rounded, size: 28, color: WoodColors.gold)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(user.displayName,
                          style: WoodTextStyles.menuLabel.copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (user.countryCode != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: CountryFlag.fromCountryCode(user.countryCode!, height: 14, width: 21),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.email, style: WoodTextStyles.caption, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: WoodColors.woodDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WoodColors.border, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: WoodColors.gold, size: 17),
                const SizedBox(width: 4),
                Text(user.elo.toString(), style: WoodTextStyles.rating),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlass() {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.kColorAccent.withOpacity(0.2),
            backgroundImage: user.profileImage != null ? CachedNetworkImageProvider(user.profileImage!) : null,
            child: user.profileImage == null
                ? Icon(Icons.person_rounded, size: 28, color: AppTheme.kColorAccent)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(user.displayName,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.kColorTextPrimary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (user.countryCode != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: CountryFlag.fromCountryCode(user.countryCode!, height: 14, width: 21),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.email,
                    style: TextStyle(fontSize: 13, color: AppTheme.kColorTextSecondary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.kColorAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: AppTheme.kColorAccent, size: 18),
                const SizedBox(width: 4),
                Text(user.elo.toString(),
                    style: TextStyle(color: AppTheme.kColorAccent, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}