import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/flight_briefing.dart';

class StoredFlightBriefing {
  const StoredFlightBriefing({
    required this.flight,
    required this.active,
    required this.selectedByUser,
  });
  final FlightBriefing flight;
  final bool active;
  final bool selectedByUser;
}

class BriefingStorage {
  static const _currentKey = 'current_flight_briefing_v1';
  static const _savedKey = 'saved_flight_briefings_v1';
  static const _closedKey = 'closed_calendar_flights_v1';

  Future<StoredFlightBriefing?> loadCurrent() async {
    final source = (await SharedPreferences.getInstance()).getString(
      _currentKey,
    );
    if (source == null) return null;
    final json = (jsonDecode(source) as Map<Object?, Object?>)
        .cast<String, Object?>();
    return StoredFlightBriefing(
      flight: _flightFromJson(
        (json['flight']! as Map<Object?, Object?>).cast<String, Object?>(),
      ),
      active: json['active'] as bool? ?? false,
      selectedByUser: json['selectedByUser'] as bool? ?? false,
    );
  }

  Future<void> saveCurrent(
    FlightBriefing flight,
    bool active, {
    bool selectedByUser = true,
  }) async {
    await (await SharedPreferences.getInstance()).setString(
      _currentKey,
      jsonEncode({
        'active': active,
        'selectedByUser': selectedByUser,
        'flight': _flightToJson(flight),
      }),
    );
  }

  Future<void> clearCurrent() async {
    await (await SharedPreferences.getInstance()).remove(_currentKey);
  }

  Future<Set<String>> loadClosedFlightKeys() async =>
      (await SharedPreferences.getInstance())
          .getStringList(_closedKey)
          ?.toSet() ??
      <String>{};

  Future<void> markFlightClosed(FlightBriefing flight) async {
    final preferences = await SharedPreferences.getInstance();
    final keys = preferences.getStringList(_closedKey)?.toSet() ?? <String>{};
    keys.add(flightKey(flight));
    await preferences.setStringList(_closedKey, keys.toList());
  }

  String flightKey(FlightBriefing flight) =>
      '${flight.flightNumber.toUpperCase()}|${flight.flightDate?.toIso8601String() ?? flight.departureTime}';

