import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App theme variants
enum AppThemeType {
  // Dark themes
  forest,
  ocean,
  midnight,
  roseDark,
  goldDark,
  woodClassic,
  // Light themes
  cream,
  sky,
  peach,
  mint,
  glassLight,
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

  // Extended color properties (JSON mapping)
  final Color? primaryColor;      // colors.primary -> Primary buttons
  final Color? primaryDark;       // colors.primaryDark
  final Color? secondaryColor;    // colors.secondary -> Secondary buttons
  final Color? accentHighlight;   // colors.accent -> Highlights
  
  final Color? cardColor;         // background.card -> Cards
  final Color? borderDefault;     // border.default
  final Color? borderDivider;     // border.divider
  
  final Color? appBarColor;       // ui.appBar -> AppBar
  final Color? navigationColor;   // ui.navigation -> BottomNavigationBar
  final Color? menuItemColor;     // ui.menuItem -> Menu items
  
  final Color? boardLightSquare;  // chessBoard.light
  final Color? boardDarkSquare;   // chessBoard.dark
  final Color? boardHighlight;    // chessBoard.highlight
  
  final Color? buttonText;        // buttons.text
  final Color? textAccent;        // text.accent
  
  // UI component card colors
  final Color? leaderboardCardColor;  // ui.leaderboardCard
  final Color? profileCardColor;      // ui.profileCard
  final Color? buttonHoverColor;      // buttons.hover

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
    // Extended properties (optional for backward compatibility)
    this.primaryColor,
    this.primaryDark,
    this.secondaryColor,
    this.accentHighlight,
    this.cardColor,
    this.borderDefault,
    this.borderDivider,
    this.appBarColor,
    this.navigationColor,
    this.menuItemColor,
    this.boardLightSquare,
    this.boardDarkSquare,
    this.boardHighlight,
    this.buttonText,
    this.textAccent,
    this.leaderboardCardColor,
    this.profileCardColor,
    this.buttonHoverColor,
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

  // Getters with fallback to existing properties
  Color get primary => primaryColor ?? accent;
  Color get secondary => secondaryColor ?? accent.withOpacity(0.7);
  Color get card => cardColor ?? surfaceColor;
  Color get appBar => appBarColor ?? Colors.transparent;
  Color get leaderboardCard => leaderboardCardColor ?? card;
  Color get profileCard => profileCardColor ?? card;
  Color get buttonHover => buttonHoverColor ?? primary.withOpacity(0.8);
  Color get navigation => navigationColor ?? (isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1));
  Color get menuItem => menuItemColor ?? surfaceColor;
  Color get highlight => accentHighlight ?? accent;
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

  // === PREMIUM THEMES ===
  static const goldDark = AppThemeColors(
    name: 'Gold Dark',
    emoji: '🏆',
    accent: Color(0xFFCFA24A),
    bgColor1: Color(0xFF1A1A1D),
    bgColor2: Color(0xFF0F0F10),
    bgColor3: Color(0xFF0F0F10),
    surfaceColor: Color(0xFF1A1A1D),
    glassColor: Color(0xFFCFA24A),
    isLight: false,
    // Extended properties from JSON
    primaryColor: Color(0xFFCFA24A),
    primaryDark: Color(0xFF8A5E1A),
    secondaryColor: Color(0xFFF5C76B),
    accentHighlight: Color(0xFFFFD978),
    cardColor: Color(0xFF222225),
    borderDefault: Color(0xFF3A3A3D),
    borderDivider: Color(0xFF2A2A2C),
    appBarColor: Color(0xFF1A1A1D),
    navigationColor: Color(0xFF141416),
    menuItemColor: Color(0xFF222225),
    boardLightSquare: Color(0xFFF2D7A3),
    boardDarkSquare: Color(0xFF8B5A2B),
    boardHighlight: Color(0xFFFFD978),
    buttonText: Color(0xFF000000),
    textAccent: Color(0xFFFFD978),
    leaderboardCardColor: Color(0xFF1F1F22),
    profileCardColor: Color(0xFF1C1C1F),
    buttonHoverColor: Color(0xFFE6B85A),
  );

  static const woodClassic = AppThemeColors(
    name: 'Classic Wood',
    emoji: '🪵',
    accent: Color(0xFF8B5A2B),
    bgColor1: Color(0xFF5A3A1F),
    bgColor2: Color(0xFF3A2414),
    bgColor3: Color(0xFF3A2414),
    surfaceColor: Color(0xFF5A3A1F),
    glassColor: Color(0xFF8B5A2B),
    isLight: false,
    // Extended properties from JSON
    primaryColor: Color(0xFF8B5A2B),
    primaryDark: Color(0xFF5E3A1A),
    secondaryColor: Color(0xFFC79A63),
    accentHighlight: Color(0xFFE3B77B),
    cardColor: Color(0xFF6B4423),
    borderDefault: Color(0xFF7A4F2A),
    borderDivider: Color(0xFF5A3A1F),
    appBarColor: Color(0xFF4A2E1A),
    navigationColor: Color(0xFF3A2414),
    menuItemColor: Color(0xFF5A3A1F),
    boardLightSquare: Color(0xFFF0D9B5),
    boardDarkSquare: Color(0xFFB58863),
    boardHighlight: Color(0xFFE3B77B),
    buttonText: Color(0xFFFFFFFF),
    textAccent: Color(0xFFFFD28A),
    leaderboardCardColor: Color(0xFF6B4423),
    profileCardColor: Color(0xFF5A3A1F),
    buttonHoverColor: Color(0xFFA36B37),
  );

  static const glassLight = AppThemeColors(
    name: 'Glass Light',
    emoji: '💎',
    accent: Color(0xFF7BA7A6),
    bgColor1: Color(0xFFF4F7F9),
    bgColor2: Color(0xFFE9F0F3),
    bgColor3: Color(0xFFE9F0F3),
    surfaceColor: Color(0xFFF4F7F9),
    glassColor: Color(0xFF7BA7A6),
    isLight: true,
    // Extended properties from JSON
    primaryColor: Color(0xFF7BA7A6),
    primaryDark: Color(0xFF5C8F8D),
    secondaryColor: Color(0xFFA6C8C6),
    accentHighlight: Color(0xFF8FD0CE),
    cardColor: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFD6E1E6),
    borderDivider: Color(0xFFE3EDF2),
    appBarColor: Color(0xFFF4F7F9),
    navigationColor: Color(0xFFE9F0F3),
    menuItemColor: Color(0xFFFFFFFF),
    boardLightSquare: Color(0xFFEEEED2),
    boardDarkSquare: Color(0xFF769656),
    boardHighlight: Color(0xFF8FD0CE),
    buttonText: Color(0xFFFFFFFF),
    textAccent: Color(0xFF4C9A97),
    leaderboardCardColor: Color(0xFFFFFFFF),
    profileCardColor: Color(0xFFFFFFFF),
    buttonHoverColor: Color(0xFF8EC1BF),
  );

  static List<AppThemeColors> get all => [
        // Dark themes first
        forest,
        ocean,
        midnight,
        roseDark,
        goldDark,
        woodClassic,
        // Light themes
        cream,
        sky,
        peach,
        mint,
        glassLight,
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
      case AppThemeType.goldDark:
        return goldDark;
      case AppThemeType.woodClassic:
        return woodClassic;
      case AppThemeType.cream:
        return cream;
      case AppThemeType.sky:
        return sky;
      case AppThemeType.peach:
        return peach;
      case AppThemeType.mint:
        return mint;
      case AppThemeType.glassLight:
        return glassLight;
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
