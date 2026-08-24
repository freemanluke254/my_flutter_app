import 'dart:async';

import 'package:flutter/material.dart';

import '../landing/tabs/briefing_tab.dart';
import '../calendar/models/calendar_entry.dart';
import '../roster/services/roster_storage.dart';
import 'models/flight_briefing.dart';
import 'services/briefing_storage.dart';
import 'tabs/calculations_tab.dart';
import 'tabs/configuration_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/weather_notams_tab.dart';

class BriefingWorkspace extends StatefulWidget {
  const BriefingWorkspace({super.key});

  @override
  State<BriefingWorkspace> createState() => _BriefingWorkspaceState();
}

class _BriefingWorkspaceState extends State<BriefingWorkspace> {
  int _selectedIndex = 1;
  FlightBriefing? _flight;
  bool _active = false;
  final _briefingStorage = BriefingStorage();

  @override
  void initState() {
    super.initState();
    _loadNextFlight();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const ConfigurationTab(),
      BriefingTab(
        flight: _flight,
        isActive: _active,
        onFlightChanged: _changeFlight,
        onSaveFlight: _saveFlight,
        onClearFlight: _clearFlight,
      ),
      WeatherNotamsTab(flight: _flight),
      const CalculationsTab(),
      DocumentsTab(flight: _flight),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Config',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'Briefing',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud_rounded),
            label: 'WX & NOTAMs',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Calculations',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Documents',
          ),
        ],
      ),
    );
  }

  void _changeFlight(FlightBriefing flight, bool active) => setState(() {
    _flight = flight;
    _active = active;
    unawaited(_briefingStorage.saveCurrent(flight, active));
  });

  Future<void> _saveFlight() async {
    final flight = _flight;
    if (flight == null) return;
    await _briefingStorage.saveCurrent(flight, _active);
    await _briefingStorage.archiveForLogbook(flight);
  }

  Future<void> _clearFlight() async {
    await _briefingStorage.clearCurrent();
    if (mounted) {
      setState(() {
        _flight = null;
        _active = false;
      });
    }
  }

  Future<void> _loadNextFlight() async {
    try {
      final stored = await _briefingStorage.loadCurrent();
      if (stored != null) {
        if (mounted) {
          setState(() {
            _flight = stored.flight;
            _active = stored.active;
          });
        }
        return;
      }
      final rosters = await RosterStorage().load();
      final flights =
          rosters
              .expand((roster) => roster.entries)
              .where(
                (entry) =>
                    entry.type == CalendarEntryType.flight &&
                    entry.showDetails &&
                    !entry.date.isBefore(
                      DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    ),
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      if (flights.isEmpty || !mounted) return;
      final entry = flights.first;
      final parts = entry.title.split(' ');
      final nextFlight = FlightBriefing(
        flightNumber: parts.first,
        route: parts.skip(1).join(' '),
        departureTime:
            '${entry.date.day}/${entry.date.month}/${entry.date.year} · ${entry.utcPeriod ?? 'Time pending'}',
        arrivalTime: 'From roster',
        aircraftType: 'Aircraft pending flight package',
        registration: '',
        planType: 'Upload flight documents',
        documents: const [],
      );
      setState(() => _flight = nextFlight);
      await _briefingStorage.saveCurrent(nextFlight, false);
    } on Object {
      /* No stored roster is a valid state. */
    }
  }
}
