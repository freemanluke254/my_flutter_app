import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/calendar_entry.dart';

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
    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
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
