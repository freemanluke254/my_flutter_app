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
    this.finalReserveFuel = '',
    this.extraFuel = '',
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
  final String finalReserveFuel;
  final String extraFuel;
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
    String match(String pattern, {int group = 1, String fallback = ''}) =>
        RegExp(
          pattern,
          caseSensitive: false,
          multiLine: true,
        ).firstMatch(text!)?.group(group)?.trim() ??
        fallback;
    final route = RegExp(r'\b([A-Z]{4})-([A-Z]{4})\b').firstMatch(text);
    final flightNumber = match(r'OPERATIONAL FLIGHT PLAN\s+([A-Z]{2}\d+)');
    if (flightNumber.isEmpty || route == null) {
      throw const FormatException(
        'The flight number or route could not be decoded. Enter the details manually.',
      );
    }
    final dateMatch = RegExp(
      r'\b(\d{2})(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(\d{2})\b',
      caseSensitive: false,
    ).firstMatch(text);
    final departure = route.group(1)!;
    final arrival = route.group(2)!;
    final atcRoute = RegExp(
      '^(${RegExp.escape(departure)}\\s+[\\s\\S]*?\\s+${RegExp.escape(arrival)})\\r?\\n${RegExp.escape(departure)}/',
      multiLine: true,
    ).firstMatch(text)?.group(1)?.replaceAll(RegExp(r'\s+'), ' ').trim();
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
      scheduledFlightTime: match(r'\bSCH\s+(\d{1,2}[.:]\d{2})'),
      flightPlanTime: match(r'\bTRIP\s+\d+\s+(\d{2}[.:]\d{2})'),
      detailedRoute: atcRoute ?? '',
      takeoffWeight: match(r'RLF1\s+(\d+)'),
      landingWeight: match(r'PAX\s+SOB\s+(\d+)'),
      zeroFuelWeight: match(r'NBR\s+PF/PNF\s+(\d+)'),
      payload: match(r'PAYLOAD\s*[: ]\s*(\d+(?:\.\d+)?)'),
      blockFuel: match(r'\bRAMP\s+(\d+)'),
      taxiFuel: match(r'\bTAXI/APU\s+(\d+)'),
      tripFuel: match(r'\bTRIP\s+(\d+)'),
      contingencyFuel: match(r'\bCONT%?\d*\s+(\d+)'),
      finalReserveFuel: match(r'\bFNL\s+RES\s+(\d+)'),
      extraFuel: match(r'\bEXTRA\s+(\d+)'),
    );
  }
}
