import 'package:flutter/material.dart';

import '../../flight_logbook_page.dart';
import '../briefing/briefing_page.dart';
import '../briefing/models/briefing_flight.dart';
import '../commute/commute_reminder_page.dart';
import '../library/operations_library_page.dart';
import '../planning/planning_compliance_page.dart';

part 'tabs/more_tab.dart';
part 'tabs/today_tab.dart';
part 'widgets/pilot_hub_widgets.dart';

class PilotHub extends StatefulWidget {
  const PilotHub({super.key});

  @override
  State<PilotHub> createState() => _PilotHubState();
}

class _PilotHubState extends State<PilotHub> {
  int _index = 0;
  final List<FlightEntry> _generatedEntries = [];

  static const flight = BriefingFlight(
    flightNumber: 'BA275',
    aircraft: 'Boeing 787-9',
    registration: 'G-ZBKM',
    departure: 'LHR',
    departureName: 'London Heathrow',
    departureTime: '16:05',
    arrival: 'LAS',
    arrivalName: 'Harry Reid International',
    arrivalTime: '18:45',
    blockTime: '10h 40m',
    reportTime: '14:20',
    gate: 'T5 · B36',
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TodayFlightPage(
        flight: flight,
        onOpenBriefing: () => setState(() => _index = 1),
        onCompleteFlight: _completeFlight,
      ),
      const BriefingPage(flight: flight),
      FlightLogbookPage(initialEntries: _generatedEntries),
      const OperationsLibraryPage(),
      const _MorePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: const Color(0xFFFBFAF6),
        indicatorColor: const Color(0xFFDCEADD),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.airplane_ticket_outlined),
            selectedIcon: Icon(Icons.airplane_ticket_rounded),
            label: 'Briefing',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Logbook',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _completeFlight() {
    final source =
        'Roster ${flight.flightNumber} ${DateTime.now().toIso8601String()}';
    setState(() {
      _generatedEntries.add(
        FlightEntry(
          date: DateTime.now(),
          aircraftType: 'B787-9',
          registration: flight.registration,
          departurePlace: flight.departure,
          departureTime: flight.departureTime,
          arrivalPlace: flight.arrival,
          arrivalTime: flight.arrivalTime,
          totalTime: const Duration(hours: 10, minutes: 40),
          picName: 'Review required',
          pilotFunction: 'Co-pilot',
          singleMultiEngine: 'Multi-engine',
          dayLandings: 0,
          nightLandings: 0,
          nightTime: Duration.zero,
          ifrTime: const Duration(hours: 10, minutes: 40),
          remarks:
              'Prefilled from roster and operational flight plan. Review before signing.',
          source: source,
        ),
      );
      _index = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Draft log entry created — review the operational details.',
        ),
      ),
    );
  }
}
