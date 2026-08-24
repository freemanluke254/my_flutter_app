import 'dart:math' as math;

import 'package:flutter/material.dart';

class OperationalCalculationsPage extends StatefulWidget {
  const OperationalCalculationsPage({super.key});

  @override
  State<OperationalCalculationsPage> createState() =>
      _OperationalCalculationsPageState();
}

class _OperationalCalculationsPageState
    extends State<OperationalCalculationsPage> {
  final _fuelNow = TextEditingController();
  final _fuelFlow = TextEditingController();
  final _minutes = TextEditingController();
  final _distance = TextEditingController();
  final _groundSpeed = TextEditingController();
  final _windSpeed = TextEditingController();
  final _windAngle = TextEditingController();
  final _pressure = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _fuelNow,
      _fuelFlow,
      _minutes,
      _distance,
      _groundSpeed,
      _windSpeed,
      _windAngle,
      _pressure,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      Text(
        'Operational calculations',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const _CalculationWarning(),
      const SizedBox(height: 12),
      _CalculatorCard(
        title: 'Fuel trend',
        subtitle: 'Simple projection from present fuel and total flow',
        fields: [
          _field(_fuelNow, 'Fuel now', 'kg'),
          _field(_fuelFlow, 'Total fuel flow', 'kg/h'),
          _field(_minutes, 'Time ahead', 'min'),
        ],
        result: () {
          final fuel = _number(_fuelNow);
          final flow = _number(_fuelFlow);
          final minutes = _number(_minutes);
          if (fuel == null || flow == null || minutes == null) return null;
          return '${(fuel - flow * minutes / 60).toStringAsFixed(0)} kg projected';
        },
      ),
      _CalculatorCard(
        title: 'Time & distance',
        subtitle: 'Still-air arithmetic using entered groundspeed',
        fields: [
          _field(_distance, 'Distance', 'nm'),
          _field(_groundSpeed, 'Groundspeed', 'kt'),
        ],
        result: () {
          final distance = _number(_distance);
          final speed = _number(_groundSpeed);
          if (distance == null || speed == null || speed <= 0) return null;
          final totalMinutes = (distance / speed * 60).round();
          return '${totalMinutes ~/ 60}h ${totalMinutes % 60}m';
        },
      ),
      _CalculatorCard(
        title: 'Wind components',
        subtitle:
            'Angle is the difference between wind direction and runway/course',
        fields: [
          _field(_windSpeed, 'Wind speed', 'kt'),
          _field(_windAngle, 'Relative angle', '°'),
        ],
        result: () {
          final speed = _number(_windSpeed);
          final angle = _number(_windAngle);
          if (speed == null || angle == null) return null;
          final radians = angle * math.pi / 180;
          final crosswind = (speed * math.sin(radians)).abs();
          final headwind = speed * math.cos(radians);
          final along = headwind >= 0 ? 'headwind' : 'tailwind';
          return '${crosswind.toStringAsFixed(1)} kt crosswind · ${headwind.abs().toStringAsFixed(1)} kt $along';
        },
      ),
      _CalculatorCard(
        title: 'Pressure conversion',
        subtitle: 'Enter hPa to convert to inches of mercury',
        fields: [_field(_pressure, 'Pressure', 'hPa')],
        result: () {
          final pressure = _number(_pressure);
          if (pressure == null) return null;
          return '${(pressure * 0.0295299830714).toStringAsFixed(2)} inHg';
        },
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.result,
  });
  final String title, subtitle;
  final List<Widget> fields;
  final String? Function() result;

  @override
  Widget build(BuildContext context) {
    final value = result();
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          ...fields,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFE4EEE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value ?? 'Enter values to calculate',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculationWarning extends StatelessWidget {
  const _CalculationWarning();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Convenience arithmetic only. Do not use these results for certified take-off/landing performance, terrain clearance, fuel-policy compliance or operational decision limits. Cross-check against the approved OFP, FMC, OPT/EFB and company procedures.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}
