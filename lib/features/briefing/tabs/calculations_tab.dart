import 'package:flutter/material.dart';

class CalculationsTab extends StatelessWidget {
  const CalculationsTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Calculations',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Flight-specific calculations and operational tools.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 18),
      const _CalculationCard(
        icon: Icons.local_gas_station_outlined,
        title: 'Fuel planning',
        subtitle: 'Planned, actual and discretionary fuel',
      ),
      const _CalculationCard(
        icon: Icons.air_outlined,
        title: 'Wind components',
        subtitle: 'Crosswind, headwind and tailwind',
      ),
      const _CalculationCard(
        icon: Icons.trending_down_rounded,
        title: 'Descent planning',
        subtitle: 'Profile, distance and rate calculations',
      ),
      const _CalculationCard(
        icon: Icons.calculate_outlined,
        title: 'Aviation calculators',
        subtitle: 'Time, ISA, conversions and more',
      ),
    ],
  );
}

class _CalculationCard extends StatelessWidget {
  const _CalculationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
