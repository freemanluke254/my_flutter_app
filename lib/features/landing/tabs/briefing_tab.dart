import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../briefing/models/flight_briefing.dart';
import '../../briefing/services/ofp_parser.dart';
import '../../roster/models/day_duty.dart';
import '../widgets/day_duty_tile.dart';

class BriefingTab extends StatelessWidget {
  const BriefingTab({
    required this.flight,
    required this.isActive,
    required this.onFlightChanged,
    required this.onSaveFlight,
    required this.onClearFlight,
    required this.onCloseFlight,
    super.key,
  });

  final FlightBriefing? flight;
  final bool isActive;
  final void Function(FlightBriefing flight, bool active) onFlightChanged;
  final Future<void> Function() onSaveFlight;
  final Future<void> Function() onClearFlight;
  final Future<void> Function() onCloseFlight;

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
        if (isActive) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _close(context),
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('Close completed flight'),
          ),
        ],
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
          'This flight and its briefing progress are stored. It will be sent to the logbook when you close the completed flight.',
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

  Future<void> _close(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.task_alt_rounded, size: 44),
            title: const Text('Close this flight?'),
            content: const Text(
              'The flight data will be sent to the logbook. Uploaded flight documents will then be removed from this device to release storage.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Close flight'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await onCloseFlight();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flight closed and document data offloaded.'),
      ),
    );
  }

  Future<void> _addFlight(BuildContext context) async {
    final method = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add flight manually'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'type'),
            child: const ListTile(
              leading: Icon(Icons.keyboard_outlined),
              title: Text('Type flight details'),
              subtitle: Text('Enter each field yourself'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'ofp'),
            child: const ListTile(
              leading: Icon(Icons.picture_as_pdf_outlined),
              title: Text('Upload OFP'),
              subtitle: Text(
                'Decode the flight details from an operational flight plan',
              ),
            ),
          ),
        ],
      ),
    );
    if (!context.mounted || method == null) return;
    if (method == 'ofp') {
      await _addFromOfp(context);
    } else {
      await _showFlightForm(context);
    }
  }

  Future<void> _addFromOfp(BuildContext context) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (file == null || !context.mounted) return;
      final details = await const OfpParser().parse(await file.readAsBytes());
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF28634A),
            size: 46,
          ),
          title: const Text('OFP loaded successfully'),
          content: Text(
            'OFP Plan ID ${details.planId} successfully loaded.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Check details'),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      await _showFlightForm(context, details: details);
    } on Object catch (error) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB93B3B),
            size: 46,
          ),
          title: const Text('OFP load unsuccessful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Reason:'),
              const SizedBox(height: 6),
              SelectableText('$error', textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _addFromOfp(context);
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showFlightForm(
    BuildContext context, {
    OfpFlightDetails? details,
  }) async {
    final number = TextEditingController(
      text: details?.flightNumber ?? flight?.flightNumber,
    );
    final departure = TextEditingController(text: details?.departure);
    final arrival = TextEditingController(text: details?.arrival);
    final departureTime = TextEditingController(text: details?.departureTime);
    final arrivalTime = TextEditingController(text: details?.arrivalTime);
    final aircraft = TextEditingController(text: details?.aircraftType);
    final registration = TextEditingController(text: details?.registration);
    final callsign = TextEditingController(
      text: details?.callsign ?? flight?.callsign,
    );
    final reportTime = TextEditingController(text: flight?.reportTime);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          details == null ? 'Enter flight details' : 'Confirm OFP details',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: number,
                decoration: const InputDecoration(labelText: 'Flight number'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: callsign,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Callsign'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: departure,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Departure airport',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: arrival,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Arrival airport'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: departureTime,
                      decoration: const InputDecoration(
                        labelText: 'Departure time',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: arrivalTime,
                      decoration: const InputDecoration(
                        labelText: 'Arrival time',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: aircraft,
                      decoration: const InputDecoration(labelText: 'Aircraft'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: registration,
                      decoration: const InputDecoration(
                        labelText: 'Registration',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reportTime,
                decoration: const InputDecoration(
                  labelText: 'Report time (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final missing = <String>[
                if (number.text.trim().isEmpty) 'flight number',
                if (callsign.text.trim().isEmpty) 'callsign',
                if (departure.text.trim().isEmpty ||
                    arrival.text.trim().isEmpty)
                  'route',
                if (departureTime.text.trim().isEmpty) 'departure time',
                if (arrivalTime.text.trim().isEmpty) 'arrival time',
                if (aircraft.text.trim().isEmpty) 'aircraft type',
              ];
              if (missing.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Check required details: ${missing.join(', ')}.',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
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
        departureTime: departureTime.text.trim().isEmpty
            ? 'Manually added flight'
            : departureTime.text.trim(),
        arrivalTime: arrivalTime.text.trim().isEmpty
            ? 'Times pending flight package'
            : arrivalTime.text.trim(),
        aircraftType: aircraft.text.trim().isEmpty
            ? 'Aircraft pending'
            : aircraft.text.trim(),
        registration: registration.text.trim(),
        planType: details?.operation ?? 'Documents not uploaded',
        callsign: callsign.text.trim().toUpperCase(),
        planId: details?.planId ?? flight?.planId ?? '',
        reportTime: reportTime.text.trim(),
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
      callsign: current?.callsign ?? '',
      planId: current?.planId ?? '',
      reportTime: current?.reportTime ?? '',
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
  Widget build(BuildContext context) {
    final route = flight.route.split(RegExp(r'\s*[→–-]\s*'));
    final duty = DayDuty.flight(
      title: flight.flightNumber,
      reportTime: flight.reportTime.isEmpty ? 'Optional' : flight.reportTime,
      startTime: flight.departureTime,
      endTime: flight.arrivalTime,
      departure: route.isNotEmpty && route.first.isNotEmpty
          ? route.first
          : 'DEP',
      arrival: route.length > 1 && route.last.isNotEmpty ? route.last : 'ARR',
      aircraft: flight.aircraftType,
    );
    return DayDutyTile(
      duty: duty,
      statusLabel: active ? 'ACTIVE FLIGHT' : 'CURRENT FLIGHT',
      backgroundColor: active
          ? const Color(0xFF173D31)
          : const Color(0xFF244A73),
      footerText: active
          ? 'All briefing tabs are showing data for this active flight'
          : 'Current flight · upload documents to activate',
    );
  }
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
