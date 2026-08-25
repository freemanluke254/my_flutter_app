import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import '../services/aviation_weather_decoder.dart';
import '../services/pdf_document_reader.dart';
import '../widgets/pdf_full_page_viewer.dart';

enum BriefingDocumentContentType { weather, notam, other }

Future<void> showBriefingDocuments(
  BuildContext context, {
  required BriefingDocument? document,
  List<String> airportCodes = const [],
  BriefingDocumentContentType contentType = BriefingDocumentContentType.other,
  bool charts = false,
  bool includeOtherSections = false,
  DateTime? relevanceStart,
  DateTime? relevanceEnd,
  String? relevanceLocalWindow,
}) async {
  final value = document;
  if (value == null || value.fileCount == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No matching documents are loaded.')),
    );
    return;
  }
  final selected = value.fileCount == 1
      ? 0
      : await showDialog<int>(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: Text(value.title),
            children: List.generate(value.fileCount, (index) {
              final name = index < value.fileNames.length
                  ? value.fileNames[index]
                  : '${value.title} ${index + 1}';
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, index),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: Text(name),
                  trailing: const Icon(Icons.open_in_new_rounded),
                ),
              );
            }),
          ),
        );
  if (selected == null || !context.mounted) return;
  final name = selected < value.fileNames.length
      ? value.fileNames[selected]
      : '${value.title} ${selected + 1}';
  final path = selected < value.filePaths.length
      ? value.filePaths[selected]
      : null;
  if (path == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reupload this document to open it.')),
    );
    return;
  }
  if (charts) {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
          child: Column(
            children: [
              ListTile(
                title: Text(name),
                trailing: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Expanded(child: PdfFullPageViewer(path: path)),
            ],
          ),
        ),
      ),
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) => _PdfTextDialog(
      name: name,
      path: path,
      airportCodes: airportCodes,
      contentType: contentType,
      includeOtherSections: includeOtherSections,
      relevanceStart: relevanceStart,
      relevanceEnd: relevanceEnd,
      relevanceLocalWindow: relevanceLocalWindow,
    ),
  );
}

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
          contentType: BriefingDocumentContentType.weather,
        ),
        _DocumentSection(
          title: 'Departure, en-route and arrival NOTAMs',
          subtitle: '${route.$1} · route/FIR · ${route.$2}',
          icon: Icons.campaign_outlined,
          document: _document(BriefingDocumentType.notams),
          airportCodes: [route.$1, route.$2],
          contentType: BriefingDocumentContentType.notam,
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
    this.contentType = BriefingDocumentContentType.other,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final BriefingDocument? document;
  final bool charts;
  final List<String> airportCodes;
  final BriefingDocumentContentType contentType;

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
                Expanded(child: PdfFullPageViewer(path: path)),
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
  const _PdfTextDialog({
    required this.name,
    required this.path,
    required this.airportCodes,
    required this.contentType,
    this.includeOtherSections = false,
    this.relevanceStart,
    this.relevanceEnd,
    this.relevanceLocalWindow,
  });
  final String name;
  final String path;
  final List<String> airportCodes;
  final BriefingDocumentContentType contentType;
  final bool includeOtherSections;
  final DateTime? relevanceStart;
  final DateTime? relevanceEnd;
  final String? relevanceLocalWindow;
  @override
  State<_PdfTextDialog> createState() => _PdfTextDialogState();
}

