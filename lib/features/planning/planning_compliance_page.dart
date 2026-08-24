import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class ComplianceItem {
  const ComplianceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amberDays,
    required this.redDays,
    required this.reminders,
    required this.link,
    required this.notes,
  });
  final String id, title, category, link, notes;
  final DateTime date;
  final int amberDays, redDays;
  final List<int> reminders;

  int get daysRemaining => DateUtils.dateOnly(
    date,
  ).difference(DateUtils.dateOnly(DateTime.now())).inDays;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'date': date.toIso8601String(),
    'amberDays': amberDays,
    'redDays': redDays,
    'reminders': reminders,
    'link': link,
    'notes': notes,
  };
  factory ComplianceItem.fromJson(Map<String, dynamic> value) => ComplianceItem(
    id: value['id'] as String,
    title: value['title'] as String,
    category: value['category'] as String,
    date: DateTime.parse(value['date'] as String),
    amberDays: value['amberDays'] as int? ?? 90,
    redDays: value['redDays'] as int? ?? 30,
    reminders: (value['reminders'] as List<dynamic>? ?? const [90, 30, 14])
        .cast<int>(),
    link: value['link'] as String? ?? '',
    notes: value['notes'] as String? ?? '',
  );
}

class _ItemForm extends StatefulWidget {
  const _ItemForm({
    required this.item,
    required this.title,
    required this.category,
    required this.amberAt,
    required this.redAt,
  });
  final ComplianceItem? item;
  final String? title, category;
  final int amberAt, redAt;
  @override
  State<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<_ItemForm> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.item?.title ?? widget.title ?? '',
  );
  late final TextEditingController _link = TextEditingController(
    text: widget.item?.link ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.item?.notes ?? '',
  );
  late DateTime _date =
      widget.item?.date ?? DateTime.now().add(const Duration(days: 365));
  late String _category = widget.item?.category ?? widget.category ?? 'Medical';
  late int _amber = widget.item?.amberDays ?? widget.amberAt;
  late int _red = widget.item?.redDays ?? widget.redAt;
  late final Set<int> _reminders = {
    ...?widget.item?.reminders,
    if (widget.item == null) ...[90, 30, 14],
  };
  static const categories = [
    'Medical',
    'Licence',
    'Rating',
    'Passport',
    'Visa',
    'Training',
    'Trip request',
    'Custom',
  ];

  @override
  void dispose() {
    _title.dispose();
    _link.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      0,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: Form(
      key: _key,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            widget.item == null
                ? 'Add date or deadline'
                : 'Edit date or deadline',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Class 1 medical',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a title' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 12),
          ListTile(
            onTap: _pickDate,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF777777)),
              borderRadius: BorderRadius.circular(4),
            ),
            leading: const Icon(Icons.event_outlined),
            title: const Text('Expiry or deadline'),
            subtitle: Text(_dateText(_date)),
            trailing: const Icon(Icons.edit_calendar_outlined),
          ),
          const SizedBox(height: 16),
          const Text(
            'Status colours',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '$_amber',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amber at days',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _amber = int.tryParse(value) ?? _amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: '$_red',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Red at days',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _red = int.tryParse(value) ?? _red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Remind me before',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            children: [180, 90, 30, 14, 7, 1]
                .map(
                  (days) => FilterChip(
                    label: Text('$days days'),
                    selected: _reminders.contains(days),
                    onSelected: (selected) => setState(
                      () => selected
                          ? _reminders.add(days)
                          : _reminders.remove(days),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _link,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Website or booking link',
              hintText: 'https://…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _save,
              child: Text(
                widget.item == null ? 'Add reminder' : 'Save changes',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!(_key.currentState?.validate() ?? false)) return;
    if (_red >= _amber) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Red days must be lower than amber days.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      ComplianceItem(
        id: widget.item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        category: _category,
        date: _date,
        amberDays: _amber,
        redDays: _red,
        reminders: _reminders.toList()..sort((a, b) => b.compareTo(a)),
        link: _link.text.trim(),
        notes: _notes.text.trim(),
      ),
    );
  }
}

enum _Status { green, amber, red, expired }

_Status _status(ComplianceItem item) {
  if (item.daysRemaining < 0) return _Status.expired;
  if (item.daysRemaining <= item.redDays) return _Status.red;
  if (item.daysRemaining <= item.amberDays) return _Status.amber;
  return _Status.green;
}

extension on _Status {
  Color get color => switch (this) {
    _Status.green => const Color(0xFF287A50),
    _Status.amber => const Color(0xFFC17A10),
    _Status.red => const Color(0xFFC33C36),
    _Status.expired => const Color(0xFF691F1C),
  };
  String get label => switch (this) {
    _Status.green => 'VALID',
    _Status.amber => 'PLAN RENEWAL',
    _Status.red => 'ACTION NEEDED',
    _Status.expired => 'EXPIRED',
  };
}

class _ExpiryCard extends StatelessWidget {
  const _ExpiryCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });
  final ComplianceItem item;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final state = _status(item);
    final days = item.daysRemaining;
    final countdown = days < 0
        ? '${days.abs()} days overdue'
        : days == 0
        ? 'Expires today'
        : '$days days remaining';
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 58,
                decoration: BoxDecoration(
                  color: state.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          state.label,
                          style: TextStyle(
                            color: state.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      countdown,
                      style: TextStyle(
                        color: state.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.category} · ${_dateText(item.date)}',
                      style: const TextStyle(
                        color: Color(0xFF6C756F),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    value == 'delete' ? onDelete() : onEdit(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.count,
    required this.amberAt,
    required this.redAt,
  });
  final int count, amberAt, redAt;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPLIANCE OVERVIEW',
          style: TextStyle(
            color: Color(0xFFBFD8C8),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count == 0
              ? 'Add your first important date'
              : '$count dates being monitored',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          children: [
            _Legend(color: const Color(0xFF4FC184), text: '>$amberAt days'),
            _Legend(
              color: const Color(0xFFE2B878),
              text: '${redAt + 1}–$amberAt days',
            ),
            _Legend(color: const Color(0xFFFF7B70), text: '0–$redAt days'),
          ],
        ),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    ),
  );
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF28634A)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(detail),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.event_available_outlined,
          size: 40,
          color: Color(0xFF28634A),
        ),
        const SizedBox(height: 10),
        const Text(
          'Nothing to monitor yet',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        const SizedBox(height: 6),
        const Text(
          'Add medicals, licences, ratings, passports, visas or any personal deadline.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6C756F)),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add important date'),
        ),
      ],
    ),
  );
}

String _dateText(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String _hour(int value) => '${value.toString().padLeft(2, '0')}:00';
