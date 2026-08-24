import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FlightLogbookPage extends StatefulWidget {
  const FlightLogbookPage({super.key});

  @override
  State<FlightLogbookPage> createState() => _FlightLogbookPageState();
}

class _FlightLogbookPageState extends State<FlightLogbookPage> {
  final List<FlightEntry> _entries = [];
  String _search = '';

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

class FlightEntry {
  const FlightEntry({
    required this.date,
    required this.aircraftType,
    required this.registration,
    required this.departurePlace,
    required this.departureTime,
    required this.arrivalPlace,
    required this.arrivalTime,
    required this.totalTime,
    required this.picName,
    required this.pilotFunction,
    required this.singleMultiEngine,
    required this.dayLandings,
    required this.nightLandings,
    required this.nightTime,
    required this.ifrTime,
    required this.remarks,
    required this.source,
  });

  final DateTime date;
  final String aircraftType;
  final String registration;
  final String departurePlace;
  final String departureTime;
  final String arrivalPlace;
  final String arrivalTime;
  final Duration totalTime;
  final String picName;
  final String pilotFunction;
  final String singleMultiEngine;
  final int dayLandings;
  final int nightLandings;
  final Duration nightTime;
  final Duration ifrTime;
  final String remarks;
  final String source;

  List<String> get pdfRow => [
    _formatDate(date),
    '$aircraftType\n$registration',
    '$departurePlace\n$departureTime',
    '$arrivalPlace\n$arrivalTime',
    singleMultiEngine.startsWith('Multi') ? 'M' : 'S',
    _formatDuration(totalTime),
    picName,
    '$dayLandings / $nightLandings',
    _formatDuration(nightTime),
    _formatDuration(ifrTime),
    pilotFunction,
    remarks,
  ];
}

class _FlightEntryForm extends StatefulWidget {
  const _FlightEntryForm();
  @override
  State<_FlightEntryForm> createState() => _FlightEntryFormState();
}

class _FlightEntryFormState extends State<_FlightEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _type = TextEditingController();
  final _registration = TextEditingController();
  final _departure = TextEditingController();
  final _departureTime = TextEditingController();
  final _arrival = TextEditingController();
  final _arrivalTime = TextEditingController();
  final _total = TextEditingController();
  final _pic = TextEditingController();
  final _dayLandings = TextEditingController(text: '1');
  final _nightLandings = TextEditingController(text: '0');
  final _night = TextEditingController(text: '00:00');
  final _ifr = TextEditingController(text: '00:00');
  final _remarks = TextEditingController();
  DateTime _date = DateTime.now();
  String _function = 'PIC';
  String _aircraftClass = 'Single-engine';

  @override
  void dispose() {
    for (final controller in [
      _type,
      _registration,
      _departure,
      _departureTime,
      _arrival,
      _arrivalTime,
      _total,
      _pic,
      _dayLandings,
      _nightLandings,
      _night,
      _ifr,
      _remarks,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Add flight entry',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Required fields follow UK Part-FCL FCL.050 record structure.',
              style: TextStyle(color: Color(0xFF6C756F)),
            ),
            const SizedBox(height: 22),
            _SectionTitle(
              title: 'Flight',
              action: TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(_formatDate(_date)),
              ),
            ),
            Row(
              children: [
                Expanded(child: _field(_type, 'Aircraft type', 'PA-28')),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    _registration,
                    'Registration',
                    'G-ABCD',
                    capitals: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _departure,
                    'Departure',
                    'EGKB',
                    capitals: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _timeField(_departureTime, 'Off blocks')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(_arrival, 'Arrival', 'EGMC', capitals: true),
                ),
                const SizedBox(width: 10),
                Expanded(child: _timeField(_arrivalTime, 'On blocks')),
              ],
            ),
            const SizedBox(height: 12),
            _timeField(_total, 'Total flight time (HH:MM)'),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Pilot function & conditions'),
            _field(_pic, 'Pilot-in-command name', 'Full name'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _function,
                    decoration: const InputDecoration(
                      labelText: 'Function',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'PIC',
                              'Co-pilot',
                              'Dual',
                              'Instructor',
                              'PICUS',
                              'SPIC',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => _function = value!,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _aircraftClass,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Single-engine', 'Multi-engine']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => _aircraftClass = value!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(_dayLandings, 'Landings day')),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_nightLandings, 'Landings night')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _timeField(_night, 'Night time')),
                const SizedBox(width: 10),
                Expanded(child: _timeField(_ifr, 'IFR time')),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarks,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Remarks and endorsements',
                hintText:
                    'Tests, checks, instructor/PIC countersignature details…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save flight entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool capitals = false,
  }) => TextFormField(
    controller: controller,
    textCapitalization: capitals
        ? TextCapitalization.characters
        : TextCapitalization.words,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    ),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
  );

  TextFormField _timeField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'HH:MM',
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          try {
            _parseDuration(value);
            return null;
          } catch (_) {
            return 'Use HH:MM';
          }
        },
      );

  TextFormField _numberField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            int.tryParse(value ?? '') == null ? 'Number' : null,
      );

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: _date,
    );
    if (selected != null) setState(() => _date = selected);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      FlightEntry(
        date: _date,
        aircraftType: _type.text.trim(),
        registration: _registration.text.trim().toUpperCase(),
        departurePlace: _departure.text.trim().toUpperCase(),
        departureTime: _departureTime.text.trim(),
        arrivalPlace: _arrival.text.trim().toUpperCase(),
        arrivalTime: _arrivalTime.text.trim(),
        totalTime: _parseDuration(_total.text),
        picName: _pic.text.trim(),
        pilotFunction: _function,
        singleMultiEngine: _aircraftClass,
        dayLandings: int.parse(_dayLandings.text),
        nightLandings: int.parse(_nightLandings.text),
        nightTime: _parseDuration(_night.text),
        ifrTime: _parseDuration(_ifr.text),
        remarks: _remarks.text.trim(),
        source: 'Entered in app · ${DateTime.now().toIso8601String()}',
      ),
    );
  }
}

