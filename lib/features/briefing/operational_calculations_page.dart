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
  final _clockTime = TextEditingController();
  final _clockOffset = TextEditingController();
  final _distance = TextEditingController();
  final _groundSpeed = TextEditingController();
  final _windSpeed = TextEditingController();
  final _windDirection = TextEditingController();
  final _runwayHeading = TextEditingController();
  final _pressure = TextEditingController();
  final _profileDistance = TextEditingController();
  final _thresholdElevation = TextEditingController(text: '0');
  final _profileAngle = TextEditingController(text: '3');
  final _currentAltitude = TextEditingController();
  final _targetAltitude = TextEditingController();
  final _descentGroundSpeed = TextEditingController();
  final _isaAltitude = TextEditingController();
  final _outsideTemperature = TextEditingController();
  final _mach = TextEditingController();
  final _machTemperature = TextEditingController();
  final _fuelVolume = TextEditingController();
  final _fuelDensity = TextEditingController(text: '0.80');

  @override
  void dispose() {
    for (final controller in [
      _fuelNow,
      _fuelFlow,
      _minutes,
      _clockTime,
      _clockOffset,
      _distance,
      _groundSpeed,
      _windSpeed,
      _windDirection,
      _runwayHeading,
      _pressure,
      _profileDistance,
      _thresholdElevation,
      _profileAngle,
      _currentAltitude,
      _targetAltitude,
      _descentGroundSpeed,
      _isaAltitude,
      _outsideTemperature,
      _mach,
      _machTemperature,
      _fuelVolume,
      _fuelDensity,
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
      const _SectionLabel('TIME & NAVIGATION'),
      _CalculatorCard(
        title: 'Time arithmetic',
        subtitle: 'Add or subtract minutes from a UTC or local time',
        fields: [
          _field(
            _clockTime,
            'Start time',
            'HH:mm',
            keyboardType: TextInputType.datetime,
          ),
          _field(_clockOffset, 'Minutes to add', 'min'),
        ],
        result: _timeResult,
        note:
            'Use a negative number to subtract time. Result wraps through midnight.',
      ),
      _CalculatorCard(
        title: 'Time & distance',
        subtitle: 'Travel time using distance and groundspeed',
        fields: [
          _field(_distance, 'Distance', 'nm'),
          _field(_groundSpeed, 'Groundspeed', 'kt'),
        ],
        result: () {
          final distance = _number(_distance);
          final speed = _number(_groundSpeed);
          if (distance == null || speed == null || speed <= 0) return null;
          final totalMinutes = (distance / speed * 60).round();
          return '${totalMinutes ~/ 60}h ${totalMinutes % 60}m · $totalMinutes min';
        },
      ),
      const _SectionLabel('WIND'),
      _CalculatorCard(
        title: 'Wind components',
        subtitle: 'Crosswind and headwind/tailwind for a runway or course',
        fields: [
          _field(_windSpeed, 'Wind speed', 'kt'),
          _field(_windDirection, 'Wind from', '°T/M'),
          _field(_runwayHeading, 'Runway/course heading', '°T/M'),
        ],
        result: () {
          final speed = _number(_windSpeed);
          final wind = _number(_windDirection);
          final heading = _number(_runwayHeading);
          if (speed == null || wind == null || heading == null) return null;
          final signedAngle = ((wind - heading + 540) % 360) - 180;
          final radians = signedAngle * math.pi / 180;
          final crosswind = speed * math.sin(radians);
          final along = speed * math.cos(radians);
          final crossLabel = crosswind >= 0 ? 'from right' : 'from left';
          final alongLabel = along >= 0 ? 'headwind' : 'tailwind';
          return '${crosswind.abs().toStringAsFixed(1)} kt $crossLabel · ${along.abs().toStringAsFixed(1)} kt $alongLabel';
        },
        note:
            'Use wind and runway/course referenced to the same north: both true or both magnetic.',
      ),
      const _SectionLabel('DESCENT'),
      _CalculatorCard(
        title: 'Altitude on a descent path',
        subtitle: 'Height expected at a selected distance from touchdown',
        fields: [
          _field(_profileDistance, 'Distance to touchdown', 'nm'),
          _field(_thresholdElevation, 'Threshold elevation', 'ft'),
          _field(_profileAngle, 'Path angle', '°'),
        ],
        result: () {
          final distance = _number(_profileDistance);
          final elevation = _number(_thresholdElevation);
          final angle = _number(_profileAngle);
          if (distance == null || elevation == null || angle == null) {
            return null;
          }
          final height = distance * 6076.12 * math.tan(angle * math.pi / 180);
          return '${(elevation + height).round()} ft altitude · ${height.round()} ft above threshold';
        },
        note:
            'Geometric path only. DME/along-track distance, procedure constraints, pressure/temperature effects and level segments can make the published profile different.',
      ),
      _CalculatorCard(
        title: 'Descent distance & vertical speed',
        subtitle: 'Distance required and rate for a constant geometric path',
        fields: [
          _field(_currentAltitude, 'Current altitude', 'ft'),
          _field(_targetAltitude, 'Target altitude', 'ft'),
          _field(_descentGroundSpeed, 'Groundspeed', 'kt'),
          _field(_profileAngle, 'Path angle', '°'),
        ],
        result: () {
          final current = _number(_currentAltitude);
          final target = _number(_targetAltitude);
          final speed = _number(_descentGroundSpeed);
          final angle = _number(_profileAngle);
          if (current == null ||
              target == null ||
              speed == null ||
              angle == null) {
            return null;
          }
          final gradient = math.tan(angle * math.pi / 180);
          if (gradient <= 0 || speed <= 0 || current < target) return null;
          final distance = (current - target) / (6076.12 * gradient);
          final verticalSpeed = speed * 6076.12 / 60 * gradient;
          return '${distance.toStringAsFixed(1)} nm required · ${verticalSpeed.round()} ft/min';
        },
        note:
            'Does not include deceleration, level restrictions, wind changes, anti-ice, speedbrake or ATC intervention.',
      ),
      const _SectionLabel('ATMOSPHERE & SPEED'),
      _CalculatorCard(
        title: 'ISA temperature & deviation',
        subtitle: 'ISA temperature at pressure altitude',
        fields: [
          _field(_isaAltitude, 'Pressure altitude', 'ft'),
          _field(_outsideTemperature, 'Actual OAT', '°C'),
        ],
        result: () {
          final altitude = _number(_isaAltitude);
          final oat = _number(_outsideTemperature);
          if (altitude == null) return null;
          final isa = _isaTemperature(altitude);
          final densityAltitude = oat == null
              ? null
              : altitude + 120 * (oat - isa);
          final deviation = oat == null
              ? ''
              : ' · ISA ${(oat - isa) >= 0 ? '+' : ''}${(oat - isa).toStringAsFixed(1)}°C';
          final density = densityAltitude == null
              ? ''
              : ' · density altitude ≈ ${densityAltitude.round()} ft';
          return 'ISA ${isa.toStringAsFixed(1)}°C$deviation$density';
        },
        note:
            'ISA lapse-rate model; density altitude is a common approximation, not certified performance data.',
      ),
      _CalculatorCard(
        title: 'Mach to TAS',
        subtitle: 'True airspeed from Mach and static air temperature',
        fields: [
          _field(_mach, 'Mach', 'M'),
          _field(_machTemperature, 'Static air temperature', '°C'),
        ],
        result: () {
          final mach = _number(_mach);
          final temperature = _number(_machTemperature);
          if (mach == null || temperature == null || temperature <= -273.15) {
            return null;
          }
          final speedOfSound = math.sqrt(
            1.4 * 287.05287 * (temperature + 273.15),
          );
          final tas = mach * speedOfSound * 1.943844;
          return '${tas.toStringAsFixed(0)} kt TAS';
        },
        note: 'Uses entered static air temperature—not total air temperature.',
      ),
      const _SectionLabel('FUEL & UNITS'),
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
        title: 'Fuel volume to mass',
        subtitle: 'Convert uplift volume using the entered observed density',
        fields: [
          _field(_fuelVolume, 'Fuel volume', 'L'),
          _field(_fuelDensity, 'Observed density', 'kg/L'),
        ],
        result: () {
          final volume = _number(_fuelVolume);
          final density = _number(_fuelDensity);
          if (volume == null || density == null || density <= 0) return null;
          return '${(volume * density).toStringAsFixed(0)} kg';
        },
        note:
            'Use the actual density supplied for the uplift; density varies with fuel and temperature.',
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

  String? _timeResult() {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})$',
    ).firstMatch(_clockTime.text.trim());
    final offset = int.tryParse(_clockOffset.text.trim());
    if (match == null || offset == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return 'Enter a valid 24-hour time';
    final total = ((hour * 60 + minute + offset) % 1440 + 1440) % 1440;
    final resultHour = (total ~/ 60).toString().padLeft(2, '0');
    final resultMinute = (total % 60).toString().padLeft(2, '0');
    final dayChange = hour * 60 + minute + offset >= 1440
        ? ' next day'
        : hour * 60 + minute + offset < 0
        ? ' previous day'
        : '';
    return '$resultHour:$resultMinute$dayChange';
  }

  double _isaTemperature(double pressureAltitudeFeet) {
    if (pressureAltitudeFeet <= 36089) {
      return 15 - 0.0019812 * pressureAltitudeFeet;
    }
    return -56.5;
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix, {
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
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
    this.note,
  });
  final String title, subtitle;
  final List<Widget> fields;
  final String? Function() result;
  final String? note;

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
          if (note != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                note!,
                style: const TextStyle(
                  color: Color(0xFF6C756F),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 10, 4, 7),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF28634A),
        fontSize: 10,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
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
