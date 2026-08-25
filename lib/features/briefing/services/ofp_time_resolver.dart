import '../../calendar/services/airport_utc_offset.dart';
import 'ofp_parser.dart';

class OfpResolvedTimes {
  const OfpResolvedTimes({
    required this.departureUtc,
    required this.arrivalUtc,
  });
  final DateTime? departureUtc;
  final DateTime? arrivalUtc;

  String get departureLabel => _label(departureUtc);
  String get arrivalLabel => _label(arrivalUtc);

  String _label(DateTime? value) => value == null
      ? ''
      : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class OfpTimeResolver {
  const OfpTimeResolver();

  OfpResolvedTimes resolve(OfpFlightDetails ofp) {
    final date = ofp.flightDate;
    if (date == null) {
      return const OfpResolvedTimes(departureUtc: null, arrivalUtc: null);
    }
    return OfpResolvedTimes(
      departureUtc: _utc(
        date: date,
        localTime: ofp.departureTime,
        airport: ofp.departure,
      ),
      arrivalUtc: _utc(
        date: ofp.arrivalTime.endsWith('+')
            ? date.add(const Duration(days: 1))
            : date,
        localTime: ofp.arrivalTime,
        airport: ofp.arrival,
      ),
    );
  }

  DateTime? _utc({
    required DateTime date,
    required String localTime,
    required String airport,
  }) {
    final time = RegExp(r'^(\d{2})(\d{2})').firstMatch(localTime.trim());
    final offset = const AirportUtcOffset().offsetFor(airport, date);
    final offsetMatch = offset == null
        ? null
        : RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(offset);
    if (time == null || offsetMatch == null) return null;
    final sign = offsetMatch.group(1) == '-' ? -1 : 1;
    final offsetMinutes =
        sign *
        (int.parse(offsetMatch.group(2)!) * 60 +
            int.parse(offsetMatch.group(3)!));
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      int.parse(time.group(1)!),
      int.parse(time.group(2)!),
    ).subtract(Duration(minutes: offsetMinutes));
  }
}
