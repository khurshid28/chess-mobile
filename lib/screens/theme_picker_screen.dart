import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chess_park/providers/theme_provider.dart';
import 'package:chess_park/theme/app_theme.dart';

class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentThemeType = themeProvider.currentThemeType;

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Theme sections
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dark Themes Section
                      _SectionHeader(
                        title: 'Dark Themes',
                        subtitle: 'Elegant dark backgrounds',
                        icon: Icons.dark_mode_rounded,
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 4, // First 4 are dark themes
                        itemBuilder: (context, index) {
                          final theme = AppThemes.all[index];
                          final themeType = AppThemeType.values[index];
                          final isSelected = currentThemeType == themeType;

                          return _ThemeCard(
                            theme: theme,
                            isSelected: isSelected,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeProvider.setTheme(themeType);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Light Themes Section
                      _SectionHeader(
                        title: 'Light Themes',
                        subtitle: 'Clean and bright',
                        icon: Icons.light_mode_rounded,
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 4, // Last 4 are light themes
                        itemBuilder: (context, index) {
                          final actualIndex = index + 4; // Offset for light themes
                          final theme = AppThemes.all[actualIndex];
                          final themeType = AppThemeType.values[actualIndex];
                          final isSelected = currentThemeType == themeType;

                          return _ThemeCard(
                            theme: theme,
                            isSelected: isSelected,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeProvider.setTheme(themeType);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeColors theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLightTheme = theme.isLight;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.95),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? theme.accent 
                : isLightTheme 
                    ? Colors.grey.withOpacity(0.3) 
                    : Colors.white.withOpacity(0.1),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? theme.accent.withOpacity(0.4) 
                  : isLightTheme
                      ? Colors.black.withOpacity(0.08)
                      : Colors.black.withOpacity(0.2),
              blurRadius: isSelected ? 20 : 8,
              spreadRadius: isSelected ? 2 : 0,
            ),
            if (isLightTheme)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 0,
                spreadRadius: 0,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              // Background gradient preview
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.5,
                    colors: [theme.bgColor1, theme.bgColor2, theme.bgColor3],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              // Glass overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isLightTheme
                        ? [
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.2),
                            theme.accent.withOpacity(0.05),
                          ]
                        : [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Accent color circle with emoji
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.accent.withOpacity(isLightTheme ? 0.15 : 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.accent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.accent.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          theme.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Theme name
                    Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.emoji,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Selected checkmark
              if (isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.accent.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.kColorAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.kColorAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.kColorTextPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.kColorTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
