class ExpiryRecord {
  const ExpiryRecord({
    required this.id,
    required this.title,
    required this.date,
  });
  final String id;
  final String title;
  final DateTime date;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
  };

  factory ExpiryRecord.fromJson(Map<String, Object?> json) => ExpiryRecord(
    id: json['id']! as String,
    title: json['title']! as String,
    date: DateTime.parse(json['date']! as String),
  );
}
