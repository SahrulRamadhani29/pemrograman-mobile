import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const background = Color(0xFF0B0F17);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B8CFF),
        brightness: Brightness.dark,
        surface: const Color(0xFF121824),
      ),
      useMaterial3: true,
      fontFamily: 'Arial',
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
