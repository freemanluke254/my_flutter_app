import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../roster/models/imported_roster.dart';
import '../../roster/services/ical_roster_parser.dart';
import '../../roster/services/roster_storage.dart';

class RosterUploadTab extends StatefulWidget {
  const RosterUploadTab({required this.onRosterChanged, super.key});
  final VoidCallback onRosterChanged;

  @override
  State<RosterUploadTab> createState() => _RosterUploadTabState();
}

class _RosterUploadTabState extends State<RosterUploadTab> {
  bool _importing = false;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Upload roster',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      const Text(
        'Upload a new version or a future roster. Existing roster months are retained.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 28),
      Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 62,
              color: Color(0xFF173D31),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select an iCalendar roster',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the .ics file supplied by your rostering system.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _importing ? null : _import,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(_importing ? 'Importing…' : 'Choose .ics file'),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _import() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['ics'],
      );
      if (!mounted || file == null) return;
      setState(() => _importing = true);
      final entries = const IcalRosterParser().parse(
        utf8.decode(await file.readAsBytes()),
      );
      if (entries.isEmpty) throw const FormatException('No duties found');
      final storage = RosterStorage();
      final existing = await storage.load();
      final roster = ImportedRoster(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: file.name,
        importedAt: DateTime.now(),
        entries: entries,
      );
      final updated = [
        ...existing.where((item) => item.fileName != file.name),
        roster,
      ];
      await storage.save(updated);
      if (!mounted) return;
      widget.onRosterChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.name} imported successfully.')),
      );
    } on Object catch (error) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Roster could not be imported'),
            content: SelectableText(error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }
}
