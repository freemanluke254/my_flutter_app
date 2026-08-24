import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

part 'features/logbook/forms/flight_entry_form.dart';
part 'features/logbook/forms/pilot_details_dialog.dart';
part 'features/logbook/models/flight_entry.dart';
part 'features/logbook/services/logbook_actions.dart';
part 'features/logbook/widgets/logbook_widgets.dart';

class FlightLogbookPage extends StatefulWidget {
  const FlightLogbookPage({super.key, this.initialEntries = const []});

  final List<FlightEntry> initialEntries;

  @override
  State<FlightLogbookPage> createState() => _FlightLogbookPageState();
}

class _FlightLogbookPageState extends State<FlightLogbookPage> {
  late final List<FlightEntry> _entries = [...widget.initialEntries];
  String _search = '';

  @override
  void didUpdateWidget(covariant FlightLogbookPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final entry in widget.initialEntries) {
      if (_entries.every((existing) => existing.source != entry.source)) {
        _entries.add(entry);
      }
    }
    _entries.sort((a, b) => a.date.compareTo(b.date));
  }

  Iterable<FlightEntry> get _visibleEntries {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return _entries.reversed;
    return _entries.reversed.where(
      (entry) =>
          entry.registration.toLowerCase().contains(query) ||
          entry.aircraftType.toLowerCase().contains(query) ||
          entry.departurePlace.toLowerCase().contains(query) ||
          entry.arrivalPlace.toLowerCase().contains(query),
    );
  }

  Duration get _totalTime =>
      _entries.fold(Duration.zero, (total, entry) => total + entry.totalTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList.list(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UK PART-FCL · FCL.050',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: const Color(0xFF6C756F),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.3,
                                ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Flight logbook',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Logbook actions',
                      onSelected: (value) {
                        if (value == 'import') _importCsv();
                        if (value == 'print') _printLogbook();
                        if (value == 'template') _showImportGuide();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'import',
                          child: ListTile(
                            leading: Icon(Icons.upload_file_rounded),
                            title: Text('Import CSV'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'template',
                          child: ListTile(
                            leading: Icon(Icons.table_view_outlined),
                            title: Text('CSV format'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'print',
                          child: ListTile(
                            leading: Icon(Icons.print_outlined),
                            title: Text('Print / PDF'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _ComplianceBanner(onTap: _showComplianceNotes),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'TOTAL TIME',
                        value: _formatDuration(_totalTime),
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        label: 'FLIGHTS',
                        value: '${_entries.length}',
                        icon: Icons.flight_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importCsv,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Import old logbook'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add flight'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    hintText: 'Search aircraft or airfield',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFFBFAF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Flight records',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _entries.isEmpty ? null : _printLogbook,
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Print'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_visibleEntries.isEmpty)
                  _EmptyLogbook(hasSearch: _search.isNotEmpty, onAdd: _addEntry)
                else
                  ..._visibleEntries.map(
                    (entry) => _FlightEntryCard(
                      entry: entry,
                      onTap: () => _showEntry(entry),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEntry(FlightEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.departurePlace} → ${entry.arrivalPlace}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.aircraftType} · ${entry.registration} · ${_formatDate(entry.date)}',
            ),
            const Divider(height: 30),
            Text(
              'Total ${_formatDuration(entry.totalTime)} · ${entry.pilotFunction} · ${entry.singleMultiEngine}',
            ),
            const SizedBox(height: 10),
            Text('PIC: ${entry.picName}'),
            if (entry.remarks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(entry.remarks),
            ],
            const SizedBox(height: 16),
            Text(
              entry.source,
              style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplianceNotes() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ComplianceSheet(),
    );
  }

  void _showImportGuide() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('CSV import columns'),
        content: const SingleChildScrollView(
          child: SelectableText(
            'Required:\nDate, Aircraft type, Registration, Departure place, Departure time, Arrival place, Arrival time, Total time, PIC name\n\nOptional:\nPilot function, Class, Day landings, Night landings, Night time, IFR time, Remarks\n\nUse YYYY-MM-DD dates and HH:MM times. Review imported records against the original logbook.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
