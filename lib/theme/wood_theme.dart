import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Yog'och (Wood) Theme - Butun app uchun
/// Issiq yog'och ranglarida chess app temasi
///
/// Foydalanish:
///   WoodTheme.themeData   → MaterialApp theme
///   WoodTheme.primary     → rang olish
///   WoodTheme.cardDecoration → BoxDecoration
class WoodTheme {
  WoodTheme._();

  // ═══════════════════════════════════════════════════════════════════
  // RANGLAR (COLORS)
  // ═══════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF8B4513);       // To'q yog'och (SaddleBrown)
  static const Color secondary = Color(0xFFD2B48C);     // Och yog'och (Tan)
  static const Color background = Color(0xFFDEB887);    // Yog'och fon (BurlyWood)
  static const Color surface = Color(0xFFF4E4C1);       // Card fon (och yog'och)
  static const Color textColor = Color(0xFF4A2C1A);     // To'q jigarrang
  static const Color textColorSecondary = Color(0xFF7A5C3A); // O'rta jigarrang
  static const Color accent = Color(0xFFCD7F32);        // Oltin rang
  static const Color dividerColor = Color(0xFFA0522D);  // Sienna (yog'och soya)
  static const Color borderColor = Color(0xFFC4956A);   // Yog'och border
  static const Color error = Color(0xFFF44336);

  // AppBar / Navigation
  static const Color appBar = Color(0xFF8B4513);
  static const Color navigation = Color(0xFFDEB887);

  // Chess board
  static const Color boardLight = Color(0xFFF0D9B5);
  static const Color boardDark = Color(0xFFB58863);
  static const Color boardHighlight = Color(0xFFE3B77B);

  // Medal colors
  static const Color medalGold = Color(0xFFCD7F32);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFA0522D);

  // ═══════════════════════════════════════════════════════════════════
  // LAYOUT CONSTANTS
  // ═══════════════════════════════════════════════════════════════════
  static const double kBorderRadius = 12.0;
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
  // SHADOWS (yog'ochga mos)
  // ═══════════════════════════════════════════════════════════════════
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(color: Color(0x55000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 3), blurRadius: 6),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // GRADIENTS (yog'och texture)
  // ═══════════════════════════════════════════════════════════════════
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDEB887), Color(0xFFD2B48C), Color(0xFFC4956A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4E4C1), Color(0xFFEAD5A8)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9A5B2F), Color(0xFF7A3F15)],
  );

  // ═══════════════════════════════════════════════════════════════════
  // DECORATIONS
  // ═══════════════════════════════════════════════════════════════════
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(kBorderRadius),
    border: Border.all(color: borderColor, width: 0.5),
    boxShadow: cardShadow,
  );

  static BoxDecoration get panelDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(kBorderRadius),
    border: Border.all(color: borderColor, width: 1.0),
    boxShadow: elevatedShadow,
  );

  // ═══════════════════════════════════════════════════════════════════
  // TEXT THEME
  // ═══════════════════════════════════════════════════════════════════
  static TextTheme get textTheme => TextTheme(
    // Headline 1: 24px Bold
    displayLarge: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
    displayMedium: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
    displaySmall: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
    headlineLarge: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
    // Headline 2: 20px SemiBold
    headlineMedium: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
    // Title: 18px SemiBold
    headlineSmall: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
    titleLarge: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
    // Subtitle: 16px Medium
    titleMedium: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
    titleSmall: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
    // Body: 14px Regular
    bodyLarge: GoogleFonts.playfairDisplay(fontSize: 16, color: textColor),
    bodyMedium: GoogleFonts.playfairDisplay(fontSize: 14, color: textColor),
    // Caption: 12px Regular
    bodySmall: GoogleFonts.playfairDisplay(fontSize: 12, color: textColorSecondary),
    // Button: 16px Medium
    labelLarge: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
    labelMedium: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
    labelSmall: GoogleFonts.cinzel(fontSize: 12, color: textColorSecondary),
  );

  // ═══════════════════════════════════════════════════════════════════
  // THEME DATA - MaterialApp uchun
  // ═══════════════════════════════════════════════════════════════════
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent, // WoodBackground handles it
      cardColor: surface,
      dividerColor: dividerColor,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: background,
        onPrimary: Colors.white,
        onSecondary: textColor,
        onSurface: textColor,
        error: error,
        onError: Colors.white,
      ),
      textTheme: textTheme,

      // AppBar: Height 56px, wood color, 20px SemiBold
      appBarTheme: AppBarTheme(
        backgroundColor: appBar,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: kAppBarHeight,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Cards: border radius 12px, padding 16px, margin 8px
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
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
          textStyle: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500),
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
        fillColor: surface,
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
        backgroundColor: appBar,
        selectedItemColor: accent,
        unselectedItemColor: secondary,
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
