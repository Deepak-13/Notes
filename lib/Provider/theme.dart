import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color _brandTeal = Color(0xFF00BFA5); // Vibrant accent
  static const Color _softGrey = Color(0xFFF5F7F8);
  static const Color _deepCharcoal = Color(0xFF121212); // Modern dark surface

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandTeal,
      brightness: Brightness.light,
      primary: _brandTeal,
      surface: _softGrey,
      outline: Colors.grey[300], // For the card borders
    ),
    
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: _softGrey,
      foregroundColor: Colors.black87,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0, // Flat design with borders is trendy
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _brandTeal,
      onPrimary: Colors.white,
      surface: Colors.black, // True Black background
      onSurface: Color(0xFFE1E3E3),
      outline: Color(0xFF2C2C2C), // Subtle border for cards in dark mode
    ),

    scaffoldBackgroundColor: Colors.black,

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    cardTheme: CardThemeData(
      color: _deepCharcoal, 
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
    ),
  );
}