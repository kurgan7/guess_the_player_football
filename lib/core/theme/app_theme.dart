import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    final cs = ColorScheme.fromSeed(
      seedColor: const Color(0xFF22C55E), // canlı yeşil
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,

      scaffoldBackgroundColor: const Color(
        0xFF0B0F0E,
      ), // çok koyu ama siyah değil

      cardTheme: CardThemeData(
        color: const Color(0xFF121917), // kartlar biraz daha açık
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0F0E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0B0F0E),
        indicatorColor: const Color(0xFF22C55E).withOpacity(0.18),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w900),
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
