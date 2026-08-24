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
      const _SectionLabel('CONVERSIONS'),
      _CalculatorCard(
        title: 'Temperature',
        subtitle: 'Celsius to Fahrenheit and Kelvin',
        fields: [_field(_celsius, 'Temperature', '°C')],
        result: () {
          final celsius = _number(_celsius);
          if (celsius == null) return null;
          final fahrenheit = celsius * 9 / 5 + 32;
          final kelvin = celsius + 273.15;
          return '${fahrenheit.toStringAsFixed(1)}°F · ${kelvin.toStringAsFixed(2)} K';
        },
      ),
      _CalculatorCard(
        title: 'Currency',
        subtitle: 'Convert using a current rate you enter',
        fields: [
          Row(
            children: [
              Expanded(
                child: _field(
                  _currencyFrom,
                  'From currency',
                  '',
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _field(
                  _currencyTo,
                  'To currency',
                  '',
                  keyboardType: TextInputType.text,
                ),
              ),
            ],
          ),
          _field(_currencyAmount, 'Amount', _currencyFrom.text.toUpperCase()),
          _field(
            _currencyRate,
            'Exchange rate',
            '${_currencyTo.text.toUpperCase()} per ${_currencyFrom.text.toUpperCase()}',
          ),
        ],
        result: () {
          final amount = _number(_currencyAmount);
          final rate = _number(_currencyRate);
          if (amount == null || rate == null || rate <= 0) return null;
          final from = _currencyFrom.text.trim().toUpperCase();
          final to = _currencyTo.text.trim().toUpperCase();
          return '$from ${amount.toStringAsFixed(2)} = $to ${(amount * rate).toStringAsFixed(2)}';
        },
        note:
            'Enter a current trusted rate. Live rates require an exchange-rate data provider and network connection.',
      ),
      _CalculatorCard(
        title: 'Gradient: percent to ft/NM',
        subtitle: 'Convert climb or descent gradient',
        fields: [_field(_gradientPercent, 'Gradient', '%')],
        result: () {
          final percent = _number(_gradientPercent);
          if (percent == null) return null;
          final feetPerNm = percent / 100 * 6076.12;
          final angle = math.atan(percent / 100) * 180 / math.pi;
          return '${feetPerNm.toStringAsFixed(0)} ft/NM · ${angle.toStringAsFixed(2)}°';
        },
        note: 'A 1% geometric gradient equals approximately 60.8 ft/NM.',
      ),
      _CalculatorCard(
        title: 'Gradient: ft/NM to percent',
        subtitle: 'Convert a published climb or descent gradient',
        fields: [_field(_gradientFeetPerNm, 'Gradient', 'ft/NM')],
        result: () {
          final feetPerNm = _number(_gradientFeetPerNm);
          if (feetPerNm == null) return null;
          final ratio = feetPerNm / 6076.12;
          final percent = ratio * 100;
          final angle = math.atan(ratio) * 180 / math.pi;
          return '${percent.toStringAsFixed(2)}% · ${angle.toStringAsFixed(2)}°';
        },
      ),
      _CalculatorCard(
        title: 'Common unit conversions',
        subtitle: 'Distance, height, mass and volume from one entered value',
        fields: [_field(_unitValue, 'Value to convert', '')],
        result: () {
          final value = _number(_unitValue);
          if (value == null) return null;
          return '${value.toStringAsFixed(2)} NM = ${(value * 1.852).toStringAsFixed(2)} km = ${(value * 1.15078).toStringAsFixed(2)} sm\n'
              '${value.toStringAsFixed(2)} ft = ${(value * 0.3048).toStringAsFixed(2)} m\n'
              '${value.toStringAsFixed(2)} kg = ${(value * 2.20462).toStringAsFixed(2)} lb\n'
              '${value.toStringAsFixed(2)} L = ${(value * 0.264172).toStringAsFixed(2)} US gal = ${(value * 0.219969).toStringAsFixed(2)} Imp gal';
        },
      ),
      _CalculatorCard(
        title: 'Local time to UTC',
        subtitle: 'Convert using a manually entered UTC offset',
        fields: [
          _field(
            _localTime,
            'Local time',
            'HH:mm',
            keyboardType: TextInputType.datetime,
          ),
          _field(_utcOffset, 'Local UTC offset', 'hours'),
        ],
        result: () {
          final offset = _number(_utcOffset);
          if (offset == null) return null;
          return _shiftTime(_localTime.text, (-offset * 60).round(), 'UTC');
        },
        note:
            'Example: enter +8 when local time is UTC+8. Confirm daylight-saving status independently.',
      ),
      const _SectionLabel('FUEL, RANGE & DIVERSION PLANNING'),
      _CalculatorCard(
        title: 'Holding time from fuel',
        subtitle: 'Available holding time using entered usable fuel and flow',
        fields: [
          _field(_holdingFuel, 'Fuel available for holding', 'kg'),
          _field(_holdingFlow, 'Total holding fuel flow', 'kg/h'),
        ],
        result: () {
          final fuel = _number(_holdingFuel);
          final flow = _number(_holdingFlow);
          if (fuel == null || flow == null || flow <= 0) return null;
          final minutes = fuel / flow * 60;
          return '${minutes.toStringAsFixed(0)} min holding';
        },
        note:
            'Enter only fuel genuinely available after required reserves and use the applicable predicted aircraft fuel flow.',
      ),
      _CalculatorCard(
        title: 'Equal-time point',
        subtitle: 'Still-airline ETP between two diversion points',
        fields: [
          _field(_etpDistance, 'Distance between diversion points', 'nm'),
          _field(_etpReturnGs, 'Groundspeed toward return point', 'kt'),
          _field(_etpContinueGs, 'Groundspeed toward continue point', 'kt'),
        ],
        result: () {
          final distance = _number(_etpDistance);
          final returnGs = _number(_etpReturnGs);
          final continueGs = _number(_etpContinueGs);
          if (distance == null ||
              returnGs == null ||
              continueGs == null ||
              returnGs <= 0 ||
              continueGs <= 0) {
            return null;
          }
          final fromReturn = distance * returnGs / (returnGs + continueGs);
          final equalMinutes = fromReturn / returnGs * 60;
          return '${fromReturn.toStringAsFixed(1)} nm from return point · ${equalMinutes.toStringAsFixed(0)} min either way';
        },
        note:
            'Geometric two-point estimate only. Approved ETP calculations may use scenario-specific winds, levels, performance, depressurisation or engine-out data.',
      ),
      _CalculatorCard(
        title: 'Point of no return / radius of action',
        subtitle: 'Maximum outbound distance using usable endurance',
        fields: [
          _field(_usableEndurance, 'Usable endurance', 'hours'),
          _field(_outboundGs, 'Outbound groundspeed', 'kt'),
          _field(_homeboundGs, 'Homebound groundspeed', 'kt'),
        ],
        result: () {
          final endurance = _number(_usableEndurance);
          final outbound = _number(_outboundGs);
          final homebound = _number(_homeboundGs);
          if (endurance == null ||
              outbound == null ||
              homebound == null ||
              outbound <= 0 ||
              homebound <= 0) {
            return null;
          }
          final radius =
              endurance * outbound * homebound / (outbound + homebound);
          final outboundMinutes = radius / outbound * 60;
          return '${radius.toStringAsFixed(1)} nm radius · PNR after ${outboundMinutes.toStringAsFixed(0)} min';
        },
        note:
            'Usable endurance must already exclude all required reserves and allowances. Not an approved operational flight-planning result.',
      ),
      _CalculatorCard(
        title: 'Specific range',
        subtitle: 'Distance achieved per unit of fuel',
        fields: [
          _field(_specificRangeGs, 'Groundspeed', 'kt'),
          _field(_specificRangeFlow, 'Total fuel flow', 'kg/h'),
        ],
        result: () {
          final speed = _number(_specificRangeGs);
          final flow = _number(_specificRangeFlow);
          if (speed == null || flow == null || flow <= 0) return null;
          return '${(speed / flow).toStringAsFixed(4)} nm/kg · ${(speed / flow * 1000).toStringAsFixed(1)} nm/tonne';
        },
      ),
      _CalculatorCard(
        title: 'Fuel uplift discrepancy',
        subtitle: 'Compare expected and indicated fuel after uplift',
        fields: [
          _field(_fuelBefore, 'Fuel before uplift', 'kg'),
          _field(_fuelUplift, 'Fuel uplifted', 'kg'),
          _field(_fuelAfter, 'Fuel indicated after uplift', 'kg'),
        ],
        result: () {
          final before = _number(_fuelBefore);
          final uplift = _number(_fuelUplift);
          final after = _number(_fuelAfter);
          if (before == null || uplift == null || after == null) return null;
          final expected = before + uplift;
          final difference = after - expected;
          final percent = expected == 0 ? 0 : difference / expected * 100;
          return 'Expected ${expected.toStringAsFixed(0)} kg · difference ${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(0)} kg (${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%)';
        },
      ),
      const _SectionLabel('ATMOSPHERE & ALTITUDE'),
      _CalculatorCard(
        title: 'Pressure altitude',
        subtitle: 'Approximate pressure altitude from QNH and elevation',
        fields: [
          _field(_fieldElevation, 'Field/indicated altitude', 'ft'),
          _field(_qnh, 'QNH', 'hPa'),
        ],
        result: () {
          final elevation = _number(_fieldElevation);
          final qnh = _number(_qnh);
          if (elevation == null || qnh == null) return null;
          return '${(elevation + (1013.25 - qnh) * 30).round()} ft pressure altitude';
        },
        note: 'Uses the common 30 ft per hPa approximation.',
      ),
      _CalculatorCard(
        title: 'Cloud-base estimate',
        subtitle: 'Approximate convective cloud base from temperature spread',
        fields: [
          _field(_temperature, 'Surface temperature', '°C'),
          _field(_dewPoint, 'Surface dew point', '°C'),
        ],
        result: () {
          final temperature = _number(_temperature);
          final dewPoint = _number(_dewPoint);
          if (temperature == null || dewPoint == null) return null;
          return '${((temperature - dewPoint).clamp(0, double.infinity) * 400).round()} ft AGL approximate base';
        },
        note:
            'Rough convective estimate only; not a substitute for METAR, TAF or observed cloud.',
      ),
      _CalculatorCard(
        title: 'Cold-temperature altitude correction',
        subtitle: 'Common screening approximation',
        fields: [
          _field(_coldHeight, 'Height above altimeter source', 'ft'),
          _field(_coldIsaDeviation, 'Temperature below ISA', '°C'),
        ],
        result: () {
          final height = _number(_coldHeight);
          final belowIsa = _number(_coldIsaDeviation);
          if (height == null || belowIsa == null) return null;
          final correction = 4 * height / 1000 * belowIsa;
          return 'Add approximately ${correction.round()} ft';
        },
        note:
            'Screening estimate only. Use the approved chart/EFB method and apply corrections only as required by the controlling procedure.',
      ),
      const _SectionLabel('TURNING & FLIGHT PATH'),
      _CalculatorCard(
        title: 'Turn radius & rate',
        subtitle: 'Coordinated level-turn geometry',
        fields: [
          _field(_turnTas, 'True airspeed', 'kt'),
          _field(_turnBank, 'Bank angle', '°'),
        ],
        result: () {
          final tas = _number(_turnTas);
          final bank = _number(_turnBank);
          if (tas == null ||
              bank == null ||
              tas <= 0 ||
              bank <= 0 ||
              bank >= 90) {
            return null;
          }
          final speed = tas * 0.514444;
          final tangent = math.tan(bank * math.pi / 180);
          final radiusNm = speed * speed / (9.80665 * tangent) / 1852;
          final rate = 9.80665 * tangent / speed * 180 / math.pi;
          return '${radiusNm.toStringAsFixed(2)} nm radius · ${rate.toStringAsFixed(2)}°/s';
        },
      ),
      _CalculatorCard(
        title: 'Bank angle for standard-rate turn',
        subtitle: 'Bank required for 3° per second',
        fields: [_field(_standardRateTas, 'True airspeed', 'kt')],
        result: () {
          final tas = _number(_standardRateTas);
          if (tas == null || tas <= 0) return null;
          final speed = tas * 0.514444;
          final bank =
              math.atan((3 * math.pi / 180) * speed / 9.80665) * 180 / math.pi;
          return '${bank.toStringAsFixed(1)}° bank';
        },
      ),
      _CalculatorCard(
        title: 'Climb gradient to vertical speed',
        subtitle: 'Required ft/min for a published ft/NM gradient',
        fields: [
          _field(_requiredGradient, 'Required gradient', 'ft/NM'),
          _field(_climbGs, 'Groundspeed', 'kt'),
        ],
        result: () {
          final gradient = _number(_requiredGradient);
          final speed = _number(_climbGs);
          if (gradient == null || speed == null) return null;
          return '${(gradient * speed / 60).round()} ft/min required';
        },
      ),
      _CalculatorCard(
        title: 'Wind correction angle & groundspeed',
        subtitle: 'Basic wind-triangle solution',
        fields: [
          _field(_windTriangleTas, 'True airspeed', 'kt'),
          _field(_windTriangleSpeed, 'Wind speed', 'kt'),
          _field(_windTriangleFrom, 'Wind from', '°'),
          _field(_desiredCourse, 'Desired course', '°'),
        ],
        result: _windTriangleResult,
        note:
            'Wind direction and course must use the same true or magnetic reference.',
      ),
      _CalculatorCard(
        title: 'IAS, TAS & Mach estimate',
        subtitle: 'Low-speed density relationship with Mach estimate',
        fields: [
          _field(_ias, 'Indicated airspeed', 'kt'),
          _field(_speedAltitude, 'Pressure altitude', 'ft'),
          _field(_speedTemperature, 'Static air temperature', '°C'),
        ],
        result: _speedEstimateResult,
        note:
            'Approximation only: ignores position, instrument and compressibility corrections. Use aircraft/EFB data for operational work.',
      ),
      const _SectionLabel('PLANNING ADJUSTMENTS'),
      _CalculatorCard(
        title: 'Distance percentage addition',
        subtitle: 'Apply a percentage increment to a base distance',
        fields: [
          _field(_baseDistance, 'Base distance', 'm'),
          _field(_distanceAddition, 'Addition', '%'),
        ],
        result: () {
          final distance = _number(_baseDistance);
          final addition = _number(_distanceAddition);
          if (distance == null || addition == null) return null;
          final added = distance * addition / 100;
          return '${(distance + added).toStringAsFixed(0)} m total · ${added.toStringAsFixed(0)} m added';
        },
        note:
            'Arithmetic only. Do not invent or apply take-off/landing factors; use the factor and method mandated by the approved performance source.',
      ),
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
