import 'package:flutter/material.dart';

enum CalendarEntryType {
  flight,
  standby,
  reserve,
  training,
  leave,
  sickness,
  expiry,
  dayOff,
}

class CalendarEntry {
  const CalendarEntry({
    required this.date,
    required this.type,
    required this.title,
    required this.details,
    this.continuityId,
    this.utcPeriod,
    this.showDetails = true,
  });

  final DateTime date;
  final CalendarEntryType type;
  final String title;
  final String details;
  final String? continuityId;
  final String? utcPeriod;
  final bool showDetails;

  String get continuityKey => continuityId ?? '${type.name}:$title';

  Color get color => switch (type) {
    CalendarEntryType.flight => const Color(0xFF28634A),
    CalendarEntryType.standby => const Color(0xFFBD7A17),
    CalendarEntryType.reserve => const Color(0xFF9A6418),
    CalendarEntryType.training => const Color(0xFF315F9A),
    CalendarEntryType.leave => const Color(0xFF6D5796),
    CalendarEntryType.sickness => const Color(0xFF9B5361),
    CalendarEntryType.expiry => const Color(0xFFB93B3B),
    CalendarEntryType.dayOff => const Color(0xFF78817B),
  };

  IconData get icon => switch (type) {
    CalendarEntryType.flight => Icons.flight_takeoff_rounded,
    CalendarEntryType.standby => Icons.schedule_rounded,
    CalendarEntryType.reserve => Icons.event_available_outlined,
    CalendarEntryType.training => Icons.school_outlined,
    CalendarEntryType.leave => Icons.beach_access_outlined,
    CalendarEntryType.sickness => Icons.medical_services_outlined,
    CalendarEntryType.expiry => Icons.warning_amber_rounded,
    CalendarEntryType.dayOff => Icons.free_breakfast_outlined,
  };
}
