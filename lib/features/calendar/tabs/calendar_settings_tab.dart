import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/roster_view_mode.dart';

class CalendarSettingsTab extends StatefulWidget {
  const CalendarSettingsTab({required this.onSettingsChanged, super.key});
  final VoidCallback onSettingsChanged;

  @override
  State<CalendarSettingsTab> createState() => _CalendarSettingsTabState();
}

class _CalendarSettingsTabState extends State<CalendarSettingsTab> {
  static const _enabledKey = 'roster_reminder_enabled';
  static const _dayKey = 'roster_reminder_day';
  static const _hourKey = 'roster_reminder_hour';
  static const _minuteKey = 'roster_reminder_minute';
  static const _viewKey = 'roster_view_mode';

  bool _enabled = true;
  int _day = 10;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  RosterViewMode _viewMode = RosterViewMode.monthly;
  bool _loading = true;

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Calendar settings',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Choose when the app should remind you to upload your next roster.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 20),
      Card(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Default roster view',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SegmentedButton<RosterViewMode>(
                segments: RosterViewMode.values
                    .map(
                      (mode) =>
                          ButtonSegment(value: mode, label: Text(mode.label)),
                    )
                    .toList(),
                selected: {_viewMode},
                onSelectionChanged: _loading
                    ? null
                    : (selection) {
                        setState(() => _viewMode = selection.first);
                        _save();
                      },
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        elevation: 0,
        color: Colors.white,
        child: Column(
          children: [
            SwitchListTile(
              value: _enabled,
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() => _enabled = value);
                      _save();
                    },
              title: const Text(
                'Roster upload reminder',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Remind me every month'),
              secondary: const Icon(Icons.notifications_active_outlined),
            ),
            const Divider(height: 1),
            ListTile(
              enabled: _enabled && !_loading,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Day of the month'),
              subtitle: Text('Every month on day $_day'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _chooseDay,
            ),
            const Divider(height: 1),
            ListTile(
              enabled: _enabled && !_loading,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Reminder time'),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _chooseTime,
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'If a month has fewer days than your selected date, the reminder will use the final day of that month.',
        style: TextStyle(color: Color(0xFF667069), fontSize: 12, height: 1.4),
      ),
    ],
  );

  Future<void> _chooseDay() async {
    var selectedDay = _day;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Roster reminder date'),
          content: DropdownButtonFormField<int>(
            initialValue: selectedDay,
            decoration: const InputDecoration(labelText: 'Day of month'),
            items: List.generate(
              31,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text('Day ${index + 1}'),
              ),
            ),
            onChanged: (value) {
              if (value != null) setDialogState(() => selectedDay = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      setState(() => _day = selectedDay);
      await _save();
    }
  }

  Future<void> _chooseTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected == null) return;
    setState(() => _time = selected);
    await _save();
  }

  Future<void> _load() async {
    try {
      final preferences = await _preferences;
      final enabled = preferences.getBool(_enabledKey);
      final day = preferences.getInt(_dayKey);
      final hour = preferences.getInt(_hourKey);
      final minute = preferences.getInt(_minuteKey);
      final viewMode = preferences.getString(_viewKey);
      if (!mounted) return;
      setState(() {
        _enabled = enabled ?? true;
        _day = day ?? 10;
        _time = TimeOfDay(hour: hour ?? 18, minute: minute ?? 0);
        _viewMode =
            RosterViewMode.values
                .where((mode) => mode.name == viewMode)
                .firstOrNull ??
            RosterViewMode.monthly;
        _loading = false;
      });
    } on Object {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final preferences = await _preferences;
    await preferences.setBool(_enabledKey, _enabled);
    await preferences.setInt(_dayKey, _day);
    await preferences.setInt(_hourKey, _time.hour);
    await preferences.setInt(_minuteKey, _time.minute);
    await preferences.setString(_viewKey, _viewMode.name);
    widget.onSettingsChanged();
  }
}
