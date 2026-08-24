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
DESCRIPTION:Duty #1: 01 May: VS 300 LHR-DEL LOCAL: 1835-0940 (UTC: 1735-0410)\\nDuty #2: 03 May: VS 301 DEL-LHR LOCAL: 0950-1645 (UTC: 0420-1545)
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
    expect(entries.first.title, 'VS300 LHR–DEL');
    expect(entries.first.type, CalendarEntryType.flight);
    expect(entries.first.utcPeriod, '1735Z–0410Z');
    expect(entries.first.barLabel, 'VS300');
    expect(entries[1].title, 'Away from home');
    expect(entries[1].showDetails, isFalse);
    expect(entries[1].barLabel, '24H10');
    expect(entries[2].title, 'VS301 DEL–LHR');
    expect(entries[2].barLabel, 'VS301');
    expect(entries[2].barLabelPosition, CalendarBarLabelPosition.right);
    expect(entries.last.title, 'RDO · Day Off');
    expect(entries.last.type, CalendarEntryType.dayOff);
  });
}
