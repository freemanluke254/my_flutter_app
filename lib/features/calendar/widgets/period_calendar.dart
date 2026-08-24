import 'package:flutter/material.dart';

import '../models/calendar_entry.dart';

class PeriodCalendar extends StatelessWidget {
  const PeriodCalendar({
    required this.startDate,
    required this.numberOfDays,
    required this.entries,
    required this.onDateSelected,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    super.key,
  });

  final DateTime startDate;
  final int numberOfDays;
  final List<CalendarEntry> entries;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final endDate = startDate.add(Duration(days: numberOfDays - 1));
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPreviousPeriod,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '${startDate.day}/${startDate.month} – ${endDate.day}/${endDate.month}/${endDate.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: onNextPeriod,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(numberOfDays, (index) {
          final date = startDate.add(Duration(days: index));
          final dayEntries = entries
              .where((entry) => _sameDay(entry.date, date))
              .toList();
          final weekend =
              date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday;
          return InkWell(
            onTap: () => onDateSelected(date),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minHeight: 58),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: weekend ? const Color(0xFFF0F3F5) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 66,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weekdays[date.weekday - 1],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF667069),
                          ),
                        ),
                        Text(
                          '${date.day}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: dayEntries.isEmpty
                        ? const Text(
                            'No duty',
                            style: TextStyle(color: Color(0xFF8A918D)),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            children: dayEntries
                                .take(3)
                                .map(
                                  (entry) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: entry.color,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      entry.barLabel ?? entry.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
