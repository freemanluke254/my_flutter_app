import '../../calendar/models/calendar_entry.dart';
import '../../calendar/services/calendar_adjustment_storage.dart';
import '../../roster/services/roster_storage.dart';
import '../models/flight_briefing.dart';

class CalendarFlightSource {
  CalendarFlightSource({
    RosterStorage? rosterStorage,
    CalendarAdjustmentStorage? adjustmentStorage,
  }) : _rosterStorage = rosterStorage ?? RosterStorage(),
       _adjustmentStorage = adjustmentStorage ?? CalendarAdjustmentStorage();

  final RosterStorage _rosterStorage;
  final CalendarAdjustmentStorage _adjustmentStorage;

  Future<FlightBriefing?> loadNextFlight() async {
    final flights = await loadUpcomingFlights();
    return flights.isEmpty ? null : flights.first;
  }

  Future<List<FlightBriefing>> loadUpcomingFlights() async {
    final rosters = await _rosterStorage.load();
    final adjustments = await _adjustmentStorage.load();
    final rosterEntries = rosters.expand((roster) => roster.entries).toList();
    final entries = _adjustmentStorage.apply(rosterEntries, adjustments);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final flights =
        entries
            .where(
              (entry) =>
                  entry.type == CalendarEntryType.flight &&
                  entry.showDetails &&
                  !entry.date.isBefore(today),
            )
            .toList()
          ..sort((first, second) => first.date.compareTo(second.date));
    final nowUtc = DateTime.now().toUtc();
    return flights
        .map(_toBriefing)
        .where(
          (flight) =>
              flight.scheduledDepartureUtc == null ||
              !flight.scheduledDepartureUtc!.isBefore(nowUtc),
        )
        .toList();
  }

  FlightBriefing _toBriefing(CalendarEntry entry) {
    final titleParts = entry.title.trim().split(RegExp(r'\s+'));
    final flightNumber = titleParts.first;
    final route = titleParts.skip(1).join(' ');
    final localTimes = _detailValue(entry.details, 'Local');
    final utcTimes =
        _detailValue(entry.details, 'UTC') ?? entry.utcPeriod ?? '';
    final report = _detailValue(entry.details, 'Report') ?? '';
    final date = '${entry.date.day}/${entry.date.month}/${entry.date.year}';
    final timeSummary = [
      if (localTimes != null) 'Local $localTimes',
      if (utcTimes.isNotEmpty) 'UTC $utcTimes',
    ].join(' · ');

    return FlightBriefing(
      flightNumber: flightNumber,
      callsign: flightNumber,
      route: route.isEmpty ? 'Route pending' : route,
      departureTime:
          '$date · ${timeSummary.isEmpty ? 'Time pending' : timeSummary}',
      arrivalTime: timeSummary.isEmpty ? 'Time pending' : timeSummary,
      reportTime: report,
      scheduledDepartureUtc: _scheduledUtc(entry, utcTimes, localTimes),
      flightDate: DateTime(entry.date.year, entry.date.month, entry.date.day),
      aircraftType: 'Aircraft pending flight package',
      registration: '',
      planType: entry.manuallyEntered
          ? 'Manual calendar flight · Upload flight documents'
          : 'Roster flight · Upload flight documents',
      documents: const [],
    );
  }

  DateTime? _scheduledUtc(
    CalendarEntry entry,
    String utcTimes,
    String? localTimes,
  ) {
    final utcMatch = RegExp(r'(\d{2}):?(\d{2})').firstMatch(utcTimes);
    if (utcMatch == null) return null;
    var departure = DateTime.utc(
      entry.date.year,
      entry.date.month,
      entry.date.day,
      int.parse(utcMatch.group(1)!),
      int.parse(utcMatch.group(2)!),
    );
    final localMatch = localTimes == null
        ? null
        : RegExp(r'(\d{2}):?(\d{2})').firstMatch(localTimes);
    if (localMatch == null) return departure;
    final utcMinutes =
        int.parse(utcMatch.group(1)!) * 60 + int.parse(utcMatch.group(2)!);
    final localMinutes =
        int.parse(localMatch.group(1)!) * 60 + int.parse(localMatch.group(2)!);
    if (utcMinutes - localMinutes > 12 * 60) {
      departure = departure.subtract(const Duration(days: 1));
    } else if (localMinutes - utcMinutes > 12 * 60) {
      departure = departure.add(const Duration(days: 1));
    }
    return departure;
  }

  String? _detailValue(String details, String label) {
    for (final line in details.split('\n')) {
      if (line.toLowerCase().startsWith('${label.toLowerCase()} ')) {
        return line.substring(label.length).trim();
      }
    }
    return null;
  }
}
