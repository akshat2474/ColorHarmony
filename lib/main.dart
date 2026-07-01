import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const ColorHarmonyApp());
}

class ColorHarmonyApp extends StatelessWidget {
  const ColorHarmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Harmony',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Force light mode for Brutalism to pop
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
