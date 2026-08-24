import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/calendar/models/calendar_entry.dart';
import 'package:trying_flutter/features/roster/services/ical_roster_parser.dart';

void main() {
  test('parses and expands iCalendar roster events', () {
    const source = '''BEGIN:VCALENDAR
BEGIN:VEVENT
DTSTART:20260501
DTEND:20260504
SUMMARY:VS300/VS301 LHR-DEL-LHR
DESCRIPTION:Duty #1: VS300\\nDuty #2: VS301
END:VEVENT
BEGIN:VEVENT
DTSTART:20260504
DTEND:20260505
SUMMARY:RDO
DESCRIPTION:RDO - Day Off
END:VEVENT
END:VCALENDAR''';

    final entries = const IcalRosterParser().parse(source);

    expect(entries, hasLength(4));
    expect(entries.first.title, 'VS300/VS301 LHR-DEL-LHR');
    expect(entries.first.type, CalendarEntryType.flight);
    expect(entries.last.title, 'RDO · Day Off');
    expect(entries.last.type, CalendarEntryType.dayOff);
  });
}
