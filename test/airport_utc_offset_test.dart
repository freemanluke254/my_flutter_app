import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/calendar/services/airport_utc_offset.dart';

void main() {
  const offsets = AirportUtcOffset();

  test('FAOR and JNB remain UTC plus two throughout the year', () {
    expect(offsets.offsetFor('FAOR', DateTime(2026, 1, 10)), '+02:00');
    expect(offsets.offsetFor('jnb', DateTime(2026, 8, 24)), '+02:00');
  });

  test('UK airports follow summer time dates', () {
    expect(offsets.offsetFor('EGLL', DateTime(2026, 1, 10)), '+00:00');
    expect(offsets.offsetFor('LHR', DateTime(2026, 8, 24)), '+01:00');
  });
}
