import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color brandRed = Color(0xFFE50914);
  static const Color brandDark = Color(0xFF141414);
  static const Color brandBlack = Colors.black;
  static const Color brandGray = Color(0xFF808080);
  static const Color brandLightGray = Color(0xFFB3B3B3);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: brandDark,
      primaryColor: brandRed,
      colorScheme: const ColorScheme.dark(
        primary: brandRed,
        secondary: brandRed,
        surface: brandDark,
      ),
      splashFactory: InkRipple.splashFactory,
      textTheme: GoogleFonts.notoSansKrTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandDark,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF333333),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: brandRed, width: 2),
        ),
        labelStyle: const TextStyle(color: brandGray),
        hintStyle: const TextStyle(color: brandGray),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
