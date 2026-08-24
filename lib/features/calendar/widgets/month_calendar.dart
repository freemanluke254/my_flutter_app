import 'package:flutter/material.dart';

import '../models/calendar_entry.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.entries,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.weekStartsMonday = true,
  });

  final DateTime month;
  final List<CalendarEntry> entries;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool weekStartsMonday;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingSpaces = weekStartsMonday
        ? firstDay.weekday - 1
        : firstDay.weekday % 7;
    final cellCount = ((leadingSpaces + daysInMonth + 6) ~/ 7) * 7;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[month.month - 1]} ${month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children:
                (weekStartsMonday
                        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        : const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                    .map(_Weekday.new)
                    .toList(),
          ),
          const SizedBox(height: 5),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.64,
            ),
            itemCount: cellCount,
            itemBuilder: (context, index) {
              final day = index - leadingSpaces + 1;
              if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
              final date = DateTime(month.year, month.month, day);
              final dateEntries = entries
                  .where((entry) => _sameDay(entry.date, date))
                  .toList();
              return _DayCell(
                date: date,
                entries: dateEntries,
                allEntries: entries,
                selected: selectedDate != null && _sameDay(selectedDate!, date),
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF667069),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.entries,
    required this.allEntries,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final List<CalendarEntry> entries;
  final List<CalendarEntry> allEntries;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFDCEADD)
            : date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday
            ? const Color(0xFFF0F3F5)
            : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            '${date.day}',
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          ...entries
              .where((entry) => entry.displaysAsBar)
              .take(2)
              .map(_buildDutyBar),
          if (entries.any((entry) => !entry.displaysAsBar))
            Wrap(
              spacing: 3,
              children: entries
                  .where((entry) => !entry.displaysAsBar)
                  .take(3)
                  .map(
                    (entry) => Tooltip(
                      message: entry.title,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: entry.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    ),
  );

  Widget _buildDutyBar(CalendarEntry entry) {
    final previousDate = date.subtract(const Duration(days: 1));
    final nextDate = date.add(const Duration(days: 1));
    final continuesFromPrevious =
        date.weekday != DateTime.monday &&
        _hasMatchingEntry(entry, previousDate);
    final continuesToNext =
        date.weekday != DateTime.sunday && _hasMatchingEntry(entry, nextDate);
    final label =
        entry.barLabel ??
        (entry.type != CalendarEntryType.flight && !continuesFromPrevious
            ? _shortLabel(entry)
            : null);
    return Container(
      height: 22,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: switch (entry.barLabelPosition) {
        CalendarBarLabelPosition.left => Alignment.centerLeft,
        CalendarBarLabelPosition.center => Alignment.center,
        CalendarBarLabelPosition.centerBoundary => Alignment.centerLeft,
        CalendarBarLabelPosition.right => Alignment.centerRight,
      },
      decoration: BoxDecoration(
        color: entry.color,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(continuesFromPrevious ? 0 : 7),
          right: Radius.circular(continuesToNext ? 0 : 7),
        ),
      ),
      child: label == null
          ? null
          : FractionalTranslation(
              translation:
                  entry.barLabelPosition ==
                      CalendarBarLabelPosition.centerBoundary
                  ? const Offset(-0.5, 0)
                  : Offset.zero,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }

  bool _hasMatchingEntry(CalendarEntry entry, DateTime targetDate) =>
      allEntries.any(
        (candidate) =>
            candidate.continuityKey == entry.continuityKey &&
            candidate.date.year == targetDate.year &&
            candidate.date.month == targetDate.month &&
            candidate.date.day == targetDate.day,
      );

  String _shortLabel(CalendarEntry entry) {
    if (entry.type == CalendarEntryType.flight) {
      final flightNumber = entry.title.split(' ').first;
      return entry.utcPeriod == null
          ? flightNumber
          : '$flightNumber ${entry.utcPeriod!.split('–').first}';
    }
    return entry.title.split(' ·').first;
  }
}
