import '../../calendar/models/calendar_entry.dart';
import '../models/duty_code.dart';

class IcalRosterParser {
  const IcalRosterParser();

  List<CalendarEntry> parse(String source) {
    final unfolded = source.replaceAll(RegExp(r'\r?\n[ \t]'), '');
    final blocks = RegExp(
      r'BEGIN:VEVENT\r?\n([\s\S]*?)END:VEVENT',
    ).allMatches(unfolded);
    final entries = <CalendarEntry>[];

    for (final block in blocks) {
      final fields = <String, String>{};
      for (final line in block.group(1)!.split(RegExp(r'\r?\n'))) {
        final separator = line.indexOf(':');
        if (separator < 0) continue;
        final key = line.substring(0, separator).split(';').first;
        fields[key] = line.substring(separator + 1);
      }

      final start = _date(fields['DTSTART']);
      final exclusiveEnd = _date(fields['DTEND']);
      if (start == null) continue;
      final end = exclusiveEnd ?? start.add(const Duration(days: 1));
      final summary = _unescape(fields['SUMMARY'] ?? 'Roster duty');
      final description = _unescape(fields['DESCRIPTION'] ?? '');
      final code = summary.split(RegExp(r'[/\s]')).first;
      final dutyCode = DutyCode.fromCode(code);
      final type = summary.contains(RegExp(r'VS\d', caseSensitive: false))
          ? CalendarEntryType.flight
          : dutyCode?.calendarType ?? CalendarEntryType.flight;
      final title = dutyCode == null
          ? summary
          : '${dutyCode.code} · ${dutyCode.name}';

      if (type == CalendarEntryType.flight) {
        final flightEntries = _flightTripEntries(
          start: start,
          end: end,
          summary: summary,
          description: description,
        );
        if (flightEntries.isNotEmpty) {
          entries.addAll(flightEntries);
          continue;
        }
      }

      for (
        var date = start;
        date.isBefore(end);
        date = date.add(const Duration(days: 1))
      ) {
        entries.add(
          CalendarEntry(
            date: date,
            type: type,
            title: title,
            details: description.isEmpty ? 'Imported from roster' : description,
          ),
        );
      }
    }
    entries.sort((first, second) => first.date.compareTo(second.date));
    return entries;
  }

  List<CalendarEntry> _flightTripEntries({
    required DateTime start,
    required DateTime end,
    required String summary,
    required String description,
  }) {
    final pattern = RegExp(
      r'Duty #\d+:\s*(\d{1,2})\s+\w+:\s*([A-Z]{2})\s*(\d+)\s+([A-Z]{3})-([A-Z]{3})\s+LOCAL:\s*(\d{4})-(\d{4})\s+\(UTC:\s*(\d{4})-(\d{4})\)',
      caseSensitive: false,
    );
    final legs = <int, _RosterLeg>{};
    for (final match in pattern.allMatches(description)) {
      final day = int.parse(match.group(1)!);
      legs[day] = _RosterLeg(
        day: day,
        flightNumber: '${match.group(2)!.toUpperCase()}${match.group(3)}',
        departure: match.group(4)!.toUpperCase(),
        arrival: match.group(5)!.toUpperCase(),
        localPeriod: '${match.group(6)}–${match.group(7)}',
        utcPeriod: '${match.group(8)}Z–${match.group(9)}Z',
      );
    }
    if (legs.isEmpty) return const [];

    final orderedLegs = legs.values.toList()
      ..sort((first, second) => first.day.compareTo(second.day));
    final downrouteLabel = orderedLegs.length < 2
        ? null
        : _downrouteTime(start, orderedLegs.first, orderedLegs.last);
    final tripDays = end.difference(start).inDays;
    final downrouteDay = tripDays < 3
        ? null
        : start.add(Duration(days: (tripDays - 1) ~/ 2));

    final result = <CalendarEntry>[];
    for (
      var date = start;
      date.isBefore(end);
      date = date.add(const Duration(days: 1))
    ) {
      final leg = legs[date.day];
      final isFirstLeg = leg == orderedLegs.first;
      final isLastLeg = leg == orderedLegs.last;
      final isDownrouteLabel =
          leg == null &&
          downrouteDay != null &&
          date.year == downrouteDay.year &&
          date.month == downrouteDay.month &&
          date.day == downrouteDay.day;
      result.add(
        CalendarEntry(
          date: date,
          type: CalendarEntryType.flight,
          continuityId: summary,
          title: leg == null
              ? 'Away from home'
              : '${leg.flightNumber} ${leg.departure}–${leg.arrival}',
          details: leg == null
              ? 'Away between rostered sectors.'
              : 'Local ${leg.localPeriod}\nUTC ${leg.utcPeriod}',
          utcPeriod: leg?.utcPeriod,
          showDetails: leg != null,
          barLabel: leg != null
              ? leg.flightNumber
              : isDownrouteLabel
              ? downrouteLabel
              : null,
          barLabelPosition: isLastLeg
              ? CalendarBarLabelPosition.right
              : isFirstLeg
              ? CalendarBarLabelPosition.left
              : CalendarBarLabelPosition.center,
        ),
      );
    }
    return result;
  }

  String _downrouteTime(
    DateTime month,
    _RosterLeg outbound,
    _RosterLeg inbound,
  ) {
    final outboundStart = _utcDateTime(month, outbound.day, outbound.utcStart);
    var outboundArrival = _utcDateTime(month, outbound.day, outbound.utcEnd);
    if (!outboundArrival.isAfter(outboundStart)) {
      outboundArrival = outboundArrival.add(const Duration(days: 1));
    }
    final inboundDeparture = _utcDateTime(month, inbound.day, inbound.utcStart);
    final minutes = inboundDeparture.difference(outboundArrival).inMinutes;
    if (minutes < 0) return 'DOWNROUTE';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return '${hours}H${remainder.toString().padLeft(2, '0')}';
  }

  DateTime _utcDateTime(DateTime month, int day, String time) => DateTime.utc(
    month.year,
    month.month,
    day,
    int.parse(time.substring(0, 2)),
    int.parse(time.substring(2, 4)),
  );

  DateTime? _date(String? value) {
    if (value == null || value.length < 8) return null;
    return DateTime.tryParse(
      '${value.substring(0, 4)}-${value.substring(4, 6)}-${value.substring(6, 8)}',
    );
  }

  String _unescape(String value) => value
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\,', ',')
      .replaceAll(r'\;', ';')
      .replaceAll(r'\\', r'\');
}

class _RosterLeg {
  const _RosterLeg({
    required this.day,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.localPeriod,
    required this.utcPeriod,
  });

  final int day;
  final String flightNumber;
  final String departure;
  final String arrival;
  final String localPeriod;
  final String utcPeriod;

  String get utcStart => utcPeriod.substring(0, 4);
  String get utcEnd => utcPeriod.substring(6, 10);
}