  Future<void> archiveForLogbook(FlightBriefing flight) async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_savedKey);
    final saved = existing == null
        ? <Object?>[]
        : jsonDecode(existing) as List<Object?>;
    saved.removeWhere(
      (value) =>
          (value! as Map<Object?, Object?>)['flightNumber'] ==
          flight.flightNumber,
    );
    saved.add({
      ..._flightToJson(flight),
      'savedAt': DateTime.now().toIso8601String(),
      'logbookStatus': 'pending',
    });
    await preferences.setString(_savedKey, jsonEncode(saved));
  }

  Map<String, Object?> _flightToJson(FlightBriefing flight) => {
    'flightNumber': flight.flightNumber,
    'route': flight.route,
    'departureTime': flight.departureTime,
    'arrivalTime': flight.arrivalTime,
    'departureTimeUtc': flight.departureTimeUtc,
    'arrivalTimeUtc': flight.arrivalTimeUtc,
    'aircraftType': flight.aircraftType,
    'registration': flight.registration,
    'planType': flight.planType,
    'callsign': flight.callsign,
    'planId': flight.planId,
    'reportTime': flight.reportTime,
    'scheduledDepartureUtc': flight.scheduledDepartureUtc?.toIso8601String(),
    'flightDate': flight.flightDate?.toIso8601String(),
    'scheduledFlightTime': flight.scheduledFlightTime,
    'flightPlanTime': flight.flightPlanTime,
    'detailedRoute': flight.detailedRoute,
    'captain': flight.captain,
    'firstOfficer': flight.firstOfficer,
    'reliefPilot': flight.reliefPilot,
    'otherCrew': flight.otherCrew,
    'otherCrewRole': flight.otherCrewRole,
    'pilotFlying': flight.pilotFlying,
    'takeoffWeight': flight.takeoffWeight,
    'landingWeight': flight.landingWeight,
    'zeroFuelWeight': flight.zeroFuelWeight,
    'payload': flight.payload,
    'blockFuel': flight.blockFuel,
    'taxiFuel': flight.taxiFuel,
    'tripFuel': flight.tripFuel,
    'contingencyFuel': flight.contingencyFuel,
    'finalReserveFuel': flight.finalReserveFuel,
    'extraFuel': flight.extraFuel,
    'flightDeckCount': flight.flightDeckCount,
    'cabinCrewCount': flight.cabinCrewCount,
    'fsm': flight.fsm,
    'css': flight.css,
    'stand': flight.stand,
    'melCdlReferences': flight.melCdlReferences,
    'defectSummary': flight.defectSummary,
    'operationalRestrictions': flight.operationalRestrictions,
    'documents': flight.documents
        .map(
          (document) => {
            'type': document.type.name,
            'title': document.title,
            'fileCount': document.fileCount,
            'fileNames': document.fileNames,
            'filePaths': document.filePaths,
          },
        )
        .toList(),
  };

  FlightBriefing _flightFromJson(Map<String, Object?> json) => FlightBriefing(
    flightNumber: json['flightNumber']! as String,
    route: json['route']! as String,
    departureTime: json['departureTime']! as String,
    arrivalTime: json['arrivalTime']! as String,
    departureTimeUtc: json['departureTimeUtc'] as String? ?? '',
    arrivalTimeUtc: json['arrivalTimeUtc'] as String? ?? '',
    aircraftType: json['aircraftType']! as String,
    registration: json['registration']! as String,
    planType: json['planType']! as String,
    callsign: json['callsign'] as String? ?? '',
    planId: json['planId'] as String? ?? '',
    reportTime: json['reportTime'] as String? ?? '',
    scheduledDepartureUtc: json['scheduledDepartureUtc'] == null
        ? null
        : DateTime.parse(json['scheduledDepartureUtc']! as String),
    flightDate: json['flightDate'] == null
        ? null
        : DateTime.parse(json['flightDate']! as String),
    scheduledFlightTime: json['scheduledFlightTime'] as String? ?? '',
    flightPlanTime: json['flightPlanTime'] as String? ?? '',
    detailedRoute: json['detailedRoute'] as String? ?? '',
    captain: json['captain'] as String? ?? '',
    firstOfficer: json['firstOfficer'] as String? ?? '',
    reliefPilot: json['reliefPilot'] as String? ?? '',
    otherCrew: json['otherCrew'] as String? ?? '',
    otherCrewRole: json['otherCrewRole'] as String? ?? 'Other',
    pilotFlying: json['pilotFlying'] as String? ?? '',
    takeoffWeight: json['takeoffWeight'] as String? ?? '',
    landingWeight: json['landingWeight'] as String? ?? '',
    zeroFuelWeight: json['zeroFuelWeight'] as String? ?? '',
    payload: json['payload'] as String? ?? '',
    blockFuel: json['blockFuel'] as String? ?? '',
    taxiFuel: json['taxiFuel'] as String? ?? '',
    tripFuel: json['tripFuel'] as String? ?? '',
    contingencyFuel: json['contingencyFuel'] as String? ?? '',
    finalReserveFuel: json['finalReserveFuel'] as String? ?? '',
    extraFuel: json['extraFuel'] as String? ?? '',
    flightDeckCount: json['flightDeckCount'] as int? ?? 3,
    cabinCrewCount: json['cabinCrewCount'] as int? ?? 10,
    fsm: json['fsm'] as String? ?? '',
    css: json['css'] as String? ?? '',
    stand: json['stand'] as String? ?? '',
    melCdlReferences: json['melCdlReferences'] as String? ?? '',
    defectSummary: json['defectSummary'] as String? ?? '',
    operationalRestrictions: json['operationalRestrictions'] as String? ?? '',
    documents: (json['documents']! as List<Object?>).map((value) {
      final item = (value! as Map<Object?, Object?>).cast<String, Object?>();
      return BriefingDocument(
        type: BriefingDocumentType.values.byName(item['type']! as String),
        title: item['title']! as String,
        fileCount: item['fileCount']! as int,
        fileNames:
            (item['fileNames'] as List<Object?>?)?.cast<String>() ?? const [],
        filePaths:
            (item['filePaths'] as List<Object?>?)?.cast<String>() ?? const [],
      );
    }).toList(),
  );
}
