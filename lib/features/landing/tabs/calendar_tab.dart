import 'package:flutter/material.dart';

import '../../calendar/models/calendar_entry.dart';
import '../../calendar/widgets/month_calendar.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  bool _rosterLoaded = false;
  DateTime _visibleMonth = DateTime(2026, 8);
  DateTime? _selectedDate;
  List<CalendarEntry> _entries = const [];

  @override
  Widget build(BuildContext context) => _rosterLoaded
      ? _buildLoadedCalendar(context)
      : _buildEmptyCalendar(context);

  Widget _buildEmptyCalendar(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Color(0xFFDCEADD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 44,
              color: Color(0xFF173D31),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'No roster loaded',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Load your roster to create the monthly calendar. Duties and expiry dates will then appear on the relevant days.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF667069), height: 1.4),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _loadSampleRoster,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Load roster'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sample data is used until file import is connected.',
            style: TextStyle(color: Color(0xFF667069), fontSize: 11),
          ),
        ],
      ),
    ),
  );

  Widget _buildLoadedCalendar(BuildContext context) {
    final selectedEntries = _selectedDate == null
        ? const <CalendarEntry>[]
        : _entries
              .where((entry) => _sameDay(entry.date, _selectedDate!))
              .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Calendar',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _loadSampleRoster,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('New roster'),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Select a day to see duties and expiry dates.',
          style: TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 16),
        MonthCalendar(
          month: _visibleMonth,
          entries: _entries,
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
          onPreviousMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
        ),
        const SizedBox(height: 18),
        Text(
          _selectedDate == null
              ? 'Select a date'
              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (_selectedDate == null)
          const _DayMessage('Tap a date in the calendar to view its details.')
        else if (selectedEntries.isEmpty)
          const _DayMessage('No duty or expiry recorded on this day.')
        else
          ...selectedEntries.map((entry) => _EntryTile(entry: entry)),
      ],
    );
  }

  void _loadSampleRoster() {
    setState(() {
      _rosterLoaded = true;
      _visibleMonth = DateTime(2026, 8);
      _selectedDate = DateTime(2026, 8, 24);
      _entries = [
        CalendarEntry(
          date: DateTime(2026, 8, 24),
          type: CalendarEntryType.flight,
          title: 'BA275 · LHR–LAS',
          details: 'Report 14:20 · Departure 16:05 · B787-9',
        ),
        CalendarEntry(
          date: DateTime(2026, 8, 26),
          type: CalendarEntryType.standby,
          title: 'Home standby',
          details: '06:00–14:00',
        ),
        CalendarEntry(
          date: DateTime(2026, 8, 30),
          type: CalendarEntryType.expiry,
          title: 'Class 1 medical expires',
          details: 'Renewal required before further flying.',
        ),
      ];
    });
  }

  void _changeMonth(int difference) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + difference,
      );
      _selectedDate = null;
    });
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});
  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: entry.color.withValues(alpha: 0.13),
        foregroundColor: entry.color,
        child: Icon(entry.icon),
      ),
      title: Text(
        entry.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(entry.details),
    ),
  );
}

class _DayMessage extends StatelessWidget {
  const _DayMessage(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(message, style: const TextStyle(color: Color(0xFF667069))),
  );
}
