import 'package:flutter/services.dart';

class OfpFlightDetails {
  const OfpFlightDetails({
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.arrivalTime,
    required this.aircraftType,
    required this.registration,
    required this.operation,
    required this.callsign,
    required this.planId,
    required this.flightDate,
    this.scheduledFlightTime = '',
    this.flightPlanTime = '',
    this.detailedRoute = '',
    this.takeoffWeight = '',
    this.landingWeight = '',
    this.zeroFuelWeight = '',
    this.payload = '',
    this.blockFuel = '',
    this.taxiFuel = '',
    this.tripFuel = '',
    this.contingencyFuel = '',
    this.alternateFuel = '',
    this.finalReserveFuel = '',
    this.etpAdjustmentFuel = '',
    this.additionalFuel = '',
    this.unusableFuel = '',
    this.arrivalDelayFuel = '',
    this.extraFuel = '',
    this.discretionaryFuel = '',
    this.fuelTimes = const {},
    this.maxPayloadPlan = false,
  });
  final String flightNumber;
  final String departure;
  final String arrival;
  final String departureTime;
  final String arrivalTime;
  final String aircraftType;
  final String registration;
  final String operation;
  final String callsign;
  final String planId;
  final DateTime? flightDate;
  final String scheduledFlightTime;
  final String flightPlanTime;
  final String detailedRoute;
  final String takeoffWeight;
  final String landingWeight;
  final String zeroFuelWeight;
  final String payload;
  final String blockFuel;
  final String taxiFuel;
  final String tripFuel;
  final String contingencyFuel;
  final String alternateFuel;
  final String finalReserveFuel;
  final String etpAdjustmentFuel;
  final String additionalFuel;
  final String unusableFuel;
  final String arrivalDelayFuel;
  final String extraFuel;
  final String discretionaryFuel;
  final Map<String, String> fuelTimes;
  final bool maxPayloadPlan;
}

class OfpParser {
  const OfpParser();
  static const _channel = MethodChannel('pilot_app/pdf_text');

  Future<OfpFlightDetails> parse(Uint8List bytes) async {
    late final String? text;
    try {
      text = await _channel.invokeMethod<String>('extractText', bytes);
    } on MissingPluginException {
      throw const FormatException(
        'OFP decoding is available in the rebuilt macOS app, not Chrome or an older hot-reloaded app. Fully stop Flutter and run: flutter run -d macos',
      );
    }
    if (text == null || text.isEmpty) {
      throw const FormatException('No selectable text was found in the OFP.');
    }
    return parseText(text);
  }

