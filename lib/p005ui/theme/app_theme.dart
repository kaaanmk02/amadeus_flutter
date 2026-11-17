import 'package:flutter/material.dart';

/// `ColorKt.java` + `TypeKt.java` + `ThemeKt.java` karşılığı.
/// Uygulamanın tek tema kaynağı.
class AppTheme {
  // ---- Renkler (ColorKt.java ile aynı hex değerler) ----
  static const Color bgDeep = Color(0xFF0A0A0F);
  static const Color bgChat = Color(0xFF14141B);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFF9A9AA5);
  static const Color accentRed = Color(0xFFFF4444);
  static const Color accentBlue = Color(0xFF4488FF);
  static const Color accentPurple = Color(0xFF8844FF);

  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: accentGreen,
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
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          titleLarge: TextStyle(color: accentGreen, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: bgChat,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: accentGreen),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF2A2A35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: accentGreen, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGreen,
            foregroundColor: bgDeep,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
