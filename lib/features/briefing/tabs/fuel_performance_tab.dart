import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/flight_briefing.dart';

class FuelPerformanceTab extends StatefulWidget {
  const FuelPerformanceTab({
    required this.flight,
    required this.onFlightChanged,
    super.key,
  });
  final FlightBriefing? flight;
  final ValueChanged<FlightBriefing> onFlightChanged;

  @override
  State<FuelPerformanceTab> createState() => _FuelPerformanceTabState();
}

class _FuelPerformanceTabState extends State<FuelPerformanceTab> {
  final _controllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _loadControllers();
  }

  @override
  void didUpdateWidget(covariant FuelPerformanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_flightKey(oldWidget.flight) != _flightKey(widget.flight)) {
      _loadControllers();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadControllers() {
    final flight = widget.flight;
    final values = <String, String>{
      'actualZfw': flight?.actualZeroFuelWeight ?? '',
      'actualTow': flight?.actualTakeoffWeight ?? '',
      'actualLwt': flight?.actualLandingWeight ?? '',
      'rtow': flight?.calculatedRtow ?? '',
      'zfwCg': flight?.airbusZfwCg ?? '',
      'stabCg': flight?.airbusStabCg ?? '',
      'prelimThrust': flight?.preliminaryThrustSetting ?? '',
      'prelimFlap': flight?.preliminaryFlapSetting ?? '',
      'actualCg': flight?.actualTakeoffCg ?? '',
      'finalThrust': flight?.finalThrustSetting ?? '',
      'finalFlap': flight?.finalFlapSetting ?? '',
      'atis': flight?.atisLetter ?? '',
      'captainPayroll': flight?.captainPayrollNumber ?? '',
      'rlw': flight == null
          ? ''
          : flight.regulatedLandingWeight.isNotEmpty
          ? flight.regulatedLandingWeight
          : flight.aircraftType.contains('787')
          ? '192776'
          : '',
    };
    for (final entry in values.entries) {
      final existing = _controllers[entry.key];
      if (existing == null) {
        _controllers[entry.key] = TextEditingController(text: entry.value);
      } else {
        existing.text = entry.value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    if (flight == null) return _empty(context);
    final type = flight.aircraftType.toUpperCase();
    final isAirbus =
        type.contains('AIRBUS') ||
        RegExp(r'\bA(?:330|340|350|380)\b').hasMatch(type);
    final isB787 = type.contains('787');
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Fuel & performance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (isB787) _compactAtisField(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${flight.callsign.isEmpty ? flight.flightNumber : flight.callsign} · ${flight.route}',
          style: const TextStyle(color: Color(0xFF667069)),
        ),
        const SizedBox(height: 16),
        Text(
          'Weights',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (isB787) ...[
          _rtowAndLoadsheetSetup(flight),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final planned = _WeightColumn(
              title: 'PLANNED · FROM OFP',
              subtitle: 'Read-only values imported from the flight plan',
              colour: const Color(0xFFE8EEF6),
              children: [
                _PlannedWeight(label: 'PLN ZFW', value: flight.zeroFuelWeight),
                _PlannedWeight(label: 'PLN TOW', value: flight.takeoffWeight),
                _PlannedWeight(label: 'PLN LWT', value: flight.landingWeight),
              ],
            );
            final actual = _WeightColumn(
              title: 'ACTUAL · CREW ENTRY',
              subtitle: 'Amend as confirmed figures become available',
              colour: const Color(0xFFE7F4EA),
              children: [
                _weightField('ACT ZFW', 'actualZfw'),
                _weightField('ACT TOW', 'actualTow'),
                _weightField('ACT LANDING WEIGHT', 'actualLwt'),
                if (isAirbus) ...[
                  _decimalField('AIRBUS ZFWCG', 'zfwCg', suffix: '%'),
                  _decimalField('AIRBUS STAB/CG', 'stabCg'),
                ],
              ],
            );
            if (constraints.maxWidth < 720) {
              return Column(
                children: [planned, const SizedBox(height: 12), actual],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: planned),
                const SizedBox(width: 14),
                Expanded(child: actual),
              ],
            );
          },
        ),
        if (isB787) ...[
          const SizedBox(height: 16),
          _takeoffPerformance(flight),
        ],
        if (flight.maxPayloadPlan) ...[
          const SizedBox(height: 16),
          const _MaxPayloadPlanNote(),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _empty(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Fuel & performance',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Text(
            'Select a flight before entering fuel and performance data.',
          ),
        ),
      ),
    ],
  );

  Widget _weightField(String label, String key) => _EntryField(
    label: label,
    controller: _controllers[key]!,
    suffix: 'kg',
    onChanged: (value) => _update(key, value),
  );

  Widget _decimalField(String label, String key, {String? suffix}) =>
      _EntryField(
        label: label,
        controller: _controllers[key]!,
        suffix: suffix,
        decimal: true,
        onChanged: (value) => _update(key, value),
      );

  Widget _takeoffPerformance(FlightBriefing flight) {
    final preliminaryTow = _preliminaryTow(flight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Take-off performance',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Material(
          color: const Color(0xFFE8EEF6),
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PRELIMINARY OPT CALCULATION',
                  style: TextStyle(
                    color: Color(0xFF315F86),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Final ZFW received'),
                  subtitle: const Text(
                    'ACT ZFW above is treated as the Final ZFW.',
                  ),
                  value: flight.finalZfwReceived,
                  onChanged: (value) =>
                      _updateFlag('finalZfwReceived', value ?? false),
                ),
                _PerformanceFormula(
                  finalZfw: flight.actualZeroFuelWeight,
                  rampFuel: flight.blockFuel,
                  takeoffWeight: preliminaryTow,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Preliminary input assumptions: no weight buffer, taxi fuel not deducted, CG 25%.',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: !flight.finalZfwReceived,
                  child: Opacity(
                    opacity: flight.finalZfwReceived ? 1 : 0.5,
                    child: Row(
                      children: [
                        Expanded(
                          child: _performanceField(
                            'Take-off thrust setting',
                            'prelimThrust',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _performanceField(
                            'Flap setting',
                            'prelimFlap',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Preliminary OPT calculation completed'),
                  value: flight.preliminaryPerformanceComplete,
                  onChanged: flight.finalZfwReceived
                      ? (value) =>
                            _updateFlag('preliminaryComplete', value ?? false)
                      : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Thrust and flap settings entered in the aircraft EFB',
                  ),
                  value: flight.efbPerformanceEntered,
                  onChanged: flight.preliminaryPerformanceComplete
                      ? (value) => _updateFlag('efbEntered', value ?? false)
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: const Color(0xFFE7F4EA),
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'FINAL OPT CALCULATION',
                  style: TextStyle(
                    color: Color(0xFF28634A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Final loadsheet received'),
                  subtitle: const Text(
                    'Transfer the actual figures from the FMC and use the actual CG from the loadsheet.',
                  ),
                  value: flight.finalLoadsheetReceived,
                  onChanged: (value) =>
                      _updateFlag('loadsheetReceived', value ?? false),
                ),
                IgnorePointer(
                  ignoring: !flight.finalLoadsheetReceived,
                  child: Opacity(
                    opacity: flight.finalLoadsheetReceived ? 1 : 0.5,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ActualValue(
                                label: 'ACT ZFW',
                                value: flight.actualZeroFuelWeight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActualValue(
                                label: 'ACT TOW',
                                value: flight.actualTakeoffWeight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _decimalField(
                                'ACTUAL CG',
                                'actualCg',
                                suffix: '%',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _performanceField(
                                'Final thrust setting',
                                'finalThrust',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _performanceField(
                                'Final flap setting',
                                'finalFlap',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Final OPT calculation completed'),
                  value: flight.finalPerformanceComplete,
                  onChanged: flight.finalLoadsheetReceived
                      ? (value) => _updateFlag('finalComplete', value ?? false)
                      : null,
                ),
                const Text(
                  'Use the approved aircraft OPT/EFB. This app records the workflow and inputs; it does not calculate certified take-off performance.',
                  style: TextStyle(color: Color(0xFF52635A), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _compactAtisField() => Container(
    padding: const EdgeInsets.fromLTRB(10, 7, 7, 7),
    decoration: BoxDecoration(
      color: const Color(0xFF315F86),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF234968), width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'ATIS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: TextField(
            controller: _controllers['atis']!,
            textAlign: TextAlign.center,
            cursorColor: const Color(0xFF315F86),
            style: const TextStyle(
              color: Color(0xFF173D31),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
              TextInputFormatter.withFunction(
                (oldValue, newValue) => newValue.copyWith(
                  text: newValue.text.toUpperCase(),
                  selection: newValue.selection,
                ),
              ),
            ],
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD4E0EA)),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF78B7E5), width: 2),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            ),
            onChanged: (value) => _update('atis', value),
          ),
        ),
      ],
    ),
  );

  Widget _rtowAndLoadsheetSetup(FlightBriefing flight) {
    final rtowRlwComplete =
        flight.landingDispatchAnswered &&
        flight.calculatedRtow.isNotEmpty &&
        (!flight.landingDispatchRequired ||
            flight.regulatedLandingWeight.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: rtowRlwComplete
              ? const Color(0xFFEAF6ED)
              : const Color(0xFFF0F3F6),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: rtowRlwComplete
                  ? const Color(0xFFA8CEB1)
                  : const Color(0xFFCBD5DE),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepHeader('1', 'RTOW and RLW'),
                const SizedBox(height: 12),
                _RtowField(
                  controller: _controllers['rtow']!,
                  onChanged: (value) => _update('rtow', value),
                  onOpenChecklist: _showRtowProcedure,
                ),
                const SizedBox(height: 8),
                _LandingDispatchDecision(
                  answered: flight.landingDispatchAnswered,
                  required: flight.landingDispatchRequired,
                  onChanged: _setLandingDispatchRequired,
                  onOpenInfo: _showLandingDispatchCriteria,
                ),
                if (flight.landingDispatchRequired) ...[
                  const SizedBox(height: 8),
                  _CalculatedRlwField(
                    controller: _controllers['rlw']!,
                    onChanged: (value) => _update('rlw', value),
                    onOpenChecklist: _showLandingDispatchProcedure,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: flight.loadsheetInitialized
              ? const Color(0xFFEAF6ED)
              : const Color(0xFFF0F3F6),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: flight.loadsheetInitialized
                  ? const Color(0xFFA8CEB1)
                  : const Color(0xFFCBD5DE),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepHeader('2', 'Initialise loadsheet'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: _ActualValue(
                        label: 'RTOW',
                        value: flight.calculatedRtow,
                        compact: true,
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: _ActualValue(
                        label: 'RLW',
                        value: flight.regulatedLandingWeight,
                        compact: true,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: _ActualValue(
                        label: 'TOTAL CREW',
                        value:
                            '${flight.flightDeckCount + flight.cabinCrewCount}',
                        suffix: null,
                        compact: true,
                      ),
                    ),
                    SizedBox(
                      width: 270,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _loadsheetField(
                              'CAPTAIN PAYROLL',
                              'captainPayroll',
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 108,
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                'Sent to GLC',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              value: flight.loadsheetInitialized,
                              onChanged: flight.loadsheetInitialized
                                  ? (_) => _undoInitialLoadsheetSent()
                                  : !_canSendInitialLoadsheet(flight)
                                  ? null
                                  : (_) => _confirmInitialLoadsheetSent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (flight.regulatedLandingWeight.replaceAll(
                      RegExp(r'\D'),
                      '',
                    ) ==
                    '192776')
                  const Text(
                    'RLW of 192,776 kg is prefilled.',
                    style: TextStyle(color: Color(0xFF667069), fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: const Color(0xFFF0F3F6),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFCBD5DE)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepHeader('3', 'Fuel'),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 180,
                    child: _weightField('FINAL ZFW', 'actualZfw'),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'OFP FUEL FIGURES',
                  style: TextStyle(
                    color: Color(0xFF315F86),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final figures = <(String, String)>[
                      ('TRIP', flight.tripFuel),
                      ('CONT', flight.contingencyFuel),
                      ('ALTN', flight.alternateFuel),
                      ('FNL RES', flight.finalReserveFuel),
                      ('ETP ADJ', flight.etpAdjustmentFuel),
                      ('ADDNL', flight.additionalFuel),
                      ('UNUSABLE', flight.unusableFuel),
                      ('ARR DLY', flight.arrivalDelayFuel),
                      ('EXTRA', flight.extraFuel),
                      ('DISC', flight.discretionaryFuel),
                      ('TAXI/APU', flight.taxiFuel),
                      ('RAMP', flight.blockFuel),
                    ];
                    final width = constraints.maxWidth < 620
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      children: figures
                          .map(
                            (figure) => SizedBox(
                              width: width,
                              child: _PlannedWeight(
                                label: figure.$1,
                                value: figure.$2,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showRtowProcedure() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: const SizedBox(
        width: 680,
        child: SingleChildScrollView(child: _RtowCalculationReference()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _showLandingDispatchCriteria() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: const SizedBox(
        width: 680,
        child: SingleChildScrollView(child: _LandingDispatchCriteria()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _showLandingDispatchProcedure() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: const SizedBox(
        width: 680,
        child: SingleChildScrollView(child: _LandingDispatchProcedure()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  void _setLandingDispatchRequired(bool value) {
    final flight = widget.flight;
    if (flight == null) return;
    final rlw = value ? '' : '192776';
    _controllers['rlw']!.text = rlw;
    widget.onFlightChanged(
      flight.copyWith(
        landingDispatchRequired: value,
        landingDispatchAnswered: true,
        regulatedLandingWeight: rlw,
        loadsheetInitialized: false,
        regulatedWeightsSent: false,
      ),
    );
  }

  void _sendInitialLoadsheet() {
    final flight = widget.flight;
    if (flight == null ||
        flight.calculatedRtow.isEmpty ||
        _controllers['rlw']!.text.isEmpty ||
        flight.flightDeckCount + flight.cabinCrewCount <= 0 ||
        _controllers['captainPayroll']!.text.isEmpty) {
      return;
    }
    widget.onFlightChanged(
      flight.copyWith(
        regulatedLandingWeight: _controllers['rlw']!.text,
        captainPayrollNumber: _controllers['captainPayroll']!.text,
        loadsheetInitialized: true,
        regulatedWeightsSent: true,
      ),
    );
  }

  void _undoInitialLoadsheetSent() {
    final flight = widget.flight;
    if (flight == null) return;
    widget.onFlightChanged(
      flight.copyWith(loadsheetInitialized: false, regulatedWeightsSent: false),
    );
  }

  bool _canSendInitialLoadsheet(FlightBriefing flight) =>
      flight.calculatedRtow.isNotEmpty &&
      _controllers['rlw']!.text.isNotEmpty &&
      flight.flightDeckCount + flight.cabinCrewCount > 0 &&
      _controllers['captainPayroll']!.text.isNotEmpty;

  Future<void> _confirmInitialLoadsheetSent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Confirm sent to GLC?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) _sendInitialLoadsheet();
  }

  Widget _stepHeader(String number, String title, {String? role}) => Row(
    children: [
      CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFF315F86),
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      if (role != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE1E9F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            role,
            style: const TextStyle(
              color: Color(0xFF315F86),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
    ],
  );

  Widget _performanceField(String label, String key) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: _controllers[key]!,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) => _update(key, value),
    ),
  );

  Widget _loadsheetField(String label, String key) => TextField(
    controller: _controllers[key]!,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      labelText: label,
      hintText: 'To come',
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
    ),
    onChanged: (value) => _update(key, value),
  );

  String _preliminaryTow(FlightBriefing flight) {
    final zfw = double.tryParse(flight.actualZeroFuelWeight);
    final rampFuel = double.tryParse(flight.blockFuel);
    if (zfw == null || rampFuel == null) return '';
    final value = zfw + rampFuel;
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  void _update(String field, String value) {
    final flight = widget.flight;
    if (flight == null) return;
    widget.onFlightChanged(switch (field) {
      'actualZfw' => flight.copyWith(actualZeroFuelWeight: value),
      'actualTow' => flight.copyWith(actualTakeoffWeight: value),
      'actualLwt' => flight.copyWith(actualLandingWeight: value),
      'rtow' => flight.copyWith(
        calculatedRtow: value,
        loadsheetInitialized: false,
        regulatedWeightsSent: false,
      ),
      'zfwCg' => flight.copyWith(airbusZfwCg: value),
      'stabCg' => flight.copyWith(airbusStabCg: value),
      'prelimThrust' => flight.copyWith(preliminaryThrustSetting: value),
      'prelimFlap' => flight.copyWith(preliminaryFlapSetting: value),
      'actualCg' => flight.copyWith(actualTakeoffCg: value),
      'finalThrust' => flight.copyWith(finalThrustSetting: value),
      'finalFlap' => flight.copyWith(finalFlapSetting: value),
      'atis' => flight.copyWith(atisLetter: value),
      'rlw' => flight.copyWith(
        regulatedLandingWeight: value,
        loadsheetInitialized: false,
        regulatedWeightsSent: false,
      ),
      'captainPayroll' => flight.copyWith(
        captainPayrollNumber: value,
        loadsheetInitialized: false,
        regulatedWeightsSent: false,
      ),
      _ => flight,
    });
  }

  void _updateFlag(String field, bool value) {
    final flight = widget.flight;
    if (flight == null) return;
    widget.onFlightChanged(switch (field) {
      'finalZfwReceived' => flight.copyWith(finalZfwReceived: value),
      'preliminaryComplete' => flight.copyWith(
        preliminaryPerformanceComplete: value,
      ),
      'efbEntered' => flight.copyWith(efbPerformanceEntered: value),
      'loadsheetReceived' => flight.copyWith(finalLoadsheetReceived: value),
      'finalComplete' => flight.copyWith(finalPerformanceComplete: value),
      'atisRetained' => flight.copyWith(atisPrintedAndRetained: value),
      'loadsheetInitialized' => flight.copyWith(loadsheetInitialized: value),
      'weightsSent' => flight.copyWith(
        regulatedLandingWeight: _controllers['rlw']!.text,
        regulatedWeightsSent: value,
      ),
      _ => flight,
    });
  }

  String _flightKey(FlightBriefing? flight) =>
      '${flight?.callsign}|${flight?.flightDate?.toIso8601String()}|${flight?.route}|${flight?.aircraftType}';
}

class _WeightColumn extends StatelessWidget {
  const _WeightColumn({
    required this.title,
    required this.subtitle,
    required this.colour,
    required this.children,
  });
  final String title;
  final String subtitle;
  final Color colour;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colour,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF667069), fontSize: 12),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );
}

class _PlannedWeight extends StatelessWidget {
  const _PlannedWeight({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFC7D4E2)),
    ),
    child: Row(
      children: [
        const Icon(Icons.lock_outline_rounded, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          value.isEmpty ? 'Not found in OFP' : '$value kg',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _EntryField extends StatelessWidget {
  const _EntryField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.suffix,
    this.decimal = false,
  });
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? suffix;
  final bool decimal;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    ),
  );
}

class _RtowField extends StatelessWidget {
  const _RtowField({
    required this.controller,
    required this.onChanged,
    required this.onOpenChecklist,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenChecklist;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF244A73),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Text(
                'CALCULATED RTOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onOpenChecklist,
                tooltip: 'Open RTOW procedure',
                padding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                icon: const Icon(Icons.fact_check_outlined, size: 21),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 220,
          child: TextField(
            controller: controller,
            cursorColor: const Color(0xFF173D31),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: Color(0xFF173D31),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter RTOW',
              hintStyle: TextStyle(color: Color(0xFF6D7E8D)),
              suffixText: 'kg',
              suffixStyle: TextStyle(color: Color(0xFF315F86)),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8FA8C0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _CalculatedRlwField extends StatelessWidget {
  const _CalculatedRlwField({
    required this.controller,
    required this.onChanged,
    required this.onOpenChecklist,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenChecklist;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF244A73),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Text(
                'CALCULATED RLW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onOpenChecklist,
                tooltip: 'Open Landing Dispatch procedure',
                padding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
                color: Colors.white,
                icon: const Icon(Icons.fact_check_outlined, size: 21),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 220,
          child: TextField(
            controller: controller,
            cursorColor: const Color(0xFF173D31),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: Color(0xFF173D31),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter RLW',
              hintStyle: TextStyle(color: Color(0xFF6D7E8D)),
              suffixText: 'kg',
              suffixStyle: TextStyle(color: Color(0xFF315F86)),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8FA8C0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _LandingDispatchDecision extends StatelessWidget {
  const _LandingDispatchDecision({
    required this.answered,
    required this.required,
    required this.onChanged,
    required this.onOpenInfo,
  });

  final bool answered;
  final bool required;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenInfo;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFEAF3FA),
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Is a Landing Dispatch calculation required?',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Check whether a calculation is required',
            onPressed: onOpenInfo,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 6),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Yes')),
              ButtonSegment(value: false, label: Text('No')),
            ],
            selected: answered ? {required} : const <bool>{},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onChanged(selection.first);
            },
          ),
        ],
      ),
    ),
  );
}

class _LandingDispatchCriteria extends StatelessWidget {
  const _LandingDispatchCriteria();

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFEAF3FA),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: Color(0xFFB9D1E4)),
    ),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You do not need a Landing Dispatch calculation if all of these apply:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          _CriteriaItem('Runway LDA is at least 8,000 ft.'),
          _CriteriaItem(
            'Expected OAT is 26°C or below when aerodrome elevation is 2,501–5,600 ft AMSL.',
          ),
          _CriteriaItem(
            'Expected OAT is 40°C or below when aerodrome elevation is 2,500 ft AMSL or lower.',
          ),
          _CriteriaItem('QNH is at least 970 hPa.'),
          _CriteriaItem('There is no tailwind component.'),
          _CriteriaItem('Expected runway condition is dry.'),
          _CriteriaItem(
            'No MEL or CDL dispatch condition affects landing performance.',
          ),
          _CriteriaItem('Missed approach climb gradient is 2.5% or less.'),
          SizedBox(height: 8),
          Text(
            'Criteria are based on a maximum landing weight of 192,776 kg.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _LandingDispatchProcedure extends StatelessWidget {
  const _LandingDispatchProcedure();

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFCBD5DE)),
    ),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tablet_mac_rounded, color: Color(0xFF315F86)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'How to calculate RLW on Portable EFB in the OPT app',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _ReferenceStep(
            number: 1,
            text: 'Confirm PERFORMANCE – LANDING – DISPATCH.',
          ),
          _ReferenceStep(number: 2, text: 'Confirm the correct aircraft.'),
          _ReferenceStep(number: 3, text: 'Enter MEL and CDL data.'),
          _ReferenceStep(number: 4, text: 'Enter ARPT.'),
          _ReferenceStep(number: 5, text: 'Enter RWY.'),
          _ReferenceStep(number: 6, text: 'Enter all remaining data.'),
          SizedBox(height: 8),
          _LandingDispatchEstimateNote(),
          _ReferenceStep(number: 7, text: 'Press CALC.'),
          SizedBox(height: 10),
          Text(
            'Reference aid only — verify against the current approved company and aircraft procedure.',
            style: TextStyle(color: Color(0xFF667069), fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _LandingDispatchEstimateNote extends StatelessWidget {
  const _LandingDispatchEstimateNote();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF3FA),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFB9D1E4)),
    ),
    child: const Text(
      'Note: The OAT and QNH entered will be estimates based upon the best available information.',
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}

class _CriteriaItem extends StatelessWidget {
  const _CriteriaItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline, size: 16),
        ),
        const SizedBox(width: 7),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _RtowCalculationReference extends StatefulWidget {
  const _RtowCalculationReference();

  @override
  State<_RtowCalculationReference> createState() =>
      _RtowCalculationReferenceState();
}

class _RtowCalculationReferenceState extends State<_RtowCalculationReference> {
  bool _portableEfbUnavailable = false;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFCBD5DE)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _portableEfbUnavailable
                    ? Icons.phonelink_erase_rounded
                    : Icons.tablet_mac_rounded,
                color: const Color(0xFF315F86),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _portableEfbUnavailable
                      ? 'No Portable EFB'
                      : 'How to calculate RTOW on Portable EFB in the OPT app',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_portableEfbUnavailable)
            const _PortableEfbUnavailableNote()
          else ...const [
            _ReferenceStep(
              number: 1,
              text: 'Confirm PERFORMANCE – TAKEOFF in the top tab bar.',
            ),
            _ReferenceStep(number: 2, text: 'Confirm the correct aircraft.'),
            _ReferenceStep(
              number: 3,
              text: 'Select AIRPORT INFO and confirm AIRPORT DATA.',
            ),
            _ReferenceStep(number: 4, text: 'Enter NOTAM, MEL and CDL data.'),
            _ReferenceStep(number: 5, text: 'Enter ARPT.'),
            _ReferenceStep(number: 6, text: 'Enter RWY.'),
            _ReferenceStep(
              number: 7,
              text:
                  'Use OPTIMUM RTG and OPTIMUM FLAP unless conditions dictate otherwise.',
            ),
            _ReferenceStep(number: 8, text: 'Do not enter TOW, ZFW or CG.'),
            _ReferenceStep(number: 9, text: 'Enter all remaining data.'),
            _ReferenceStep(number: 10, text: 'Press CALC.'),
            SizedBox(height: 10),
            _RtowOutputSection(),
            SizedBox(height: 8),
            _ReferenceWarning(),
            SizedBox(height: 8),
            _CrosswindReferenceNote(),
          ],
          const SizedBox(height: 10),
          const Text(
            'Reference aid only — verify against the current approved company and aircraft procedure.',
            style: TextStyle(color: Color(0xFF667069), fontSize: 11),
          ),
          const Divider(height: 22),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Portable EFB or OPT APP failure?'),
            value: _portableEfbUnavailable,
            onChanged: (value) =>
                setState(() => _portableEfbUnavailable = value ?? false),
          ),
        ],
      ),
    ),
  );
}

class _PortableEfbUnavailableNote extends StatelessWidget {
  const _PortableEfbUnavailableNote();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1DA),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE3B96F)),
    ),
    child: const Text(
      'Refer to OPT Device Failures in Chapter SP, Section 20.',
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}

class _RtowOutputSection extends StatelessWidget {
  const _RtowOutputSection();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFE7F4EA),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF9FC9AA)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OUTPUT',
          style: TextStyle(
            color: Color(0xFF28634A),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5),
        Text('• Verify the correct RWY / INTX position.'),
        Text(
          '• Note TOGW (RTOW).',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _ReferenceStep extends StatelessWidget {
  const _ReferenceStep({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25,
          child: Text(
            '$number.',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _ReferenceWarning extends StatelessWidget {
  const _ReferenceWarning();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1DA),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE3B96F)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ignore the following message:',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 4),
        Text(
          '“For limit weight calculation, maximum crosswind has not been checked for this runway condition”.',
        ),
      ],
    ),
  );
}

