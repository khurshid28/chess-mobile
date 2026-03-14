import 'package:flutter/material.dart';

/// Centralized theme color definitions from JSON configuration.
/// Each theme contains all color tokens for the chess application.
/// 
/// JSON Structure Mapping:
/// - background.app → Scaffold background
/// - background.surface → Container backgrounds  
/// - background.card → Card widgets
/// - text.primary → Main titles
/// - text.secondary → Subtitles, descriptions
/// - text.accent → Highlighted text
/// - buttons.primary → ElevatedButton background
/// - buttons.secondary → Secondary buttons
/// - buttons.hover → Hover/active states
/// - buttons.text → Button text color
/// - ui.appBar → AppBar background
/// - ui.navigation → BottomNavigationBar
/// - ui.menuItem → Menu list items
/// - ui.leaderboardCard → Leaderboard container
/// - ui.profileCard → Player profile card
/// - chessBoard.light → Light square
/// - chessBoard.dark → Dark square
/// - chessBoard.highlight → Selected/last move

/// Complete theme color scheme with all JSON tokens
class ChessThemeColors {
  // Meta
  final String name;
  final String emoji;
  final bool isDark;
  final String description;

  // Background colors
  final Color backgroundApp;
  final Color backgroundSurface;
  final Color backgroundCard;

  // Primary colors
  final Color colorPrimary;
  final Color colorPrimaryDark;
  final Color colorSecondary;
  final Color colorAccent;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textAccent;

  // Button colors
  final Color buttonPrimary;
  final Color buttonSecondary;
  final Color buttonHover;
  final Color buttonText;

  // Border colors
  final Color borderDefault;
  final Color borderDivider;

  // Chess board colors
  final Color boardLight;
  final Color boardDark;
  final Color boardHighlight;

  // UI component colors
  final Color uiAppBar;
  final Color uiNavigation;
  final Color uiMenuItem;
  final Color uiLeaderboardCard;
  final Color uiProfileCard;

  const ChessThemeColors({
    required this.name,
    required this.emoji,
    required this.isDark,
    required this.description,
    required this.backgroundApp,
    required this.backgroundSurface,
    required this.backgroundCard,
    required this.colorPrimary,
    required this.colorPrimaryDark,
    required this.colorSecondary,
    required this.colorAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textAccent,
    required this.buttonPrimary,
    required this.buttonSecondary,
    required this.buttonHover,
    required this.buttonText,
    required this.borderDefault,
    required this.borderDivider,
    required this.boardLight,
    required this.boardDark,
    required this.boardHighlight,
    required this.uiAppBar,
    required this.uiNavigation,
    required this.uiMenuItem,
    required this.uiLeaderboardCard,
    required this.uiProfileCard,
  });

  /// Get gradient background decoration
  BoxDecoration get backgroundGradient => BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [backgroundSurface, backgroundApp, backgroundApp],
      stops: const [0.0, 0.3, 1.0],
    ),
  );

  /// Get solid background decoration
  BoxDecoration get backgroundSolid => BoxDecoration(
    color: backgroundApp,
  );
}

/// All premium theme definitions from JSON
class ChessThemes {
  ChessThemes._();

  // ═══════════════════════════════════════════════════════════════════
  // GOLD DARK THEME
  // ═══════════════════════════════════════════════════════════════════
  static const goldDark = ChessThemeColors(
    name: 'Gold Dark',
    emoji: '🏆',
    isDark: true,
    description: 'Premium dark gold chess theme',
    
    // Background
    backgroundApp: Color(0xFF0F0F10),
    backgroundSurface: Color(0xFF1A1A1D),
    backgroundCard: Color(0xFF222225),
    
    // Colors
    colorPrimary: Color(0xFFCFA24A),
    colorPrimaryDark: Color(0xFF8A5E1A),
    colorSecondary: Color(0xFFF5C76B),
    colorAccent: Color(0xFFFFD978),
    
    // Text
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8B8B8),
    textAccent: Color(0xFFFFD978),
    
    // Buttons
    buttonPrimary: Color(0xFFCFA24A),
    buttonSecondary: Color(0xFF3A3A3D),
    buttonHover: Color(0xFFE6B85A),
    buttonText: Color(0xFF000000),
    
    // Borders
    borderDefault: Color(0xFF3A3A3D),
    borderDivider: Color(0xFF2A2A2C),
    
    // Chess Board
    boardLight: Color(0xFFF2D7A3),
    boardDark: Color(0xFF8B5A2B),
    boardHighlight: Color(0xFFFFD978),
    
