import 'dart:async';

import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';

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
    final weather = _has(current, BriefingDocumentType.weather);
    final sigWx = _document(current, BriefingDocumentType.significantWeather);
    final notams = _has(current, BriefingDocumentType.notams);
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
                subtitle: '${route.$1}\nAt STD',
                icon: Icons.flight_takeoff_rounded,
                available: weather,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'En-route WX',
                subtitle: 'SIGWX\ncharts',
                icon: Icons.thunderstorm_outlined,
                available: sigWx != null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'Arrival WX',
                subtitle: '${route.$2}\nAt STA',
                icon: Icons.flight_land_rounded,
                available: weather,
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
                subtitle: '${route.$1}\nNOTAMs',
                icon: Icons.flight_takeoff_rounded,
                available: notams,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'En-route',
                subtitle: 'FIR and route\nNOTAMs',
                icon: Icons.route_outlined,
                available: notams,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusBlock(
                title: 'Arrival',
                subtitle: '${route.$2}\nNOTAMs',
                icon: Icons.flight_land_rounded,
                available: notams,
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
  bool _has(FlightBriefing flight, BriefingDocumentType type) =>
      flight.documents.any((item) => item.type == type);
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
  Widget build(BuildContext context) => Card(
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
                  '${flight.flightDeckCount} flight deck',
                  [
                    'Captain ${_name(flight.captain)}',
                    'FO ${_name(flight.firstOfficer)}',
                    if (flight.reliefPilot.isNotEmpty)
                      'Relief ${flight.reliefPilot}',
                    if (flight.otherCrew.isNotEmpty) flight.otherCrew,
                  ].join(' · '),
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
            height: 145,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFB93B3B),
                      size: 42,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SIGWX chart ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PDF preview',
                      style: TextStyle(color: Color(0xFF667069), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FlightTimeCard extends StatelessWidget {
  const _FlightTimeCard({required this.flight});
  final FlightBriefing flight;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _time('SCH', flight.scheduledFlightTime)),
          const Icon(Icons.compare_arrows_rounded, color: Color(0xFF667069)),
          Expanded(child: _time('FP flight time', flight.flightPlanTime)),
        ],
      ),
    ),
  );
  Widget _time(String label, String value) => Column(
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF667069))),
      const SizedBox(height: 4),
      Text(
        _duration(value),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
    ],
  );
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