class _CrosswindReferenceNote extends StatelessWidget {
  const _CrosswindReferenceNote();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFE8EEF6),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF9BB1CB)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CROSSWIND LIMIT CONSIDERATION',
          style: TextStyle(
            color: Color(0xFF315F86),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Refer to “Take-off Crosswind Guidelines – TALPA ARC” in FCTM Chapter 3, section “Crosswind Take-off”, or QRH OI “Runway Condition Matrix and Crosswind Limits”.',
        ),
      ],
    ),
  );
}

class _PerformanceFormula extends StatelessWidget {
  const _PerformanceFormula({
    required this.finalZfw,
    required this.rampFuel,
    required this.takeoffWeight,
  });
  final String finalZfw;
  final String rampFuel;
  final String takeoffWeight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFC7D4E2)),
    ),
    child: Row(
      children: [
        Expanded(child: _value('FINAL ZFW', finalZfw)),
        const Text(
          '+',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Expanded(child: _value('RAMP FUEL', rampFuel)),
        const Text(
          '=',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Expanded(child: _value('PRELIM TOW', takeoffWeight, highlight: true)),
        const SizedBox(width: 8),
        const Column(
          children: [
            Text(
              'ASSUMED CG',
              style: TextStyle(fontSize: 10, color: Color(0xFF667069)),
            ),
            Text('25%', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    ),
  );

  Widget _value(String label, String value, {bool highlight = false}) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF667069)),
      ),
      Text(
        value.isEmpty ? 'Pending' : '$value kg',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: highlight ? const Color(0xFF315F86) : null,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _ActualValue extends StatelessWidget {
  const _ActualValue({
    required this.label,
    required this.value,
    this.suffix = 'kg',
    this.compact = false,
  });
  final String label;
  final String value;
  final String? suffix;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.symmetric(horizontal: 11, vertical: compact ? 9 : 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFC6DCCD)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF667069), fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(
          value.isEmpty
              ? 'Pending'
              : suffix == null
              ? value
              : '$value $suffix',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _MaxPayloadPlanNote extends StatelessWidget {
  const _MaxPayloadPlanNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1DA),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE3B96F)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFF8A5B13)),
            SizedBox(width: 8),
            Text(
              'MAX PAYLOAD PLAN · CREW NOTE',
              style: TextStyle(
                color: Color(0xFF8A5B13),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'For OFPs stating “Max Payload Plan” on the front page:',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 8),
        Text(
          '• Ensure GLC are advised of any change to flight plan fuel figures that may affect the PLN ZFW.',
        ),
        Text(
          '• If RTOW is greater than the OFP planned take-off weight, calculate the additional fuel to be carried and send free-text ACARS to GLC.',
        ),
        Text(
          '• If RTOW is less than the OFP planned take-off weight, calculate the reduction in fuel to be carried and send free-text ACARS to GLC.',
        ),
        Text(
          '• Whenever additional fuel is needed regardless of RTOW—for example due to destination weather—send free-text ACARS to GLC.',
        ),
        SizedBox(height: 12),
        Text(
          'ACARS TEXT FORMAT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFFFF8EC),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: SelectableText(
              'PRED FUEL FP + (or -) x.x T.',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Verify against the current company procedure and operational flight plan.',
          style: TextStyle(color: Color(0xFF795A29), fontSize: 12),
        ),
      ],
    ),
  );
}