    // UI Components
    uiAppBar: Color(0xFF1A1A1D),
    uiNavigation: Color(0xFF141416),
    uiMenuItem: Color(0xFF222225),
    uiLeaderboardCard: Color(0xFF1F1F22),
    uiProfileCard: Color(0xFF1C1C1F),
  );

  // ═══════════════════════════════════════════════════════════════════
  // WOOD CLASSIC THEME
  // ═══════════════════════════════════════════════════════════════════
  static const woodClassic = ChessThemeColors(
    name: 'Classic Wood',
    emoji: '🪵',
    isDark: false,
    description: 'Warm wooden chess board style',
    
    // Background
    backgroundApp: Color(0xFFDEB887),
    backgroundSurface: Color(0xFFF4E4C1),
    backgroundCard: Color(0xFFF4E4C1),
    
    // Colors
    colorPrimary: Color(0xFF8B4513),
    colorPrimaryDark: Color(0xFF6B3410),
    colorSecondary: Color(0xFFD2B48C),
    colorAccent: Color(0xFFCD7F32),
    
    // Text
    textPrimary: Color(0xFF4A2C1A),
    textSecondary: Color(0xFF7A5C3A),
    textAccent: Color(0xFFCD7F32),
    
    // Buttons
    buttonPrimary: Color(0xFF8B4513),
    buttonSecondary: Color(0xFFD2B48C),
    buttonHover: Color(0xFFA06E3A),
    buttonText: Color(0xFFFFFFFF),
    
    // Borders
    borderDefault: Color(0xFFC4956A),
    borderDivider: Color(0xFFA0522D),
    
    // Chess Board
    boardLight: Color(0xFFF0D9B5),
    boardDark: Color(0xFFB58863),
    boardHighlight: Color(0xFFE3B77B),
    
    // UI Components
    uiAppBar: Color(0xFF8B4513),
    uiNavigation: Color(0xFFDEB887),
    uiMenuItem: Color(0xFFF4E4C1),
    uiLeaderboardCard: Color(0xFFF4E4C1),
    uiProfileCard: Color(0xFFF4E4C1),
  );

  // ═══════════════════════════════════════════════════════════════════
  // CLEAN WHITE THEME
  // ═══════════════════════════════════════════════════════════════════
  static const glassLight = ChessThemeColors(
    name: 'Clean White',
    emoji: '⬜',
    isDark: false,
    description: 'Clean white UI with purple accent',
    
    // Background
    backgroundApp: Color(0xFFFFFFFF),
    backgroundSurface: Color(0xFFFFFFFF),
    backgroundCard: Color(0xFFFFFFFF),
    
    // Colors
    colorPrimary: Color(0xFF8A6DE9),
    colorPrimaryDark: Color(0xFF6B4FCC),
    colorSecondary: Color(0xFFF2F2F7),
    colorAccent: Color(0xFF8A6DE9),
    
    // Text
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF6C6C70),
    textAccent: Color(0xFF8A6DE9),
    
    // Buttons
    buttonPrimary: Color(0xFF8A6DE9),
    buttonSecondary: Color(0xFFF2F2F7),
    buttonHover: Color(0xFF9D84EE),
    buttonText: Color(0xFFFFFFFF),
    
    // Borders
    borderDefault: Color(0xFFE5E5EA),
    borderDivider: Color(0xFFE5E5EA),
    
    // Chess Board
    boardLight: Color(0xFFEEEED2),
    boardDark: Color(0xFF769656),
    boardHighlight: Color(0xFFB5AFEE),
    
    // UI Components
    uiAppBar: Color(0xFFFFFFFF),
    uiNavigation: Color(0xFFF2F2F7),
    uiMenuItem: Color(0xFFFFFFFF),
    uiLeaderboardCard: Color(0xFFFFFFFF),
    uiProfileCard: Color(0xFFFFFFFF),
  );

  /// Get all premium themes
  static List<ChessThemeColors> get premiumThemes => [
    goldDark,
    woodClassic,
    glassLight,
  ];

  /// Get theme by name
  static ChessThemeColors? getByName(String name) {
    return premiumThemes.firstWhere(
      (t) => t.name.toLowerCase() == name.toLowerCase(),
      orElse: () => goldDark,
    );
  }
}

/// Semantic color constants for the app
class SemanticColors {
  SemanticColors._();

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Game result colors
  static const Color win = Color(0xFF4CAF50);
  static const Color loss = Color(0xFFF44336);
  static const Color draw = Color(0xFF9E9E9E);

  // Rating colors
  static Color getRatingColor(int rating) {
    if (rating < 800) return const Color(0xFF4CAF50);   // Green - Beginner
    if (rating < 1200) return const Color(0xFF8BC34A);  // Light Green
    if (rating < 1600) return const Color(0xFF2196F3); // Blue - Intermediate
    if (rating < 2000) return const Color(0xFF9C27B0); // Purple - Advanced
    if (rating < 2400) return const Color(0xFFFF9800); // Orange - Expert
    return const Color(0xFFF44336);                     // Red - Master
  }

  // Badge colors
  static const Color badgeBronze = Color(0xFFCD7F32);
  static const Color badgeSilver = Color(0xFFC0C0C0);
  static const Color badgeGold = Color(0xFFFFD700);
  static const Color badgePlatinum = Color(0xFFE5E4E2);
  static const Color badgeDiamond = Color(0xFFB9F2FF);
}
