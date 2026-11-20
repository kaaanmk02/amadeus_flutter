import 'package:flutter/material.dart';

/// `ColorKt.java` + `TypeKt.java` + `ThemeKt.java` karşılığı.
/// Steins;Gate 0 / Amadeus lab acessoria hareket eder.
class AppTheme {
  // ---- Renkler (Steins;Gate 0 / Amadeus lab acessoria) ----
  // Amadeus ana rengi: koyu lacivert + kızıl üst üste
  static const Color bgDeep = Color(0xFF06060C);
  static const Color bgChat = Color(0xFF0C0C14);
  static const Color accentRed = Color(0xFFFF3B4C);
  static const Color accentAmber = Color(0xFFFFB020);
  static const Color accentPurple = Color(0xFF8B6FBF);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFFE5E5E5);
  static const Color textSecondary = Color(0xFF9A9AA5);
  static const Color textTertiary = Color(0xFF6A6A75);
  static const Color borderColor = Color(0xFF2A2A3A);

  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: accentRed,
    onPrimary: bgDeep,
    secondary: accentAmber,
    onSecondary: bgDeep,
    error: accentRed,
    onError: Colors.white,
    surface: bgChat,
    onSurface: textPrimary,
  );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _scheme,
        scaffoldBackgroundColor: bgDeep,
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textTertiary),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: bgChat,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: accentRed, width: 2),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentRed,
          foregroundColor: bgDeep,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentRed,
            foregroundColor: bgDeep,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accentRed,
            side: const BorderSide(color: accentRed),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgChat,
          selectedItemColor: accentRed,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
      );

  // ---- Sadow / karanlık tema (Steins;Gate 0 gece atmosferi) ----
  static ThemeData get darkThemeDeep => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _scheme,
        scaffoldBackgroundColor: bgDeep,
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textTertiary),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: bgChat,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: accentRed, width: 2),
          ),
        ),
      );
}
