import 'package:flutter/material.dart';

class FlightTimeTab extends StatelessWidget {
  const FlightTimeTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Flight time',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Planned timings, time zones and milestones from the operational flight plan.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 20),
      const _TimeItem(label: 'Scheduled departure', value: 'From imported OFP'),
      const _TimeItem(
        label: 'Planned airborne time',
        value: 'From imported OFP',
      ),
      const _TimeItem(label: 'Scheduled arrival', value: 'From imported OFP'),
      const _TimeItem(label: 'Duty and FDP', value: 'From roster and OFP'),
    ],
  );
}

class _TimeItem extends StatelessWidget {
  const _TimeItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(value, style: const TextStyle(color: Color(0xFF667069))),
      ],
    ),
  );
}
