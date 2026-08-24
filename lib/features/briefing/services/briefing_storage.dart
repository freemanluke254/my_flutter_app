import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/flight_briefing.dart';

class StoredFlightBriefing {
  const StoredFlightBriefing({required this.flight, required this.active});
  final FlightBriefing flight;
  final bool active;
}

class BriefingStorage {
  static const _currentKey = 'current_flight_briefing_v1';
  static const _savedKey = 'saved_flight_briefings_v1';

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
    );
  }

  Future<void> saveCurrent(FlightBriefing flight, bool active) async {
    await (await SharedPreferences.getInstance()).setString(
      _currentKey,
      jsonEncode({'active': active, 'flight': _flightToJson(flight)}),
    );
  }

  Future<void> clearCurrent() async {
    await (await SharedPreferences.getInstance()).remove(_currentKey);
  }

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
    'aircraftType': flight.aircraftType,
    'registration': flight.registration,
    'planType': flight.planType,
    'documents': flight.documents
        .map(
          (document) => {
            'type': document.type.name,
            'title': document.title,
            'fileCount': document.fileCount,
          },
        )
        .toList(),
  };

  FlightBriefing _flightFromJson(Map<String, Object?> json) => FlightBriefing(
    flightNumber: json['flightNumber']! as String,
    route: json['route']! as String,
    departureTime: json['departureTime']! as String,
    arrivalTime: json['arrivalTime']! as String,
    aircraftType: json['aircraftType']! as String,
    registration: json['registration']! as String,
    planType: json['planType']! as String,
    documents: (json['documents']! as List<Object?>).map((value) {
      final item = (value! as Map<Object?, Object?>).cast<String, Object?>();
      return BriefingDocument(
        type: BriefingDocumentType.values.byName(item['type']! as String),
        title: item['title']! as String,
        fileCount: item['fileCount']! as int,
      );
    }).toList(),
  );
}
