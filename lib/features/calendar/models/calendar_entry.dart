import 'package:flutter/material.dart';

enum CalendarEntryType { flight, standby, training, expiry, dayOff }

class CalendarEntry {
  const CalendarEntry({
    required this.date,
    required this.type,
    required this.title,
    required this.details,
  });

  final DateTime date;
  final CalendarEntryType type;
  final String title;
  final String details;

  Color get color => switch (type) {
    CalendarEntryType.flight => const Color(0xFF28634A),
    CalendarEntryType.standby => const Color(0xFFBD7A17),
    CalendarEntryType.training => const Color(0xFF315F9A),
    CalendarEntryType.expiry => const Color(0xFFB93B3B),
    CalendarEntryType.dayOff => const Color(0xFF78817B),
  };

  IconData get icon => switch (type) {
    CalendarEntryType.flight => Icons.flight_takeoff_rounded,
    CalendarEntryType.standby => Icons.schedule_rounded,
    CalendarEntryType.training => Icons.school_outlined,
    CalendarEntryType.expiry => Icons.warning_amber_rounded,
    CalendarEntryType.dayOff => Icons.free_breakfast_outlined,
  };
}
