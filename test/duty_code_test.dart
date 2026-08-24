import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/calendar/models/calendar_entry.dart';
import 'package:trying_flutter/features/roster/models/duty_code.dart';

void main() {
  test('duty codes are matched without case or surrounding spaces', () {
    final duty = DutyCode.fromCode(' opc ');

    expect(duty?.name, 'Operator Proficiency Check');
    expect(duty?.calendarType, CalendarEntryType.training);
  });

  test('unknown duty codes remain available for manual review', () {
    expect(DutyCode.fromCode('UNKNOWN'), isNull);
  });
}
