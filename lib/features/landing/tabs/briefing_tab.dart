import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../briefing/models/flight_briefing.dart';

class BriefingTab extends StatelessWidget {
  const BriefingTab({
    required this.flight,
    required this.isActive,
    required this.onFlightChanged,
    required this.onSaveFlight,
    required this.onClearFlight,
    super.key,
  });

  final FlightBriefing? flight;
  final bool isActive;
  final void Function(FlightBriefing flight, bool active) onFlightChanged;
  final Future<void> Function() onSaveFlight;
  final Future<void> Function() onClearFlight;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Briefing',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Prepare and activate the next flight from your roster.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 18),
      if (flight == null)
        _NoFlightCard(onAdd: () => _addFlight(context))
      else
        _FlightCard(flight: flight!, active: isActive),
      const SizedBox(height: 18),
      if (flight != null && !isActive)
        _UploadCard(
          onUpload: () => _uploadDocuments(context),
          onChangeFlight: () => _addFlight(context),
        )
      else if (flight != null)
        _ActiveCard(
          flight: flight!,
          onReplaceDocuments: () => _uploadDocuments(context),
        ),
      if (flight != null) ...[
        const SizedBox(height: 14),
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _clear(context),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear flight'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isActive ? () => _save(context) : null,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save flight'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );

  Future<void> _save(BuildContext context) async {
    await onSaveFlight();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.bookmark_added_rounded,
          color: Color(0xFF28634A),
          size: 44,
        ),
        title: const Text('Flight saved'),
        content: const Text(
          'This flight is stored and ready to be added to the pilot logbook after completion.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _clear(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear this flight?'),
            content: const Text(
              'All entered flight and briefing data will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear all fields'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) await onClearFlight();
  }

  Future<void> _addFlight(BuildContext context) async {
    final number = TextEditingController(text: flight?.flightNumber);
    final departure = TextEditingController();
    final arrival = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add flight manually'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: number,
              decoration: const InputDecoration(labelText: 'Flight number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: departure,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Departure airport'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: arrival,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Arrival airport'),
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
            child: const Text('Add flight'),
          ),
        ],
      ),
    );
    if (saved != true || number.text.trim().isEmpty) return;
    onFlightChanged(
      FlightBriefing(
        flightNumber: number.text.trim().toUpperCase(),
        route:
            '${departure.text.trim().toUpperCase()} → ${arrival.text.trim().toUpperCase()}',
        departureTime: 'Manually added flight',
        arrivalTime: 'Times pending flight package',
        aircraftType: 'Aircraft pending',
        registration: '',
        planType: 'Documents not uploaded',
        documents: const [],
      ),
      false,
    );
  }

  Future<void> _uploadDocuments(BuildContext context) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (files.isEmpty || !context.mounted) return;
    final documents = <BriefingDocumentType, int>{};
    for (final file in files) {
      final type = _documentType(file.name);
      documents[type] = (documents[type] ?? 0) + 1;
    }
    final detectedNumber = RegExp(
      r'^([A-Za-z]+\d+)',
    ).firstMatch(files.first.name)?.group(1)?.toUpperCase();
    final current = flight;
    final updated = FlightBriefing(
      flightNumber: detectedNumber ?? current?.flightNumber ?? 'IMPORTED',
      route: current?.route ?? 'Route pending OFP decoding',
      departureTime: current?.departureTime ?? 'From uploaded flight package',
      arrivalTime: current?.arrivalTime ?? '${files.length} documents uploaded',
      aircraftType: current?.aircraftType ?? 'Aircraft pending OFP decoding',
      registration: current?.registration ?? '',
      planType: 'Active flight package',
      documents: documents.entries
          .map(
            (item) => BriefingDocument(
              type: item.key,
              title: _title(item.key),
              fileCount: item.value,
            ),
          )
          .toList(),
    );
    onFlightChanged(updated, true);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF28634A),
          size: 44,
        ),
        title: const Text('Flight activated'),
        content: Text(
          '${updated.flightNumber}\n${files.length} documents uploaded',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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

  String _title(BriefingDocumentType type) => switch (type) {
    BriefingDocumentType.operationalFlightPlan => 'Operational flight plan',
    BriefingDocumentType.weather => 'Weather briefing',
    BriefingDocumentType.notams => 'NOTAM briefing',
    BriefingDocumentType.routeChart => 'Route charts',
    BriefingDocumentType.significantWeather => 'Significant weather charts',
    BriefingDocumentType.tracks => 'Track message',
    BriefingDocumentType.terrain => 'Critical terrain scenario',
  };
}

class _FlightCard extends StatelessWidget {
  const _FlightCard({required this.flight, required this.active});
  final FlightBriefing flight;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF173D31) : const Color(0xFFD9E1EA),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                active ? 'ACTIVE FLIGHT' : 'NEXT FLIGHT',
                style: TextStyle(
                  color: active
                      ? const Color(0xFF9BD1B4)
                      : const Color(0xFF244A73),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              active ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: active ? const Color(0xFF9BD1B4) : const Color(0xFF244A73),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${flight.flightNumber} · ${flight.route}',
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF18334F),
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${flight.departureTime}\n${flight.arrivalTime}',
          style: TextStyle(
            color: active ? Colors.white70 : const Color(0xFF43576A),
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _NoFlightCard extends StatelessWidget {
  const _NoFlightCard({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.flight_outlined, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No upcoming rostered flight',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add flight manually'),
          ),
        ],
      ),
    ),
  );
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.onUpload, required this.onChangeFlight});
  final VoidCallback onUpload;
  final VoidCallback onChangeFlight;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Upload flight documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload the OFP, weather, NOTAMs, charts and any additional planning documents.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Choose flight documents'),
          ),
          TextButton(
            onPressed: onChangeFlight,
            child: const Text('Schedule changed? Choose another flight'),
          ),
        ],
      ),
    ),
  );
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.flight, required this.onReplaceDocuments});
  final FlightBriefing flight;
  final VoidCallback onReplaceDocuments;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.folder_copy_outlined)),
      title: Text(
        '${flight.documents.fold<int>(0, (sum, item) => sum + item.fileCount)} documents ready',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: const Text('Continue through the briefing tabs below.'),
      trailing: IconButton(
        onPressed: onReplaceDocuments,
        tooltip: 'Replace documents',
        icon: const Icon(Icons.refresh_rounded),
      ),
    ),
  );
}
