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

  Future<void> _addEntry() async {
    final entry = await showModalBottomSheet<FlightEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _FlightEntryForm(),
    );
    if (entry == null || !mounted) return;
    setState(() {
      _entries.add(entry);
      _entries.sort((a, b) => a.date.compareTo(b.date));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flight added to your logbook.')),
    );
  }

  Future<void> _importCsv() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final rows = Csv().decode(utf8.decode(bytes));
      if (rows.length < 2) throw const FormatException('No flight rows found.');
      final headers = rows.first.map((value) => '$value'.trim()).toList();
      const requiredHeaders = [
        'Date',
        'Aircraft type',
        'Registration',
        'Departure place',
        'Departure time',
        'Arrival place',
        'Arrival time',
        'Total time',
        'PIC name',
      ];
      final missing = requiredHeaders.where((name) => !headers.contains(name));
      if (missing.isNotEmpty) {
        throw FormatException('Missing columns: ${missing.join(', ')}');
      }

      final imported = <FlightEntry>[];
      for (final row in rows.skip(1)) {
        if (row.every((value) => '$value'.trim().isEmpty)) continue;
        String value(String header) {
          final index = headers.indexOf(header);
          return index >= 0 && index < row.length ? '${row[index]}'.trim() : '';
        }

        imported.add(
          FlightEntry(
            date: DateTime.parse(value('Date')),
            aircraftType: value('Aircraft type'),
            registration: value('Registration'),
            departurePlace: value('Departure place'),
            departureTime: value('Departure time'),
            arrivalPlace: value('Arrival place'),
            arrivalTime: value('Arrival time'),
            totalTime: _parseDuration(value('Total time')),
            picName: value('PIC name'),
            pilotFunction: value('Pilot function').isEmpty
                ? 'PIC'
                : value('Pilot function'),
            singleMultiEngine: value('Class').isEmpty
                ? 'Single-engine'
                : value('Class'),
            dayLandings: int.tryParse(value('Day landings')) ?? 0,
            nightLandings: int.tryParse(value('Night landings')) ?? 0,
            nightTime: _parseDuration(value('Night time'), allowEmpty: true),
            ifrTime: _parseDuration(value('IFR time'), allowEmpty: true),
            remarks: value('Remarks'),
            source: 'Imported: ${file.name}',
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _entries.addAll(imported);
        _entries.sort((a, b) => a.date.compareTo(b.date));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${imported.length} flights imported. Review them before use.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    }
  }

  Future<void> _printLogbook() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add or import a flight before printing.'),
        ),
      );
      return;
    }
    final profile = await _requestPilotDetails();
    if (profile == null || !mounted) return;
    await Printing.layoutPdf(
      name: 'UK_Part-FCL_Logbook.pdf',
      onLayout: (_) => _buildPdf(profile),
    );
  }

  Future<_PilotDetails?> _requestPilotDetails() {
    return showDialog<_PilotDetails>(
      context: context,
      builder: (_) => const _PilotDetailsDialog(),
    );
  }

  Future<Uint8List> _buildPdf(_PilotDetails pilot) async {
    final document = pw.Document(
      title: 'Personal Flying Logbook',
      author: pilot.name,
      subject: 'UK Part-FCL flight-time record',
    );
    const headers = [
      'Date',
      'Aircraft\nType / Reg',
      'Departure\nPlace / Time',
      'Arrival\nPlace / Time',
      'S/M',
      'Total',
      'PIC name',
      'Landings\nD / N',
      'Night',
      'IFR',
      'Function',
      'Remarks / endorsements',
    ];
    final rows = _entries.map((entry) => entry.pdfRow).toList();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PERSONAL FLYING LOGBOOK',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '${pilot.name}  |  CAA reference: ${pilot.caaReference}  |  ${pilot.address}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated under UK Part-FCL FCL.050 / AMC1 FCL.050',
              style: const pw.TextStyle(fontSize: 7),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ],
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 6),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFDCEADD),
            ),
            cellPadding: const pw.EdgeInsets.all(3),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Page total: ${_formatDuration(_totalTime)}    Entries: ${_entries.length}',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'I certify that this is a true record of my flying experience.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Signed: ${pilot.signatureName}    Date: ${pilot.signatureDate}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return document.save();
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
