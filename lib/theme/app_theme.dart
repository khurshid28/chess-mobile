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

  // Const colors for widgets that require const
  static const Color kColorAccent = Color(0xFF4CAF50); // Default green - use Theme.of(context).colorScheme.primary for dynamic
  static const Color kColorTextPrimary = Colors.white;
  static const Color kColorTextSecondary = Color.fromRGBO(255, 255, 255, 0.75);
  static const Color kColorWin = Color(0xFF4CAF50);
  static const Color kColorLoss = Color(0xFFF44336);

  // Dynamic color accessors (use these for non-const contexts)
  static Color get accentColor => _currentColors.accent;
  static Color get winColor => _currentColors.accent;

  static Color get kBgColor1 => _currentColors.bgColor1;
  static Color get kBgColor2 => _currentColors.bgColor2;
  static Color get kBgColor3 => _currentColors.bgColor3;

  static BoxDecoration get backgroundDecoration => _currentColors.backgroundDecoration;

  static ThemeData get darkTheme {
    final TextTheme baseTextTheme = ThemeData(brightness: Brightness.dark).textTheme;

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kColorAccent,
      scaffoldBackgroundColor: kBgColor2,
      cardColor: Colors.white.withAlpha(26),
      dividerColor: Colors.white.withAlpha(38),
      colorScheme: ColorScheme.dark(
        primary: kColorAccent,
        secondary: kColorAccent,
        surface: kBgColor2,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: kColorTextPrimary,
        error: kColorLoss,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kColorTextPrimary,
        ),
        iconTheme: IconThemeData(color: kColorTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kColorAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kColorAccent,
          side: BorderSide(color: kColorAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kBgColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: kColorAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: kColorTextSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: kBgColor3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
        ),
      ),
    );
  }
}