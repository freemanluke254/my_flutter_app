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
