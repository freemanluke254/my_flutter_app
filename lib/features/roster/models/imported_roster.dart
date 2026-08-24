import '../../calendar/models/calendar_entry.dart';

class ImportedRoster {
  const ImportedRoster({
    required this.id,
    required this.fileName,
    required this.importedAt,
    required this.entries,
  });

  final String id;
  final String fileName;
  final DateTime importedAt;
  final List<CalendarEntry> entries;

  Map<String, Object?> toJson() => {
    'id': id,
    'fileName': fileName,
    'importedAt': importedAt.toIso8601String(),
    'entries': entries.map(_entryToJson).toList(),
  };

  factory ImportedRoster.fromJson(Map<String, Object?> json) => ImportedRoster(
    id: json['id']! as String,
    fileName: json['fileName']! as String,
    importedAt: DateTime.parse(json['importedAt']! as String),
    entries: (json['entries']! as List<Object?>)
        .map((value) => _entryFromJson(value! as Map<String, Object?>))
        .toList(),
  );

  static Map<String, Object?> _entryToJson(CalendarEntry entry) => {
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

  static CalendarEntry _entryFromJson(Map<String, Object?> json) =>
      CalendarEntry(
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
        manuallyEntered: json['manuallyEntered'] as bool? ?? false,
      );
}
