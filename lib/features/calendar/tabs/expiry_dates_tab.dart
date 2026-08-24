import 'package:flutter/material.dart';

import '../models/expiry_record.dart';
import '../services/expiry_storage.dart';

class ExpiryDatesTab extends StatefulWidget {
  const ExpiryDatesTab({required this.onExpiryChanged, super.key});
  final VoidCallback onExpiryChanged;

  @override
  State<ExpiryDatesTab> createState() => _ExpiryDatesTabState();
}

class _ExpiryDatesTabState extends State<ExpiryDatesTab> {
  final _storage = ExpiryStorage();
  List<ExpiryRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Expiry dates',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          FilledButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
          ),
        ],
      ),
      const SizedBox(height: 6),
      const Text(
        'Certificates and documents added here also appear on the main calendar.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 18),
      if (_records.isEmpty)
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No expiry dates added yet.'),
          ),
        )
      else
        ..._records.map(
          (record) => Card(
            elevation: 0,
            color: Colors.white,
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.verified_user_outlined),
              ),
              title: Text(
                record.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${record.date.day}/${record.date.month}/${record.date.year}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Delete',
                onPressed: () => _delete(record),
              ),
            ),
          ),
        ),
    ],
  );

  Future<void> _load() async {
    try {
      final records = await _storage.load();
      records.sort((a, b) => a.date.compareTo(b.date));
      if (mounted) setState(() => _records = records);
    } on Object {
      /* Native storage is unavailable in widget tests. */
    }
  }

  Future<void> _add() async {
    final controller = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 365));
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add expiry date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Certificate or document',
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expiry date'),
                subtitle: Text('${date.day}/${date.month}/${date.year}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 3650),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 7300)),
                  );
                  if (selected != null) setDialogState(() => date = selected);
                },
              ),
            ],
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
    if (saved != true || controller.text.trim().isEmpty) return;
    final records = [
      ..._records,
      ExpiryRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: controller.text.trim(),
        date: date,
      ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    await _storage.save(records);
    if (!mounted) return;
    setState(() => _records = records);
    widget.onExpiryChanged();
  }

  Future<void> _delete(ExpiryRecord record) async {
    final records = _records.where((item) => item.id != record.id).toList();
    await _storage.save(records);
    if (!mounted) return;
    setState(() => _records = records);
    widget.onExpiryChanged();
  }
}
