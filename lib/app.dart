import 'package:flutter/material.dart';

import 'flight_logbook_page.dart';
import 'features/home/pilot_hub.dart';

part 'features/auth/create_account_screen.dart';
part 'features/auth/sign_in_screen.dart';
part 'features/learning/learning_page.dart';
part 'features/legacy/legacy_home_screen.dart';
part 'features/legacy/widgets/placeholder_page.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17211B);
    const green = Color(0xFF28634A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sage',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F3EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          primary: green,
          surface: const Color(0xFFFBFAF6),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
          fontFamily: 'Georgia',
        ),
      ),
      home: const CreateAccountScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const PilotHub();
}
