import 'dart:math' as math;

import 'package:flutter/material.dart';

part 'calculations/advanced_calculator_sections.dart';
part 'calculations/basic_calculator_sections.dart';
part 'calculations/conversion_calculator_sections.dart';
part 'widgets/calculator_widgets.dart';

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
  final _celsius = TextEditingController();
  final _currencyAmount = TextEditingController();
  final _currencyRate = TextEditingController();
  final _currencyFrom = TextEditingController(text: 'GBP');
  final _currencyTo = TextEditingController(text: 'USD');
  final _gradientPercent = TextEditingController();
  final _gradientFeetPerNm = TextEditingController();
  final _unitValue = TextEditingController();
  final _localTime = TextEditingController();
  final _utcOffset = TextEditingController();
  final _holdingFuel = TextEditingController();
  final _holdingFlow = TextEditingController();
  final _etpDistance = TextEditingController();
  final _etpReturnGs = TextEditingController();
  final _etpContinueGs = TextEditingController();
  final _usableEndurance = TextEditingController();
  final _outboundGs = TextEditingController();
  final _homeboundGs = TextEditingController();
  final _specificRangeGs = TextEditingController();
  final _specificRangeFlow = TextEditingController();
  final _fieldElevation = TextEditingController();
  final _qnh = TextEditingController();
  final _temperature = TextEditingController();
  final _dewPoint = TextEditingController();
  final _coldHeight = TextEditingController();
  final _coldIsaDeviation = TextEditingController();
  final _turnTas = TextEditingController();
  final _turnBank = TextEditingController();
  final _standardRateTas = TextEditingController();
  final _requiredGradient = TextEditingController();
  final _climbGs = TextEditingController();
  final _windTriangleTas = TextEditingController();
  final _windTriangleSpeed = TextEditingController();
  final _windTriangleFrom = TextEditingController();
  final _desiredCourse = TextEditingController();
  final _ias = TextEditingController();
  final _speedAltitude = TextEditingController();
  final _speedTemperature = TextEditingController();
  final _fuelBefore = TextEditingController();
  final _fuelUplift = TextEditingController();
  final _fuelAfter = TextEditingController();
  final _baseDistance = TextEditingController();
  final _distanceAddition = TextEditingController();

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
      _celsius,
      _currencyAmount,
      _currencyRate,
      _currencyFrom,
      _currencyTo,
      _gradientPercent,
      _gradientFeetPerNm,
      _unitValue,
      _localTime,
      _utcOffset,
      _holdingFuel,
      _holdingFlow,
      _etpDistance,
      _etpReturnGs,
      _etpContinueGs,
      _usableEndurance,
      _outboundGs,
      _homeboundGs,
      _specificRangeGs,
      _specificRangeFlow,
      _fieldElevation,
      _qnh,
      _temperature,
      _dewPoint,
      _coldHeight,
      _coldIsaDeviation,
      _turnTas,
      _turnBank,
      _standardRateTas,
      _requiredGradient,
      _climbGs,
      _windTriangleTas,
      _windTriangleSpeed,
      _windTriangleFrom,
      _desiredCourse,
      _ias,
      _speedAltitude,
      _speedTemperature,
      _fuelBefore,
      _fuelUplift,
      _fuelAfter,
      _baseDistance,
      _distanceAddition,
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
      ..._timeNavigationCards(),
      ..._windCards(),
      ..._descentCards(),
      ..._atmosphereSpeedCards(),
      ..._fuelUnitCards(),
      ..._conversionCards(),
      ..._fuelRangeCards(),
      ..._atmosphereAltitudeCards(),
      ..._turningFlightPathCards(),
      ..._planningAdjustmentCards(),
    ],
  );

  String? _shiftTime(String input, int offsetMinutes, String label) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(input.trim());
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return 'Enter a valid 24-hour time';
    final raw = hour * 60 + minute + offsetMinutes;
    final total = ((raw % 1440) + 1440) % 1440;
    final hh = (total ~/ 60).toString().padLeft(2, '0');
    final mm = (total % 60).toString().padLeft(2, '0');
    final day = raw >= 1440
        ? ' next day'
        : raw < 0
        ? ' previous day'
        : '';
    return '$hh:$mm $label$day';
  }

  String? _windTriangleResult() {
    final tas = _number(_windTriangleTas);
    final windSpeed = _number(_windTriangleSpeed);
    final windFrom = _number(_windTriangleFrom);
    final course = _number(_desiredCourse);
    if (tas == null ||
        windSpeed == null ||
        windFrom == null ||
        course == null ||
        tas <= 0) {
      return null;
    }
    final difference = (windFrom - course) * math.pi / 180;
    final sine = windSpeed / tas * math.sin(difference);
    if (sine.abs() > 1) return 'No wind-triangle solution at this TAS';
    final correction = math.asin(sine);
    final heading = (course + correction * 180 / math.pi + 360) % 360;
    final groundSpeed =
        tas * math.cos(correction) - windSpeed * math.cos(difference);
    return 'Heading ${heading.toStringAsFixed(0).padLeft(3, '0')}° · WCA ${correction >= 0 ? '+' : ''}${(correction * 180 / math.pi).toStringAsFixed(1)}° · GS ${groundSpeed.toStringAsFixed(0)} kt';
  }

  String? _speedEstimateResult() {
    final ias = _number(_ias);
    final altitudeFeet = _number(_speedAltitude);
    final temperatureC = _number(_speedTemperature);
    if (ias == null ||
        altitudeFeet == null ||
        temperatureC == null ||
        ias < 0 ||
        temperatureC <= -273.15) {
      return null;
    }
    final altitudeMetres = altitudeFeet * 0.3048;
    final pressure = altitudeMetres <= 11000
        ? 101325 * math.pow(1 - 0.0000225577 * altitudeMetres, 5.25588)
        : 22632.1 * math.exp(-0.000157689 * (altitudeMetres - 11000));
    final temperatureKelvin = temperatureC + 273.15;
    final density = pressure / (287.05287 * temperatureKelvin);
    if (density <= 0) return null;
    final tas = ias / math.sqrt(density / 1.225);
    final speedOfSound = math.sqrt(1.4 * 287.05287 * temperatureKelvin);
    final mach = tas / (speedOfSound * 1.943844);
    return '${tas.toStringAsFixed(0)} kt TAS · Mach ${mach.toStringAsFixed(2)}';
  }

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
