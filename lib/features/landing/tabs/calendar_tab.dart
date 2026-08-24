import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../calendar/models/calendar_entry.dart';
import '../../calendar/widgets/month_calendar.dart';
import '../../roster/services/ical_roster_parser.dart';

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
            onPressed: _importRoster,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Load roster'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the .ics file supplied with your roster.',
            style: TextStyle(color: Color(0xFF667069), fontSize: 11),
          ),
        ],
      ),
    ),
  );

  Widget _buildLoadedCalendar(BuildContext context) {
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
              onPressed: _importRoster,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('New roster'),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Select a day to see details. Continuous flight bars show the full period you are away from home.',
          style: TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 16),
        MonthCalendar(
          month: _visibleMonth,
          entries: _entries,
          selectedDate: _selectedDate,
          onDateSelected: _showDateDetails,
          onPreviousMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
        ),
      ],
    );
  }

  Future<void> _showDateDetails(DateTime date) async {
    setState(() => _selectedDate = date);
    final entries = _entries
        .where((entry) => _sameDay(entry.date, date) && entry.showDetails)
        .toList();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${date.day}/${date.month}/${date.year}'),
        content: SizedBox(
          width: 420,
          child: entries.isEmpty
              ? const Text('No flight or duty details for this date.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: entries
                      .map((entry) => _EntryTile(entry: entry))
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _importRoster() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['ics'],
    );
    if (!mounted || file == null) return;
    try {
      final bytes = await file.readAsBytes();
      final entries = const IcalRosterParser().parse(utf8.decode(bytes));
      if (entries.isEmpty) throw const FormatException('No duties found');
      if (!mounted) return;
      setState(() {
        _rosterLoaded = true;
        _entries = entries;
        _visibleMonth = DateTime(
          entries.first.date.year,
          entries.first.date.month,
        );
        _selectedDate = entries.first.date;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${entries.length} calendar days imported.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Roster could not be imported: $error')),
      );
    }
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
