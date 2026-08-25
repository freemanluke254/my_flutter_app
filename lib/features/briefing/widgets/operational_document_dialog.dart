import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import '../services/pdf_document_reader.dart';
import '../services/terrain_scenario_decoder.dart';
import '../services/track_message_decoder.dart';

class OperationalDocumentDialog extends StatefulWidget {
  const OperationalDocumentDialog({
    required this.name,
    required this.path,
    required this.type,
    super.key,
  });

  final String name;
  final String path;
  final BriefingDocumentType type;

  @override
  State<OperationalDocumentDialog> createState() =>
      _OperationalDocumentDialogState();
}

class _OperationalDocumentDialogState extends State<OperationalDocumentDialog> {
  late final Future<String> _text = const PdfDocumentReader().extractText(
    widget.path,
  );
  bool _raw = false;

  bool get _isTerrain => widget.type == BriefingDocumentType.terrain;

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 820),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _isTerrain ? Icons.terrain_rounded : Icons.public_rounded,
            ),
            title: Text(widget.name),
            subtitle: Text(_isTerrain ? 'Terrain scenario' : 'Track message'),
            trailing: IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('RAW')),
                ButtonSegment(value: false, label: Text('Decoded')),
              ],
              selected: {_raw},
              onSelectionChanged: (selection) =>
                  setState(() => _raw = selection.first),
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
                final text = snapshot.data ?? '';
                if (_raw) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(text),
                  );
                }
                return _isTerrain
                    ? _TerrainDecodedView(source: text)
                    : _TrackDecodedView(source: text);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _TrackDecodedView extends StatelessWidget {
  const _TrackDecodedView({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    final decoded = const TrackMessageDecoder().decode(source);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _Notice(
          text:
              'Decoded for easier review. Confirm route, levels and remarks against the original track message.',
        ),
        _SummaryCard(
          title: decoded.title,
          rows: {
            'Validity': decoded.validity,
            if (decoded.flightLevels.isNotEmpty)
              'Flight levels': decoded.flightLevels,
          },
        ),
        if (decoded.tracks.isEmpty)
          const _Notice(text: 'No standard NAT track blocks were identified.'),
        for (final track in decoded.tracks)
          Card(
            elevation: 0,
            color: const Color(0xFFEAF3FA),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track ${track.designator}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    track.route,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  _detail('Eastbound levels', track.eastLevels),
                  _detail('Westbound levels', track.westLevels),
                  _detail('European route', track.europeanRoute),
                  _detail('North American route', track.northAmericanRoute),
                ],
              ),
            ),
          ),
        for (final group in decoded.informationGroups)
          _TrackInformationCard(group: group),
      ],
    );
  }
}

class _TrackInformationCard extends StatelessWidget {
  const _TrackInformationCard({required this.group});
  final DecodedTrackInformationGroup group;

  @override
  Widget build(BuildContext context) {
    final colours = _colours();
    return Card(
      elevation: 0,
      color: colours.$1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colours.$2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title,
              style: TextStyle(
                color: colours.$3,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            for (final item in group.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectableText.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF202522),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: '${item.label}: ',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: item.value),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  (Color, Color, Color) _colours() => switch (group.title) {
    'Flight and package details' => (
      const Color(0xFFE8EEF6),
      const Color(0xFF9BB1CB),
      const Color(0xFF315F86),
    ),
    'Operational requirements and remarks' => (
      const Color(0xFFFFF1DA),
      const Color(0xFFE3B96F),
      const Color(0xFF8A5B13),
    ),
    'PACOTS message details' => (
      const Color(0xFFE9F3F2),
      const Color(0xFF8CC3BE),
      const Color(0xFF287A78),
    ),
    'PACOTS routes' => (
      const Color(0xFFEDE7F6),
      const Color(0xFFBAA3D5),
      const Color(0xFF704C9F),
    ),
    'TDM tracks' => (
      const Color(0xFFE5F0F8),
      const Color(0xFF9EC2DC),
      const Color(0xFF356D9E),
    ),
    _ => (
      const Color(0xFFF0F2F1),
      const Color(0xFFC6CECA),
      const Color(0xFF59645E),
    ),
  };
}

class _TerrainDecodedView extends StatelessWidget {
  const _TerrainDecodedView({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    final decoded = const TerrainScenarioDecoder().decode(source);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _Notice(
          text:
              'Operational safety data: verify every diversion, altitude and terrain figure against the original company TERRA document.',
          warning: true,
        ),
        _SummaryCard(
          title: decoded.title,
          rows: {
            'Flight': decoded.flight,
            'Route': decoded.route,
            'Aircraft': decoded.registrationAndType,
            'STD': decoded.scheduledDeparture,
            'STA': decoded.scheduledArrival,
            'Flight time': decoded.flightTime,
            'Variant / rating': decoded.variantAndRating,
            'Forecast validity': decoded.forecastValidity,
            'Scenario': decoded.scenarioRoute,
          },
        ),
        if (decoded.segments.isEmpty)
          const _Notice(text: 'No terrain scenario segments were identified.'),
        for (final segment in decoded.segments)
          Card(
            elevation: 0,
            color: segment.isCritical
                ? const Color(0xFFFFF0D9)
                : const Color(0xFFE7F4EA),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    segment.heading,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    segment.isCritical
                        ? 'CRITICAL TERRAIN SEGMENT'
                        : 'TERRAIN NOT CRITICAL',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: segment.isCritical
                          ? const Color(0xFF9B4A00)
                          : const Color(0xFF23733A),
                    ),
                  ),
                  if (segment.isCritical) ...[
                    const SizedBox(height: 10),
                    Text(
                      'ENTRY AND EXIT POINTS',
                      style: TextStyle(
                        color: const Color(0xFF9B4A00),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _detail('Entry point', segment.entryPoint),
                    _detail('Exit point', segment.exitPoint),
                    const Divider(height: 22),
                    const Text(
                      'RESOLVER INFORMATION',
                      style: TextStyle(
                        color: Color(0xFF9B4A00),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  _detail(
                    'Emergency-descent diversion',
                    segment.emergencyDescentDiversion,
                  ),
                  _detail(
                    'One-engine-out diversion',
                    segment.engineOutDiversion,
                  ),
                  _detail('Maximum terrain', segment.maximumTerrain),
                  _detail('Engine anti-ice', segment.engineAntiIce),
                  _detail('MEL restrictions', segment.melRestriction),
                  for (final line in segment.additionalInformation)
                    _detail('Additional instruction', line),
                ],
              ),
            ),
          ),
        if (decoded.additionalInformation.isNotEmpty)
          _TextLinesCard(
            title: 'Flight and source information',
            lines: decoded.additionalInformation,
          ),
      ],
    );
  }
}

Widget _detail(String label, String value) => value.isEmpty
    ? const SizedBox.shrink()
    : Padding(
        padding: const EdgeInsets.only(top: 7),
        child: SelectableText.rich(
          TextSpan(
            style: const TextStyle(color: Color(0xFF202522), height: 1.35),
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(text: value),
            ],
          ),
        ),
      );

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.rows});
  final String title;
  final Map<String, String> rows;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          for (final row in rows.entries) _detail(row.key, row.value),
        ],
      ),
    ),
  );
}

class _TextLinesCard extends StatelessWidget {
  const _TextLinesCard({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SelectableText(line),
            ),
        ],
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: warning ? const Color(0xFFFFE9E3) : const Color(0xFFE9F2FA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(warning ? Icons.warning_amber_rounded : Icons.info_outline),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
