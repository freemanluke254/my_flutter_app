import '../../calendar/models/calendar_entry.dart';

class DutyCode {
  const DutyCode({
    required this.code,
    required this.name,
    required this.calendarType,
  });

  final String code;
  final String name;
  final CalendarEntryType calendarType;

  static const catalogue = <String, DutyCode>{
    'CDO': DutyCode(
      code: 'CDO',
      name: 'Confirmed Day Off',
      calendarType: CalendarEntryType.dayOff,
    ),
    'LPC': DutyCode(
      code: 'LPC',
      name: 'Line Proficiency Check',
      calendarType: CalendarEntryType.training,
    ),
    'OPC': DutyCode(
      code: 'OPC',
      name: 'Operator Proficiency Check',
      calendarType: CalendarEntryType.training,
    ),
    'RDO': DutyCode(
      code: 'RDO',
      name: 'Day Off',
      calendarType: CalendarEntryType.dayOff,
    ),
    'RSV': DutyCode(
      code: 'RSV',
      name: 'Reserve Duty',
      calendarType: CalendarEntryType.reserve,
    ),
    'SBY': DutyCode(
      code: 'SBY',
      name: 'Home Standby Duty',
      calendarType: CalendarEntryType.standby,
    ),
    'LVE': DutyCode(
      code: 'LVE',
      name: 'Leave',
      calendarType: CalendarEntryType.leave,
    ),
    'XX': DutyCode(
      code: 'XX',
      name: 'Long-Term Sick',
      calendarType: CalendarEntryType.sickness,
    ),
    'LB': DutyCode(
      code: 'LB',
      name: 'Parental Leave',
      calendarType: CalendarEntryType.leave,
    ),
    'LSS': DutyCode(
      code: 'LSS',
      name: 'Leave Stability Day Short',
      calendarType: CalendarEntryType.leave,
    ),
    'RDOL': DutyCode(
      code: 'RDOL',
      name: 'Parental Leave Day Off',
      calendarType: CalendarEntryType.dayOff,
    ),
    'LSL': DutyCode(
      code: 'LSL',
      name: 'Leave Stability Day Long',
      calendarType: CalendarEntryType.leave,
    ),
  };

  static DutyCode? fromCode(String value) =>
      catalogue[value.trim().toUpperCase()];
}
