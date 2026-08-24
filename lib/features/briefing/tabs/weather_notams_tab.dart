import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';

class WeatherNotamsTab extends StatelessWidget {
  const WeatherNotamsTab({required this.flight, super.key});
  final FlightBriefing? flight;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'WX & NOTAMs',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Weather and NOTAM information decoded from the active package.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 18),
      _SourceCard(
        title: 'Departure weather',
        icon: Icons.flight_takeoff_rounded,
        available: _has(BriefingDocumentType.weather),
      ),
      _SourceCard(
        title: 'Destination weather',
        icon: Icons.flight_land_rounded,
        available: _has(BriefingDocumentType.weather),
      ),
      _SourceCard(
        title: 'En-route and significant weather',
        icon: Icons.thunderstorm_outlined,
        available: _has(BriefingDocumentType.significantWeather),
      ),
      _SourceCard(
        title: 'Operational NOTAMs',
        icon: Icons.campaign_outlined,
        available: _has(BriefingDocumentType.notams),
      ),
    ],
  );

  bool _has(BriefingDocumentType type) =>
      flight?.documents.any((document) => document.type == type) ?? false;
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.title,
    required this.icon,
    required this.available,
  });
  final String title;
  final IconData icon;
  final bool available;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        available
            ? 'Source document available'
            : 'Upload flight documents to populate',
      ),
      trailing: Icon(
        available ? Icons.check_circle_rounded : Icons.pending_outlined,
        color: available ? const Color(0xFF28634A) : null,
      ),
    ),
  );
}
