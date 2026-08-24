import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedRosterSettings extends StatefulWidget {
  const AdvancedRosterSettings({required this.onChanged, super.key});
  final VoidCallback onChanged;

  @override
  State<AdvancedRosterSettings> createState() => _AdvancedRosterSettingsState();
}

class _AdvancedRosterSettingsState extends State<AdvancedRosterSettings> {
  bool _mondayStart = true;
  String _timeDisplay = 'both';
  bool _showDaysOff = true;
  String _flightLabel = 'both';
  String _flightColour = 'navy';
  bool _missingRosterReminder = true;
  int _releaseDay = 10;
  int _requestDeadline = 20;
  int _leadHours = 6;
  bool _autoSelectToday = true;
  bool _retainCrewNames = false;
  bool _conflictWarnings = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SettingsCard(
        title: 'Display',
        children: [
          SwitchListTile(
            title: const Text('Week starts on Monday'),
            value: _mondayStart,
            onChanged: (value) => _update(() => _mondayStart = value),
          ),
          _choice('Time display', _timeDisplay, const {
            'local': 'Local',
            'utc': 'UTC',
            'both': 'Local and UTC',
          }, (value) => _timeDisplay = value),
          SwitchListTile(
            title: const Text('Show days off'),
            value: _showDaysOff,
            onChanged: (value) => _update(() => _showDaysOff = value),
          ),
          _choice('Flight bar labels', _flightLabel, const {
            'flight': 'Flight number',
            'route': 'Route',
            'both': 'Flight and route',
          }, (value) => _flightLabel = value),
          _choice('Flight colour', _flightColour, const {
            'navy': 'Dark blue',
            'green': 'Dark green',
            'purple': 'Purple',
          }, (value) => _flightColour = value),
          SwitchListTile(
            title: const Text('Open on today'),
            subtitle: const Text('Select the current date when Calendar opens'),
            value: _autoSelectToday,
            onChanged: (value) => _update(() => _autoSelectToday = value),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _SettingsCard(
        title: 'Roster reminders',
        children: [
          SwitchListTile(
            title: const Text('Missing roster warning'),
            subtitle: const Text(
              'Warn if the expected next roster is not uploaded',
            ),
            value: _missingRosterReminder,
            onChanged: (value) => _update(() => _missingRosterReminder = value),
          ),
          _dayChoice(
            'Expected roster release day',
            _releaseDay,
            (value) => _releaseDay = value,
          ),
          _dayChoice(
            'Trip-request deadline',
            _requestDeadline,
            (value) => _requestDeadline = value,
          ),
          _choice(
            'Default reminder lead time',
            '$_leadHours',
            const {
              '1': '1 hour',
              '3': '3 hours',
              '6': '6 hours',
              '12': '12 hours',
              '24': '1 day',
            },
            (value) => _leadHours = int.parse(value),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _SettingsCard(
        title: 'Privacy and safety',
        children: [
          SwitchListTile(
            title: const Text('Retain crew names'),
            subtitle: const Text(
              'Keep crew names found in imported roster files',
            ),
            value: _retainCrewNames,
            onChanged: (value) => _update(() => _retainCrewNames = value),
          ),
          SwitchListTile(
            title: const Text('Duty conflict warnings'),
            subtitle: const Text('Highlight overlapping roster entries'),
            value: _conflictWarnings,
            onChanged: (value) => _update(() => _conflictWarnings = value),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.sync_outlined),
            title: Text('Device calendar sync'),
            subtitle: Text(
              'Available when calendar permission integration is connected',
            ),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.ios_share_outlined),
            title: Text('Export calendar'),
            subtitle: Text('Export options will be connected later'),
          ),
        ],
      ),
    ],
  );

  Widget _choice(
    String title,
    String value,
    Map<String, String> options,
    ValueChanged<String> change,
  ) => ListTile(
    title: Text(title),
    trailing: DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      items: options.entries
          .map(
            (item) =>
                DropdownMenuItem(value: item.key, child: Text(item.value)),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) _update(() => change(selected));
      },
    ),
  );

  Widget _dayChoice(String title, int value, ValueChanged<int> change) =>
      _choice(title, '$value', {
        for (var day = 1; day <= 31; day++) '$day': 'Day $day',
      }, (selected) => change(int.parse(selected)));

  Future<void> _update(VoidCallback change) async {
    setState(change);
    await _save();
    widget.onChanged();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _mondayStart = preferences.getBool('roster_week_starts_monday') ?? true;
      _timeDisplay = preferences.getString('roster_time_display') ?? 'both';
      _showDaysOff = preferences.getBool('show_roster_days_off') ?? true;
      _flightLabel = preferences.getString('roster_flight_label') ?? 'both';
      _flightColour = preferences.getString('roster_flight_colour') ?? 'navy';
      _missingRosterReminder =
          preferences.getBool('missing_roster_reminder') ?? true;
      _releaseDay = preferences.getInt('roster_release_day') ?? 10;
      _requestDeadline = preferences.getInt('trip_request_deadline') ?? 20;
      _leadHours = preferences.getInt('roster_reminder_lead_hours') ?? 6;
      _autoSelectToday =
          preferences.getBool('roster_auto_select_today') ?? true;
      _retainCrewNames =
          preferences.getBool('roster_retain_crew_names') ?? false;
      _conflictWarnings =
          preferences.getBool('roster_conflict_warnings') ?? true;
    });
  }

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('roster_week_starts_monday', _mondayStart);
    await preferences.setString('roster_time_display', _timeDisplay);
    await preferences.setBool('show_roster_days_off', _showDaysOff);
    await preferences.setString('roster_flight_label', _flightLabel);
    await preferences.setString('roster_flight_colour', _flightColour);
    await preferences.setBool(
      'missing_roster_reminder',
      _missingRosterReminder,
    );
    await preferences.setInt('roster_release_day', _releaseDay);
    await preferences.setInt('trip_request_deadline', _requestDeadline);
    await preferences.setInt('roster_reminder_lead_hours', _leadHours);
    await preferences.setBool('roster_auto_select_today', _autoSelectToday);
    await preferences.setBool('roster_retain_crew_names', _retainCrewNames);
    await preferences.setBool('roster_conflict_warnings', _conflictWarnings);
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          ...children,
        ],
      ),
    ),
  );
}
