import 'dart:async';

import 'package:flutter/material.dart';

import '../models/flight_briefing.dart';

class ConfigurationTab extends StatefulWidget {
  const ConfigurationTab({
    required this.flight,
    required this.onUploadDocuments,
    required this.onReuploadDocuments,
    required this.onClearAllFields,
    required this.onFlightChanged,
    super.key,
  });
  final FlightBriefing? flight;
  final Future<void> Function() onUploadDocuments;
  final Future<void> Function() onReuploadDocuments;
  final Future<void> Function() onClearAllFields;
  final ValueChanged<FlightBriefing> onFlightChanged;
  @override
  State<ConfigurationTab> createState() => _ConfigurationTabState();
}

class _ConfigurationTabState extends State<ConfigurationTab> {
  final _controllers = <String, TextEditingController>{};
  String _pilotFlying = '';

  @override
  void initState() {
    super.initState();
    _load(widget.flight);
  }

  @override
  void didUpdateWidget(covariant ConfigurationTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flight != widget.flight) _load(widget.flight);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final hasUploadedPackage = flight?.documents.isNotEmpty == true;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          flight == null
              ? 'Upload flight plan documents'
              : hasUploadedPackage
              ? 'Displaying config details for ${flight.flightNumber}'
              : 'Upload flight plan documents for ${flight.flightNumber}',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Load the OFP and supporting package, then confirm the flight setup below.',
          style: TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 16),
        if (flight == null)
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Select a flight in Flights first.'),
            ),
          )
        else ...[
          if (!hasUploadedPackage) ...[
            FilledButton.icon(
              onPressed: widget.onUploadDocuments,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload OFP and flight documents'),
            ),
            const SizedBox(height: 14),
          ],
          _FlightPlanHeader(flight: flight),
          const SizedBox(height: 14),
          _section(
            title: 'Aircraft and crew',
            child: Column(
              children: [
                _row([
                  _field('registration', 'Registration'),
                  _field('aircraftType', 'Aircraft type'),
                ]),
                _crewAssignmentRow('captain', 'Captain', 'Captain'),
                _crewAssignmentRow(
                  'firstOfficer',
                  'First officer',
                  'First officer',
                ),
                _row([
                  _field('reliefPilot', 'SO / Relief'),
                  _field('otherCrew', 'Other'),
                ]),
              ],
            ),
          ),
          _section(
            title: 'Flight times',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _timeValue(
                  'STD',
                  _dualTime(flight.departureTime, flight.departureTimeUtc),
                ),
                _timeValue(
                  'STA',
                  _dualTime(flight.arrivalTime, flight.arrivalTimeUtc),
                ),
                _timeValue('SCH', flight.scheduledFlightTime),
                _timeValue('FP flight time', flight.flightPlanTime),
              ],
            ),
          ),
          _section(
            title: 'Route',
            child: TextField(
              controller: _controllers['detailedRoute'],
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Planned ATC route',
                alignLabelWithHint: true,
              ),
            ),
          ),
          _section(
            title: 'Planned weights',
            child: Column(
              children: [
                _row([
                  _field('takeoffWeight', 'TOW'),
                  _field('landingWeight', 'LAW'),
                ]),
                _row([
                  _field('zeroFuelWeight', 'ZFW'),
                  _field('payload', 'Payload'),
                ]),
              ],
            ),
          ),
          _section(
            title: 'Fuel plan',
            child: Column(
              children: [
                _row([
                  _field('blockFuel', 'Block fuel'),
                  _field('taxiFuel', 'Taxi fuel'),
                ]),
                _row([
                  _field('tripFuel', 'Trip fuel'),
                  _field('contingencyFuel', 'Contingency'),
                ]),
                _row([
                  _field('finalReserveFuel', 'Final reserve'),
                  _field('extraFuel', 'Extra fuel'),
                ]),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save flight setup'),
          ),
          if (hasUploadedPackage) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _confirmReupload,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Reupload flight plan documents'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _confirmClearAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear all fields'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB93B3B),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _section({required String title, required Widget child}) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
  Widget _row(List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 10),
        Expanded(child: children[1]),
      ],
    ),
  );
  Widget _field(String key, String label) => TextField(
    controller: _controllers[key],
    decoration: InputDecoration(labelText: label),
  );

  Widget _crewAssignmentRow(String key, String label, String crewRole) {
    final otherRole = crewRole == 'Captain' ? 'First officer' : 'Captain';
    final selection = _pilotFlying.isEmpty
        ? <String>{}
        : {_pilotFlying == crewRole ? 'PF' : 'PM'};
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: _field(key, label)),
          const SizedBox(width: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'PF', label: Text('PF')),
              ButtonSegment(value: 'PM', label: Text('PM')),
            ],
            selected: selection,
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (selected) {
              if (selected.isEmpty) return;
              setState(
                () => _pilotFlying = selected.first == 'PF'
                    ? crewRole
                    : otherRole,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _timeValue(String label, String value) => Container(
    width: 145,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F5F3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF667069))),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? 'Pending' : value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ],
    ),
  );

  String _formatLocalTime(String value) {
    final match = RegExp(r'^(\d{2})(\d{2})(\+?)$').firstMatch(value.trim());
    if (match == null) return value;
    return '${match.group(1)}:${match.group(2)}${match.group(3)}';
  }

  String _dualTime(String local, String utc) =>
      '${_formatLocalTime(local)} local\n${utc.isEmpty ? 'Pending' : _formatLocalTime(utc)} UTC';

  void _load(FlightBriefing? flight) {
    final values = <String, String>{
      'registration': flight?.registration ?? '',
      'aircraftType': flight?.aircraftType ?? '',
      'captain': flight?.captain ?? '',
      'firstOfficer': flight?.firstOfficer ?? '',
      'reliefPilot': flight?.reliefPilot ?? '',
      'otherCrew': flight?.otherCrew ?? '',
      'detailedRoute': flight?.detailedRoute ?? '',
      'takeoffWeight': flight?.takeoffWeight ?? '',
      'landingWeight': flight?.landingWeight ?? '',
      'zeroFuelWeight': flight?.zeroFuelWeight ?? '',
      'payload': flight?.payload ?? '',
      'blockFuel': flight?.blockFuel ?? '',
      'taxiFuel': flight?.taxiFuel ?? '',
      'tripFuel': flight?.tripFuel ?? '',
      'contingencyFuel': flight?.contingencyFuel ?? '',
      'finalReserveFuel': flight?.finalReserveFuel ?? '',
      'extraFuel': flight?.extraFuel ?? '',
    };
    for (final entry in values.entries) {
      (_controllers[entry.key] ??= TextEditingController()).text = entry.value;
    }
    _pilotFlying = flight?.pilotFlying ?? '';
  }

  void _save() {
    final flight = widget.flight;
    if (flight == null) return;
    String value(String key) => _controllers[key]!.text.trim();
    widget.onFlightChanged(
      flight.copyWith(
        registration: value('registration'),
        aircraftType: value('aircraftType'),
        captain: value('captain'),
        firstOfficer: value('firstOfficer'),
        reliefPilot: value('reliefPilot'),
        otherCrew: value('otherCrew'),
        pilotFlying: _pilotFlying,
        detailedRoute: value('detailedRoute'),
        takeoffWeight: value('takeoffWeight'),
        landingWeight: value('landingWeight'),
        zeroFuelWeight: value('zeroFuelWeight'),
        payload: value('payload'),
        blockFuel: value('blockFuel'),
        taxiFuel: value('taxiFuel'),
        tripFuel: value('tripFuel'),
        contingencyFuel: value('contingencyFuel'),
        finalReserveFuel: value('finalReserveFuel'),
        extraFuel: value('extraFuel'),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Flight setup saved.')));
  }

  Future<void> _confirmReupload() async {
    final confirmed = await _confirmReset(
      title: 'Reupload flight plan documents?',
      message:
          'Are you sure? This will clear all current configuration data before you select a new flight package.',
      action: 'Continue',
    );
    if (confirmed) await widget.onReuploadDocuments();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await _confirmReset(
      title: 'Clear all fields?',
      message:
          'Are you sure? This will clear all current data and documents. You will need to upload the flight plan documents again.',
      action: 'Clear all',
    );
    if (confirmed) await widget.onClearAllFields();
  }

  Future<bool> _confirmReset({
    required String title,
    required String message,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB93B3B),
            size: 44,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;
}

class _FlightPlanHeader extends StatefulWidget {
  const _FlightPlanHeader({required this.flight});
  final FlightBriefing flight;

  @override
  State<_FlightPlanHeader> createState() => _FlightPlanHeaderState();
}

class _FlightPlanHeaderState extends State<_FlightPlanHeader> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _FlightPlanHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flight.scheduledDepartureUtc !=
        widget.flight.scheduledDepartureUtc) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.flight.scheduledDepartureUtc == null) return;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final date = flight.flightDate;
    final dateText = date == null
        ? 'Date pending'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final callsign = flight.callsign.isEmpty
        ? flight.flightNumber
        : flight.callsign;
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
                  callsign,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateText  ·  ${flight.route}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'STD ${_localTime(flight.departureTime)} local / ${flight.departureTimeUtc.isEmpty ? 'Pending' : _localTime(flight.departureTimeUtc)} UTC\nSTA ${_localTime(flight.arrivalTime)} local / ${flight.arrivalTimeUtc.isEmpty ? 'Pending' : _localTime(flight.arrivalTimeUtc)} UTC   SCH ${flight.scheduledFlightTime.isEmpty ? 'Pending' : flight.scheduledFlightTime}',
                  style: const TextStyle(
                    color: Color(0xFFDCE8F3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                _CountdownBadge(
                  label: _countdown(flight.scheduledDepartureUtc),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text('PLAN ID', style: TextStyle(color: Color(0xFFDCE8F3))),
              Text(
                flight.planId.isEmpty ? '—' : flight.planId,
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

  String _localTime(String value) {
    final match = RegExp(r'^(\d{2})(\d{2})(\+?)$').firstMatch(value.trim());
    if (match == null) return value;
    return '${match.group(1)}:${match.group(2)}${match.group(3)}';
  }

  String _countdown(DateTime? departureUtc) {
    if (departureUtc == null) return 'STD countdown pending';
    final difference = departureUtc.difference(DateTime.now().toUtc());
    final passed = difference.isNegative;
    final duration = difference.abs();
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final value = [
      if (days > 0) '${days}d',
      '${hours}h',
      '${minutes}m',
    ].join(' ');
    return passed ? 'STD passed $value ago' : 'STD in $value';
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, color: Colors.white, size: 17),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
