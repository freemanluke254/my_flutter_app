part of '../../../flight_logbook_page.dart';

extension _LogbookActions on _FlightLogbookPageState {
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
}
