import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/briefing/models/flight_briefing.dart';
import 'package:trying_flutter/features/briefing/services/flight_package_validator.dart';
import 'package:trying_flutter/features/briefing/services/ofp_parser.dart';

void main() {
  const validator = FlightPackageValidator();
  final selected = FlightBriefing(
    flightNumber: 'VS358',
    callsign: 'VS358',
    route: 'LHR → JNB',
    departureTime: '10:00',
    arrivalTime: '21:00',
    aircraftType: 'B787-9',
    registration: '',
    planType: 'Roster flight',
    documents: const [],
    flightDate: DateTime(2026, 8, 25),
  );

  test('accepts equivalent airline callsign and ICAO route', () {
    final issues = validator.validate(
      selected: selected,
      ofp: OfpFlightDetails(
        flightNumber: 'VS358',
        callsign: 'VIR358',
        departure: 'EGLL',
        arrival: 'FAOR',
        departureTime: '1000',
        arrivalTime: '2100',
        aircraftType: 'B789',
        registration: 'G-VXXX',
        operation: 'ETOPS',
        planId: '123',
        flightDate: DateTime(2026, 8, 25),
      ),
    );
    expect(issues, isEmpty);
  });

  test('reports date route and callsign mismatches', () {
    final issues = validator.validate(
      selected: selected,
      ofp: OfpFlightDetails(
        flightNumber: 'VS23',
        callsign: 'VIR23',
        departure: 'EGLL',
        arrival: 'KLAS',
        departureTime: '1000',
        arrivalTime: '2100',
        aircraftType: 'B789',
        registration: 'G-VXXX',
        operation: 'ETOPS',
        planId: '456',
        flightDate: DateTime(2026, 8, 26),
      ),
    );
    expect(issues, hasLength(3));
  });
}
