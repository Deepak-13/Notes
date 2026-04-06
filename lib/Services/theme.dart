import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/Services/comman.dart';

final themeProvider = Provider.family<ThemeData, String>((ref, type) {
  final data = ref.watch(dataprovider);
  final brandAccent = Color(data['color'] ?? 0xFFFFB300);
  return type == 'light'
      ? AppTheme.lightTheme(brandAccent)
      : AppTheme.darkTheme(brandAccent);
});

class AppTheme {
  // Brand Colors
  static const Color _warmGrey = Color(0xFFF8FAFC); // Light theme surface
  static const Color _deepCharcoal = Color(0xFF121212); // Modern dark surface

  static ThemeData lightTheme(Color brandAccent) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandAccent,
        brightness: Brightness.light,
        primary: brandAccent,
        surface: _warmGrey,
        outline: Colors.grey[300], // For the card borders
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: _warmGrey,
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
        titleLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: brandAccent,
        headerForegroundColor: Colors.black87,
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteColor: Colors.grey[200],
        hourMinuteTextColor: Colors.black87,
        dialHandColor: brandAccent,
        dialBackgroundColor: Colors.grey[200],
        dialTextColor: Colors.black87,
      ),
    );
  }

  static ThemeData darkTheme(Color brandAccent) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: brandAccent,
        onPrimary: Colors.black, // Cyan looks better with black text on it
        surface: Colors.black, // True Black background
        onSurface: const Color(0xFFE1E3E3),
        outline: const Color(
          0xFF2C2C2C,
        ), // Subtle border for cards in dark mode
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
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1A1A1A), // slightly lighter than scaffold
        modalBackgroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(
            color: Color(0xFF2C2C2C), // subtle border
            width: 1,
          ),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: brandAccent,
        headerForegroundColor: Colors.black,
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        hourMinuteColor: Color(0xFF2C2C2C),
        hourMinuteTextColor: Colors.white,
        dialHandColor: brandAccent,
        dialBackgroundColor: Color(0xFF2C2C2C),
        dialTextColor: Colors.white,
      ),
    );
  }
}
