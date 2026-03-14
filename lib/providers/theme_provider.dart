import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App theme variants
enum AppThemeType {
  goldDark,
  woodClassic,
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

  // Custom text colors (optional)
  final Color? textPrimaryColor;
  final Color? textSecondaryColor;

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
    this.textPrimaryColor,
    this.textSecondaryColor,
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
        color: bgColor2,
      );

  Color get textPrimary => textPrimaryColor ?? (isLight ? const Color(0xFF1a1a1a) : Colors.white);
  Color get textSecondary => textSecondaryColor ?? (isLight 
      ? const Color(0xFF1a1a1a).withOpacity(0.7) 
      : Colors.white.withOpacity(0.75));

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
    accent: Color(0xFFCD7F32),       // Oltin rang
    bgColor1: Color(0xFFF4E4C1),     // Och yog'och
    bgColor2: Color(0xFFDEB887),     // BurlyWood fon
    bgColor3: Color(0xFFD2B48C),     // Tan
    surfaceColor: Color(0xFFF4E4C1), // Card fon
    glassColor: Color(0xFFCD7F32),
    isLight: true,
    textPrimaryColor: Color(0xFF4A2C1A),   // To'q jigarrang
    textSecondaryColor: Color(0xFF7A5C3A), // O'rta jigarrang
    // Extended properties
    primaryColor: Color(0xFF8B4513),  // SaddleBrown
    primaryDark: Color(0xFF6B3410),
    secondaryColor: Color(0xFFD2B48C), // Tan
    accentHighlight: Color(0xFFCD7F32),
    cardColor: Color(0xFFF4E4C1),
    borderDefault: Color(0xFFC4956A),
    borderDivider: Color(0xFFA0522D), // Sienna
    appBarColor: Color(0xFF8B4513),
    navigationColor: Color(0xFFDEB887),
    menuItemColor: Color(0xFFF4E4C1),
    boardLightSquare: Color(0xFFF0D9B5),
    boardDarkSquare: Color(0xFFB58863),
    boardHighlight: Color(0xFFE3B77B),
    buttonText: Color(0xFFFFFFFF),
    textAccent: Color(0xFFCD7F32),
    leaderboardCardColor: Color(0xFFF4E4C1),
    profileCardColor: Color(0xFFF4E4C1),
    buttonHoverColor: Color(0xFFA06E3A),
  );

  static const glassLight = AppThemeColors(
    name: 'Clean White',
    emoji: '⬜',
    accent: Color(0xFF7B5CD6),       // To'q Purple
    bgColor1: Color(0xFFFFFFFF),     // Oq
    bgColor2: Color(0xFFFFFFFF),     // Oq
    bgColor3: Color(0xFFF2F2F7),     // Och kulrang
    surfaceColor: Color(0xFFFFFFFF), // Oq
    glassColor: Color(0xFF7B5CD6),
    isLight: true,
    textPrimaryColor: Color(0xFF1C1C1E),   // Qora
    textSecondaryColor: Color(0xFF48484A), // To'q kulrang
    // Extended properties
    primaryColor: Color(0xFF7B5CD6),  // To'q Purple
    primaryDark: Color(0xFF6347B8),
    secondaryColor: Color(0xFFF2F2F7), // Och kulrang
    accentHighlight: Color(0xFF7B5CD6),
    cardColor: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFD1D1D6),
    borderDivider: Color(0xFFE5E5EA),
    appBarColor: Color(0xFFFFFFFF),
    navigationColor: Color(0xFFF2F2F7),
    menuItemColor: Color(0xFFFFFFFF),
    boardLightSquare: Color(0xFFEEEED2),
    boardDarkSquare: Color(0xFF769656),
    boardHighlight: Color(0xFFB5AFEE),
    buttonText: Color(0xFFFFFFFF),
    textAccent: Color(0xFF7B5CD6),
    leaderboardCardColor: Color(0xFFFFFFFF),
    profileCardColor: Color(0xFFFFFFFF),
    buttonHoverColor: Color(0xFF8E72DD),
  );

  static List<AppThemeColors> get all => [
        goldDark,
        woodClassic,
        glassLight,
      ];

  static AppThemeColors fromType(AppThemeType type) {
    switch (type) {
      case AppThemeType.goldDark:
        return goldDark;
      case AppThemeType.woodClassic:
        return woodClassic;
      case AppThemeType.glassLight:
        return glassLight;
    }
  }

  static AppThemeType typeFromIndex(int index) {
    if (index < 0 || index >= AppThemeType.values.length) {
      return AppThemeType.goldDark;
    }
    return AppThemeType.values[index];
  }
}

/// Theme provider for managing app theme
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_index';

  AppThemeType _currentThemeType = AppThemeType.goldDark;
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
      // Ensure index is valid for current theme count
      if (themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
        _currentThemeType = AppThemeType.values[themeIndex];
      } else {
        // Reset to default if saved index is out of range
        _currentThemeType = AppThemeType.goldDark;
        await prefs.setInt(_themeKey, 0);
      }
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
