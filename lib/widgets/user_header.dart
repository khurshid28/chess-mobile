
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/providers/theme_provider.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_textures.dart';
import 'package:chess_park/theme/wood_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:provider/provider.dart';

class UserHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onSettingsTap;

  const UserHeader({super.key, required this.user, this.onTap, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final isWood = context.watch<ThemeProvider>().currentThemeType == AppThemeType.woodClassic;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, statusBarHeight + 10, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isWood ? WoodColors.border : AppTheme.kBorderColor,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), offset: Offset(1, 2), blurRadius: 4),
                ],
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: isWood ? WoodColors.woodDark : AppTheme.kSurfaceColor,
                backgroundImage: user.profileImage != null
                    ? CachedNetworkImageProvider(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Icon(Icons.person_rounded, size: 22, color: isWood ? Colors.white : (AppTheme.isLight ? AppTheme.kColorTextPrimary : AppTheme.kColorAccent))
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isWood ? Colors.white : AppTheme.kColorTextPrimary,
                            shadows: isWood ? WoodTextStyles.woodShadow : null,
                          ),
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
                              height: 16,
                              width: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: isWood ? Colors.white : AppTheme.kColorAccent, size: 18),
                      const SizedBox(width: 3),
                      Text(
                        '${user.elo}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isWood ? Colors.white70 : AppTheme.kColorTextPrimary,
                          shadows: isWood ? WoodTextStyles.woodShadow : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onSettingsTap != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSettingsTap!();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isWood ? null : AppTheme.kColorAccent.withOpacity(0.15),
                    image: isWood ? WoodTextures.icon() : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isWood ? Border.all(color: WoodColors.border, width: 1.5) : null,
                  ),
                  child: Icon(Icons.settings_rounded, color: isWood ? Colors.white : AppTheme.kColorAccent, size: 22),
                ),
              ),
          ],
        ),
      ),
    );
  }
}