  OfpFlightDetails parseText(String text) {
    String match(String pattern, {int group = 1, String fallback = ''}) =>
        RegExp(
          pattern,
          caseSensitive: false,
          multiLine: true,
        ).firstMatch(text)?.group(group)?.trim() ??
        fallback;
    String fuelTime(String labelPattern) => match(
      '$labelPattern\\s+\\d+\\s+(\\d{1,2}[.:]\\d{2})',
    ).replaceAll('.', ':');
    final route = RegExp(r'\b([A-Z]{4})-([A-Z]{4})\b').firstMatch(text);
    final flightNumber = match(r'OPERATIONAL FLIGHT PLAN\s+([A-Z]{2}\d+)');
    if (flightNumber.isEmpty || route == null) {
      throw const FormatException(
        'The flight number or route could not be decoded. Enter the details manually.',
      );
    }
    final datePattern = RegExp(
      r'(\d{2})(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(\d{2})',
      caseSensitive: false,
    );
    final flightHeader = RegExp(
      r'^[A-Z]{3}\d+[A-Z]?\s+(\d{2}(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\d{2})',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(text);
    final dateMatch = datePattern.firstMatch(flightHeader?.group(1) ?? text);
    final departure = route.group(1)!;
    final arrival = route.group(2)!;
    final atcRoute = _frontPageRoute(text, departure, arrival);
    return OfpFlightDetails(
      flightNumber: flightNumber,
      departure: departure,
      arrival: arrival,
      departureTime: match(r'STD LOCAL\s+\S+\s+(\d{4})', fallback: 'Pending'),
      arrivalTime: match(r'STA\s+\S+\s+(\d{4}\+?)', fallback: 'Pending'),
      aircraftType: match(r'^TYPE\s+([^\r\n]+)', fallback: 'Pending'),
      registration: match(r'REGN\s+([A-Z0-9]+)', fallback: 'Pending'),
      operation: match(r'APPL RULE:\s*([^\r\n]+)', fallback: 'From OFP'),
      callsign: match(r'^([A-Z]{3}\d+[A-Z]?)\s+\d{2}[A-Z]{3}\d{2}'),
      planId: match(r'PLAN ID\s+([A-Z0-9]+)', fallback: 'Not stated'),
      flightDate: dateMatch == null
          ? null
          : DateTime(
              2000 + int.parse(dateMatch.group(3)!),
              const {
                'JAN': 1,
                'FEB': 2,
                'MAR': 3,
                'APR': 4,
                'MAY': 5,
                'JUN': 6,
                'JUL': 7,
                'AUG': 8,
                'SEP': 9,
                'OCT': 10,
                'NOV': 11,
                'DEC': 12,
              }[dateMatch.group(2)!.toUpperCase()]!,
              int.parse(dateMatch.group(1)!),
            ),
      scheduledFlightTime: match(r'\bSCH\s*[: ]\s*(\d{1,2}[.:]\d{2})'),
      flightPlanTime: match(r'\bTRIP\s+[\d,.]+(?:KG)?\s+(\d{1,2}[.:]\d{2})'),
      detailedRoute: atcRoute,
      takeoffWeight: match(r'RLF1\s+(\d+)'),
      landingWeight: match(r'PAX\s+SOB\s+(\d+)'),
      zeroFuelWeight: match(r'NBR\s+PF/PNF\s+(\d+)'),
      payload: match(r'PAYLOAD\s*[: ]\s*(\d+(?:\.\d+)?)'),
      blockFuel: match(r'\bRAMP\s+(\d+)'),
      taxiFuel: match(r'\bTAXI/APU\s+(\d+)'),
      tripFuel: match(r'\bTRIP\s+(\d+)'),
      contingencyFuel: match(r'\bCONT(?:%\d+|\d+MI\s*N)?\s+(\d+)'),
      alternateFuel: match(r'\bALTN\s+(\d+)'),
      finalReserveFuel: match(r'\bFNL\s+RES\s+(\d+)'),
      etpAdjustmentFuel: match(r'\bETP\s+ADJ\s+(\d+)'),
      additionalFuel: match(r'\bADDNL\s+(\d+)'),
      unusableFuel: match(r'\bUNUSABLE\s+(\d+)'),
      arrivalDelayFuel: match(r'\bARR\s+DLY\s+(\d+)'),
      extraFuel: match(r'\bEXTRA\s+(\d+)'),
      discretionaryFuel: match(r'\bDISC\s+(\d+)'),
      fuelTimes: {
        'trip': fuelTime(r'\bTRIP'),
        'cont': fuelTime(r'\bCONT(?:%\d+|\d+MI\s*N)?'),
        'altn': fuelTime(r'\bALTN'),
        'fnlRes': fuelTime(r'\bFNL\s+RES'),
        'etpAdj': fuelTime(r'\bETP\s+ADJ'),
        'addnl': fuelTime(r'\bADDNL'),
        'unusable': fuelTime(r'\bUNUSABLE'),
        'arrDly': fuelTime(r'\bARR\s+DLY'),
        'extra': fuelTime(r'\bEXTRA'),
        'disc': fuelTime(r'\bDISC'),
        'taxiApu': fuelTime(r'\bTAXI/APU'),
        'ramp': fuelTime(r'\bRAMP'),
      },
      maxPayloadPlan: RegExp(
        r'\bMAX\s+PAYLOAD\s+PLAN\b',
        caseSensitive: false,
      ).hasMatch(text),
    );
  }

  String _frontPageRoute(String text, String departure, String arrival) {
    final lines = text.split(RegExp(r'\r?\n'));
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      if (!line.startsWith('$departure ')) continue;
      final routeLines = <String>[line];
      for (var next = index + 1; next < lines.length; next++) {
        final nextLine = lines[next].trim();
        if (nextLine.startsWith('$departure/')) break;
        if (nextLine.isNotEmpty) routeLines.add(nextLine);
      }
      final route = routeLines.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (RegExp(r'\b' + RegExp.escape(arrival) + r'$').hasMatch(route)) {
        return route;
      }
    }
    return '';
  }
}
