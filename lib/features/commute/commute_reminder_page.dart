import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'models/commute_settings.dart';
part 'widgets/commute_today_card.dart';
part 'widgets/commute_widgets.dart';

const _commuteStorageKey = 'commute_settings_v1';

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
