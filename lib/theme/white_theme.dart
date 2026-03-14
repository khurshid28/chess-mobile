import 'package:flutter/material.dart';

/// Oq (White) Theme - Butun app uchun
/// Toza oq rangda, purple accent bilan
///
/// Foydalanish:
///   WhiteTheme.themeData   → MaterialApp theme
///   WhiteTheme.primary     → rang olish
///   WhiteTheme.cardDecoration → BoxDecoration
///
/// Glassmorphism/blur effekt YO'Q - oddiy oq card lar
class WhiteTheme {
  WhiteTheme._();

  // ═══════════════════════════════════════════════════════════════════
  // RANGLAR (COLORS)
  // ═══════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF8A6DE9);       // Purple
  static const Color secondary = Color(0xFFF2F2F7);     // Och kulrang
  static const Color background = Color(0xFFFFFFFF);    // Oq
  static const Color surface = Color(0xFFFFFFFF);       // Oq (card lar)
  static const Color textColor = Color(0xFF1C1C1E);     // Qora
  static const Color textColorSecondary = Color(0xFF6C6C70); // Kulrang
  static const Color accent = Color(0xFF8A6DE9);        // Purple
  static const Color dividerColor = Color(0xFFE5E5EA);  // Och kulrang chiziq
  static const Color borderColor = Color(0xFFE5E5EA);   // Och kulrang border
  static const Color error = Color(0xFFF44336);

  // AppBar / Navigation
  static const Color appBar = Color(0xFFFFFFFF);
  static const Color navigation = Color(0xFFF2F2F7);

  // Chess board
  static const Color boardLight = Color(0xFFEEEED2);
  static const Color boardDark = Color(0xFF769656);
  static const Color boardHighlight = Color(0xFFB5AFEE);

  // ═══════════════════════════════════════════════════════════════════
  // LAYOUT CONSTANTS
  // ═══════════════════════════════════════════════════════════════════
  static const double kBorderRadius = 16.0;
  static const double kCardPadding = 16.0;
  static const double kCardMargin = 8.0;
  static const double kButtonHeight = 48.0;
  static const double kButtonRadius = 8.0;
  static const double kInputHeight = 48.0;
  static const double kInputRadius = 8.0;
  static const double kAppBarHeight = 56.0;
  static const double kBottomNavHeight = 60.0;
  static const double kListItemHeight = 56.0;

  // ═══════════════════════════════════════════════════════════════════
  // SHADOWS (engil, oddiy)
  // ═══════════════════════════════════════════════════════════════════
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 2), blurRadius: 10),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 16),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // DECORATIONS
  // ═══════════════════════════════════════════════════════════════════
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(kBorderRadius),
    border: Border.all(color: borderColor, width: 0.5),
    boxShadow: cardShadow,
  );

  // ═══════════════════════════════════════════════════════════════════
  // TEXT THEME
  // ═══════════════════════════════════════════════════════════════════
  static TextTheme get textTheme {
    const textPrimary = textColor;
    const textSec = textColorSecondary;

    return TextTheme(
      // Headline 1: 24px Bold
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      // Headline 2: 20px SemiBold
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      // Title: 18px SemiBold
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      // Subtitle: 16px Medium
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      // Body: 14px Regular
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
      // Caption: 12px Regular
      bodySmall: TextStyle(fontSize: 12, color: textSec),
      // Button: 16px Medium
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      labelSmall: TextStyle(fontSize: 12, color: textSec),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // THEME DATA - MaterialApp uchun
  // ═══════════════════════════════════════════════════════════════════
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: dividerColor,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: textColor,
        onSurface: textColor,
        error: error,
        onError: Colors.white,
      ),
      textTheme: textTheme,

      // AppBar: Height 56px, oq bg, 20px SemiBold
      appBarTheme: const AppBarTheme(
        backgroundColor: appBar,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: kAppBarHeight,
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: textColor,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),

      // Cards: border radius 16px, padding 16px, margin 8px
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        margin: const EdgeInsets.all(kCardMargin),
      ),

      // Buttons: Height 48px, radius 8px, text 16px Medium
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, kButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kButtonRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, kButtonHeight),
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kButtonRadius),
          ),
        ),
      ),

      // Input Fields: Height 48px, radius 8px, padding 12px
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kInputRadius),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kInputRadius),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kInputRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textColorSecondary),
      ),

      // Bottom Navigation: Height 60px, icons 24px
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navigation,
        selectedItemColor: primary,
        unselectedItemColor: textColorSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
        ),
      ),

      iconTheme: const IconThemeData(color: textColor),

      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 0,
      ),

      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
