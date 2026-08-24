import 'package:flutter/material.dart';

import '../../roster/models/imported_roster.dart';
import '../../roster/services/roster_storage.dart';

class RosterHistoryTab extends StatefulWidget {
  const RosterHistoryTab({
    required this.refreshVersion,
    required this.onRosterChanged,
    super.key,
  });
  final int refreshVersion;
  final VoidCallback onRosterChanged;

  @override
  State<RosterHistoryTab> createState() => _RosterHistoryTabState();
}

class _RosterHistoryTabState extends State<RosterHistoryTab> {
  final _storage = RosterStorage();
  List<ImportedRoster> _rosters = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RosterHistoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) _load();
  }

  @override
  Widget build(BuildContext context) {
    final activeId = _rosters.isEmpty
        ? null
        : (_rosters.toList()
                ..sort((a, b) => b.importedAt.compareTo(a.importedAt)))
              .first
              .id;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Roster history',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Review uploaded rosters or remove ones you no longer need.',
          style: TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 18),
        if (_rosters.isEmpty)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No roster history yet.'),
            ),
          ),
        ..._rosters.reversed.map(
          (roster) => Card(
            elevation: 0,
            color: Colors.white,
            child: ListTile(
              leading: const Icon(
                Icons.event_note_outlined,
                color: Color(0xFF173D31),
              ),
              title: Text(
                roster.fileName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${roster.entries.length} calendar days · imported ${roster.importedAt.day}/${roster.importedAt.month}/${roster.importedAt.year}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (roster.id == activeId) const Chip(label: Text('Active')),
                  IconButton(
                    onPressed: () => _delete(roster),
                    tooltip: 'Delete roster',
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _load() async {
    try {
      final rosters = await _storage.load();
      if (mounted) setState(() => _rosters = rosters);
    } on Object {
      /* Tests have no native store. */
    }
  }

  Future<void> _delete(ImportedRoster roster) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete roster?'),
            content: Text(roster.fileName),
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
        ) ??
        false;
    if (!confirmed) return;
    await _storage.delete(roster.id);
    await _load();
    widget.onRosterChanged();
  }
}