class _PdfTextDialogState extends State<_PdfTextDialog> {
  late final Future<String> _text = const PdfDocumentReader().extractText(
    widget.path,
  );
  bool _raw = false;

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
          if (widget.contentType != BriefingDocumentContentType.other)
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
                  child: _raw
                      ? SelectableText(displayText)
                      : _DecodedContentView(
                          text: displayText,
                          contentType: widget.contentType,
                        ),
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
    final relevantCodes = widget.airportCodes.toSet();
    final starts = RegExp(
      r'^([A-Z]{4})\s*(?:-|/)',
      multiLine: true,
    ).allMatches(text).toList();
    final sections = <String>[];
    for (var index = 0; index < starts.length; index++) {
      final code = starts[index].group(1)!;
      final selected = widget.includeOtherSections
          ? !relevantCodes.contains(code)
          : relevantCodes.contains(code);
      if (!selected) continue;
      final end = index + 1 < starts.length
          ? starts[index + 1].start
          : text.length;
      sections.add(text.substring(starts[index].start, end).trim());
    }
    if (sections.isEmpty) {
      final scope = widget.includeOtherSections
          ? 'en-route or alternate'
          : widget.airportCodes.join(' or ');
      return 'No $scope section was found in this document.\n\n$text';
    }
    return sections.join('\n\n────────────────────\n\n');
  }

  String _decodedText(String raw) {
    if (widget.contentType == BriefingDocumentContentType.notam) {
      return _categorisedNotams(raw);
    }
    return const AviationWeatherDecoder().decodeDocument(raw);
  }

  String _categorisedNotams(String raw) {
    final matches = RegExp(
      r'(?=^[A-Z]{4}[A-Z]\d{4}/\d{2}\b)',
      multiLine: true,
    ).allMatches(raw).toList();
    if (matches.isEmpty) return raw;
    final grouped = <String, List<String>>{};
    var excluded = 0;
    var ambiguous = 0;
    for (var index = 0; index < matches.length; index++) {
      final end = index + 1 < matches.length
          ? matches[index + 1].start
          : raw.length;
      final entry = raw.substring(matches[index].start, end).trim();
      final relevance = _relevance(entry);
      if (relevance == _NotamRelevance.outsideFlightWindow) {
        excluded++;
        continue;
      }
      if (relevance == _NotamRelevance.ambiguous) ambiguous++;
      (grouped[_notamCategory(entry)] ??= []).add(_formatNotam(entry));
    }
    const order = <String>[
      'Runways',
      'Taxiways, aprons and stands',
      'SIDs and departures',
      'STARs and arrivals',
      'Approaches',
      'Navigation and communications',
      'Airspace and FIR',
      'Aerodrome facilities',
      'Other operational NOTAMs',
    ];
    final categories = order
        .where((category) => grouped[category]?.isNotEmpty == true)
        .map(
          (category) =>
              '$category (${grouped[category]!.length})\n${'─' * 34}\n${grouped[category]!.join('\n\n')}',
        )
        .join('\n\n══════════════════════════════════\n\n');
    final summary = [
      'Flight-relevance filter',
      if (excluded > 0)
        '$excluded notice${excluded == 1 ? '' : 's'} outside the operational window hidden',
      if (ambiguous > 0)
        '$ambiguous notice${ambiguous == 1 ? '' : 's'} retained because validity could not be proven',
      'Window: STD −2 hours to STA +2 hours',
      if (widget.relevanceStart != null && widget.relevanceEnd != null)
        'UTC: ${_utc(widget.relevanceStart!)} – ${_utc(widget.relevanceEnd!)}',
      if (widget.relevanceLocalWindow != null)
        'Local: ${widget.relevanceLocalWindow}',
      'Scope: selected airport/FIR sections from the uploaded flight package',
    ].join('\n');
    return '$summary\n\n══════════════════════════════════\n\n$categories';
  }

  String _utc(DateTime value) {
    final utc = value.toUtc();
    return '${utc.day.toString().padLeft(2, '0')}/${utc.month.toString().padLeft(2, '0')} ${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}Z';
  }

  _NotamRelevance _relevance(String entry) {
    final relevanceStart = widget.relevanceStart;
    final relevanceEnd = widget.relevanceEnd;
    if (relevanceStart == null || relevanceEnd == null) {
      return _NotamRelevance.ambiguous;
    }
    final match = RegExp(
      r'(\d{2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{4})\s+(\d{2}):(\d{2})\s*-\s*(\d{2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{4})\s+(\d{2}):(\d{2})',
      caseSensitive: false,
    ).firstMatch(entry);
    if (match == null) return _NotamRelevance.ambiguous;
    final start = _notamDate(match, 1);
    final end = _notamDate(match, 6);
    return !end.isAfter(relevanceStart) || !start.isBefore(relevanceEnd)
        ? _NotamRelevance.outsideFlightWindow
        : _NotamRelevance.relevant;
  }

  DateTime _notamDate(RegExpMatch match, int offset) {
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
    return DateTime.utc(
      int.parse(match.group(offset + 2)!),
      months.indexOf(match.group(offset + 1)!.toUpperCase()) + 1,
      int.parse(match.group(offset)!),
      int.parse(match.group(offset + 3)!),
      int.parse(match.group(offset + 4)!),
    );
  }

  String _notamCategory(String entry) {
    final value = entry.toUpperCase();
    if (RegExp(r'\b(SID|DEPARTURE)\b').hasMatch(value)) {
      return 'SIDs and departures';
    }
    if (RegExp(r'\b(STAR|ARRIVAL)\b').hasMatch(value)) {
      return 'STARs and arrivals';
    }
    if (RegExp(r'\b(IAP|APPROACH|ILS|RNP|RNAV APP)\b').hasMatch(value)) {
      return 'Approaches';
    }
    if (RegExp(r'\b(TWY|TAXIWAY|APRON|STAND|GATE)\b').hasMatch(value)) {
      return 'Taxiways, aprons and stands';
    }
    if (RegExp(r'\b(RWY|RUNWAY)\b').hasMatch(value)) return 'Runways';
    if (RegExp(r'\b(VOR|DME|NDB|FREQ|CPDLC|COM|NAV)\b').hasMatch(value)) {
      return 'Navigation and communications';
    }
    if (RegExp(
      r'\b(FIR|AIRSPACE|RESTRICTED AREA|UAS|UAV|DRONE|ATS ROUTE)\b',
    ).hasMatch(value)) {
      return 'Airspace and FIR';
    }
    if (RegExp(
      r'\b(AD |AERODROME|TERMINAL|LIGHT|RFFS|FIRE)\b',
    ).hasMatch(value)) {
      return 'Aerodrome facilities';
    }
    return 'Other operational NOTAMs';
  }

  String _formatNotam(String entry) {
    var decoded = entry
        .replaceAll(' E)', '\nDetails: ')
        .replaceAll(' D)', '\nSchedule: ')
        .replaceAll(' F)', '\nLower limit: ')
        .replaceAll(' G)', '\nUpper limit: ');
    const contractions = <String, String>{
      'ABV': 'above',
      'ACFT': 'aircraft',
      'ACT': 'active',
      'AD': 'aerodrome',
      'AGL': 'above ground level',
      'ALTN': 'alternate',
      'APCH': 'approach',
      'ARR': 'arrival',
      'AUTH': 'authorised',
      'AVBL': 'available',
      'BLW': 'below',
      'BTN': 'between',
      'CLSD': 'closed',
      'COM': 'communications',
      'CTC': 'contact',
      'DLA': 'delay',
      'DLY': 'daily',
      'EXC': 'except',
      'FREQ': 'frequency',
      'FLT': 'flight',
      'FM': 'from',
      'H24': 'continuous day and night service',
      'INOP': 'inoperative',
      'MAINT': 'maintenance',
      'NAV': 'navigation',
      'OPR': 'operating',
      'PPR': 'prior permission required',
      'RMK': 'remark',
      'RTE': 'route',
      'RWY': 'runway',
      'SFC': 'surface',
      'TFC': 'traffic',
      'TWR': 'tower',
      'TWY': 'taxiway',
      'U/S': 'unserviceable',
      'WI': 'within',
      'WIP': 'work in progress',
      'WEF': 'with effect from',
    };
    for (final item in contractions.entries) {
      decoded = decoded.replaceAll(
        RegExp('(?<![A-Z0-9/])${RegExp.escape(item.key)}(?![A-Z0-9/])'),
        item.value,
      );
    }
    return decoded.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}

