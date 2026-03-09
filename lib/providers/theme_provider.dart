import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App theme variants
enum AppThemeType {
  // Dark themes
  forest,
  ocean,
  midnight,
  roseDark,
  // Light themes
  cream,
  sky,
  peach,
  mint,
}

/// Theme color scheme data
class AppThemeColors {
  final String name;
  final String emoji;
  final Color accent;
  final Color bgColor1;
  final Color bgColor2;
  final Color bgColor3;
  final Color surfaceColor;
  final Color glassColor;
  final bool isLight;

  const AppThemeColors({
    required this.name,
    required this.emoji,
    required this.accent,
    required this.bgColor1,
    required this.bgColor2,
    required this.bgColor3,
    required this.surfaceColor,
    required this.glassColor,
    this.isLight = false,
  });

  BoxDecoration get backgroundDecoration => BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [bgColor1, bgColor2, bgColor3],
          stops: const [0.0, 0.3, 1.0],
        ),
      );

  Color get textPrimary => isLight ? const Color(0xFF1a1a1a) : Colors.white;
  Color get textSecondary => isLight 
      ? const Color(0xFF1a1a1a).withOpacity(0.7) 
      : Colors.white.withOpacity(0.75);
}

/// All available themes
class AppThemes {
  // === DARK THEMES ===
  static const forest = AppThemeColors(
    name: 'Forest',
    emoji: '🌲',
    accent: Color(0xFF7CB342),
    bgColor1: Color(0xFF2d3a2e),
    bgColor2: Color(0xFF242d24),
    bgColor3: Color(0xFF1a211a),
    surfaceColor: Color(0xFF2d3a2e),
    glassColor: Color(0xFF7CB342),
  );

  static const ocean = AppThemeColors(
    name: 'Ocean',
    emoji: '🌊',
    accent: Color(0xFF29B6F6),
    bgColor1: Color(0xFF1e3a5f),
    bgColor2: Color(0xFF162d4d),
    bgColor3: Color(0xFF0d1f33),
    surfaceColor: Color(0xFF1e3a5f),
    glassColor: Color(0xFF29B6F6),
  );

  static const midnight = AppThemeColors(
    name: 'Midnight',
    emoji: '🌙',
    accent: Color(0xFFAB47BC),
    bgColor1: Color(0xFF2a2040),
    bgColor2: Color(0xFF1f1830),
    bgColor3: Color(0xFF150f20),
    surfaceColor: Color(0xFF2a2040),
    glassColor: Color(0xFFAB47BC),
  );

  static const roseDark = AppThemeColors(
    name: 'Rose',
    emoji: '🌹',
    accent: Color(0xFFE91E63),
    bgColor1: Color(0xFF3d2030),
    bgColor2: Color(0xFF2d1825),
    bgColor3: Color(0xFF1f101a),
    surfaceColor: Color(0xFF3d2030),
    glassColor: Color(0xFFE91E63),
  );

  // === LIGHT THEMES ===
  static const cream = AppThemeColors(
    name: 'Cream',
    emoji: '☕',
    accent: Color(0xFF8D6E63),
    bgColor1: Color(0xFFFFFBF5),
    bgColor2: Color(0xFFF5EFE6),
    bgColor3: Color(0xFFEAE0D5),
    surfaceColor: Color(0xFFFAF6F0),
    glassColor: Color(0xFF8D6E63),
    isLight: true,
  );

  static const sky = AppThemeColors(
    name: 'Sky',
    emoji: '☁️',
    accent: Color(0xFF1976D2),
    bgColor1: Color(0xFFF0F7FF),
    bgColor2: Color(0xFFE3F2FD),
    bgColor3: Color(0xFFD0E8FF),
    surfaceColor: Color(0xFFEBF4FF),
    glassColor: Color(0xFF1976D2),
    isLight: true,
  );

  static const peach = AppThemeColors(
    name: 'Peach',
    emoji: '🍑',
    accent: Color(0xFFE64A19),
    bgColor1: Color(0xFFFFF5F0),
    bgColor2: Color(0xFFFFECE3),
    bgColor3: Color(0xFFFFDDD0),
    surfaceColor: Color(0xFFFFF0E8),
    glassColor: Color(0xFFE64A19),
    isLight: true,
  );

  static const mint = AppThemeColors(
    name: 'Mint',
    emoji: '🌿',
    accent: Color(0xFF00897B),
    bgColor1: Color(0xFFF0FFF8),
    bgColor2: Color(0xFFE0F7EF),
    bgColor3: Color(0xFFD0EFE5),
    surfaceColor: Color(0xFFE8FFF5),
    glassColor: Color(0xFF00897B),
    isLight: true,
  );

  static List<AppThemeColors> get all => [
        // Dark themes first
        forest,
        ocean,
        midnight,
        roseDark,
        // Light themes
        cream,
        sky,
        peach,
        mint,
      ];

  static AppThemeColors fromType(AppThemeType type) {
    switch (type) {
      case AppThemeType.forest:
        return forest;
      case AppThemeType.ocean:
        return ocean;
      case AppThemeType.midnight:
        return midnight;
      case AppThemeType.roseDark:
        return roseDark;
      case AppThemeType.cream:
        return cream;
      case AppThemeType.sky:
        return sky;
      case AppThemeType.peach:
        return peach;
      case AppThemeType.mint:
        return mint;
    }
  }

  static AppThemeType typeFromIndex(int index) {
    if (index < 0 || index >= AppThemeType.values.length) {
      return AppThemeType.forest;
    }
    return AppThemeType.values[index];
  }
}

/// Theme provider for managing app theme
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_index';

  AppThemeType _currentThemeType = AppThemeType.forest;
  bool _isLoaded = false;

  AppThemeType get currentThemeType => _currentThemeType;
  AppThemeColors get currentTheme => AppThemes.fromType(_currentThemeType);
  bool get isLoaded => _isLoaded;

  /// Load theme from SharedPreferences
  Future<void> loadTheme() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _currentThemeType = AppThemes.typeFromIndex(themeIndex);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Set theme and save to SharedPreferences
  Future<void> setTheme(AppThemeType themeType) async {
    if (_currentThemeType == themeType) return;

    _currentThemeType = themeType;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeType.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Set theme by index
  Future<void> setThemeByIndex(int index) async {
    final themeType = AppThemes.typeFromIndex(index);
    await setTheme(themeType);
  }
}
