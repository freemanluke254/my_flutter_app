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

  static const _flights = [
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
              onPressed: _showImportMessage,
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
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('VS23')),
            ButtonSegment(value: 1, label: Text('VS358')),
          ],
          selected: {_selectedFlight},
          onSelectionChanged: (value) =>
              setState(() => _selectedFlight = value.first),
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

  void _showImportMessage() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Package file selection will be connected next.'),
    ),
  );
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
