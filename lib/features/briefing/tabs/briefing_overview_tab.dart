import 'dart:async';

import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import '../widgets/pdf_preview_thumbnail.dart';
import '../widgets/pdf_full_page_viewer.dart';
import '../widgets/operational_document_dialog.dart';
import 'weather_notams_tab.dart';

class BriefingOverviewTab extends StatelessWidget {
  const BriefingOverviewTab({required this.flight, super.key});
  final FlightBriefing? flight;

  @override
  Widget build(BuildContext context) {
    final current = flight;
    if (current == null || current.documents.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _heading(context),
          const SizedBox(height: 18),
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Select a flight and upload its OFP and supporting documents in Config to build the briefing overview.',
              ),
            ),
          ),
        ],
      );
    }
    final route = _route(current.route);
    final weather = _document(current, BriefingDocumentType.weather);
    final sigWx = _document(current, BriefingDocumentType.significantWeather);
    final notams = _document(current, BriefingDocumentType.notams);
    final notamWindow = _notamWindow(current);
    final localNotamWindow = _localNotamWindow(current);
    final hasTrackOrTerrain = current.documents.any(
      (document) =>
          document.type == BriefingDocumentType.tracks ||
          document.type == BriefingDocumentType.terrain,
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _heading(context),
        const SizedBox(height: 14),
        _BriefingFlightTile(flight: current),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Aircraft'),
        _AircraftDetailsCard(flight: current),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Crew and load'),
        _CrewLoadCard(
          flight: current,
          onLoadChecker: () => _loadChecker(context),
        ),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Flight time'),
        _FlightTimeCard(flight: current),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Weather'),
        Row(
          children: [
            Expanded(
              child: _StatusBlock(
                title: 'Departure WX',
                subtitle: '${route.$1} at STD\nMETAR & TAF',
                icon: Icons.flight_takeoff_rounded,
                available: weather != null,
                onTap: () => showBriefingDocuments(
                  context,
                  document: weather,
                  airportCodes: [route.$1],
                  contentType: BriefingDocumentContentType.weather,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'En-route WX',
                subtitle: 'Alternates and route\nweather',
                icon: Icons.thunderstorm_outlined,
                available: weather != null,
                onTap: () => showBriefingDocuments(
                  context,
                  document: weather,
                  airportCodes: [route.$1, route.$2],
                  contentType: BriefingDocumentContentType.weather,
                  includeOtherSections: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'Arrival WX',
                subtitle: '${route.$2} at STA\nMETAR & TAF',
                icon: Icons.flight_land_rounded,
                available: weather != null,
                onTap: () => showBriefingDocuments(
                  context,
                  document: weather,
                  airportCodes: [route.$2],
                  contentType: BriefingDocumentContentType.weather,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SigWxGallery(document: sigWx),
        const SizedBox(height: 16),
        _sectionTitle(context, 'NOTAMs'),
        Row(
          children: [
            Expanded(
              child: _StatusBlock(
                title: 'Departure',
                subtitle: '${route.$1}\nAerodrome + FIR',
                icon: Icons.flight_takeoff_rounded,
                available: notams != null,
                onTap: () => showBriefingDocuments(
                  context,
                  document: notams,
                  airportCodes: [route.$1],
                  contentType: BriefingDocumentContentType.notam,
                  relevanceStart: notamWindow?.$1,
                  relevanceEnd: notamWindow?.$2,
                  relevanceLocalWindow: localNotamWindow,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'En-route',
                subtitle: 'Route, FIR\nand alternates',
                icon: Icons.route_outlined,
                available: notams != null,
                onTap: () => showBriefingDocuments(
                  context,
                  document: notams,
                  airportCodes: [route.$1, route.$2],
                  contentType: BriefingDocumentContentType.notam,
                  includeOtherSections: true,
                  relevanceStart: notamWindow?.$1,
                  relevanceEnd: notamWindow?.$2,
                  relevanceLocalWindow: localNotamWindow,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'Arrival',
                subtitle: '${route.$2}\nAerodrome + FIR',
                icon: Icons.flight_land_rounded,
                available: notams != null,
                onTap: () => showBriefingDocuments(
                  context,
                  document: notams,
                  airportCodes: [route.$2],
                  contentType: BriefingDocumentContentType.notam,
                  relevanceStart: notamWindow?.$1,
                  relevanceEnd: notamWindow?.$2,
                  relevanceLocalWindow: localNotamWindow,
                ),
              ),
            ),
          ],
        ),
        if (hasTrackOrTerrain) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, 'Track & terrain'),
          _TrackTerrainSection(flight: current),
        ],
        const SizedBox(height: 20),
        _sectionTitle(context, 'Original flight documents'),
        _OriginalDocumentsSection(flight: current),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _heading(BuildContext context) => Text(
    'Briefing overview',
    style: Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
  );
  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
  BriefingDocument? _document(
    FlightBriefing flight,
    BriefingDocumentType type,
  ) => flight.documents.where((item) => item.type == type).firstOrNull;
  (String, String) _route(String value) {
    final parts = value.split(RegExp(r'\s*[→–-]\s*'));
    return (parts.firstOrNull ?? 'DEP', parts.length > 1 ? parts.last : 'ARR');
  }

  (DateTime, DateTime)? _notamWindow(FlightBriefing flight) {
    final departure = flight.scheduledDepartureUtc;
    if (departure == null) return null;
    final arrival = _scheduledArrivalUtc(flight, departure);
    if (arrival == null) return null;
    return (
      departure.subtract(const Duration(hours: 2)),
      arrival.add(const Duration(hours: 2)),
    );
  }

  DateTime? _scheduledArrivalUtc(FlightBriefing flight, DateTime departure) {
    final value = flight.arrivalTimeUtc.replaceAll(':', '').replaceAll(' ', '');
    final match = RegExp(r'^(\d{2})(\d{2})(?:\+(\d*))?$').firstMatch(value);
    if (match == null) return null;
    final hasDaySuffix = value.contains('+');
    final statedDayOffset = hasDaySuffix
        ? int.tryParse(match.group(3) ?? '') ?? 1
        : null;
    var arrival = DateTime.utc(
      departure.year,
      departure.month,
      departure.day,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    ).add(Duration(days: statedDayOffset ?? 0));
    if (statedDayOffset == null && !arrival.isAfter(departure)) {
      arrival = arrival.add(const Duration(days: 1));
    }
    return arrival;
  }

  String? _localNotamWindow(FlightBriefing flight) {
    final date = flight.flightDate;
    if (date == null) return null;
    final departure = _localDateTime(date, flight.departureTime);
    final arrival = _localDateTime(date, flight.arrivalTime);
    if (departure == null || arrival == null) return null;
    var adjustedArrival = arrival;
    if (!adjustedArrival.isAfter(departure)) {
      adjustedArrival = adjustedArrival.add(const Duration(days: 1));
    }
    final start = departure.subtract(const Duration(hours: 2));
    final end = adjustedArrival.add(const Duration(hours: 2));
    return '${_dateTime(start)} – ${_dateTime(end)} local';
  }

  DateTime? _localDateTime(DateTime date, String value) {
    final compact = value.replaceAll(':', '').replaceAll(' ', '');
    final match = RegExp(r'^(\d{2})(\d{2})(?:\+(\d*))?$').firstMatch(compact);
    if (match == null) return null;
    final hasDaySuffix = compact.contains('+');
    final dayOffset = hasDaySuffix
        ? int.tryParse(match.group(3) ?? '') ?? 1
        : 0;
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    ).add(Duration(days: dayOffset));
  }

  String _dateTime(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  void _loadChecker(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.link_rounded, size: 42),
      title: const Text('Load checker'),
      content: const Text(
        'Add your company load-checker web address to connect this button.',
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

class _TrackTerrainSection extends StatelessWidget {
  const _TrackTerrainSection({required this.flight});
  final FlightBriefing flight;

  @override
  Widget build(BuildContext context) {
    final documents = flight.documents.where(
      (document) =>
          document.type == BriefingDocumentType.tracks ||
          document.type == BriefingDocumentType.terrain,
    );
    final files = <({String name, String? path, BriefingDocumentType type})>[];
    for (final document in documents) {
      for (var index = 0; index < document.fileCount; index++) {
        files.add((
          name: index < document.fileNames.length
              ? document.fileNames[index]
              : '${document.title} ${index + 1}',
          path: index < document.filePaths.length
              ? document.filePaths[index]
              : null,
          type: document.type,
        ));
      }
    }
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final file = files[index];
          final terrain = file.type == BriefingDocumentType.terrain;
          return SizedBox(
            width: 230,
            child: Card(
              elevation: 0,
              color: terrain
                  ? const Color(0xFFF3EBDD)
                  : const Color(0xFFE3EEF7),
              child: ListTile(
                leading: Icon(
                  terrain ? Icons.terrain_rounded : Icons.public_rounded,
                  color: terrain
                      ? const Color(0xFF8A6235)
                      : const Color(0xFF315F86),
                ),
                title: Text(
                  terrain ? 'Terrain' : 'Track',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: file.path == null
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reupload this document to open it.'),
                        ),
                      )
                    : () => _open(context, file.name, file.path!, file.type),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    String name,
    String path,
    BriefingDocumentType type,
  ) => showDialog<void>(
    context: context,
    builder: (context) =>
        OperationalDocumentDialog(name: name, path: path, type: type),
  );
}

class _OriginalDocumentsSection extends StatelessWidget {
  const _OriginalDocumentsSection({required this.flight});
  final FlightBriefing flight;

  @override
  Widget build(BuildContext context) {
    final files = <({String name, String? path, String type})>[];
    for (final document in flight.documents) {
      if (document.type == BriefingDocumentType.significantWeather ||
          document.type == BriefingDocumentType.operationalFlightPlan) {
        continue;
      }
      for (var index = 0; index < document.fileCount; index++) {
        files.add((
          name: index < document.fileNames.length
              ? document.fileNames[index]
              : '${document.title} ${index + 1}',
          path: index < document.filePaths.length
              ? document.filePaths[index]
              : null,
          type: document.title,
        ));
      }
    }
    if (files.isEmpty) {
      return const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No additional flight documents loaded.'),
        ),
      );
    }
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Column(
        children: List.generate(files.length, (index) {
          final file = files[index];
          return Column(
            children: [
              if (index > 0) const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFB93B3B),
                ),
                title: Text(
                  file.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(file.type),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: file.path == null
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reupload this document to open it.'),
                        ),
                      )
                    : () => _open(context, file.name, file.path!),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _open(BuildContext context, String name, String path) =>
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 800),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: Text(name),
                  subtitle: const Text('Original loaded document'),
                  trailing: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: PdfFullPageViewer(path: path)),
              ],
            ),
          ),
        ),
      );
}

class _AircraftDetailsCard extends StatelessWidget {
  const _AircraftDetailsCard({required this.flight});
  final FlightBriefing flight;

  @override
  Widget build(BuildContext context) {
    final hasDefects =
        flight.melCdlReferences.isNotEmpty ||
        flight.defectSummary.isNotEmpty ||
        flight.operationalRestrictions.isNotEmpty;
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _detail('REG', flight.registration)),
                Expanded(child: _detail('TYPE', flight.aircraftType)),
                Expanded(child: _detail('STAND', flight.stand)),
              ],
            ),
            const Divider(height: 22),
            Row(
              children: [
                Icon(
                  hasDefects
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: hasDefects
                      ? const Color(0xFFBD7A17)
                      : const Color(0xFF28634A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasDefects
                        ? 'MEL / CDL ${_value(flight.melCdlReferences)}'
                        : 'No aircraft defects entered',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (flight.defectSummary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Effect: ${flight.defectSummary}'),
            ],
            if (flight.operationalRestrictions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Restrictions: ${flight.operationalRestrictions}',
                style: const TextStyle(color: Color(0xFFB93B3B)),
              ),
            ],
            if (hasDefects) ...[
              const SizedBox(height: 8),
              const Text(
                'Pilot-entered information — verify against the approved MEL/CDL and technical log.',
                style: TextStyle(color: Color(0xFF667069), fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Column(
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF667069))),
      const SizedBox(height: 3),
      Text(
        _value(value),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ],
  );

  String _value(String value) => value.trim().isEmpty ? 'Pending' : value;
}

class _CrewLoadCard extends StatelessWidget {
  const _CrewLoadCard({required this.flight, required this.onLoadChecker});
  final FlightBriefing flight;
  final VoidCallback onLoadChecker;
  @override
  Widget build(BuildContext context) {
    final flightDeckNames = <String>[
      if (flight.captain.isNotEmpty) 'Captain ${flight.captain}',
      if (flight.firstOfficer.isNotEmpty) 'FO ${flight.firstOfficer}',
      if (flight.reliefPilot.isNotEmpty) 'SO / Relief ${flight.reliefPilot}',
      if (flight.otherCrew.isNotEmpty)
        '${flight.otherCrewRole} ${flight.otherCrew}',
    ];
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _crew(
                    '${flightDeckNames.length} flight deck',
                    flightDeckNames.isEmpty
                        ? 'Crew names pending'
                        : flightDeckNames.join(' · '),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _crew(
                    '${flight.cabinCrewCount} cabin crew',
                    'FSM ${_name(flight.fsm)} · CSS ${_name(flight.css)}',
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onLoadChecker,
                icon: const Icon(Icons.groups_2_outlined),
                label: const Text('Open load checker'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crew(String title, String names) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(names, style: const TextStyle(color: Color(0xFF667069))),
    ],
  );
  String _name(String value) => value.isEmpty ? 'Pending' : value;
}

class _StatusBlock extends StatelessWidget {
  const _StatusBlock({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.available,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final bool available;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: available ? onTap : null,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: available ? const Color(0xFF86B79E) : const Color(0xFFE0B96F),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: available
                ? const Color(0xFF28634A)
                : const Color(0xFFBD7A17),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF667069), fontSize: 12),
          ),
          const SizedBox(height: 7),
          Icon(
            available ? Icons.check_circle_rounded : Icons.pending_outlined,
            size: 18,
            color: available
                ? const Color(0xFF28634A)
                : const Color(0xFFBD7A17),
          ),
        ],
      ),
    ),
  );
}

class _SigWxGallery extends StatelessWidget {
  const _SigWxGallery({required this.document});
  final BriefingDocument? document;
  @override
  Widget build(BuildContext context) {
    final count = document?.fileCount ?? 0;
    final charts = _charts(document);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Significant-weather charts',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (count == 0)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('No SIGWX chart PDFs loaded.'),
            ),
          )
        else
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: charts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final chart = charts[index];
                return InkWell(
                  onTap: chart.path == null
                      ? null
                      : () => _showChart(context, chart),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5F3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD8E0DC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(13),
                          ),
                          child: SizedBox(
                            height: 118,
                            width: double.infinity,
                            child: PdfPreviewThumbnail(path: chart.path),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 9, 10, 0),
                          child: Text(
                            chart.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            chart.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF667069),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _showChart(BuildContext context, _SigWxChart chart) =>
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
            child: Column(
              children: [
                ListTile(
                  title: Text(chart.title),
                  subtitle: Text(chart.name),
                  trailing: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Expanded(child: PdfFullPageViewer(path: chart.path!)),
              ],
            ),
          ),
        ),
      );

  List<_SigWxChart> _charts(BriefingDocument? document) {
    final value = document;
    if (value == null) return const [];
    final charts = List<_SigWxChart>.generate(value.fileCount, (index) {
      final name = index < value.fileNames.length
          ? value.fileNames[index]
          : 'SIGWX chart ${index + 1}';
      final path = index < value.filePaths.length
          ? value.filePaths[index]
          : null;
      final validAt = _validTime(name);
      return _SigWxChart(
        name: name,
        path: path,
        validAt: validAt,
        title: validAt == null ? 'SIGWX chart ${index + 1}' : _title(validAt),
      );
    });
    charts.sort((a, b) {
      if (a.validAt == null && b.validAt == null) {
        return a.name.compareTo(b.name);
      }
      if (a.validAt == null) return 1;
      if (b.validAt == null) return -1;
      return a.validAt!.compareTo(b.validAt!);
    });
    return charts;
  }

  DateTime? _validTime(String name) {
    final match = RegExp(
      r'(\d{2}):(\d{2})\s+(\d{2})(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(\d{2})',
      caseSensitive: false,
    ).firstMatch(name);
    if (match == null) return null;
    const months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final month = months.indexOf(match.group(4)!.toUpperCase()) + 1;
    return DateTime.utc(
      2000 + int.parse(match.group(5)!),
      month,
      int.parse(match.group(3)!),
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
  }

  String _title(DateTime date) {
    const months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} · $hour:$minute UTC';
  }
}

