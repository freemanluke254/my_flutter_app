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
  });

  final DateTime month;
  final List<CalendarEntry> entries;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

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
    final leadingSpaces = firstDay.weekday - 1;
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
          const Row(
            children: [
              _Weekday('M'),
              _Weekday('T'),
              _Weekday('W'),
              _Weekday('T'),
              _Weekday('F'),
              _Weekday('S'),
              _Weekday('S'),
            ],
          ),
          const SizedBox(height: 5),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.82,
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
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final List<CalendarEntry> entries;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFDCEADD) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 2,
            children: entries
                .take(3)
                .map(
                  (entry) => Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: entry.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}
