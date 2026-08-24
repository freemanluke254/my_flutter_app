import 'package:flutter/material.dart';

class RosterTab extends StatelessWidget {
  const RosterTab({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: _RosterPlaceholder());
}

class _RosterPlaceholder extends StatelessWidget {
  const _RosterPlaceholder();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_month_outlined, size: 58),
        SizedBox(height: 16),
        Text(
          'Roster',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        Text('Roster import and upcoming duties will be added here.'),
      ],
    ),
  );
}
