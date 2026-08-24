part of '../operational_calculations_page.dart';

extension _ConversionCalculatorSections on _OperationalCalculationsPageState {
  List<Widget> _fuelUnitCards() => [
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
  ];

  List<Widget> _conversionCards() => [
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
  ];
}
