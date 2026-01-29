/*
import 'package:flutter/material.dart';

class AppTheme {

  static const double kBorderRadius = 10.0;


  static const Color kColorAccent = Color(0xFFF0B90B);
  static const Color kColorTextPrimary = Colors.white;
  static const Color kColorTextSecondary = Color.fromRGBO(255, 255, 255, 0.75);
  static const Color kColorWin = kColorAccent;
  static const Color kColorLoss = Color(0xFFF44336);


  static const Color kBgColor1 = Color(0xFF414345);
  static const Color kBgColor2 = Color(0xFF424342);
  static const Color kBgColor3 = Color(0xFF413C36);


  static const BoxDecoration backgroundDecoration = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        kBgColor1,
        kBgColor2,
        kBgColor3,
      ],
      stops: [
        0.0,
        0.3,
        1.0,
      ],
    ),
  );

  static ThemeData get darkTheme {

      final TextTheme baseTextTheme = ThemeData(brightness: Brightness.dark).textTheme;


    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kColorAccent,

      scaffoldBackgroundColor: kBgColor2,

      cardColor: Colors.white.withAlpha(230),
      dividerColor: Colors.white.withAlpha(230),
      colorScheme: const ColorScheme.dark(
        primary: kColorAccent,
        secondary: kColorAccent,


        surface: Color(0xFF3B4252),
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
          side: const BorderSide(color: kColorAccent),
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
        fillColor: Colors.white.withAlpha(230),
        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: const BorderSide(color: kColorAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: kColorTextSecondary),
      ),
       bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kBgColor3,
        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
        ),
      ),
    );
  }
}
*/





import 'package:flutter/material.dart';

class AppTheme {

  static const double kBorderRadius = 10.0;


  static const Color kColorAccent = Color(0xFFF0B90B);
  static const Color kColorTextPrimary = Colors.white;
  static const Color kColorTextSecondary = Color.fromRGBO(255, 255, 255, 0.75);
  static const Color kColorWin = kColorAccent;
  static const Color kColorLoss = Color(0xFFF44336);


  static const Color kBgColor1 = Color(0xFF414345);
  static const Color kBgColor2 = Color(0xFF424342);
  static const Color kBgColor3 = Color(0xFF413C36);


  static const BoxDecoration backgroundDecoration = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        kBgColor1,
        kBgColor2,
        kBgColor3,
      ],
      stops: [
        0.0,
        0.3,
        1.0,
      ],
    ),
  );

  static ThemeData get darkTheme {

      final TextTheme baseTextTheme = ThemeData(brightness: Brightness.dark).textTheme;


    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kColorAccent,

      scaffoldBackgroundColor: kBgColor2,

      cardColor: Colors.white.withAlpha(26),
     dividerColor: Colors.white.withAlpha(38),
      colorScheme: const ColorScheme.dark(
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
          side: const BorderSide(color: kColorAccent),
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
          borderSide: const BorderSide(color: kColorAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: kColorTextSecondary),
      ),
       bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kBgColor3,
        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
        ),
      ),
    );
  }
}