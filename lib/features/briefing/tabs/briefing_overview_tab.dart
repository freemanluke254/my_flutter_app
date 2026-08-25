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
    final hasWeather = _has(current, BriefingDocumentType.weather);
    final hasSigWx = _has(current, BriefingDocumentType.significantWeather);
    final hasNotams = _has(current, BriefingDocumentType.notams);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _heading(context),
        const SizedBox(height: 6),
        Text(
          '${current.callsign.isEmpty ? current.flightNumber : current.callsign}  ·  ${current.route}',
          style: const TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 18),
        _sectionTitle(context, 'Weather overview'),
        _OverviewCard(
          icon: Icons.flight_takeoff_rounded,
          title: '${route.$1} departure weather',
          subtitle: hasWeather
              ? 'MET package loaded · Forecast for STD'
              : 'Weather document not loaded',
          available: hasWeather,
        ),
        _OverviewCard(
          icon: Icons.flight_land_rounded,
          title: '${route.$2} arrival weather',
          subtitle: hasWeather
              ? 'MET package loaded · Forecast for STA'
              : 'Weather document not loaded',
          available: hasWeather,
        ),
        _OverviewCard(
          icon: Icons.thunderstorm_outlined,
          title: 'En-route weather',
          subtitle: hasSigWx
              ? 'Significant-weather charts available'
              : 'Significant-weather document not loaded',
          available: hasSigWx,
        ),
        const SizedBox(height: 12),
        _sectionTitle(context, 'Flight time'),
        _FlightTimeCard(flight: current),
        const SizedBox(height: 12),
        _sectionTitle(context, 'Load and crew'),
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _loadChecker(context),
                    icon: const Icon(Icons.groups_2_outlined),
                    label: const Text('Open load checker'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'View the expected passenger load',
                  style: TextStyle(color: Color(0xFF667069)),
                ),
                const Divider(height: 28),
                _crewLine(
                  Icons.badge_outlined,
                  '${current.flightDeckCount} flight deck',
                  _flightDeckNames(current),
                ),
                const SizedBox(height: 12),
                _crewLine(
                  Icons.groups_outlined,
                  '${current.cabinCrewCount} cabin crew',
                  'FSM ${_name(current.fsm)}  ·  CSS ${_name(current.css)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _sectionTitle(context, 'NOTAM overview'),
        _OverviewCard(
          icon: Icons.flight_takeoff_rounded,
          title: '${route.$1} departure NOTAMs',
          subtitle: hasNotams
              ? 'Departure NOTAM package available'
              : 'NOTAM document not loaded',
          available: hasNotams,
        ),
        _OverviewCard(
          icon: Icons.flight_land_rounded,
          title: '${route.$2} destination NOTAMs',
          subtitle: hasNotams
              ? 'Destination NOTAM package available'
              : 'NOTAM document not loaded',
          available: hasNotams,
        ),
        _OverviewCard(
          icon: Icons.route_outlined,
          title: 'En-route NOTAMs',
          subtitle: hasNotams
              ? 'En-route and FIR NOTAM package available'
              : 'NOTAM document not loaded',
          available: hasNotams,
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
      flight.documents.any((document) => document.type == type);

  (String, String) _route(String value) {
    final parts = value.split(RegExp(r'\s*[→–-]\s*'));
    return (
      parts.firstOrNull ?? 'Departure',
      parts.length > 1 ? parts.last : 'Destination',
    );
  }

  String _flightDeckNames(FlightBriefing flight) => [
    'Captain ${_name(flight.captain)}',
    'FO ${_name(flight.firstOfficer)}',
    if (flight.reliefPilot.isNotEmpty) 'Relief ${flight.reliefPilot}',
    if (flight.otherCrew.isNotEmpty) flight.otherCrew,
  ].join('  ·  ');

  String _name(String value) => value.isEmpty ? 'Pending' : value;

  Widget _crewLine(IconData icon, String title, String subtitle) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: const Color(0xFF244A73)),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF667069))),
          ],
        ),
      ),
    ],
  );

  void _loadChecker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.link_rounded, size: 42),
        title: const Text('Load checker'),
        content: const Text(
          'The load-checker button is ready. Add your company load-checker web address to connect it.',
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
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.available,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool available;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF244A73)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: Icon(
        available ? Icons.check_circle_rounded : Icons.pending_outlined,
        color: available ? const Color(0xFF28634A) : const Color(0xFFBD7A17),
      ),
    ),
  );
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
    if (match == null) return value.isEmpty ? 'Pending' : value;
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }
}
