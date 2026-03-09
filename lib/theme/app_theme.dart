import 'package:flutter/material.dart';
import 'package:chess_park/providers/theme_provider.dart';

class AppTheme {
  static const double kBorderRadius = 10.0;

  // Current theme colors (updated by ThemeProvider)
  static AppThemeColors _currentColors = AppThemes.forest;

  // Update current theme colors
  static void updateColors(AppThemeColors colors) {
    _currentColors = colors;
  }

  // Dynamic text colors based on theme
  static Color get kColorTextPrimary => _currentColors.textPrimary;
  static Color get kColorTextSecondary => _currentColors.textSecondary;
  static const Color kColorLoss = Color(0xFFF44336);

  // Dynamic color accessors - USE THESE for accent colors
  static Color get kColorAccent => _currentColors.accent;
  static Color get kColorWin => _currentColors.accent;
  static Color get accentColor => _currentColors.accent;
  static Color get winColor => _currentColors.accent;

  static Color get kBgColor1 => _currentColors.bgColor1;
  static Color get kBgColor2 => _currentColors.bgColor2;
  static Color get kBgColor3 => _currentColors.bgColor3;
  
  static bool get isLight => _currentColors.isLight;

  static BoxDecoration get backgroundDecoration => _currentColors.backgroundDecoration;

  static ThemeData get darkTheme {
    final accent = _currentColors.accent;
    final bgColor1 = _currentColors.bgColor1;
    final bgColor2 = _currentColors.bgColor2;
    final bgColor3 = _currentColors.bgColor3;
    final isLightTheme = _currentColors.isLight;
    final textPrimary = _currentColors.textPrimary;
    final textSecondary = _currentColors.textSecondary;
    
    final brightness = isLightTheme ? Brightness.light : Brightness.dark;
    final TextTheme baseTextTheme = ThemeData(brightness: brightness).textTheme;

    return ThemeData(
      brightness: brightness,
      primaryColor: accent,
      scaffoldBackgroundColor: bgColor2,
      cardColor: isLightTheme ? Colors.black.withAlpha(13) : Colors.white.withAlpha(26),
      dividerColor: isLightTheme ? Colors.black.withAlpha(20) : Colors.white.withAlpha(38),
      colorScheme: isLightTheme 
          ? ColorScheme.light(
              primary: accent,
              secondary: accent,
              surface: bgColor2,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: textPrimary,
              error: kColorLoss,
              onError: Colors.white,
            )
          : ColorScheme.dark(
              primary: accent,
              secondary: accent,
              surface: bgColor2,
              onPrimary: Colors.black,
              onSecondary: Colors.black,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent),
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
        fillColor: isLightTheme ? Colors.black.withAlpha(13) : Colors.white.withAlpha(26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bgColor3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
        ),
      ),
    );
  }
}