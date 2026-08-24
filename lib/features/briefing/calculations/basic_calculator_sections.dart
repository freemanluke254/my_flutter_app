part of '../operational_calculations_page.dart';

extension _BasicCalculatorSections on _OperationalCalculationsPageState {
  List<Widget> _timeNavigationCards() => [
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
  ];

  List<Widget> _windCards() => [
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
  ];

  List<Widget> _descentCards() => [
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
  ];

  List<Widget> _atmosphereSpeedCards() => [
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
  ];
}
