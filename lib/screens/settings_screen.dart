import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/theme/app_constants.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_park/providers/settings_provider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:country_picker/country_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
          child: const Center(
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.kColorTextPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    _buildSectionHeader('Profile', theme),

                    GlassPanel(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        leading: const Icon(
                          Icons.flag_outlined,
                          color: AppTheme.kColorTextPrimary,
                        ),
                        title: const Text('Country'),
                        subtitle: Text(
                          user.countryCode != null
                              ? Country.tryParse(user.countryCode!)?.name ??
                                    user.countryCode!
                              : 'Not set',
                          style: const TextStyle(
                            color: AppTheme.kColorTextSecondary,
                          ),
                        ),
                        trailing: user.countryCode != null
                            ? CountryFlag.fromCountryCode(
                                user.countryCode!,
                                height: 16,
                                width: 24,
                              )
                            : const Icon(
                                Icons.chevron_right,
                                color: AppTheme.kColorTextSecondary,
                              ),
                        onTap: () =>
                            _showCountryPickerDialog(context, authProvider),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Appearance',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownSelector(
                      context,
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

                    _buildDropdownSelector(
                      context,
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

                    const SizedBox(height: 32),

                    Text(
                      'Gameplay',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GlassPanel(
                      padding: EdgeInsets.zero,
                      child: SwitchListTile(
                        title: const Text('Enable Premoves'),
                        subtitle: const Text(
                          'Make moves while waiting for the opponent\'s turn.',
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
                        thumbColor: WidgetStateProperty.all<Color>(
                          theme.colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        secondary: const Icon(
                          Icons.fast_forward,
                          color: AppTheme.kColorTextPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildSectionHeader('About', theme),

                    GlassPanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.privacy_tip_outlined,
                              color: AppTheme.kColorTextPrimary,
                            ),
                            title: const Text('Privacy Policy'),
                            trailing: const Icon(
                              Icons.launch,
                              color: AppTheme.kColorTextSecondary,
                              size: 18,
                            ),
                            onTap: () =>
                                _launchUrl(AppConstants.privacyPolicyUrl),
                          ),
                          Divider(
                            color: Colors.white.withAlpha(230),
                            height: 1,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.description_outlined,
                              color: AppTheme.kColorTextPrimary,
                            ),
                            title: const Text('Terms of Service'),
                            trailing: const Icon(
                              Icons.launch,
                              color: AppTheme.kColorTextSecondary,
                              size: 18,
                            ),
                            onTap: () =>
                                _launchUrl(AppConstants.termsOfServiceUrl),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSelector(
    BuildContext context, {
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

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      initialValue: effectiveValue,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            itemLabelBuilder != null
                ? itemLabelBuilder(value)
                : _capitalize(value),
          ),
        );
      }).toList(),
      onChanged: onChanged,
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

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.kColorTextSecondary,
        ),
      ),
    );
  }
}
