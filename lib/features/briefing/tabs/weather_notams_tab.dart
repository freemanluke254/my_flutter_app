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
        ),
        _DocumentSection(
          title: 'Departure, en-route and arrival NOTAMs',
          subtitle: '${route.$1} · route/FIR · ${route.$2}',
          icon: Icons.campaign_outlined,
          document: _document(BriefingDocumentType.notams),
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
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final BriefingDocument? document;
  final bool charts;

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
        builder: (context) => _PdfTextDialog(name: name, path: path),
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

class _PdfTextDialog extends StatefulWidget {
  const _PdfTextDialog({required this.name, required this.path});
  final String name;
  final String path;
  @override
  State<_PdfTextDialog> createState() => _PdfTextDialogState();
}

class _PdfTextDialogState extends State<_PdfTextDialog> {
  late final Future<String> _text = const PdfDocumentReader().extractText(
    widget.path,
  );
  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.name),
            subtitle: const Text('Extracted from the loaded PDF'),
            trailing: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: SelectableText(snapshot.data ?? 'No text found.'),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
