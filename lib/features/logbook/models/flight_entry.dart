part of '../../../flight_logbook_page.dart';

class FlightEntry {
  const FlightEntry({
    required this.date,
    required this.aircraftType,
    required this.registration,
    required this.departurePlace,
    required this.departureTime,
    required this.arrivalPlace,
    required this.arrivalTime,
    required this.totalTime,
    required this.picName,
    required this.pilotFunction,
    required this.singleMultiEngine,
    required this.dayLandings,
    required this.nightLandings,
    required this.nightTime,
    required this.ifrTime,
    required this.remarks,
    required this.source,
  });

  final DateTime date;
  final String aircraftType;
  final String registration;
  final String departurePlace;
  final String departureTime;
  final String arrivalPlace;
  final String arrivalTime;
  final Duration totalTime;
  final String picName;
  final String pilotFunction;
  final String singleMultiEngine;
  final int dayLandings;
  final int nightLandings;
  final Duration nightTime;
  final Duration ifrTime;
  final String remarks;
  final String source;

  List<String> get pdfRow => [
    _formatDate(date),
    '$aircraftType\n$registration',
    '$departurePlace\n$departureTime',
    '$arrivalPlace\n$arrivalTime',
    singleMultiEngine.startsWith('Multi') ? 'M' : 'S',
    _formatDuration(totalTime),
    picName,
    '$dayLandings / $nightLandings',
    _formatDuration(nightTime),
    _formatDuration(ifrTime),
    pilotFunction,
    remarks,
  ];
}
