import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'forms/compliance_item_form.dart';
part 'models/compliance_item.dart';
part 'widgets/compliance_widgets.dart';

class PlanningCompliancePage extends StatefulWidget {
  const PlanningCompliancePage({super.key});
  @override
  State<PlanningCompliancePage> createState() => _PlanningCompliancePageState();
}

class _PlanningCompliancePageState extends State<PlanningCompliancePage> {
  static const _itemsKey = 'compliance_items_v1';
  SharedPreferences? _prefs;
  final List<ComplianceItem> _items = [];
  bool _loading = true;
  int _amberAt = 90;
  int _redAt = 30;
  int _rosterDay = 10;
  int _rosterHour = 19;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._items]..sort((a, b) => a.date.compareTo(b.date));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning & compliance'),
        actions: [
          IconButton(
            onPressed: _editDefaults,
            tooltip: 'Colour settings',
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editItem(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add item'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              children: [
                _Overview(
                  count: sorted.length,
                  amberAt: _amberAt,
                  redAt: _redAt,
                ),
                const SizedBox(height: 22),
                _heading(context, 'Monthly routine'),
                const SizedBox(height: 10),
                _RoutineTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'Roster upload',
                  detail:
                      'Expected on day $_rosterDay · remind at ${_hour(_rosterHour)} if not uploaded',
                  onTap: _editRosterRule,
                ),
                _RoutineTile(
                  icon: Icons.how_to_vote_outlined,
                  title: 'Trip requests',
                  detail: 'Add the deadline, reminders and request website',
                  onTap: () => _editItem(
                    title: 'Trip request deadline',
                    category: 'Trip request',
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: _heading(context, 'Dates & deadlines')),
                    Text(
                      '${sorted.length} items',
                      style: const TextStyle(color: Color(0xFF6C756F)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (sorted.isEmpty)
                  _EmptyState(onAdd: () => _editItem())
                else
                  ...sorted.map(
                    (item) => _ExpiryCard(
                      item: item,
                      onEdit: () => _editItem(item: item),
                      onDelete: () => _delete(item),
                    ),
                  ),
                const SizedBox(height: 14),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: Color(0xFF6C756F),
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Saved locally for this pilot build. Original licences and certificates remain the authoritative records.',
                        style: TextStyle(
                          color: Color(0xFF6C756F),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _heading(BuildContext context, String text) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
  );

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _prefs = preferences;
    final values = await Future.wait([
      Future.value(preferences.getString(_itemsKey)),
      Future.value(preferences.getInt('compliance_amber_at')),
      Future.value(preferences.getInt('compliance_red_at')),
      Future.value(preferences.getInt('roster_release_day')),
      Future.value(preferences.getInt('roster_reminder_hour')),
    ]);
    if (!mounted) return;
    setState(() {
      final encoded = values[0] as String?;
      if (encoded != null) {
        _items.addAll(
          (jsonDecode(encoded) as List<dynamic>).map(
            (value) => ComplianceItem.fromJson(value as Map<String, dynamic>),
          ),
        );
      }
      _amberAt = values[1] as int? ?? 90;
      _redAt = values[2] as int? ?? 30;
      _rosterDay = values[3] as int? ?? 10;
      _rosterHour = values[4] as int? ?? 19;
      _loading = false;
    });
  }

  Future<void> _persistItems() async {
    await _prefs!.setString(
      _itemsKey,
      jsonEncode(_items.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _editItem({
    ComplianceItem? item,
    String? title,
    String? category,
  }) async {
    final result = await showModalBottomSheet<ComplianceItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ItemForm(
        item: item,
        title: title,
        category: category,
        amberAt: _amberAt,
        redAt: _redAt,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      final index = _items.indexWhere((current) => current.id == result.id);
      index < 0 ? _items.add(result) : _items[index] = result;
    });
    await _persistItems();
  }

  Future<void> _delete(ComplianceItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('Remove “${item.title}” and its saved date?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _items.removeWhere((current) => current.id == item.id));
    await _persistItems();
  }

  Future<void> _editDefaults() async {
    var amber = _amberAt;
    var red = _redAt;
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, update) => AlertDialog(
          title: const Text('Default colour thresholds'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New items inherit these settings. You can override them per item.',
              ),
              const SizedBox(height: 18),
              Text('Amber at $amber days'),
              Slider(
                value: amber.toDouble(),
                min: 31,
                max: 365,
                divisions: 334,
                onChanged: (value) => update(() => amber = value.round()),
              ),
              Text('Red at $red days'),
              Slider(
                value: red.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                onChanged: (value) => update(() => red = value.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (save != true || !mounted) return;
    setState(() {
      _amberAt = amber;
      _redAt = red;
    });
    await Future.wait([
      _prefs!.setInt('compliance_amber_at', amber),
      _prefs!.setInt('compliance_red_at', red),
    ]);
  }

  Future<void> _editRosterRule() async {
    var day = _rosterDay;
    var hour = _rosterHour;
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, update) => AlertDialog(
          title: const Text('Roster reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: day,
                decoration: const InputDecoration(
                  labelText: 'Roster release day',
                ),
                items: List.generate(28, (i) => i + 1)
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('Day $value'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => update(() => day = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: hour,
                decoration: const InputDecoration(labelText: 'Reminder time'),
                items: List.generate(24, (i) => i)
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(_hour(value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => update(() => hour = value!),
              ),
              const SizedBox(height: 12),
              const Text(
                'The reminder clears only after next month’s roster is successfully imported.',
                style: TextStyle(color: Color(0xFF6C756F), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (save != true || !mounted) return;
    setState(() {
      _rosterDay = day;
      _rosterHour = hour;
    });
    await Future.wait([
      _prefs!.setInt('roster_release_day', day),
      _prefs!.setInt('roster_reminder_hour', hour),
    ]);
  }
}