class _PilotDetailsDialog extends StatefulWidget {
  const _PilotDetailsDialog();
  @override
  State<_PilotDetailsDialog> createState() => _PilotDetailsDialogState();
}

class _PilotDetailsDialogState extends State<_PilotDetailsDialog> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _reference = TextEditingController();
  final _address = TextEditingController();
  bool _certified = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Sign your export'),
    content: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'UK CAA electronic submissions should identify the owner and be electronically signed. Printed copies may be hand signed.',
            ),
            const SizedBox(height: 16),
            _requiredField(_name, 'Full legal name'),
            const SizedBox(height: 12),
            _requiredField(_reference, 'CAA reference number'),
            const SizedBox(height: 12),
            _requiredField(_address, 'Address'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _certified,
              onChanged: (value) => setState(() => _certified = value ?? false),
              title: const Text(
                'I certify this is a true record of my flying experience.',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _certified ? _continue : null,
        child: const Text('Open print preview'),
      ),
    ],
  );

  TextFormField _requiredField(
    TextEditingController controller,
    String label,
  ) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
  );

  void _continue() {
    if (!(_key.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    Navigator.pop(
      context,
      _PilotDetails(
        name: _name.text.trim(),
        caaReference: _reference.text.trim(),
        address: _address.text.trim(),
        signatureName: _name.text.trim(),
        signatureDate: _formatDate(now),
      ),
    );
  }
}

class _PilotDetails {
  const _PilotDetails({
    required this.name,
    required this.caaReference,
    required this.address,
    required this.signatureName,
    required this.signatureDate,
  });
  final String name;
  final String caaReference;
  final String address;
  final String signatureName;
  final String signatureDate;
}

class _ComplianceBanner extends StatelessWidget {
  const _ComplianceBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFECE1CD),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.verified_user_outlined, color: Color(0xFF79562E)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAA record fields included',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Review logging rules and required countersignatures',
                    style: TextStyle(color: Color(0xFF6F5A40), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

class _ComplianceSheet extends StatelessWidget {
  const _ComplianceSheet();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UK CAA record checklist',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        const Text(
          'The entry form and PDF include the standard FCL.050 / AMC1 FCL.050 flight particulars, totals, operational conditions, pilot function, remarks and endorsements.',
        ),
        const SizedBox(height: 12),
        const Text(
          'SPIC, PICUS, tests, checks and certain revalidation flights require names, signatures or countersignatures in remarks. The pilot remains responsible for correct classification and supporting evidence.',
        ),
        const SizedBox(height: 12),
        const Text(
          'This pilot build has not been approved or certified by the UK CAA. Have the workflow and generated PDF reviewed before relying on it as your sole statutory record.',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I understand'),
          ),
        ),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF28634A)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6C756F),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyLogbook extends StatelessWidget {
  const _EmptyLogbook({required this.hasSearch, required this.onAdd});
  final bool hasSearch;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
    decoration: BoxDecoration(
      color: const Color(0xFFFBFAF6),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.flight_takeoff_rounded,
          size: 42,
          color: Color(0xFF28634A),
        ),
        const SizedBox(height: 12),
        Text(
          hasSearch ? 'No matching flights' : 'Your logbook is ready',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 7),
        Text(
          hasSearch
              ? 'Try another aircraft or airfield.'
              : 'Import an existing CSV or add your first flight.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6C756F)),
        ),
        if (!hasSearch) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add first flight'),
          ),
        ],
      ],
    ),
  );
}

class _FlightEntryCard extends StatelessWidget {
  const _FlightEntryCard({required this.entry, required this.onTap});
  final FlightEntry entry;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFDCEADD),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.flight_rounded, color: Color(0xFF28634A)),
      ),
      title: Text(
        '${entry.departurePlace} → ${entry.arrivalPlace}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${_formatDate(entry.date)} · ${entry.aircraftType} · ${entry.registration}',
      ),
      trailing: Text(
        _formatDuration(entry.totalTime),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ),
        ?action,
      ],
    ),
  );
}

Duration _parseDuration(String value, {bool allowEmpty = false}) {
  final text = value.trim();
  if (text.isEmpty && allowEmpty) return Duration.zero;
  final parts = text.split(':');
  if (parts.length != 2) throw const FormatException('Time must use HH:MM.');
  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  if (hours == null ||
      minutes == null ||
      hours < 0 ||
      minutes < 0 ||
      minutes > 59) {
    throw const FormatException('Time must use HH:MM.');
  }
  return Duration(hours: hours, minutes: minutes);
}

String _formatDuration(Duration value) {
  final hours = value.inHours.toString().padLeft(2, '0');
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
