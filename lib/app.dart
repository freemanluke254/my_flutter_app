import 'package:flutter/material.dart';

import 'features/landing/landing_screen.dart';

class PilotApp extends StatelessWidget {
  const PilotApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Pilot App',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF173D31),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F4EF),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      useMaterial3: true,
    ),
    home: const LandingScreen(pilotName: 'Luke'),
  );
}
