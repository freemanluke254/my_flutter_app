import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _commuteStorageKey = 'commute_settings_v1';

class CommuteSettings {
  const CommuteSettings({
    required this.enabled,
    required this.homeAddress,
    required this.workAddress,
    required this.mode,
    required this.arrivalBufferMinutes,
    required this.reminderLeadMinutes,
    required this.fallbackTravelMinutes,
  });

  final bool enabled;
  final String homeAddress;
  final String workAddress;
  final String mode;
  final int arrivalBufferMinutes;
  final int reminderLeadMinutes;
  final int fallbackTravelMinutes;

  static const defaults = CommuteSettings(
    enabled: false,
    homeAddress: '',
    workAddress: '',
    mode: 'Driving',
    arrivalBufferMinutes: 60,
    reminderLeadMinutes: 30,
    fallbackTravelMinutes: 160,
  );

  DateTime leaveTime(DateTime signOn, {int? liveTravelMinutes}) =>
      signOn.subtract(
        Duration(
          minutes:
              arrivalBufferMinutes +
              (liveTravelMinutes ?? fallbackTravelMinutes),
        ),
      );

  DateTime reminderTime(DateTime signOn, {int? liveTravelMinutes}) => leaveTime(
    signOn,
    liveTravelMinutes: liveTravelMinutes,
  ).subtract(Duration(minutes: reminderLeadMinutes));

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'homeAddress': homeAddress,
    'workAddress': workAddress,
    'mode': mode,
    'arrivalBufferMinutes': arrivalBufferMinutes,
    'reminderLeadMinutes': reminderLeadMinutes,
    'fallbackTravelMinutes': fallbackTravelMinutes,
  };

  factory CommuteSettings.fromJson(Map<String, dynamic> json) =>
      CommuteSettings(
        enabled: json['enabled'] as bool? ?? false,
        homeAddress: json['homeAddress'] as String? ?? '',
        workAddress: json['workAddress'] as String? ?? '',
        mode: json['mode'] as String? ?? 'Driving',
        arrivalBufferMinutes: json['arrivalBufferMinutes'] as int? ?? 60,
        reminderLeadMinutes: json['reminderLeadMinutes'] as int? ?? 30,
        fallbackTravelMinutes: json['fallbackTravelMinutes'] as int? ?? 160,
      );
}

class CommuteSettingsStore {
  static Future<CommuteSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_commuteStorageKey);
    if (encoded == null) return CommuteSettings.defaults;
    return CommuteSettings.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  static Future<void> save(CommuteSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _commuteStorageKey,
      jsonEncode(settings.toJson()),
    );
  }
}

class CommuteReminderPage extends StatefulWidget {
  const CommuteReminderPage({super.key});

  @override
  State<CommuteReminderPage> createState() => _CommuteReminderPageState();
}

