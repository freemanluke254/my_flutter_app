import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';

class FlightsTab extends StatelessWidget {
  const FlightsTab({
    required this.flights,
    required this.selectedFlight,
    required this.onSelected,
    super.key,
  });

  final List<FlightBriefing> flights;
  final FlightBriefing? selectedFlight;
  final ValueChanged<FlightBriefing> onSelected;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Flights',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Select a rostered or manually entered flight to begin its briefing.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 18),
      if (flights.isEmpty)
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No calendar flights are available.'),
          ),
        )
      else
        ...flights.map((flight) {
          final selected = _sameFlight(flight, selectedFlight);
          return Card(
            elevation: 0,
            color: selected ? const Color(0xFFE6EEF7) : Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                Icons.flight_takeoff_rounded,
                color: selected
                    ? const Color(0xFF244A73)
                    : const Color(0xFF667069),
              ),
              title: Text(
                '${flight.flightNumber}  ${flight.route}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${flight.departureTime}\n${flight.planType}'),
              isThreeLine: true,
              trailing: selected
                  ? const Chip(label: Text('SELECTED'))
                  : const Icon(Icons.chevron_right_rounded),
              onTap: () => onSelected(flight),
            ),
          );
        }),
    ],
  );

  bool _sameFlight(FlightBriefing first, FlightBriefing? second) =>
      second != null &&
      first.flightNumber == second.flightNumber &&
      first.departureTime == second.departureTime;
}
