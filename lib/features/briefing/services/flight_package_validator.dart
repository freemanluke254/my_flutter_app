import '../models/flight_briefing.dart';
import 'ofp_parser.dart';

class FlightPackageValidator {
  const FlightPackageValidator();

  List<String> validate({
    required FlightBriefing selected,
    required OfpFlightDetails ofp,
  }) {
    final issues = <String>[];
    final selectedRoute = _route(selected.route);
    final ofpRoute = [_airport(ofp.departure), _airport(ofp.arrival)];
    if (selectedRoute.length == 2 &&
        (selectedRoute[0] != ofpRoute[0] || selectedRoute[1] != ofpRoute[1])) {
      issues.add(
        'Route mismatch: selected ${selected.route}, OFP ${ofp.departure}–${ofp.arrival}.',
      );
    }

    final selectedIdentity = selected.callsign.isEmpty
        ? selected.flightNumber
        : selected.callsign;
    if (!_sameFlightIdentity(selectedIdentity, ofp.callsign) &&
        !_sameFlightIdentity(selected.flightNumber, ofp.flightNumber)) {
      issues.add(
        'Callsign mismatch: selected $selectedIdentity, OFP ${ofp.callsign.isEmpty ? ofp.flightNumber : ofp.callsign}.',
      );
    }

    final selectedDate = selected.flightDate;
    final ofpDate = ofp.flightDate;
    if (selectedDate != null &&
        ofpDate != null &&
        !_sameDate(selectedDate, ofpDate)) {
      issues.add(
        'Date mismatch: selected ${_date(selectedDate)}, OFP ${_date(ofpDate)}.',
      );
    }
    if (ofpDate == null) {
      issues.add('The flight date could not be verified from the OFP.');
    }
    return issues;
  }

  List<String> _route(String value) => value
      .toUpperCase()
      .split(RegExp(r'\s*[→–-]\s*'))
      .where((part) => part.isNotEmpty)
      .map(_airport)
      .toList();

  String _airport(String code) =>
      const {
        'LHR': 'EGLL',
        'JNB': 'FAOR',
        'CPT': 'FACT',
        'LAS': 'KLAS',
        'JFK': 'KJFK',
        'BOS': 'KBOS',
        'LAX': 'KLAX',
        'SFO': 'KSFO',
        'MCO': 'KMCO',
        'ATL': 'KATL',
        'IAD': 'KIAD',
        'DXB': 'OMDB',
        'DEL': 'VIDP',
        'BOM': 'VABB',
      }[code.trim().toUpperCase()] ??
      code.trim().toUpperCase();

  bool _sameFlightIdentity(String first, String second) {
    final firstNumber = RegExp(r'\d+[A-Z]?$').firstMatch(first.toUpperCase());
    final secondNumber = RegExp(r'\d+[A-Z]?$').firstMatch(second.toUpperCase());
    return firstNumber != null &&
        secondNumber != null &&
        firstNumber.group(0) == secondNumber.group(0);
  }

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
