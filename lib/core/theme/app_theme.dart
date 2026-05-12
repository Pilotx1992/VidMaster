import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Premium dark surfaces + gold accent (system font)
  static const Color primaryColor = Color(0xFF111827); // near-black (header/bg anchor)
  static const Color secondaryColor = Color(0xFFF9A825); // Amber Gold (accent)
  static const Color backgroundDark = Color(0xFF0B0F14);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceDark2 = Color(0xFF0F172A);
  static const Color outlineDark = Color(0xFF253041);
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          actionsIconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
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
          primary: secondaryColor,
          onPrimary: Colors.black,
          secondary: secondaryColor,
          onSecondary: Colors.black,
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          outline: outlineDark,
        ),
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          foregroundColor: onSurfaceDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          iconTheme: const IconThemeData(color: onSurfaceDark),
          actionsIconTheme: const IconThemeData(color: onSurfaceDark),
          titleTextStyle: const TextStyle(
            color: onSurfaceDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        dividerTheme: const DividerThemeData(color: outlineDark, thickness: 1, space: 1),
        iconTheme: const IconThemeData(color: Colors.white70),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark2,
          hintStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outlineDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outlineDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: secondaryColor),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: surfaceDark2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white70,
          textColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: backgroundDark,
          indicatorColor: Color(0x26F9A825),
          labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: secondaryColor,
          dividerColor: outlineDark,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
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
