import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../landing/tabs/briefing_tab.dart';
import 'models/flight_briefing.dart';
import 'services/briefing_storage.dart';
import 'services/calendar_flight_source.dart';
import 'services/flight_package_validator.dart';
import 'services/ofp_parser.dart';
import 'services/ofp_time_resolver.dart';
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
      ConfigurationTab(
        flight: _flight,
        onUploadDocuments: _uploadDocuments,
        onReuploadDocuments: _reuploadDocuments,
        onClearAllFields: _clearConfiguration,
        onFlightChanged: (flight) => _changeFlight(flight, _active),
      ),
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
    if (!mounted) return;
    final callsign = flight.callsign.isEmpty
        ? flight.flightNumber
        : flight.callsign;
    final flightDate = flight.flightDate;
    final dateLabel = flightDate == null
        ? 'Date pending'
        : '${flightDate.day.toString().padLeft(2, '0')}/${flightDate.month.toString().padLeft(2, '0')}/${flightDate.year}';
    final activate =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.flight_takeoff_rounded,
              color: Color(0xFF28634A),
              size: 46,
            ),
            title: Text('Activate $callsign?'),
            content: Text(
              '$dateLabel\n${flight.route}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.flight_takeoff_rounded),
                label: const Text('Let’s go flying'),
              ),
            ],
          ),
        ) ??
        false;
    if (!activate || !mounted) return;
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
      departureTimeUtc: flight.departureTimeUtc,
      arrivalTimeUtc: flight.arrivalTimeUtc,
      aircraftType: flight.aircraftType,
      registration: flight.registration,
      planType: 'Closed flight',
      callsign: flight.callsign,
      planId: flight.planId,
      reportTime: flight.reportTime,
      scheduledDepartureUtc: flight.scheduledDepartureUtc,
      flightDate: flight.flightDate,
      documents: const [],
    );
    await _briefingStorage.archiveForLogbook(logbookFlight);
    await _briefingStorage.markFlightClosed(flight);
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
    Object? ofpError;
    for (final file in files) {
      if (file.name.toUpperCase().contains('OFP')) {
        try {
          ofp = await const OfpParser().parse(await file.readAsBytes());
        } on Object catch (error) {
          ofpError = error;
        }
        break;
      }
    }
    final validationIssues = <String>[
      if (ofp != null)
        ...const FlightPackageValidator().validate(selected: current, ofp: ofp)
      else if (ofpError != null)
        'The OFP could not be decoded, so its date, route and callsign could not be verified.'
      else
        'No OFP was selected, so the package date, route and callsign could not be fully verified.',
      if (ofp != null && ofp.scheduledFlightTime.isEmpty)
        'The OFP SCH time could not be decoded.',
      if (ofp != null && ofp.flightPlanTime.isEmpty)
        'The OFP flight-plan time could not be decoded.',
      if (ofp != null && ofp.detailedRoute.isEmpty)
        'The full ATC route could not be decoded from the OFP.',
      ..._filenameValidationIssues(current, files.map((file) => file.name)),
    ];
    final loadedWithWarnings = validationIssues.isNotEmpty;
    if (validationIssues.isNotEmpty) {
      final useAnyway =
          await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB93B3B),
                size: 46,
              ),
              title: const Text('Flight package warning'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The background check found the following:',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ...validationIssues.map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $issue'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Choose documents again'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Use anyway'),
                ),
              ],
            ),
          ) ??
          false;
      if (!useAnyway || !mounted) return;
    }
    final counts = <BriefingDocumentType, int>{};
    for (final file in files) {
      final type = _documentType(file.name);
      counts[type] = (counts[type] ?? 0) + 1;
    }
    final ofpTimes = ofp == null ? null : const OfpTimeResolver().resolve(ofp);
    final updated = FlightBriefing(
      flightNumber: ofp?.flightNumber ?? current.flightNumber,
      route: ofp == null ? current.route : '${ofp.departure} → ${ofp.arrival}',
      departureTime: ofp?.departureTime ?? current.departureTime,
      arrivalTime: ofp?.arrivalTime ?? current.arrivalTime,
      departureTimeUtc: ofp == null
          ? current.departureTimeUtc
          : ofpTimes?.departureLabel ?? '',
      arrivalTimeUtc: ofp == null
          ? current.arrivalTimeUtc
          : ofpTimes?.arrivalLabel ?? '',
      aircraftType: ofp?.aircraftType ?? current.aircraftType,
      registration: ofp?.registration ?? current.registration,
      planType: 'Active flight package',
      callsign: ofp?.callsign ?? current.callsign,
      planId: ofp?.planId ?? current.planId,
      reportTime: current.reportTime,
      scheduledDepartureUtc: ofp == null
          ? current.scheduledDepartureUtc
          : ofpTimes?.departureUtc,
      flightDate: ofp?.flightDate ?? current.flightDate,
      scheduledFlightTime:
          ofp?.scheduledFlightTime ?? current.scheduledFlightTime,
      flightPlanTime: ofp?.flightPlanTime ?? current.flightPlanTime,
      detailedRoute: ofp?.detailedRoute ?? current.detailedRoute,
      captain: current.captain,
      firstOfficer: current.firstOfficer,
      reliefPilot: current.reliefPilot,
      otherCrew: current.otherCrew,
      pilotFlying: current.pilotFlying,
      takeoffWeight: ofp?.takeoffWeight ?? current.takeoffWeight,
      landingWeight: ofp?.landingWeight ?? current.landingWeight,
      zeroFuelWeight: ofp?.zeroFuelWeight ?? current.zeroFuelWeight,
      payload: ofp?.payload ?? current.payload,
      blockFuel: ofp?.blockFuel ?? current.blockFuel,
      taxiFuel: ofp?.taxiFuel ?? current.taxiFuel,
      tripFuel: ofp?.tripFuel ?? current.tripFuel,
      contingencyFuel: ofp?.contingencyFuel ?? current.contingencyFuel,
      finalReserveFuel: ofp?.finalReserveFuel ?? current.finalReserveFuel,
      extraFuel: ofp?.extraFuel ?? current.extraFuel,
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
        title: Text(
          loadedWithWarnings ? 'Uploaded with warnings' : 'Upload successful',
        ),
        content: Text(
          loadedWithWarnings
              ? '${updated.flightNumber}\n${files.length} documents loaded after validation warnings.'
              : updated.planId.isEmpty || updated.planId == 'Not stated'
              ? '${updated.flightNumber}\n${files.length} documents loaded successfully.\nOFP Plan ID not stated.'
              : 'OFP Plan ID ${updated.planId} loaded successfully.\n${updated.flightNumber} · ${files.length} documents',
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

  Future<void> _reuploadDocuments() async {
    await _clearConfiguration();
    if (!mounted) return;
    await _uploadDocuments();
  }

  Future<void> _clearConfiguration() async {
    final current = _flight;
    if (current == null) return;
    final base = _upcomingFlights.where((candidate) {
      if (candidate.flightNumber != current.flightNumber) return false;
      final first = candidate.flightDate;
      final second = current.flightDate;
      if (first == null || second == null) return true;
      return first.year == second.year &&
          first.month == second.month &&
          first.day == second.day;
    }).firstOrNull;
    final cleared =
        base ??
        FlightBriefing(
          flightNumber: current.flightNumber,
          route: current.route,
          departureTime: current.departureTime,
          arrivalTime: current.arrivalTime,
          departureTimeUtc: current.departureTimeUtc,
          arrivalTimeUtc: current.arrivalTimeUtc,
          aircraftType: 'Aircraft pending flight package',
          registration: '',
          planType: 'Upload flight documents',
          callsign: current.callsign,
          reportTime: current.reportTime,
          scheduledDepartureUtc: current.scheduledDepartureUtc,
          flightDate: current.flightDate,
          documents: const [],
        );
    _changeFlight(cleared, false);
  }

  List<String> _filenameValidationIssues(
    FlightBriefing selected,
    Iterable<String> filenames,
  ) {
    final expected = RegExp(
      r'\d+[A-Z]?$',
    ).firstMatch(selected.flightNumber.toUpperCase())?.group(0);
    if (expected == null) return const [];
    final mismatches = <String>[];
    for (final filename in filenames) {
      final identity = RegExp(
        r'(?:VS|VIR)(\d+[A-Z]?)',
        caseSensitive: false,
      ).firstMatch(filename)?.group(1)?.toUpperCase();
      if (identity != null && identity != expected) mismatches.add(filename);
    }
    return mismatches.isEmpty
        ? const []
        : [
            'Document filename does not match the selected flight: ${mismatches.join(', ')}.',
          ];
  }

  Future<void> _loadNextFlight() async {
    try {
      final upcoming = await _calendarFlightSource.loadUpcomingFlights();
      final closedKeys = await _briefingStorage.loadClosedFlightKeys();
      final available = upcoming
          .where(
            (flight) =>
                !closedKeys.contains(_briefingStorage.flightKey(flight)),
          )
          .toList();
      if (mounted) setState(() => _upcomingFlights = available);
      final stored = await _briefingStorage.loadCurrent();
      if (stored != null && (stored.active || stored.selectedByUser)) {
        final calendarFlight = available.where((candidate) {
          if (candidate.flightNumber != stored.flight.flightNumber) {
            return false;
          }
          final first = candidate.flightDate;
          final second = stored.flight.flightDate;
          return first == null ||
              second == null ||
              (first.year == second.year &&
                  first.month == second.month &&
                  first.day == second.day);
        }).firstOrNull;
        final restoredFlight = calendarFlight == null
            ? stored.flight
            : stored.flight.copyWith(
                departureTimeUtc: stored.flight.departureTimeUtc.isEmpty
                    ? calendarFlight.departureTimeUtc
                    : stored.flight.departureTimeUtc,
                arrivalTimeUtc: stored.flight.arrivalTimeUtc.isEmpty
                    ? calendarFlight.arrivalTimeUtc
                    : stored.flight.arrivalTimeUtc,
              );
        if (mounted) {
          setState(() {
            _flight = restoredFlight;
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
      final closedKeys = await _briefingStorage.loadClosedFlightKeys();
      final available = flights
          .where(
            (flight) =>
                !closedKeys.contains(_briefingStorage.flightKey(flight)),
          )
          .toList();
      if (mounted) setState(() => _upcomingFlights = available);
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
