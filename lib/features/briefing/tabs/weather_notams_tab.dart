import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import '../services/pdf_document_reader.dart';
import '../widgets/pdf_preview_thumbnail.dart';

class WeatherNotamsTab extends StatelessWidget {
  const WeatherNotamsTab({required this.flight, super.key});
  final FlightBriefing? flight;

  @override
  Widget build(BuildContext context) {
    final route = _route(flight?.route ?? '');
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'WX & NOTAMs',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          flight == null
              ? 'Select a flight to review its package.'
              : '${route.$1} → ${route.$2} · tap a document to open it',
          style: const TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 18),
        _DocumentSection(
          title: 'Departure and arrival weather',
          subtitle: '${route.$1} at STD · ${route.$2} at STA',
          icon: Icons.cloud_outlined,
          document: _document(BriefingDocumentType.weather),
          airportCodes: [route.$1, route.$2],
          contentType: _ContentType.weather,
        ),
        _DocumentSection(
          title: 'Departure, en-route and arrival NOTAMs',
          subtitle: '${route.$1} · route/FIR · ${route.$2}',
          icon: Icons.campaign_outlined,
          document: _document(BriefingDocumentType.notams),
          airportCodes: [route.$1, route.$2],
          contentType: _ContentType.notam,
        ),
        _DocumentSection(
          title: 'En-route significant weather',
          subtitle: 'Charts are ordered by valid UTC time in Briefing',
          icon: Icons.thunderstorm_outlined,
          document: _document(BriefingDocumentType.significantWeather),
          charts: true,
        ),
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Operational note: extracted text is a briefing aid. Always verify weather, NOTAMs, alternates and restrictions against the original current documents.',
              style: TextStyle(color: Color(0xFF667069), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  BriefingDocument? _document(BriefingDocumentType type) =>
      flight?.documents.where((item) => item.type == type).firstOrNull;
  (String, String) _route(String value) {
    final parts = value.split(RegExp(r'\s*[→–-]\s*'));
    return (parts.firstOrNull ?? 'DEP', parts.length > 1 ? parts.last : 'ARR');
  }
}

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.document,
    this.charts = false,
    this.airportCodes = const [],
    this.contentType = _ContentType.other,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final BriefingDocument? document;
  final bool charts;
  final List<String> airportCodes;
  final _ContentType contentType;

  @override
  Widget build(BuildContext context) {
    final value = document;
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF244A73)),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF667069),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (value == null || value.fileCount == 0)
              const Text('No matching documents loaded.')
            else
              ...List.generate(value.fileCount, (index) {
                final name = index < value.fileNames.length
                    ? value.fileNames[index]
                    : '${value.title} ${index + 1}';
                final path = index < value.filePaths.length
                    ? value.filePaths[index]
                    : null;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: Text(name, maxLines: 2),
                  subtitle: Text(
                    charts ? 'Open chart preview' : 'Read PDF text',
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: path == null
                      ? () => _missingPath(context)
                      : () => charts
                            ? _showChart(context, name, path)
                            : _showText(context, name, path),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showText(BuildContext context, String name, String path) =>
      showDialog<void>(
        context: context,
        builder: (context) => _PdfTextDialog(
          name: name,
          path: path,
          airportCodes: airportCodes,
          contentType: contentType,
        ),
      );
  Future<void> _showChart(BuildContext context, String name, String path) =>
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
            child: Column(
              children: [
                ListTile(
                  title: Text(name),
                  trailing: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Expanded(child: PdfPreviewThumbnail(path: path)),
              ],
            ),
          ),
        ),
      );
  void _missingPath(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reupload this document to open it.')),
      );
}

enum _ContentType { weather, notam, other }

class _PdfTextDialog extends StatefulWidget {
  const _PdfTextDialog({
    required this.name,
    required this.path,
    required this.airportCodes,
    required this.contentType,
  });
  final String name;
  final String path;
  final List<String> airportCodes;
  final _ContentType contentType;
  @override
  State<_PdfTextDialog> createState() => _PdfTextDialogState();
}

class _PdfTextDialogState extends State<_PdfTextDialog> {
  late final Future<String> _text = const PdfDocumentReader().extractText(
    widget.path,
  );
  bool _raw = true;
  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.name),
            subtitle: Text(
              widget.airportCodes.isEmpty
                  ? 'Extracted from the loaded PDF'
                  : 'Showing ${widget.airportCodes.join(' and ')} sections',
            ),
            trailing: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          if (widget.contentType != _ContentType.other)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('RAW')),
                  ButtonSegment(value: false, label: Text('Decoded')),
                ],
                selected: {_raw},
                onSelectionChanged: (value) =>
                    setState(() => _raw = value.first),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<String>(
              future: _text,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'This document could not be decoded. ${snapshot.error}',
                    ),
                  );
                }
                final rawText = _relevantText(snapshot.data ?? '');
                final displayText = _raw ? rawText : _decodedText(rawText);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: SelectableText(displayText),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  String _relevantText(String text) {
    if (widget.airportCodes.isEmpty) return text;
    final starts = RegExp(
      r'^([A-Z]{4})\s*(?:-|/)',
      multiLine: true,
    ).allMatches(text).toList();
    final sections = <String>[];
    for (var index = 0; index < starts.length; index++) {
      final code = starts[index].group(1)!;
      if (!widget.airportCodes.contains(code)) continue;
      final end = index + 1 < starts.length
          ? starts[index + 1].start
          : text.length;
      sections.add(text.substring(starts[index].start, end).trim());
    }
    if (sections.isEmpty) {
      return 'No ${widget.airportCodes.join(' or ')} section was found in this document.\n\n$text';
    }
    return sections.join('\n\n────────────────────\n\n');
  }

  String _decodedText(String raw) {
    if (widget.contentType == _ContentType.notam) {
      return raw
          .replaceAll(RegExp(r'\n(?=[A-Z0-9])'), ' ')
          .replaceAll(RegExp(r'(?=\b[A-Z]{4}[A-Z]\d{4}/\d{2}\b)'), '\n\nNOTAM ')
          .replaceAll(' E)', '\nDetails: ')
          .replaceAll(' D)', '\nSchedule: ')
          .replaceAll(' F)', '\nLower limit: ')
          .replaceAll(' G)', '\nUpper limit: ')
          .trim();
    }
    return raw
        .replaceAllMapped(
          RegExp(r'\bMETAR\s+([^=]+)=', dotAll: true),
          (match) => 'OBSERVATION (METAR)\n${match.group(1)!.trim()}\n',
        )
        .replaceAllMapped(
          RegExp(r'\bTAF\s+([^=]+)=', dotAll: true),
          (match) => 'FORECAST (TAF)\n${match.group(1)!.trim()}\n',
        )
        .replaceAllMapped(
          RegExp(r'\b(\d{3}|VRB)(\d{2})(G(\d{2}))?KT\b'),
          (match) =>
              'Wind ${match.group(1)}° at ${match.group(2)} kt${match.group(4) == null ? '' : ', gusting ${match.group(4)} kt'}',
        )
        .replaceAllMapped(
          RegExp(r'\bQ(\d{4})\b'),
          (match) => 'QNH ${match.group(1)} hPa',
        )
        .replaceAllMapped(
          RegExp(r'\b(\d{2})/(M?\d{2})\b'),
          (match) =>
              'Temperature ${match.group(1)}°C, dew point ${match.group(2)!.replaceFirst('M', '-')}°C',
        );
  }
}
