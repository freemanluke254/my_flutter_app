enum DutyType { flight, standby }

class DayDuty {
  const DayDuty.flight({
    required this.title,
    required this.reportTime,
    required this.startTime,
    required this.endTime,
    required this.departure,
    required this.arrival,
    this.aircraft,
  }) : type = DutyType.flight,
       standbyLocation = null;

  const DayDuty.standby({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.standbyLocation,
  }) : type = DutyType.standby,
       reportTime = null,
       departure = null,
       arrival = null,
       aircraft = null;

  final DutyType type;
  final String title;
  final String? reportTime;
  final String startTime;
  final String endTime;
  final String? departure;
  final String? arrival;
  final String? aircraft;
  final String? standbyLocation;
}
