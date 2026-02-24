import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8D6E63), // Marrón cuero base
        brightness: Brightness.light,
        surface: const Color(0xFFF2EAD3), // Beige pergamino
        primary: const Color(0xFF2C3E50), // Azul medianoche
        onPrimary: Colors.white,
        secondary: const Color(0xFF8B0000), // Rojo Lacre
        onSecondary: Colors.white,
        tertiary: const Color(0xFFC5A059), // Dorado viejo
        error: const Color(0xFFB7410E), // Naranja quemado
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.bold,
          fontFamily: 'Serif',
        ),
        bodyLarge: TextStyle(color: Color(0xFF4E342E), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF5D4037)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFEADCBF),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
