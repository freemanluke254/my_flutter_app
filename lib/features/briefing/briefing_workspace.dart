import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../landing/tabs/briefing_tab.dart';
import 'models/flight_briefing.dart';
import 'services/briefing_storage.dart';
import 'services/calendar_flight_source.dart';
import 'services/ofp_parser.dart';
import 'tabs/calculations_tab.dart';
import 'tabs/configuration_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/flights_tab.dart';
import 'tabs/weather_notams_tab.dart';

class BriefingWorkspace extends StatefulWidget {
  const BriefingWorkspace({this.refreshToken = 0, super.key});

  final int refreshToken;

  @override
  State<BriefingWorkspace> createState() => _BriefingWorkspaceState();
}

class _BriefingWorkspaceState extends State<BriefingWorkspace> {
  int _selectedIndex = 0;
  FlightBriefing? _flight;
  List<FlightBriefing> _upcomingFlights = const [];
  bool _active = false;
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
    if (widget.refreshToken != oldWidget.refreshToken) {
      _refreshFlightList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      FlightsTab(
        flights: _upcomingFlights,
        selectedFlight: _flight,
        onSelected: _selectUpcomingFlight,
      ),
      ConfigurationTab(flight: _flight, onUploadDocuments: _uploadDocuments),
      BriefingTab(
        flight: _flight,
        isActive: _active,
        onFlightChanged: _changeFlight,
        onSaveFlight: _saveFlight,
        onClearFlight: _clearFlight,
        onCloseFlight: _closeFlight,
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
            icon: Icon(Icons.upcoming_outlined),
            selectedIcon: Icon(Icons.upcoming_rounded),
            label: 'Flights',
          ),
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

  Future<void> _selectUpcomingFlight(FlightBriefing flight) async {
    final departure = flight.scheduledDepartureUtc;
    if (departure != null) {
      final leadTime = departure.difference(DateTime.now().toUtc());
      if (leadTime > const Duration(hours: 24)) {
        final days = leadTime.inDays;
        final hours = leadTime.inHours.remainder(24);
        final confirmed =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                icon: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFBD7A17),
                  size: 44,
                ),
                title: const Text('Future flight selected'),
                content: Text(
                  'You have selected ${flight.flightNumber}, which is ${days > 0 ? '$days day${days == 1 ? '' : 's'} ' : ''}$hours hour${hours == 1 ? '' : 's'} in the future. Are you sure this is the correct flight?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Choose another'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Select flight'),
                  ),
                ],
              ),
            ) ??
            false;
        if (!confirmed || !mounted) return;
      }
    }
    _changeFlight(flight, false);
    setState(() => _selectedIndex = 1);
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

  Future<void> _closeFlight() async {
    final flight = _flight;
    if (flight == null) return;
    final logbookFlight = FlightBriefing(
      flightNumber: flight.flightNumber,
      route: flight.route,
      departureTime: flight.departureTime,
      arrivalTime: flight.arrivalTime,
      aircraftType: flight.aircraftType,
      registration: flight.registration,
      planType: 'Closed flight',
      callsign: flight.callsign,
      planId: flight.planId,
      reportTime: flight.reportTime,
      scheduledDepartureUtc: flight.scheduledDepartureUtc,
      documents: const [],
    );
    await _briefingStorage.archiveForLogbook(logbookFlight);
    await _briefingStorage.clearCurrent();
    if (!mounted) return;
    setState(() {
      _flight = null;
      _active = false;
      _selectedIndex = 0;
    });
    await _loadNextFlight();
  }

  Future<void> _uploadDocuments() async {
    final current = _flight;
    if (current == null) return;
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (files.isEmpty || !mounted) return;
    OfpFlightDetails? ofp;
    for (final file in files) {
      if (file.name.toUpperCase().contains('OFP')) {
        try {
          ofp = await const OfpParser().parse(await file.readAsBytes());
        } on Object {
          // Other selected documents can still be attached if OFP decoding fails.
        }
        break;
      }
    }
    final counts = <BriefingDocumentType, int>{};
    for (final file in files) {
      final type = _documentType(file.name);
      counts[type] = (counts[type] ?? 0) + 1;
    }
    final updated = FlightBriefing(
      flightNumber: ofp?.flightNumber ?? current.flightNumber,
      route: ofp == null ? current.route : '${ofp.departure} → ${ofp.arrival}',
      departureTime: ofp?.departureTime ?? current.departureTime,
      arrivalTime: ofp?.arrivalTime ?? current.arrivalTime,
      aircraftType: ofp?.aircraftType ?? current.aircraftType,
      registration: ofp?.registration ?? current.registration,
      planType: 'Active flight package',
      callsign: ofp?.callsign ?? current.callsign,
      planId: ofp?.planId ?? current.planId,
      reportTime: current.reportTime,
      scheduledDepartureUtc: current.scheduledDepartureUtc,
      documents: counts.entries
          .map(
            (entry) => BriefingDocument(
              type: entry.key,
              title: _documentTitle(entry.key),
              fileCount: entry.value,
            ),
          )
          .toList(),
    );
    _changeFlight(updated, true);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF28634A),
          size: 44,
        ),
        title: const Text('Flight package uploaded'),
        content: Text(
          '${updated.flightNumber}\n${files.length} documents loaded${updated.planId.isEmpty ? '' : '\nOFP Plan ID ${updated.planId}'}',
          textAlign: TextAlign.center,
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

  Future<void> _loadNextFlight() async {
    try {
      final upcoming = await _calendarFlightSource.loadUpcomingFlights();
      if (mounted) setState(() => _upcomingFlights = upcoming);
      final stored = await _briefingStorage.loadCurrent();
      if (stored != null && stored.active) {
        if (mounted) {
          setState(() {
            _flight = stored.flight;
            _active = stored.active;
          });
        }
        return;
      }
      if (stored != null) await _briefingStorage.clearCurrent();
      if (!mounted) return;
      setState(() {
        _flight = null;
        _active = false;
      });
    } on Object {
      /* No stored roster is a valid state. */
    }
  }

  Future<void> _refreshFlightList() async {
    try {
      final flights = await _calendarFlightSource.loadUpcomingFlights();
      if (mounted) setState(() => _upcomingFlights = flights);
    } on Object {
      // An empty or unavailable roster is a valid state.
    }
  }

  BriefingDocumentType _documentType(String filename) {
    final name = filename.toUpperCase();
    if (name.contains('NOTAM')) return BriefingDocumentType.notams;
    if (name.contains('OFP')) return BriefingDocumentType.operationalFlightPlan;
    if (name.contains('TERRA')) return BriefingDocumentType.terrain;
    if (name.contains('TRACK')) return BriefingDocumentType.tracks;
    if (name.contains('ROUTE')) return BriefingDocumentType.routeChart;
    if (name.contains('SIG')) return BriefingDocumentType.significantWeather;
    return BriefingDocumentType.weather;
  }

  String _documentTitle(BriefingDocumentType type) => switch (type) {
    BriefingDocumentType.operationalFlightPlan => 'Operational flight plan',
    BriefingDocumentType.weather => 'Weather briefing',
    BriefingDocumentType.notams => 'NOTAM briefing',
    BriefingDocumentType.routeChart => 'Route charts',
    BriefingDocumentType.significantWeather => 'Significant weather charts',
    BriefingDocumentType.tracks => 'Track message',
    BriefingDocumentType.terrain => 'Critical terrain scenario',
  };
}
