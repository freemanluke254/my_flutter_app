import 'dart:async';

import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';
import '../widgets/pdf_preview_thumbnail.dart';

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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _heading(context),
        const SizedBox(height: 14),
        _BriefingFlightTile(flight: current),
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
                subtitle:
                    '${route.$1} at STD\n${weather?.fileCount ?? 0} file${weather?.fileCount == 1 ? '' : 's'} loaded',
                icon: Icons.flight_takeoff_rounded,
                available: weather != null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'En-route WX',
                subtitle:
                    '${sigWx?.fileCount ?? 0} SIGWX chart${sigWx?.fileCount == 1 ? '' : 's'}\nloaded',
                icon: Icons.thunderstorm_outlined,
                available: sigWx != null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'Arrival WX',
                subtitle:
                    '${route.$2} at STA\n${weather?.fileCount ?? 0} file${weather?.fileCount == 1 ? '' : 's'} loaded',
                icon: Icons.flight_land_rounded,
                available: weather != null,
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
                subtitle:
                    '${route.$1}\n${notams?.fileCount ?? 0} file${notams?.fileCount == 1 ? '' : 's'} loaded',
                icon: Icons.flight_takeoff_rounded,
                available: notams != null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'En-route',
                subtitle:
                    'FIR and route\n${notams?.fileCount ?? 0} file${notams?.fileCount == 1 ? '' : 's'} loaded',
                icon: Icons.route_outlined,
                available: notams != null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'Arrival',
                subtitle:
                    '${route.$2}\n${notams?.fileCount ?? 0} file${notams?.fileCount == 1 ? '' : 's'} loaded',
                icon: Icons.flight_land_rounded,
                available: notams != null,
              ),
            ),
          ],
        ),
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
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final bool available;
  @override
  Widget build(BuildContext context) => Container(
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
          color: available ? const Color(0xFF28634A) : const Color(0xFFBD7A17),
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
          color: available ? const Color(0xFF28634A) : const Color(0xFFBD7A17),
        ),
      ],
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
                return Container(
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
                );
              },
            ),
          ),
      ],
    );
  }

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
