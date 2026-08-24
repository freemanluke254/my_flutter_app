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
  });
  final String flightNumber;
  final String departure;
  final String arrival;
  final String departureTime;
  final String arrivalTime;
  final String aircraftType;
  final String registration;
  final String operation;
}

class OfpParser {
  const OfpParser();
  static const _channel = MethodChannel('pilot_app/pdf_text');

  Future<OfpFlightDetails> parse(Uint8List bytes) async {
    final text = await _channel.invokeMethod<String>('extractText', bytes);
    if (text == null || text.isEmpty) {
      throw const FormatException('No selectable text was found in the OFP.');
    }
    String match(String pattern, {int group = 1, String fallback = ''}) =>
        RegExp(
          pattern,
          caseSensitive: false,
          multiLine: true,
        ).firstMatch(text)?.group(group)?.trim() ??
        fallback;
    final route = RegExp(r'\b([A-Z]{4})-([A-Z]{4})\b').firstMatch(text);
    final flightNumber = match(r'OPERATIONAL FLIGHT PLAN\s+([A-Z]{2}\d+)');
    if (flightNumber.isEmpty || route == null) {
      throw const FormatException(
        'The flight number or route could not be decoded. Enter the details manually.',
      );
    }
    return OfpFlightDetails(
      flightNumber: flightNumber,
      departure: route.group(1)!,
      arrival: route.group(2)!,
      departureTime: match(r'STD LOCAL\s+\S+\s+(\d{4})', fallback: 'Pending'),
      arrivalTime: match(r'STA\s+\S+\s+(\d{4}\+?)', fallback: 'Pending'),
      aircraftType: match(r'^TYPE\s+([^\r\n]+)', fallback: 'Pending'),
      registration: match(r'REGN\s+([A-Z0-9]+)', fallback: 'Pending'),
      operation: match(r'APPL RULE:\s*([^\r\n]+)', fallback: 'From OFP'),
    );
  }
}
