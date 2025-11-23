import 'package:flutter/material.dart';

/// Theme mode enum for Day/Night switching
enum AppThemeMode {
  day,
  night,
}

/// Neumorphic theme data containing all design tokens
class NeuTheme {
  final Color background;
  final Color mainText;
  final Color shadowLight;
  final Color shadowDark;
  final Color accent;
  final AppThemeMode mode;

  const NeuTheme({
    required this.background,
    required this.mainText,
    required this.shadowLight,
    required this.shadowDark,
    required this.accent,
    required this.mode,
  });

  /// Day mode theme
  static const day = NeuTheme(
    background: Color(0xFFE0E5EC),
    mainText: Color(0xFF4D4D4D),
    shadowLight: Color(0xFFFFFFFF),
    shadowDark: Color(0xFFA3B1C6),
    accent: Color(0xFF6C63FF),
    mode: AppThemeMode.day,
  );

  /// Night mode theme
  static const night = NeuTheme(
    background: Color(0xFF292D32),
    mainText: Color(0xFFE0E5EC),
    shadowLight: Color(0xFF353B41),
    shadowDark: Color(0xFF1E2226),
    accent: Color(0xFF9D96FF),
    mode: AppThemeMode.night,
  );

  /// Get pop-out shadows (for buttons, cards)
  List<BoxShadow> getPopOutShadows({double distance = 10.0, double blur = 20.0}) {
    return [
      BoxShadow(
        color: shadowLight,
        offset: Offset(-distance, -distance),
        blurRadius: blur,
      ),
      BoxShadow(
        color: shadowDark,
        offset: Offset(distance, distance),
        blurRadius: blur,
      ),
    ];
  }

  /// Get pressed-in shadows (for inputs, pressed buttons)
  List<BoxShadow> getPressedInShadows({double distance = 5.0, double blur = 10.0}) {
    return [
      BoxShadow(
        color: shadowLight,
        offset: Offset(-distance, -distance),
        blurRadius: blur,
      ),
      BoxShadow(
        color: shadowDark,
        offset: Offset(distance, distance),
        blurRadius: blur,
      ),
    ];
  }

  /// Toggle to opposite theme
  NeuTheme toggle() {
    return mode == AppThemeMode.day ? night : day;
  }

  /// Check if current theme is dark
  bool get isDark => mode == AppThemeMode.night;
}
