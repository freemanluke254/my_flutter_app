part of '../operational_calculations_page.dart';

extension _AdvancedCalculatorSections on _OperationalCalculationsPageState {
  List<Widget> _fuelRangeCards() => [
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
  ];

  List<Widget> _atmosphereAltitudeCards() => [
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
  ];

  List<Widget> _turningFlightPathCards() => [
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
  ];

  List<Widget> _planningAdjustmentCards() => [
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
  ];
}