enum _NotamRelevance { relevant, outsideFlightWindow, ambiguous }

class _DecodedContentView extends StatelessWidget {
  const _DecodedContentView({required this.text, required this.contentType});
  final String text;
  final BriefingDocumentContentType contentType;

  @override
  Widget build(BuildContext context) {
    final sections = text
        .split(RegExp(r'\n\n═{10,}\n\n'))
        .where((section) => section.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(sections.length, (index) {
        final section = sections[index].trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: contentType == BriefingDocumentContentType.weather
              ? _weatherCard(section, index)
              : _notamCard(section),
        );
      }),
    );
  }

  Widget _weatherCard(String section, int index) {
    String? heading;
    var body = section;
    if (section.startsWith('AIRPORT ·')) {
      final lineEnd = section.indexOf('\n');
      heading = lineEnd < 0 ? section : section.substring(0, lineEnd);
      body = lineEnd < 0 ? '' : section.substring(lineEnd).trim();
    }
    final parts = body
        .split(RegExp(r'\n\n─{10,}\n\n'))
        .where((part) => part.trim().isNotEmpty);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFF0F2F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heading != null) ...[
            Text(
              heading,
              style: const TextStyle(
                color: Color(0xFF173E67),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...parts.map((part) {
            final taf = part.trimLeft().startsWith('FORECAST');
            final colour = taf
                ? const Color(0xFFEDE6F7)
                : const Color(0xFFE2F0F7);
            final accent = taf
                ? const Color(0xFF704C9F)
                : const Color(0xFF216487);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: accent, width: 4)),
              ),
              child: _labelledText(part.trim(), boldFirstLine: true),
            );
          }),
        ],
      ),
    );
  }

  Widget _notamCard(String section) {
    final title = section.split('\n').first;
    final colour = _notamColour(title);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colour.$1,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: colour.$2, width: 5)),
      ),
      child: _labelledText(section, boldFirstLine: true),
    );
  }

  Widget _labelledText(String value, {bool boldFirstLine = false}) {
    final lines = value.split('\n');
    final spans = <InlineSpan>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (boldFirstLine && index == 0) {
        spans.add(
          TextSpan(
            text: line,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      } else {
        final separator = line.indexOf(':');
        if (separator > 0 && separator < 32) {
          spans.add(
            TextSpan(
              text: line.substring(0, separator + 1),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          );
          spans.add(TextSpan(text: line.substring(separator + 1)));
        } else if (RegExp(r'^[A-Z]{4}[A-Z]\d{4}/\d{2}\b').hasMatch(line)) {
          spans.add(
            TextSpan(
              text: line,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          );
        } else {
          spans.add(TextSpan(text: line));
        }
      }
      if (index < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(
          color: Color(0xFF202522),
          height: 1.4,
          fontSize: 14,
        ),
        children: spans,
      ),
    );
  }

  (Color, Color) _notamColour(String title) {
    if (title.startsWith('Runways')) {
      return (const Color(0xFFFBE7E5), const Color(0xFFB9473D));
    }
    if (title.startsWith('Taxiways')) {
      return (const Color(0xFFFFF3D8), const Color(0xFFB97918));
    }
    if (title.startsWith('SIDs')) {
      return (const Color(0xFFE2EEF9), const Color(0xFF356D9E));
    }
    if (title.startsWith('STARs')) {
      return (const Color(0xFFE6F3EC), const Color(0xFF34785A));
    }
    if (title.startsWith('Approaches')) {
      return (const Color(0xFFEDE6F7), const Color(0xFF704C9F));
    }
    if (title.startsWith('Airspace')) {
      return (const Color(0xFFE2F3F2), const Color(0xFF287A78));
    }
    if (title.startsWith('Navigation')) {
      return (const Color(0xFFE8ECF5), const Color(0xFF4D638E));
    }
    return (const Color(0xFFF0F2F1), const Color(0xFF737C77));
  }
}
