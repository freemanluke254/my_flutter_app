import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../calendar/models/calendar_entry.dart';
import '../../calendar/models/roster_view_mode.dart';
import '../../calendar/services/expiry_storage.dart';
import '../../calendar/services/calendar_adjustment_storage.dart';
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
  final _adjustmentStorage = CalendarAdjustmentStorage();
  List<CalendarAdjustment> _adjustments = const [];
  bool _loading = true;
  bool _rosterLoaded = false;
  DateTime _visibleMonth = DateTime(2026, 8);
  DateTime? _selectedDate;
  RosterViewMode _viewMode = RosterViewMode.monthly;
  bool _weekStartsMonday = true;
  bool _autoSelectToday = true;
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
            FilledButton.icon(
              onPressed: () =>
                  _editEntry(date: _selectedDate ?? DateTime.now()),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add entry'),
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
            weekStartsMonday: _weekStartsMonday,
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
                      .map(
                        (entry) => _EntryTile(
                          entry: entry,
                          onEdit: () {
                            Navigator.pop(context);
                            _editEntry(entry: entry);
                          },
                          onDelete: () {
                            Navigator.pop(context);
                            _deleteEntry(entry);
                          },
                        ),
                      )
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
      final adjustments = await _adjustmentStorage.load();
      final savedView = (await SharedPreferences.getInstance()).getString(
        'roster_view_mode',
      );
      final preferences = await SharedPreferences.getInstance();
      final showDaysOff = preferences.getBool('show_roster_days_off') ?? true;
      final weekStartsMonday =
          preferences.getBool('roster_week_starts_monday') ?? true;
      final autoSelectToday =
          preferences.getBool('roster_auto_select_today') ?? true;
      if (!showDaysOff) {
        rosterEntries.removeWhere(
          (entry) => entry.type == CalendarEntryType.dayOff,
        );
      }
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
      final adjustedEntries = _adjustmentStorage.apply(entries, adjustments);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _entries = adjustedEntries;
        _adjustments = adjustments;
        _viewMode =
            RosterViewMode.values
                .where((mode) => mode.name == savedView)
                .firstOrNull ??
            RosterViewMode.monthly;
        _weekStartsMonday = weekStartsMonday;
        _autoSelectToday = autoSelectToday;
        _rosterLoaded = rosters.isNotEmpty;
        if (rosters.isNotEmpty) {
          final initialDate = _autoSelectToday
              ? DateTime.now()
              : rosterEntries.last.date;
          _visibleMonth = DateTime(initialDate.year, initialDate.month);
          _selectedDate = initialDate;
        }
      });
    } on Object {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _editEntry({CalendarEntry? entry, DateTime? date}) async {
    if (entry == null) {
      await _addManualEntry(date ?? DateTime.now());
      return;
    }
    var selectedDate = entry.date;
    var selectedType = entry.type;
    final title = TextEditingController(text: entry.title);
    final details = TextEditingController(text: entry.details);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Amend calendar entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<CalendarEntryType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Duty type'),
                  items: CalendarEntryType.values
                      .where((type) => type != CalendarEntryType.expiry)
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_typeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Duty, flight number or route',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: details,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Times and details',
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final chosen = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (chosen != null) {
                      setDialogState(() => selectedDate = chosen);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isNotEmpty) Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    if (!mounted) return;
    final overlaps = _entries
        .where(
          (candidate) =>
              candidate.displaysAsBar &&
              candidate.entryKey != entry.entryKey &&
              _sameDay(candidate.date, selectedDate),
        )
        .toList();
    if (selectedType != CalendarEntryType.dayOff && overlaps.isNotEmpty) {
      final continueWithOverlap =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFBD7A17),
                size: 44,
              ),
              title: const Text('Duty overlap detected'),
              content: Text(
                'This entry overlaps ${overlaps.map((item) => item.title).join(', ')} on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}. Do you want to save it anyway?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Go back'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save anyway'),
                ),
              ],
            ),
          ) ??
          false;
      if (!continueWithOverlap) return;
    }
    final id =
        entry.adjustmentId ?? DateTime.now().microsecondsSinceEpoch.toString();
    final originalKey = entry.originalEntryKey ?? entry.entryKey;
    final amended = CalendarEntry(
      date: selectedDate,
      type: selectedType,
      title: title.text.trim(),
      details: details.text.trim().isEmpty
          ? 'Manually entered'
          : details.text.trim(),
      continuityId: entry.continuityId,
      utcPeriod: entry.utcPeriod,
      showDetails: entry.showDetails,
      barLabel:
          selectedType == CalendarEntryType.flight ||
              selectedType == CalendarEntryType.positioning
          ? '${entry.manuallyEntered ? 'M · ' : ''}${title.text.trim().split(' ').first}'
          : null,
      barLabelPosition: entry.barLabelPosition,
      adjustmentId: id,
      originalEntryKey: originalKey,
      manuallyEntered: entry.manuallyEntered,
    );
    final changes = [..._adjustments];
    final index = changes.indexWhere((change) => change.id == id);
    final change = CalendarAdjustment(
      id: id,
      originalEntryKey: originalKey,
      entry: amended,
    );
    if (index < 0) {
      changes.add(change);
    } else {
      changes[index] = change;
    }
    await _adjustmentStorage.save(changes);
    await _restoreRosters();
  }

  Future<void> _addManualEntry(DateTime initialDate) async {
    var date = initialDate;
    var type = CalendarEntryType.flight;
    var basis = 'local';
    final name = TextEditingController();
    final departure = TextEditingController();
    final arrival = TextEditingController();
    final start = TextEditingController();
    final finish = TextEditingController();
    final startOffset = TextEditingController(text: '+00:00');
    final finishOffset = TextEditingController(text: '+00:00');
    final report = TextEditingController();
    final downroute = TextEditingController();
    final notes = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final flightLike = _isFlightLike(type);
          final timed = flightLike || _requiresDutyTimes(type);
          return AlertDialog(
            title: const Text('Add calendar entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CalendarEntryType>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Duty type'),
                    items: CalendarEntryType.values
                        .where((item) => item != CalendarEntryType.expiry)
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_typeLabel(item)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => type = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: name,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: flightLike ? 'Callsign' : 'Duty name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (flightLike) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: departure,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Departure',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: arrival,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Arrival',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (timed) ...[
                    DropdownButtonFormField<String>(
                      initialValue: basis,
                      decoration: const InputDecoration(
                        labelText: 'Times entered as',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'local',
                          child: Text('Local time'),
                        ),
                        DropdownMenuItem(value: 'utc', child: Text('UTC')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => basis = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: start,
                            decoration: const InputDecoration(
                              labelText: 'Start HH:mm',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: finish,
                            decoration: const InputDecoration(
                              labelText: 'Finish HH:mm',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startOffset,
                            decoration: const InputDecoration(
                              labelText: 'Start UTC offset',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: finishOffset,
                            decoration: const InputDecoration(
                              labelText: 'Finish UTC offset',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (type == CalendarEntryType.flight) ...[
                    TextField(
                      controller: report,
                      decoration: const InputDecoration(
                        labelText: 'Report time (optional)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: downroute,
                      decoration: const InputDecoration(
                        labelText: 'Downroute rest (optional, e.g. 48H30)',
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: notes,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text('${date.day}/${date.month}/${date.year}'),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final value = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (value != null) setDialogState(() => date = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final missing = <String>[
                    if (name.text.trim().isEmpty)
                      flightLike ? 'callsign' : 'duty name',
                    if (flightLike &&
                        (departure.text.trim().isEmpty ||
                            arrival.text.trim().isEmpty))
                      'route',
                    if (timed &&
                        (start.text.trim().isEmpty ||
                            finish.text.trim().isEmpty))
                      'start and finish times',
                  ];
                  if (missing.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Required: ${missing.join(', ')}.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    if (saved != true || !mounted) return;
    final flightLike = _isFlightLike(type);
    final timed = flightLike || _requiresDutyTimes(type);
    final title = flightLike
        ? '${name.text.trim().toUpperCase()} ${departure.text.trim().toUpperCase()}–${arrival.text.trim().toUpperCase()}'
        : name.text.trim();
    final detailText = timed
        ? _timedDetails(
            basis: basis,
            start: start.text,
            finish: finish.text,
            startOffset: startOffset.text,
            finishOffset: finishOffset.text,
            report: report.text,
            downroute: downroute.text,
            notes: notes.text,
          )
        : '${notes.text.trim().isEmpty ? 'Full-day duty' : notes.text.trim()}\nMANUALLY ENTERED';
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final showsBar = switch (type) {
      CalendarEntryType.flight ||
      CalendarEntryType.positioning ||
      CalendarEntryType.standby ||
      CalendarEntryType.reserve ||
      CalendarEntryType.leave ||
      CalendarEntryType.sickness => true,
      CalendarEntryType.training ||
      CalendarEntryType.expiry ||
      CalendarEntryType.dayOff => false,
    };
    final entry = CalendarEntry(
      date: date,
      type: type,
      title: title,
      details: detailText,
      barLabel: showsBar ? 'M · ${name.text.trim().toUpperCase()}' : null,
      adjustmentId: id,
      manuallyEntered: true,
    );
    final changes = [..._adjustments, CalendarAdjustment(id: id, entry: entry)];
    await _adjustmentStorage.save(changes);
    await _restoreRosters();
  }

  bool _isFlightLike(CalendarEntryType type) =>
      type == CalendarEntryType.flight || type == CalendarEntryType.positioning;
  bool _requiresDutyTimes(CalendarEntryType type) =>
      type == CalendarEntryType.standby ||
      type == CalendarEntryType.reserve ||
      type == CalendarEntryType.training;

  String _timedDetails({
    required String basis,
    required String start,
    required String finish,
    required String startOffset,
    required String finishOffset,
    required String report,
    required String downroute,
    required String notes,
  }) {
    final startPair = _localUtcPair(start, startOffset, basis);
    final finishPair = _localUtcPair(finish, finishOffset, basis);
    final reportPair = report.trim().isEmpty
        ? null
        : _localUtcPair(report, startOffset, basis);
    return [
      'Local ${startPair.$1}–${finishPair.$1}',
      'UTC ${startPair.$2}Z–${finishPair.$2}Z',
      if (reportPair != null)
        'Report ${reportPair.$1} local / ${reportPair.$2}Z UTC',
      if (downroute.trim().isNotEmpty) 'Downroute rest ${downroute.trim()}',
      if (notes.trim().isNotEmpty) notes.trim(),
      'MANUALLY ENTERED',
    ].join('\n');
  }

  (String, String) _localUtcPair(
    String value,
    String offsetText,
    String basis,
  ) {
    final parts = value.trim().split(':');
    if (parts.length != 2) return (value.trim(), value.trim());
    final offsetMatch = RegExp(
      r'^([+-]?)(\d{1,2})(?::?(\d{2}))?$',
    ).firstMatch(offsetText.trim());
    final sign = offsetMatch?.group(1) == '-' ? -1 : 1;
    final offset =
        sign *
        ((int.tryParse(offsetMatch?.group(2) ?? '') ?? 0) * 60 +
            (int.tryParse(offsetMatch?.group(3) ?? '') ?? 0));
    final entered =
        (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    final local = basis == 'local' ? entered : entered + offset;
    final utc = basis == 'utc' ? entered : entered - offset;
    String format(int minutes) {
      final normal = minutes % 1440;
      return '${(normal ~/ 60).toString().padLeft(2, '0')}:${(normal % 60).toString().padLeft(2, '0')}';
    }

    return (format(local), format(utc));
  }

  Future<void> _deleteEntry(CalendarEntry entry) async {
    final tripEntries = entry.continuityId == null
        ? <CalendarEntry>[entry]
        : _entries
              .where(
                (candidate) => candidate.continuityId == entry.continuityId,
              )
              .toList();
    final deletionScope = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFB93B3B),
          size: 44,
        ),
        title: Text(
          entry.type == CalendarEntryType.flight
              ? 'Are you sure you want to delete this flight?'
              : 'Are you sure you want to delete this duty?',
        ),
        content: Text(
          tripEntries.length > 1
              ? '${entry.title} is part of a ${tripEntries.length}-day trip. Choose whether to delete only this sector/day or the complete trip, including downroute time and the return flight.'
              : entry.title,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (tripEntries.length > 1)
            OutlinedButton(
              onPressed: () => Navigator.pop(context, 'trip'),
              child: const Text('Delete entire trip'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'entry'),
            child: Text(
              tripEntries.length > 1 ? 'Delete this only' : 'Delete duty',
            ),
          ),
        ],
      ),
    );
    if (deletionScope == null) return;
    final changes = [..._adjustments];
    final targets = deletionScope == 'trip' ? tripEntries : [entry];
    for (final target in targets) {
      _applyDeletion(changes, target);
    }
    await _adjustmentStorage.save(changes);
    await _restoreRosters();
  }

  void _applyDeletion(List<CalendarAdjustment> changes, CalendarEntry entry) {
    if (entry.adjustmentId != null && entry.originalEntryKey == null) {
      changes.removeWhere((change) => change.id == entry.adjustmentId);
    } else {
      final id =
          entry.adjustmentId ??
          DateTime.now().microsecondsSinceEpoch.toString();
      final originalKey = entry.originalEntryKey ?? entry.entryKey;
      final index = changes.indexWhere((change) => change.id == id);
      final deletion = CalendarAdjustment(
        id: id,
        originalEntryKey: originalKey,
      );
      if (index < 0) {
        changes.add(deletion);
      } else {
        changes[index] = deletion;
      }
    }
  }

  String _typeLabel(CalendarEntryType type) => switch (type) {
    CalendarEntryType.flight => 'Flight',
    CalendarEntryType.positioning => 'Positioning sector',
    CalendarEntryType.standby => 'Home standby',
    CalendarEntryType.reserve => 'Reserve',
    CalendarEntryType.training => 'Training or check',
    CalendarEntryType.leave => 'Leave',
    CalendarEntryType.sickness => 'Sickness',
    CalendarEntryType.expiry => 'Expiry',
    CalendarEntryType.dayOff => 'Day off',
  };

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
    final offset = _weekStartsMonday ? anchor.weekday - 1 : anchor.weekday % 7;
    return anchor.subtract(Duration(days: offset));
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
  const _EntryTile({required this.entry, this.onEdit, this.onDelete});
  final CalendarEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
      trailing: onEdit == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Amend',
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
    ),
  );
}
