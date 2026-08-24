import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../briefing/models/flight_briefing.dart';
import '../../briefing/widgets/briefing_document_tile.dart';

class BriefingTab extends StatefulWidget {
  const BriefingTab({super.key});

  @override
  State<BriefingTab> createState() => _BriefingTabState();
}

class _BriefingTabState extends State<BriefingTab> {
  int _selectedFlight = 0;

  final List<FlightBriefing> _flights = [
    FlightBriefing(
      flightNumber: 'VS23',
      route: 'LHR → LAX',
      departureTime: '24 Aug · 17:15 local',
      arrivalTime: '25 Aug · 04:25 local',
      aircraftType: 'B787-9',
      registration: 'G-VMAP',
      planType: 'ETOPS 138 · North Atlantic',
      documents: [
        BriefingDocument(
          type: BriefingDocumentType.operationalFlightPlan,
          title: 'Operational flight plan',
          fileCount: 1,
        ),
        BriefingDocument(
          type: BriefingDocumentType.weather,
          title: 'Weather briefing',
          fileCount: 1,
        ),
        BriefingDocument(
          type: BriefingDocumentType.notams,
          title: 'NOTAM briefing',
          fileCount: 1,
        ),
        BriefingDocument(
          type: BriefingDocumentType.routeChart,
          title: 'Route chart',
          fileCount: 1,
        ),
        BriefingDocument(
          type: BriefingDocumentType.significantWeather,
          title: 'Significant weather charts',
          fileCount: 4,
        ),
        BriefingDocument(
          type: BriefingDocumentType.tracks,
          title: 'North Atlantic tracks',
          fileCount: 1,
        ),
      ],
    ),
    FlightBriefing(
      flightNumber: 'VS358',
      route: 'LHR → BOM',
      departureTime: '24 Aug · 11:25 local',
      arrivalTime: '25 Aug · 20:40 local',
      aircraftType: 'B787-9',
      registration: 'G-VOWS',
      planType: 'Non-ETOPS · Terrain critical',
      documents: [
        BriefingDocument(
          type: BriefingDocumentType.operationalFlightPlan,
          title: 'Operational flight plan',
          fileCount: 1,
        ),
        BriefingDocument(
          type: BriefingDocumentType.weather,
          title: 'Weather briefing',
          fileCount: 1,
        ),
        BriefingDocument(
          type: BriefingDocumentType.notams,
          title: 'NOTAM briefing',
          fileCount: 1,
        ),
        BriefingDocument(
          type: BriefingDocumentType.routeChart,
          title: 'Route charts',
          fileCount: 2,
        ),
        BriefingDocument(
          type: BriefingDocumentType.significantWeather,
          title: 'Significant weather charts',
          fileCount: 4,
        ),
        BriefingDocument(
          type: BriefingDocumentType.terrain,
          title: 'Critical terrain scenario',
          fileCount: 1,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final flight = _flights[_selectedFlight];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Briefing',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _importPackage,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Import'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Review the decoded package while retaining every original document.',
          style: TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              _flights.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_flights[index].flightNumber),
                  selected: index == _selectedFlight,
                  onSelected: (_) => setState(() => _selectedFlight = index),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _FlightHeader(flight: flight),
        const SizedBox(height: 22),
        const Text(
          'Flight package',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...flight.documents.map(
          (document) => BriefingDocumentTile(
            document: document,
            onTap: () => _showDocumentMessage(document),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Decoded information is for briefing support. Verify operational decisions against the current approved source document.',
          style: TextStyle(color: Color(0xFF667069), fontSize: 11, height: 1.4),
        ),
      ],
    );
  }

  Future<void> _importPackage() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (!mounted || files.isEmpty) return;

    final grouped = <String, List<PlatformFile>>{};
    for (final file in files) {
      final match = RegExp(
        r'^([A-Za-z]+\d+)',
        caseSensitive: false,
      ).firstMatch(file.name);
      final flightNumber = match?.group(1)?.toUpperCase() ?? 'IMPORTED';
      grouped.putIfAbsent(flightNumber, () => []).add(file);
    }
    final imported = grouped.entries
        .map((group) => _flightFromFiles(group.key, group.value))
        .toList();
    if (imported.isEmpty) return;
    setState(() {
      _flights
        ..clear()
        ..addAll(imported);
      _selectedFlight = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${files.length} documents grouped into ${imported.length} flight package${imported.length == 1 ? '' : 's'}.',
        ),
      ),
    );
  }

  FlightBriefing _flightFromFiles(
    String flightNumber,
    List<PlatformFile> files,
  ) {
    final counts = <BriefingDocumentType, int>{};
    for (final file in files) {
      final type = _documentType(file.name);
      counts[type] = (counts[type] ?? 0) + 1;
    }
    final documents = counts.entries
        .map(
          (entry) => BriefingDocument(
            type: entry.key,
            title: _documentTitle(entry.key),
            fileCount: entry.value,
          ),
        )
        .toList();
    return FlightBriefing(
      flightNumber: flightNumber,
      route: 'Imported flight package',
      departureTime: 'Open the OFP to confirm flight details',
      arrivalTime: '${files.length} source documents selected',
      aircraftType: 'Aircraft details pending OFP decoding',
      registration: '',
      planType: 'Imported locally',
      documents: documents,
    );
  }

  BriefingDocumentType _documentType(String filename) {
    final name = filename.toUpperCase();
    if (name.contains('NOTAM')) return BriefingDocumentType.notams;
    if (name.contains('OFP')) return BriefingDocumentType.operationalFlightPlan;
    if (name.contains('TERRA')) return BriefingDocumentType.terrain;
    if (name.contains('TRACK')) return BriefingDocumentType.tracks;
    if (name.contains('ROUTE')) return BriefingDocumentType.routeChart;
    if (name.contains('SIG')) return BriefingDocumentType.significantWeather;
    return BriefingDocumentType.weather;
  }

  String _documentTitle(BriefingDocumentType type) => switch (type) {
    BriefingDocumentType.operationalFlightPlan => 'Operational flight plan',
    BriefingDocumentType.weather => 'Weather briefing',
    BriefingDocumentType.notams => 'NOTAM briefing',
    BriefingDocumentType.routeChart => 'Route charts',
    BriefingDocumentType.significantWeather => 'Significant weather charts',
    BriefingDocumentType.tracks => 'Track message',
    BriefingDocumentType.terrain => 'Critical terrain scenario',
  };

  void _showDocumentMessage(
    BriefingDocument document,
  ) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${document.title}: original PDF and decoded summary will open here.',
      ),
    ),
  );
}

class _FlightHeader extends StatelessWidget {
  const _FlightHeader({required this.flight});
  final FlightBriefing flight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${flight.flightNumber} · ${flight.route}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${flight.departureTime}\n${flight.arrivalTime}',
          style: const TextStyle(color: Color(0xFFDCEADD), height: 1.5),
        ),
        const SizedBox(height: 10),
        Text(
          '${flight.aircraftType} · ${flight.registration}\n${flight.planType}',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
      ],
    ),
  );
}
