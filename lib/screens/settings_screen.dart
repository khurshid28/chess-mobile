import 'package:chess_park/providers/auth_provider.dart';import 'package:chess_park/providers/theme_provider.dart';
import 'package:chess_park/screens/theme_picker_screen.dart';import 'package:chess_park/theme/app_constants.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/theme/app_icons.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_park/providers/settings_provider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:country_picker/country_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.backgroundDecoration,
          child: Center(
            child: Text(
              "Please log in to change settings.",
              style: TextStyle(color: AppTheme.kColorTextSecondary),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.containerBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(
                          AppIcons.back,
                          color: AppTheme.kColorTextPrimary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.kColorAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.settings,
                        color: AppTheme.kColorAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _buildSectionHeader('Profile', theme, AppIcons.profile),

                    GlassPanel(
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.kSecondaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              AppIcons.language,
                              color: AppTheme.kSecondaryColor,
                              size: 22,
                            ),
                          ),
                          title: const Text('Country'),
                          subtitle: Text(
                            user.countryCode != null
                                ? Country.tryParse(user.countryCode!)?.name ??
                                      user.countryCode!
                                : 'Not set',
                            style: TextStyle(
                              color: AppTheme.kColorTextSecondary,
                            ),
                          ),
                          trailing: user.countryCode != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CountryFlag.fromCountryCode(
                                    user.countryCode!,
                                    height: 20,
                                    width: 30,
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.containerBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    AppIcons.chevronRight,
                                    color: AppTheme.kColorTextSecondary,
                                  ),
                                ),
                          onTap: () =>
                              _showCountryPickerDialog(context, authProvider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('Appearance', theme, AppIcons.theme),

                    // App Theme Picker
                    GlassPanel(
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.kColorAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              AppIcons.theme,
                              color: AppTheme.kColorAccent,
                              size: 22,
                            ),
                          ),
                          title: const Text('App Theme'),
                          subtitle: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return Text(
                                '${themeProvider.currentTheme.emoji} ${themeProvider.currentTheme.name}',
                                style: TextStyle(
                                  color: AppTheme.kColorTextSecondary,
                                ),
                              );
                            },
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.containerBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              AppIcons.chevronRight,
                              color: AppTheme.kColorTextSecondary,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ThemePickerScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    GlassPanel(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDropdownSelector(
                            context,
                            icon: AppIcons.chessBoard,
                            iconColor: AppTheme.kSecondaryColor,
                            label: 'Board Theme',
                            currentValue: settingsProvider.boardThemeName,
                            items: SettingsProvider.boardThemeMap.keys.toList()
                              ..sort(),
                            onChanged: (value) {
                              if (value != null) {
                                settingsProvider.updateSetting(
                                  user.id,
                                  'boardTheme',
                                  value,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppTheme.dividerColor, height: 1),
                          const SizedBox(height: 16),
                          _buildDropdownSelector(
                            context,
                            icon: AppIcons.puzzles,
                            iconColor: AppTheme.kColorAccent,
                            label: 'Piece Set',
                            currentValue: settingsProvider.pieceSetName,
                            items: SettingsProvider.pieceSetMap.keys.toList()..sort(),
                            itemLabelBuilder: (value) =>
                                SettingsProvider.pieceSetMap[value]?.label ??
                                _capitalize(value),
                            onChanged: (value) {
                              if (value != null) {
                                settingsProvider.updateSetting(
                                  user.id,
                                  'pieceSet',
                                  value,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildSectionHeader('Gameplay', theme, AppIcons.games),

                    GlassPanel(
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          title: const Text('Enable Premoves'),
                          subtitle: Text(
                            'Make moves while waiting for opponent\'s turn.',
                            style: TextStyle(color: AppTheme.kColorTextSecondary),
                          ),
                          value: settingsProvider.enablePremove,
                          onChanged: (value) {
                            settingsProvider.updateSetting(
                              user.id,
                              'enablePremove',
                              value,
                            );
                          },
                          activeColor: AppTheme.kColorAccent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.kPrimaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              AppIcons.blitz,
                              color: AppTheme.kPrimaryColor,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildSectionHeader('About', theme, AppIcons.about),

                    GlassPanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6.0,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.kSecondaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  AppIcons.privacy,
                                  color: AppTheme.kSecondaryColor,
                                  size: 22,
                                ),
                              ),
                              title: const Text('Privacy Policy'),
                              trailing: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.containerBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  AppIcons.forward,
                                  color: AppTheme.kColorTextSecondary,
                                  size: 18,
                                ),
                              ),
                              onTap: () =>
                                  _launchUrl(AppConstants.privacyPolicyUrl),
                            ),
                          ),
                          Divider(
                            color: AppTheme.dividerColor,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6.0,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.kColorAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  AppIcons.help,
                                  color: AppTheme.kColorAccent,
                                  size: 22,
                                ),
                              ),
                              title: const Text('Terms of Service'),
                              trailing: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.containerBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  AppIcons.forward,
                                  color: AppTheme.kColorTextSecondary,
                                  size: 18,
                                ),
                              ),
                              onTap: () =>
                                  _launchUrl(AppConstants.termsOfServiceUrl),
                            ),
                          ),
                          Divider(
                            color: AppTheme.dividerColor,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6.0,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.kColorSuccess.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  AppIcons.share,
                                  color: AppTheme.kColorSuccess,
                                  size: 22,
                                ),
                              ),
                              title: const Text('Share App'),
                              subtitle: Text(
                                'Invite friends to play',
                                style: TextStyle(
                                  color: AppTheme.kColorTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.containerBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  AppIcons.chevronRight,
                                  color: AppTheme.kColorTextSecondary,
                                  size: 18,
                                ),
                              ),
                              onTap: () => _shareApp(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share(
      '🎮 Play chess with me!\n\n'
      'Download Chess Game:\n'
      '📱 Android: ${AppConstants.playStoreUrl}\n'
      '🍎 iOS: ${AppConstants.appStoreUrl}',
    );
  }

  Widget _buildDropdownSelector(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String currentValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? itemLabelBuilder,
  }) {
    String effectiveValue = items.contains(currentValue)
        ? currentValue
        : (items.isNotEmpty ? items.first : "");

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.kColorTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: effectiveValue,
                  isExpanded: true,
                  dropdownColor: AppTheme.kBgColor1,
                  borderRadius: BorderRadius.circular(12),
                  icon: Icon(
                    AppIcons.expand,
                    color: AppTheme.kColorTextSecondary,
                  ),
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        itemLabelBuilder != null
                            ? itemLabelBuilder(value)
                            : _capitalize(value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : "";

  void _showCountryPickerDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        backgroundColor: AppTheme.kBgColor1,
        textStyle: TextStyle(color: AppTheme.kColorTextPrimary),
        searchTextStyle: TextStyle(color: AppTheme.kColorTextPrimary),
        inputDecoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: AppTheme.kColorTextSecondary),
          prefixIcon: Icon(AppIcons.search, color: AppTheme.kColorTextSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.containerBgColor,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      onSelect: (Country country) async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final errorMessage = await authProvider.updateCountry(
          country.countryCode,
        );

        if (errorMessage != null && context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.kColorAccent,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.kColorAccent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
