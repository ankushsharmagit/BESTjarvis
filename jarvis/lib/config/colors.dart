// lib/config/colors.dart
// JARVIS Color Palette - Iron Man HUD Theme

import 'package:flutter/material.dart';

class JarvisColors {
  // Primary Background Colors
  static const Color bgPrimary = Color(0xFF0A0E21);
  static const Color bgSecondary = Color(0xFF1A1A2E);
  static const Color bgCard = Color(0xFF16213E);
  static const Color bgDark = Color(0xFF05080F);
  static const Color bgOverlay = Color(0xCC0A0E21);
  
  // Accent Colors - Iron Man Arc Reactor Theme
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentBlue = Color(0xFF0088FF);
  static const Color accentGlow = Color(0xFF00F5FF);
  static const Color accentDeepBlue = Color(0xFF0044FF);
  static const Color accentLightBlue = Color(0xFF33D4FF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF607D8B);
  static const Color textDisabled = Color(0xFF455A64);
  
  // Status Colors
  static const Color success = Color(0xFF00FF88);
  static const Color error = Color(0xFFFF0040);
  static const Color warning = Color(0xFFFF8800);
  static const Color info = Color(0xFF00D4FF);
  
  // Telegram Colors
  static const Color telegram = Color(0xFF26A5E4);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color instagram = Color(0xFFE4405F);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color facebook = Color(0xFF1877F2);
  
  // Arc Reactor State Colors
  static const Color reactorIdle = Color(0xFF00D4FF);
  static const Color reactorListening = Color(0xFFFF3366);
  static const Color reactorProcessing = Color(0xFF00FF88);
  static const Color reactorExecuting = Color(0xFFFF8800);
  static const Color reactorSpeaking = Color(0xFFAA00FF);
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0E21), Color(0xFF1A1A2E)],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4FF), Color(0xFF0088FF)],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x0FFFFFFF)],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF0040), Color(0xFFCC0033)],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8800), Color(0xFFCC6600)],
  );
  
  static const LinearGradient telegramGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF26A5E4), Color(0xFF1E88E5)],
  );
  
  // Shadow Colors
  static const Color glowColor = Color(0x3300D4FF);
  static const Color shadowColor = Color(0x80000000);
  
  // Border Colors
  static const Color borderColor = Color(0x3300D4FF);
  static const Color borderHover = Color(0x6600D4FF);
  
  // Specific UI Element Colors
  static const Color micButtonGlow = Color(0x6600D4FF);
  static const Color quickActionBackground = Color(0x1AFFFFFF);
  static const Color chatUserBubble = Color(0xFF0088FF);
  static const Color chatJarvisBubble = Color(0xFF16213E);
  static const Color cardBorder = Color(0x3300D4FF);
  static const Color dividerColor = Color(0x1AFFFFFF);
  
  // Glassmorphism Colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0FFFFFFF);
  
  // Animation Colors
  static const Color particleColor = Color(0x6600D4FF);
  static const Color waveColor = Color(0xFF00D4FF);
  
  // Dark Theme Overrides
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF0A0E21);
}

class ThemeConfig {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: JarvisColors.accentCyan,
      primaryColorDark: JarvisColors.accentBlue,
      primaryColorLight: JarvisColors.accentLightBlue,
      scaffoldBackgroundColor: JarvisColors.bgPrimary,
      cardColor: JarvisColors.bgCard,
      dividerColor: JarvisColors.dividerColor,
      focusColor: JarvisColors.accentCyan,
      hoverColor: JarvisColors.accentCyan.withOpacity(0.1),
      highlightColor: JarvisColors.accentCyan.withOpacity(0.2),
      
      colorScheme: const ColorScheme.dark(
        primary: JarvisColors.accentCyan,
        secondary: JarvisColors.accentBlue,
        surface: JarvisColors.bgCard,
        background: JarvisColors.bgPrimary,
        error: JarvisColors.error,
        onPrimary: JarvisColors.textPrimary,
        onSecondary: JarvisColors.textPrimary,
        onSurface: JarvisColors.textPrimary,
        onBackground: JarvisColors.textPrimary,
        onError: JarvisColors.textPrimary,
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: JarvisColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
          letterSpacing: 1.2,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: JarvisColors.textPrimary,
          letterSpacing: 1.0,
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
          letterSpacing: 2.0,
        ),
      ),
      
      cardTheme: CardTheme(
        color: JarvisColors.bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: JarvisColors.cardBorder, width: 1),
        ),
        shadowColor: JarvisColors.glowColor,
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
        prefixIconColor: JarvisColors.accentCyan,
        suffixIconColor: JarvisColors.accentCyan,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JarvisColors.accentCyan,
          foregroundColor: JarvisColors.bgPrimary,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
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
          textStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: JarvisColors.accentCyan,
        size: 24,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: JarvisColors.bgCard,
        contentTextStyle: const TextStyle(color: JarvisColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
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
          fontFamily: 'Rajdhani',
          fontSize: 14,
          color: JarvisColors.textPrimary,
        ),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: JarvisColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}