class _SigWxChart {
  const _SigWxChart({
    required this.name,
    required this.path,
    required this.validAt,
    required this.title,
  });
  final String name;
  final String? path;
  final DateTime? validAt;
  final String title;
}

class _FlightTimeCard extends StatelessWidget {
  const _FlightTimeCard({required this.flight});
  final FlightBriefing flight;

  @override
  Widget build(BuildContext context) {
    final scheduledMinutes = _minutes(flight.scheduledFlightTime);
    final planMinutes = _minutes(flight.flightPlanTime);
    final difference = scheduledMinutes == null || planMinutes == null
        ? null
        : planMinutes - scheduledMinutes;
    final eta = _estimatedArrival(difference);
    final status = _arrivalStatus(difference);
    final statusColor = difference == null
        ? const Color(0xFF667069)
        : difference <= 0
        ? const Color(0xFF28634A)
        : const Color(0xFFB93B3B);

    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(child: _time('SCH', flight.scheduledFlightTime)),
            Container(width: 1, height: 34, color: const Color(0xFFE2E7E4)),
            Expanded(child: _time('FP', flight.flightPlanTime)),
            Container(width: 1, height: 34, color: const Color(0xFFE2E7E4)),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Text(
                    'Estimated arrival · local',
                    style: TextStyle(color: Color(0xFF667069), fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    eta,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _time(String label, String value) => Column(
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF667069))),
      const SizedBox(height: 2),
      Text(
        _duration(value),
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
      ),
    ],
  );

  int? _minutes(String value) {
    final match = RegExp(r'^(\d{1,2})[.:](\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
  }

  String _estimatedArrival(int? difference) {
    if (difference == null) return 'Pending';
    final match = RegExp(
      r'^(\d{2}):?(\d{2})(\+?)$',
    ).firstMatch(flight.arrivalTime.trim());
    if (match == null) return 'Pending';
    final scheduledDay = match.group(3)!.isEmpty ? 0 : 1;
    final total =
        scheduledDay * 1440 +
        int.parse(match.group(1)!) * 60 +
        int.parse(match.group(2)!) +
        difference;
    final day = total ~/ 1440;
    final clockMinutes = total.remainder(1440);
    final hour = (clockMinutes ~/ 60).toString().padLeft(2, '0');
    final minute = (clockMinutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute${day > 0 ? ' +$day' : ''}';
  }

  String _arrivalStatus(int? difference) {
    if (difference == null) return 'Comparison pending';
    if (difference == 0) return 'On schedule';
    final amount = difference.abs();
    final duration = amount >= 60
        ? '${amount ~/ 60}h ${amount % 60}m'
        : '${amount}m';
    return difference < 0 ? '$duration early' : '$duration late';
  }

  String _duration(String value) {
    final match = RegExp(r'^(\d{1,2})[.:](\d{2})$').firstMatch(value);
    return match == null
        ? (value.isEmpty ? 'Pending' : value)
        : '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }
}

class _BriefingFlightTile extends StatefulWidget {
  const _BriefingFlightTile({required this.flight});
  final FlightBriefing flight;
  @override
  State<_BriefingFlightTile> createState() => _BriefingFlightTileState();
}

class _BriefingFlightTileState extends State<_BriefingFlightTile> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flight;
    final d = f.flightDate;
    final date = d == null
        ? 'Date pending'
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final passed =
        f.scheduledDepartureUtc?.isBefore(DateTime.now().toUtc()) ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF244A73),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.callsign.isEmpty ? f.flightNumber : f.callsign,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$date · ${f.route}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'STD ${_clock(f.departureTime)} local / ${_clock(f.departureTimeUtc)} UTC\nSTA ${_clock(f.arrivalTime)} local / ${_clock(f.arrivalTimeUtc)} UTC',
                  style: const TextStyle(
                    color: Color(0xFFDCE8F3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: passed
                        ? const Color(0xFFB93B3B)
                        : const Color(0xFF28634A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _countdown(f.scheduledDepartureUtc),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text('PLAN ID', style: TextStyle(color: Color(0xFFDCE8F3))),
              Text(
                f.planId.isEmpty ? '—' : f.planId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _clock(String value) {
    final m = RegExp(r'^(\d{2})(\d{2})(\+?)$').firstMatch(value);
    return m == null
        ? (value.isEmpty ? 'Pending' : value)
        : '${m.group(1)}:${m.group(2)}${m.group(3)}';
  }

  String _countdown(DateTime? value) {
    if (value == null) return 'STD countdown pending';
    final d = value.difference(DateTime.now().toUtc());
    final a = d.abs();
    final text = '${a.inHours}h ${a.inMinutes.remainder(60)}m';
    return d.isNegative ? 'STD passed $text ago' : 'STD in $text';
  }
}
