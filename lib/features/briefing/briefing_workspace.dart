import 'dart:async';

import 'package:flutter/material.dart';

import '../landing/tabs/briefing_tab.dart';
import 'models/flight_briefing.dart';
import 'services/briefing_storage.dart';
import 'services/calendar_flight_source.dart';
import 'tabs/calculations_tab.dart';
import 'tabs/configuration_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/weather_notams_tab.dart';

class BriefingWorkspace extends StatefulWidget {
  const BriefingWorkspace({this.refreshToken = 0, super.key});

  final int refreshToken;

  @override
  State<BriefingWorkspace> createState() => _BriefingWorkspaceState();
}

class _BriefingWorkspaceState extends State<BriefingWorkspace> {
  int _selectedIndex = 1;
  FlightBriefing? _flight;
  bool _active = false;
  bool _calendarSuggested = false;
  final _briefingStorage = BriefingStorage();
  final _calendarFlightSource = CalendarFlightSource();

  @override
  void initState() {
    super.initState();
    _loadNextFlight();
  }

  @override
  void didUpdateWidget(covariant BriefingWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken &&
        (_flight == null || _calendarSuggested)) {
      _loadNextFlight();
    }
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
    _calendarSuggested = false;
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
        _calendarSuggested = false;
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
      final nextFlight = await _calendarFlightSource.loadNextFlight();
      if (!mounted) return;
      setState(() {
        _flight = nextFlight;
        _active = false;
        _calendarSuggested = nextFlight != null;
      });
    } on Object {
      /* No stored roster is a valid state. */
    }
  }
}
