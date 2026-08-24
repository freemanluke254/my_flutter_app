import 'package:flutter/material.dart';

void main() => runApp(const PilotApp());

class PilotApp extends StatelessWidget {
  const PilotApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Pilot App',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF173D31)),
      useMaterial3: true,
    ),
    home: const StartPage(),
  );
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pilot App')),
    body: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flight_takeoff_rounded, size: 64),
          SizedBox(height: 16),
          Text(
            'Fresh start',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text('Ready to build one page at a time.'),
        ],
      ),
    ),
  );
}
