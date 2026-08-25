import 'package:flutter/material.dart';

class FuelPerformanceTab extends StatelessWidget {
  const FuelPerformanceTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Fuel & performance',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Flight-specific fuel review and performance tools will be built here.',
          ),
        ),
      ),
    ],
  );
}
