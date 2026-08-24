import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/calendar_entry.dart';
import 'airport_utc_offset.dart';

class CalendarAdjustment {
  const CalendarAdjustment({
    required this.id,
    this.originalEntryKey,
    this.entry,
  });
  final String id;
  final String? originalEntryKey;
  final CalendarEntry? entry;
}

class CalendarAdjustmentStorage {
  static const _key = 'calendar_adjustments_v1';

  Future<List<CalendarAdjustment>> load() async {
    final source = (await SharedPreferences.getInstance()).getString(_key);
    if (source == null) return [];
    return (jsonDecode(source) as List<Object?>).map((value) {
      final json = (value! as Map<Object?, Object?>).cast<String, Object?>();
      final id = json['id']! as String;
      return CalendarAdjustment(
        id: id,
        originalEntryKey: json['originalEntryKey'] as String?,
        entry: json['entry'] == null
            ? null
            : _entryFromJson(
                (json['entry']! as Map<Object?, Object?>)
                    .cast<String, Object?>(),
                id,
                json['originalEntryKey'] as String?,
              ),
      );
    }).toList();
  }

  Future<void> save(List<CalendarAdjustment> changes) async {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(
        changes
            .map(
              (change) => {
                'id': change.id,
                'originalEntryKey': change.originalEntryKey,
                'entry': change.entry == null
                    ? null
                    : _entryToJson(change.entry!),
              },
            )
            .toList(),
      ),
    );
  }

  List<CalendarEntry> apply(
    List<CalendarEntry> originals,
    List<CalendarAdjustment> changes,
  ) {
    final entries = [...originals];
    for (final change in changes) {
      if (change.originalEntryKey != null) {
        entries.removeWhere(
          (entry) => entry.entryKey == change.originalEntryKey,
        );
      }
      if (change.entry != null) entries.add(change.entry!);
    }
    final corrected = entries.map(_correctManualFlightTimes).toList();
    corrected.sort((a, b) => a.date.compareTo(b.date));
    return corrected;
  }

  CalendarEntry _correctManualFlightTimes(CalendarEntry entry) {
    if (!entry.manuallyEntered || entry.type != CalendarEntryType.flight) {
      return entry;
    }
    final route = RegExp(
      r'\b([A-Z]{3,4})\s*[→–-]\s*([A-Z]{3,4})\b',
    ).firstMatch(entry.title.toUpperCase());
    final local = RegExp(
      r'^Local\s+(\d{2}):(\d{2})[–-](\d{2}):(\d{2})',
      multiLine: true,
    ).firstMatch(entry.details);
    if (route == null || local == null) return entry;
    const airportOffsets = AirportUtcOffset();
    final departureOffset = airportOffsets.offsetFor(
      route.group(1)!,
      entry.date,
    );
    final arrivalOffset = airportOffsets.offsetFor(route.group(2)!, entry.date);
    if (departureOffset == null || arrivalOffset == null) return entry;
    final departureUtc = _toUtc(
      int.parse(local.group(1)!),
      int.parse(local.group(2)!),
      departureOffset,
    );
    final arrivalUtc = _toUtc(
      int.parse(local.group(3)!),
      int.parse(local.group(4)!),
      arrivalOffset,
    );
    var details = entry.details.replaceFirst(
      RegExp(r'^UTC\s+.*$', multiLine: true),
      'UTC ${_formatMinutes(departureUtc)}Z–${_formatMinutes(arrivalUtc)}Z',
    );
    final report = RegExp(
      r'^Report\s+(\d{2}):(\d{2})\s+local\s+/.*$',
      multiLine: true,
    ).firstMatch(details);
    if (report != null) {
      final reportUtc = _toUtc(
        int.parse(report.group(1)!),
        int.parse(report.group(2)!),
        departureOffset,
      );
      details = details.replaceFirst(
        report.group(0)!,
        'Report ${report.group(1)}:${report.group(2)} local / ${_formatMinutes(reportUtc)}Z UTC',
      );
    }
    return CalendarEntry(
      date: entry.date,
      type: entry.type,
      title: entry.title,
      details: details,
      continuityId: entry.continuityId,
      utcPeriod:
          '${_formatMinutes(departureUtc)}Z–${_formatMinutes(arrivalUtc)}Z',
      showDetails: entry.showDetails,
      barLabel: entry.barLabel,
      barLabelPosition: entry.barLabelPosition,
      adjustmentId: entry.adjustmentId,
      originalEntryKey: entry.originalEntryKey,
      manuallyEntered: entry.manuallyEntered,
    );
  }

  int _toUtc(int hour, int minute, String offset) {
    final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(offset)!;
    final direction = match.group(1) == '-' ? -1 : 1;
    final offsetMinutes =
        direction *
        (int.parse(match.group(2)!) * 60 + int.parse(match.group(3)!));
    return hour * 60 + minute - offsetMinutes;
  }

  String _formatMinutes(int minutes) {
    final normalised = minutes % (24 * 60);
    return '${(normalised ~/ 60).toString().padLeft(2, '0')}:${(normalised % 60).toString().padLeft(2, '0')}';
  }

  Map<String, Object?> _entryToJson(CalendarEntry entry) => {
    'date': entry.date.toIso8601String(),
    'type': entry.type.name,
    'title': entry.title,
    'details': entry.details,
    'continuityId': entry.continuityId,
    'utcPeriod': entry.utcPeriod,
    'showDetails': entry.showDetails,
    'barLabel': entry.barLabel,
    'barLabelPosition': entry.barLabelPosition.name,
    'manuallyEntered': entry.manuallyEntered,
  };

  CalendarEntry _entryFromJson(
    Map<String, Object?> json,
    String id,
    String? originalKey,
  ) => CalendarEntry(
    date: DateTime.parse(json['date']! as String),
    type: CalendarEntryType.values.byName(json['type']! as String),
    title: json['title']! as String,
    details: json['details']! as String,
    continuityId: json['continuityId'] as String?,
    utcPeriod: json['utcPeriod'] as String?,
    showDetails: json['showDetails'] as bool? ?? true,
    barLabel: json['barLabel'] as String?,
    barLabelPosition: CalendarBarLabelPosition.values.byName(
      json['barLabelPosition'] as String? ?? 'left',
    ),
    adjustmentId: id,
    originalEntryKey: originalKey,
    manuallyEntered: json['manuallyEntered'] as bool? ?? true,
  );
}