class _CommuteReminderPageState extends State<CommuteReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _home = TextEditingController();
  final _work = TextEditingController();
  bool _loading = true;
  bool _enabled = false;
  String _mode = 'Driving';
  int _arrivalBuffer = 60;
  int _reminderLead = 30;
  int _fallbackTravel = 160;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _home.dispose();
    _work.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exampleSignOn = DateTime(2026, 8, 24, 10);
    final settings = _currentSettings;
    return Scaffold(
      appBar: AppBar(title: const Text('Commute assistant')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    tileColor: const Color(0xFFFBFAF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    value: _enabled,
                    onChanged: (value) => setState(() => _enabled = value),
                    secondary: const Icon(
                      Icons.commute_rounded,
                      color: Color(0xFF28634A),
                    ),
                    title: const Text(
                      'Commute reminders',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      _enabled
                          ? 'Enabled for rostered duties'
                          : 'Off — no commute alerts will be scheduled',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Locations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _home,
                    enabled: _enabled,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Home address',
                      prefixIcon: Icon(Icons.home_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _enabled && (value == null || value.trim().isEmpty)
                        ? 'Enter your home address'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _work,
                    enabled: _enabled,
                    decoration: const InputDecoration(
                      labelText: 'Work or report location',
                      prefixIcon: Icon(Icons.work_outline_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _enabled && (value == null || value.trim().isEmpty)
                        ? 'Enter your work address'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _mode,
                    decoration: const InputDecoration(
                      labelText: 'Usual travel mode',
                      prefixIcon: Icon(Icons.directions_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        const [
                              'Driving',
                              'Public transport',
                              'Train',
                              'Walking',
                              'Cycling',
                              'Other',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: _enabled
                        ? (value) => setState(() => _mode = value!)
                        : null,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Timing preferences',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MinuteSelector(
                    title: 'Arrive before sign-on',
                    subtitle: 'Extra time at work before your duty begins',
                    value: _arrivalBuffer,
                    options: const [0, 15, 30, 45, 60, 90],
                    enabled: _enabled,
                    onChanged: (value) =>
                        setState(() => _arrivalBuffer = value),
                  ),
                  _MinuteSelector(
                    title: 'Alert before leave time',
                    subtitle: 'Time to finish getting ready before departure',
                    value: _reminderLead,
                    options: const [0, 15, 30, 45, 60],
                    enabled: _enabled,
                    onChanged: (value) => setState(() => _reminderLead = value),
                  ),
                  _DurationSelector(
                    value: _fallbackTravel,
                    enabled: _enabled,
                    onChanged: (value) =>
                        setState(() => _fallbackTravel = value),
                  ),
                  const SizedBox(height: 18),
                  _CommutePreview(signOn: exampleSignOn, settings: settings),
                  const SizedBox(height: 12),
                  const _ProviderNote(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save commute settings'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  CommuteSettings get _currentSettings => CommuteSettings(
    enabled: _enabled,
    homeAddress: _home.text.trim(),
    workAddress: _work.text.trim(),
    mode: _mode,
    arrivalBufferMinutes: _arrivalBuffer,
    reminderLeadMinutes: _reminderLead,
    fallbackTravelMinutes: _fallbackTravel,
  );

  Future<void> _load() async {
    final settings = await CommuteSettingsStore.load();
    if (!mounted) return;
    setState(() {
      _enabled = settings.enabled;
      _home.text = settings.homeAddress;
      _work.text = settings.workAddress;
      _mode = settings.mode;
      _arrivalBuffer = settings.arrivalBufferMinutes;
      _reminderLead = settings.reminderLeadMinutes;
      _fallbackTravel = settings.fallbackTravelMinutes;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await CommuteSettingsStore.save(_currentSettings);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _enabled
              ? 'Commute reminder settings saved.'
              : 'Commute reminders turned off.',
        ),
      ),
    );
  }
}

class CommuteTodayCard extends StatefulWidget {
  const CommuteTodayCard({super.key, required this.signOn});
  final DateTime signOn;

  @override
  State<CommuteTodayCard> createState() => _CommuteTodayCardState();
}

class _CommuteTodayCardState extends State<CommuteTodayCard> {
  CommuteSettings? _settings;

  @override
  void initState() {
    super.initState();
    CommuteSettingsStore.load().then((value) {
      if (mounted) setState(() => _settings = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null || !settings.enabled) return const SizedBox.shrink();
    final leave = settings.leaveTime(widget.signOn);
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFECE1CD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car_outlined, color: Color(0xFF79562E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave by ${_time(leave)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_duration(settings.fallbackTravelMinutes)} estimated · arrive ${settings.arrivalBufferMinutes} min before report',
                  style: const TextStyle(
                    color: Color(0xFF6F5A40),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'ESTIMATE',
            style: TextStyle(
              color: Color(0xFF79562E),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MinuteSelector extends StatelessWidget {
  const _MinuteSelector({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });
  final String title, subtitle;
  final int value;
  final List<int> options;
  final bool enabled;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: options
                .map(
                  (minutes) => ChoiceChip(
                    label: Text('$minutes min'),
                    selected: value == minutes,
                    onSelected: enabled ? (_) => onChanged(minutes) : null,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final hours = value ~/ 60;
    final minutes = value.remainder(60);
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fallback journey time',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            const Text(
              'Used when live routing is unavailable',
              style: TextStyle(color: Color(0xFF6C756F), fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: hours,
                    decoration: const InputDecoration(labelText: 'Hours'),
                    items: List.generate(
                      7,
                      (index) =>
                          DropdownMenuItem(value: index, child: Text('$index')),
                    ),
                    onChanged: enabled
                        ? (hours) => onChanged((hours! * 60) + minutes)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: minutes,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    items: [0, 10, 15, 20, 30, 40, 45, 50]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value'),
                          ),
                        )
                        .toList(),
                    onChanged: enabled
                        ? (minutes) => onChanged((hours * 60) + minutes!)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommutePreview extends StatelessWidget {
  const _CommutePreview({required this.signOn, required this.settings});
  final DateTime signOn;
  final CommuteSettings settings;
  @override
  Widget build(BuildContext context) {
    final leave = settings.leaveTime(signOn);
    final reminder = settings.reminderTime(signOn);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF173D31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXAMPLE · 10:00 SIGN-ON',
            style: TextStyle(
              color: Color(0xFFBFD8C8),
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Leave at ${_time(leave)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reminder at ${_time(reminder)} · arrive at ${_time(signOn.subtract(Duration(minutes: settings.arrivalBufferMinutes)))}',
            style: const TextStyle(color: Color(0xFFE2ECE5)),
          ),
          const SizedBox(height: 5),
          Text(
            '${_duration(settings.fallbackTravelMinutes)} travel + ${settings.arrivalBufferMinutes} min arrival buffer',
            style: const TextStyle(color: Color(0xFFBFD8C8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProviderNote extends StatelessWidget {
  const _ProviderNote();
  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF6C756F)),
      SizedBox(width: 7),
      Expanded(
        child: Text(
          'Live traffic and transit times require a routing provider. Until one is connected, reminders use your fallback journey time and are labelled as estimates.',
          style: TextStyle(color: Color(0xFF6C756F), fontSize: 11, height: 1.4),
        ),
      ),
    ],
  );
}

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _duration(int minutes) =>
    '${minutes ~/ 60}h ${minutes.remainder(60).toString().padLeft(2, '0')}m';
