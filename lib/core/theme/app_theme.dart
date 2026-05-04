import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1565C0); // Deep Blue
  static const Color secondaryColor = Color(0xFFF9A825); // Amber Gold
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF1C2B3A);
  static const Color backgroundLight = Color(0xFFF5F7FA);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color playerOverlayTop = Color(0x8A000000); // black54
  static const Color playerOverlayBottom = Color(0xDE000000); // black87

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          onPrimary: onPrimary,
          secondary: secondaryColor,
          surface: backgroundLight,
        ),
        scaffoldBackgroundColor: backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          onPrimary: onPrimary,
          secondary: secondaryColor,
          surface: surfaceDark,
        ),
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceDark,
          foregroundColor: onSurfaceDark,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          color: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
}

class AppDecorations {
  static const playerOverlay = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppTheme.playerOverlayTop,
        Colors.transparent,
        Colors.transparent,
        AppTheme.playerOverlayBottom,
      ],
      stops: [0.0, 0.2, 0.8, 1.0],
    ),
  );
}

class AppTextStyles {
  static const playerTime = TextStyle(
    color: AppTheme.onSurfaceDark,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}