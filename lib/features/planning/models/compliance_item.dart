part of '../planning_compliance_page.dart';

class ComplianceItem {
  const ComplianceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amberDays,
    required this.redDays,
    required this.reminders,
    required this.link,
    required this.notes,
  });
  final String id, title, category, link, notes;
  final DateTime date;
  final int amberDays, redDays;
  final List<int> reminders;

  int get daysRemaining => DateUtils.dateOnly(
    date,
  ).difference(DateUtils.dateOnly(DateTime.now())).inDays;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'date': date.toIso8601String(),
    'amberDays': amberDays,
    'redDays': redDays,
    'reminders': reminders,
    'link': link,
    'notes': notes,
  };
  factory ComplianceItem.fromJson(Map<String, dynamic> value) => ComplianceItem(
    id: value['id'] as String,
    title: value['title'] as String,
    category: value['category'] as String,
    date: DateTime.parse(value['date'] as String),
    amberDays: value['amberDays'] as int? ?? 90,
    redDays: value['redDays'] as int? ?? 30,
    reminders: (value['reminders'] as List<dynamic>? ?? const [90, 30, 14])
        .cast<int>(),
    link: value['link'] as String? ?? '',
    notes: value['notes'] as String? ?? '',
  );
}
