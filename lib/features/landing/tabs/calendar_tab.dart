import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../calendar/models/calendar_entry.dart';
import '../../calendar/models/roster_view_mode.dart';
import '../../calendar/services/expiry_storage.dart';
import '../../calendar/widgets/month_calendar.dart';
import '../../calendar/widgets/period_calendar.dart';
import '../../roster/services/roster_storage.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({
    required this.refreshVersion,
    required this.onUploadRequested,
    super.key,
  });
  final int refreshVersion;
  final VoidCallback onUploadRequested;

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final _storage = RosterStorage();
  final _expiryStorage = ExpiryStorage();
  bool _loading = true;
  bool _rosterLoaded = false;
  DateTime _visibleMonth = DateTime(2026, 8);
  DateTime? _selectedDate;
  RosterViewMode _viewMode = RosterViewMode.monthly;
  List<CalendarEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _restoreRosters();
  }

  @override
  void didUpdateWidget(covariant CalendarTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) _restoreRosters();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const Center(child: CircularProgressIndicator())
      : _rosterLoaded
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
            onPressed: widget.onUploadRequested,
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
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Select a day to see details. Continuous flight bars show the full period you are away from home.',
          style: TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 16),
        if (_viewMode == RosterViewMode.monthly)
          MonthCalendar(
            month: _visibleMonth,
            entries: _entries,
            selectedDate: _selectedDate,
            onDateSelected: _showDateDetails,
            onPreviousMonth: () => _changeMonth(-1),
            onNextMonth: () => _changeMonth(1),
          )
        else
          PeriodCalendar(
            startDate: _periodStart,
            numberOfDays: _viewMode == RosterViewMode.weekly ? 7 : 14,
            entries: _entries,
            onDateSelected: _showDateDetails,
            onPreviousPeriod: () => _changePeriod(-1),
            onNextPeriod: () => _changePeriod(1),
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

  Future<void> _restoreRosters() async {
    try {
      final rosters = await _storage.load();
      final rosterEntries = rosters.expand((roster) => roster.entries).toList()
        ..sort((first, second) => first.date.compareTo(second.date));
      final entries = [...rosterEntries];
      final expiries = await _expiryStorage.load();
      final savedView = await SharedPreferencesAsync().getString(
        'roster_view_mode',
      );
      entries.addAll(
        expiries.map(
          (record) => CalendarEntry(
            date: record.date,
            type: CalendarEntryType.expiry,
            title: '${record.title} expires',
            details:
                'Expiry date: ${record.date.day}/${record.date.month}/${record.date.year}',
          ),
        ),
      );
      entries.sort((first, second) => first.date.compareTo(second.date));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _entries = entries;
        _viewMode =
            RosterViewMode.values
                .where((mode) => mode.name == savedView)
                .firstOrNull ??
            RosterViewMode.monthly;
        _rosterLoaded = rosters.isNotEmpty;
        if (rosters.isNotEmpty) {
          _visibleMonth = DateTime(
            rosterEntries.last.date.year,
            rosterEntries.last.date.month,
          );
          _selectedDate = rosterEntries.last.date;
        }
      });
    } on Object {
      if (!mounted) return;
      setState(() => _loading = false);
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

  DateTime get _periodStart {
    final anchor = _selectedDate ?? _visibleMonth;
    return anchor.subtract(Duration(days: anchor.weekday - 1));
  }

  void _changePeriod(int direction) {
    final days = _viewMode == RosterViewMode.weekly ? 7 : 14;
    final next = _periodStart.add(Duration(days: days * direction));
    setState(() {
      _selectedDate = next;
      _visibleMonth = DateTime(next.year, next.month);
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
