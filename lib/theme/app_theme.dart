import 'package:flutter/material.dart';
import 'package:chess_park/providers/theme_provider.dart';
import 'package:chess_park/theme/theme_colors.dart';

class AppTheme {
  static const double kBorderRadius = 10.0;

  // Current theme colors (updated by ThemeProvider)
  static AppThemeColors _currentColors = AppThemes.goldDark;

  // Update current theme colors
  static void updateColors(AppThemeColors colors) {
    _currentColors = colors;
  }

  // ═══════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color get kColorTextPrimary => _currentColors.textPrimary;
  static Color get kColorTextSecondary => _currentColors.textSecondary;
  static Color get kTextAccent => _currentColors.textAccent ?? _currentColors.accent;
  
  // ═══════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS (use SemanticColors for consistency)
  // ═══════════════════════════════════════════════════════════════════
  static const Color kColorLoss = SemanticColors.loss;
  static const Color kColorWin = SemanticColors.win;
  static const Color kColorDraw = SemanticColors.draw;
  static const Color kColorSuccess = SemanticColors.success;
  static const Color kColorWarning = SemanticColors.warning;
  static const Color kColorError = SemanticColors.error;
  static const Color kColorInfo = SemanticColors.info;

  // ═══════════════════════════════════════════════════════════════════
  // ACCENT & PRIMARY COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color get kColorAccent => _currentColors.accent;
  static Color get accentColor => _currentColors.accent;
  static Color get winColor => _currentColors.accent;
  static Color get kPrimaryColor => _currentColors.primary;
  static Color get kPrimaryDarkColor => _currentColors.primaryDark ?? _currentColors.primary;
  static Color get kSecondaryColor => _currentColors.secondary;
  static Color get kHighlightColor => _currentColors.highlight;

  // ═══════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color get kBgColor1 => _currentColors.bgColor1;
  static Color get kBgColor2 => _currentColors.bgColor2;
  static Color get kBgColor3 => _currentColors.bgColor3;
  static Color get kSurfaceColor => _currentColors.surfaceColor;
  
  static bool get isLight => _currentColors.isLight;

  // ═══════════════════════════════════════════════════════════════════
  // CARD COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color get kCardColor => _currentColors.card;
  static Color get kLeaderboardCardColor => _currentColors.leaderboardCard;
  static Color get kProfileCardColor => _currentColors.profileCard;
  
  // ═══════════════════════════════════════════════════════════════════
  // UI COMPONENT COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color get kAppBarColor => _currentColors.appBar;
  static Color get kNavigationColor => _currentColors.navigation;
  static Color get kMenuItemColor => _currentColors.menuItem;
  
  // ═══════════════════════════════════════════════════════════════════
  // CHESS BOARD COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color? get kBoardLightSquare => _currentColors.boardLightSquare;
  static Color? get kBoardDarkSquare => _currentColors.boardDarkSquare;
  static Color? get kBoardHighlight => _currentColors.boardHighlight;
  
  // ═══════════════════════════════════════════════════════════════════
  // BUTTON COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color get kButtonTextColor => _currentColors.buttonText ?? (isLight ? Colors.white : Colors.black);
  static Color get kButtonPrimaryColor => _currentColors.primary;
  static Color get kButtonSecondaryColor => _currentColors.secondary;
  static Color get kButtonHoverColor => _currentColors.buttonHover;

  // ═══════════════════════════════════════════════════════════════════
  // BORDER COLORS
  // ═══════════════════════════════════════════════════════════════════
  static Color get kBorderColor => _currentColors.borderDefault ?? (isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1));
  static Color get kDividerColor => _currentColors.borderDivider ?? (isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05));

  // ═══════════════════════════════════════════════════════════════════
  // HELPER COLORS (theme-aware)
  // ═══════════════════════════════════════════════════════════════════
  /// Theme-aware container background color (use instead of Colors.white.withOpacity(0.1))
  static Color get containerBgColor => isLight 
      ? Colors.black.withOpacity(0.05) 
      : Colors.white.withOpacity(0.1);
  
  /// Theme-aware divider color
  static Color get dividerColor => kDividerColor;
  
  /// Theme-aware glass effect color
  static Color get glassColor => _currentColors.glassColor.withOpacity(0.1);

  // ═══════════════════════════════════════════════════════════════════
  // DECORATIONS
  // ═══════════════════════════════════════════════════════════════════
  static BoxDecoration get backgroundDecoration => _currentColors.backgroundDecoration;
  
  /// Card decoration with proper theme colors
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: kCardColor,
    borderRadius: BorderRadius.circular(kBorderRadius),
    border: Border.all(color: kBorderColor, width: 0.5),
  );
  
  /// Leaderboard card decoration
  static BoxDecoration get leaderboardCardDecoration => BoxDecoration(
    color: kLeaderboardCardColor,
    borderRadius: BorderRadius.circular(kBorderRadius),
    border: Border.all(color: kBorderColor, width: 0.5),
  );
  
  /// Profile card decoration
  static BoxDecoration get profileCardDecoration => BoxDecoration(
    color: kProfileCardColor,
    borderRadius: BorderRadius.circular(kBorderRadius),
    border: Border.all(color: kBorderColor, width: 0.5),
  );

  // ═══════════════════════════════════════════════════════════════════
  // RATING COLOR HELPER
  // ═══════════════════════════════════════════════════════════════════
  static Color getRatingColor(int rating) => SemanticColors.getRatingColor(rating);

  static ThemeData get darkTheme {
    final accent = _currentColors.accent;
    final primary = _currentColors.primary;
    final secondary = _currentColors.secondary;
    final bgColor1 = _currentColors.bgColor1;
    final bgColor2 = _currentColors.bgColor2;
    final bgColor3 = _currentColors.bgColor3;
    final cardBgColor = _currentColors.card;
    final appBarBgColor = _currentColors.appBar;
    final navigationBgColor = _currentColors.navigation;
    final isLightTheme = _currentColors.isLight;
    final textPrimary = _currentColors.textPrimary;
    final textSecondary = _currentColors.textSecondary;
    final buttonTextColor = _currentColors.buttonText ?? (isLightTheme ? Colors.white : Colors.black);
    
    final brightness = isLightTheme ? Brightness.light : Brightness.dark;
    final TextTheme baseTextTheme = ThemeData(brightness: brightness).textTheme;

    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: bgColor2,
      cardColor: cardBgColor,
      dividerColor: _currentColors.borderDivider ?? (isLightTheme ? Colors.black.withAlpha(20) : Colors.white.withAlpha(38)),
      colorScheme: isLightTheme 
          ? ColorScheme.light(
              primary: primary,
              secondary: secondary,
              surface: bgColor2,
              onPrimary: buttonTextColor,
              onSecondary: buttonTextColor,
              onSurface: textPrimary,
              error: kColorLoss,
              onError: Colors.white,
            )
          : ColorScheme.dark(
              primary: primary,
              secondary: secondary,
              surface: bgColor2,
              onPrimary: buttonTextColor,
              onSecondary: buttonTextColor,
              onSurface: textPrimary,
              error: kColorLoss,
              onError: Colors.white,
            ),
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textPrimary),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBgColor,
        elevation: appBarBgColor == Colors.transparent ? 0 : 0.5,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: _currentColors.borderDefault ?? primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bgColor3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navigationBgColor,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}