import 'package:flutter/material.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Calendar',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Your complete roster, personal events and expiry dates.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 22),
      const _MonthPlaceholder(),
      const SizedBox(height: 18),
      const _CalendarSection(
        icon: Icons.flight_takeoff_rounded,
        title: 'Roster duties',
        message:
            'Imported flights, standby duties, days off and training will appear here.',
      ),
      const SizedBox(height: 10),
      const _CalendarSection(
        icon: Icons.verified_user_outlined,
        title: 'Expiry dates',
        message:
            'Medical, licence, passport, visa, training and custom expiries will appear here.',
      ),
    ],
  );
}

class _MonthPlaceholder extends StatelessWidget {
  const _MonthPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const Expanded(
              child: Text(
                'August 2026',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('M'),
            Text('T'),
            Text('W'),
            Text('T'),
            Text('F'),
            Text('S'),
            Text('S'),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Calendar entries will populate after roster and expiry data are added.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF667069)),
        ),
      ],
    ),
  );
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDCEADD),
        foregroundColor: const Color(0xFF173D31),
        child: Icon(icon),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(message),
      ),
    ),
  );
}
