import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App theme variants
enum AppThemeType {
  forest,
  ocean,
  sunset,
  midnight,
  gold,
  rose,
}

/// Theme color scheme data
class AppThemeColors {
  final String name;
  final String nameUz;
  final String emoji;
  final Color accent;
  final Color bgColor1;
  final Color bgColor2;
  final Color bgColor3;
  final Color surfaceColor;
  final Color glassColor;

  const AppThemeColors({
    required this.name,
    required this.nameUz,
    required this.emoji,
    required this.accent,
    required this.bgColor1,
    required this.bgColor2,
    required this.bgColor3,
    required this.surfaceColor,
    required this.glassColor,
  });

  BoxDecoration get backgroundDecoration => BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [bgColor1, bgColor2, bgColor3],
          stops: const [0.0, 0.3, 1.0],
        ),
      );
}

/// All available themes
class AppThemes {
  static const forest = AppThemeColors(
    name: 'Forest',
    nameUz: 'O\'rmon',
    emoji: '🌲',
    accent: Color(0xFF628141),
    bgColor1: Color(0xFF2a3123),
    bgColor2: Color(0xFF232a1c),
    bgColor3: Color(0xFF1a2113),
    surfaceColor: Color(0xFF2a3123),
    glassColor: Color(0xFF628141),
  );

  static const ocean = AppThemeColors(
    name: 'Ocean',
    nameUz: 'Okean',
    emoji: '🌊',
    accent: Color(0xFF4A90A4),
    bgColor1: Color(0xFF1a2530),
    bgColor2: Color(0xFF152028),
    bgColor3: Color(0xFF0f1a20),
    surfaceColor: Color(0xFF1a2530),
    glassColor: Color(0xFF4A90A4),
  );

  static const sunset = AppThemeColors(
    name: 'Sunset',
    nameUz: 'Quyosh botishi',
    emoji: '🌅',
    accent: Color(0xFFD4854A),
    bgColor1: Color(0xFF2a2520),
    bgColor2: Color(0xFF221d18),
    bgColor3: Color(0xFF1a1510),
    surfaceColor: Color(0xFF2a2520),
    glassColor: Color(0xFFD4854A),
  );

  static const midnight = AppThemeColors(
    name: 'Midnight',
    nameUz: 'Yarim tun',
    emoji: '🌙',
    accent: Color(0xFF7C5CBF),
    bgColor1: Color(0xFF201a2a),
    bgColor2: Color(0xFF1a1522),
    bgColor3: Color(0xFF15101a),
    surfaceColor: Color(0xFF201a2a),
    glassColor: Color(0xFF7C5CBF),
  );

  static const gold = AppThemeColors(
    name: 'Gold',
    nameUz: 'Oltin',
    emoji: '✨',
    accent: Color(0xFFD4AF37),
    bgColor1: Color(0xFF2a2820),
    bgColor2: Color(0xFF222018),
    bgColor3: Color(0xFF1a1810),
    surfaceColor: Color(0xFF2a2820),
    glassColor: Color(0xFFD4AF37),
  );

  static const rose = AppThemeColors(
    name: 'Rose',
    nameUz: 'Atirgul',
    emoji: '🌸',
    accent: Color(0xFFC76B8F),
    bgColor1: Color(0xFF2a2025),
    bgColor2: Color(0xFF22181d),
    bgColor3: Color(0xFF1a1015),
    surfaceColor: Color(0xFF2a2025),
    glassColor: Color(0xFFC76B8F),
  );

  static List<AppThemeColors> get all => [
        forest,
        ocean,
        sunset,
        midnight,
        gold,
        rose,
      ];

  static AppThemeColors fromType(AppThemeType type) {
    switch (type) {
      case AppThemeType.forest:
        return forest;
      case AppThemeType.ocean:
        return ocean;
      case AppThemeType.sunset:
        return sunset;
      case AppThemeType.midnight:
        return midnight;
      case AppThemeType.gold:
        return gold;
      case AppThemeType.rose:
        return rose;
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
