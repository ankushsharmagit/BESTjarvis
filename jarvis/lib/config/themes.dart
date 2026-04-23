// lib/config/themes.dart
// JARVIS Theme Configuration

import 'package:flutter/material.dart';
import 'colors.dart';

class AppThemes {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: JarvisColors.accentCyan,
      scaffoldBackgroundColor: JarvisColors.bgPrimary,
      cardColor: JarvisColors.bgCard,
      dividerColor: JarvisColors.dividerColor,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: JarvisColors.accentCyan),
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: JarvisColors.accentCyan,
          letterSpacing: 2,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: JarvisColors.accentCyan,
        unselectedItemColor: JarvisColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JarvisColors.accentCyan,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JarvisColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JarvisColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JarvisColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JarvisColors.accentCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JarvisColors.error),
        ),
        labelStyle: const TextStyle(color: JarvisColors.textSecondary),
        hintStyle: const TextStyle(color: JarvisColors.textHint),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JarvisColors.accentCyan,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: JarvisColors.accentCyan,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JarvisColors.accentCyan,
          side: const BorderSide(color: JarvisColors.accentCyan),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: JarvisColors.bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: JarvisColors.cardBorder, width: 0.5),
        ),
      ),
      
      dialogTheme: DialogTheme(
        backgroundColor: JarvisColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: JarvisColors.accentCyan, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: JarvisColors.accentCyan,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: JarvisColors.textPrimary,
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: JarvisColors.bgCard,
        contentTextStyle: const TextStyle(color: JarvisColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: JarvisColors.accentCyan,
        circularTrackColor: JarvisColors.textHint,
      ),
      
      dividerTheme: const DividerThemeData(
        color: JarvisColors.dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      iconTheme: const IconThemeData(
        color: JarvisColors.accentCyan,
        size: 24,
      ),
      
      primaryIconTheme: const IconThemeData(
        color: JarvisColors.accentCyan,
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: JarvisColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: JarvisColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 16,
          color: JarvisColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 14,
          color: JarvisColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 12,
          color: JarvisColors.textHint,
        ),
        labelLarge: TextStyle(
          fontFamily: 'ShareTechMono',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: JarvisColors.accentCyan,
        ),
        labelMedium: TextStyle(
          fontFamily: 'ShareTechMono',
          fontSize: 12,
          color: JarvisColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'ShareTechMono',
          fontSize: 10,
          color: JarvisColors.textHint,
        ),
      ),
    );
  }
  
  static ThemeData get lightTheme {
    // Light theme variant for users who prefer light mode
    return darkTheme.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.grey[100],
      primaryColor: JarvisColors.accentBlue,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
    );
  }
}