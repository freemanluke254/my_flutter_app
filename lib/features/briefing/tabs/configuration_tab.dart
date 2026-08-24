import 'package:flutter/material.dart';

class ConfigurationTab extends StatelessWidget {
  const ConfigurationTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Configuration',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Confirm the aircraft and operational setup before beginning the briefing.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 20),
      const _ConfigurationItem(
        icon: Icons.airplanemode_active_rounded,
        title: 'Aircraft',
        value: 'B787-9 · From imported OFP',
      ),
      const _ConfigurationItem(
        icon: Icons.badge_outlined,
        title: 'Registration',
        value: 'Read from imported OFP',
      ),
      const _ConfigurationItem(
        icon: Icons.route_outlined,
        title: 'Operation',
        value: 'ETOPS, terrain and airspace requirements',
      ),
      const _ConfigurationItem(
        icon: Icons.build_outlined,
        title: 'Technical status',
        value: 'MEL and defect review pending',
      ),
    ],
  );
}

class _ConfigurationItem extends StatelessWidget {
  const _ConfigurationItem({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF173D31)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
