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

  Widget _rtowAndLoadsheetSetup(FlightBriefing flight) => Material(
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
          const Text(
            'RTOW & LOADSHEET SETUP',
            style: TextStyle(
              color: Color(0xFF315F86),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _stepHeader('1', 'RTOW · Calculate', role: 'C, F/O'),
              ),
              IconButton(
                tooltip: 'How to calculate RTOW',
                onPressed: _showRtowProcedure,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF315F86),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IgnorePointer(
            ignoring: flight.atisLetter.isEmpty,
            child: Opacity(
              opacity: flight.atisLetter.isEmpty ? 0.5 : 1,
              child: _RtowField(
                controller: _controllers['rtow']!,
                onChanged: (value) => _update('rtow', value),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _LandingDispatchCriteria(),
          const SizedBox(height: 8),
          const _ProcedureNote(
            title: 'PORTABLE EFB / OPT APP UNAVAILABLE',
            text:
                'If no portable pilot-attached EFB OPT app is available—for example following portable EFB or OPT app failures—refer to OPT Device Failures in Chapter SP, Section 20.',
            warning: true,
          ),
          const Divider(height: 28),
          _stepHeader(
            '2',
            'Initialise the loadsheet in the aircraft COMM page',
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Loadsheet initialised'),
            value: flight.loadsheetInitialized,
            onChanged: flight.calculatedRtow.isEmpty
                ? null
                : (value) =>
                      _updateFlag('loadsheetInitialized', value ?? false),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _ActualValue(
                  label: 'RTOW TO SEND',
                  value: flight.calculatedRtow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _weightField('RLW TO SEND', 'rlw')),
            ],
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('RTOW and RLW sent through COMM'),
            subtitle: const Text(
              'The B787 RLW is prefilled to 192,776 kg and remains amendable.',
            ),
            value: flight.regulatedWeightsSent,
            onChanged:
                !flight.loadsheetInitialized ||
                    flight.calculatedRtow.isEmpty ||
                    _controllers['rlw']!.text.isEmpty
                ? null
                : (value) => _updateFlag('weightsSent', value ?? false),
          ),
        ],
      ),
    ),
  );

  Future<void> _showRtowProcedure() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('How to calculate RTOW'),
      content: const SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: _RtowCalculationReference(initiallyExpanded: true),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

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
      'rtow' => flight.copyWith(calculatedRtow: value),
      'zfwCg' => flight.copyWith(airbusZfwCg: value),
      'stabCg' => flight.copyWith(airbusStabCg: value),
      'prelimThrust' => flight.copyWith(preliminaryThrustSetting: value),
      'prelimFlap' => flight.copyWith(preliminaryFlapSetting: value),
      'actualCg' => flight.copyWith(actualTakeoffCg: value),
      'finalThrust' => flight.copyWith(finalThrustSetting: value),
      'finalFlap' => flight.copyWith(finalFlapSetting: value),
      'atis' => flight.copyWith(atisLetter: value),
      'rlw' => flight.copyWith(regulatedLandingWeight: value),
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
  const _RtowField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF244A73),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CALCULATED RTOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'B787 crew-entered regulated take-off weight',
                style: TextStyle(color: Color(0xFFDCE8F3)),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 220,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter RTOW',
              hintStyle: TextStyle(color: Color(0xFFB8CADB)),
              suffixText: 'kg',
              suffixStyle: TextStyle(color: Colors.white),
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
    child: const ExpansionTile(
      dense: true,
      leading: Icon(Icons.flight_land_rounded, color: Color(0xFF315F86)),
      title: Text(
        'Is a Landing Dispatch calculation needed?',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text('Open to check all exemption criteria'),
      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You do not need a Landing Dispatch calculation if all of these apply:',
          style: TextStyle(fontWeight: FontWeight.w800),
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
        SizedBox(height: 8),
        Text(
          'When a Landing Dispatch calculation is required, enter estimated OAT and QNH in OPT using the best available information.',
        ),
      ],
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

class _RtowCalculationReference extends StatelessWidget {
  const _RtowCalculationReference({this.initiallyExpanded = false});

  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFCBD5DE)),
    ),
    child: ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      leading: const Icon(Icons.fact_check_outlined, color: Color(0xFF315F86)),
      title: const Text(
        'How to calculate RTOW',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: const Text('OPT take-off setup sequence'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ReferenceStep(
          number: 1,
          text: 'Confirm the correct aircraft is displayed at the top left.',
        ),
        _ReferenceStep(
          number: 2,
          text: 'Select or confirm TAKEOFF in the tab bar.',
        ),
        _ReferenceStep(
          number: 3,
          text: 'Confirm the selected module shows PERFORMANCE – TAKEOFF.',
        ),
        _ReferenceStep(number: 4, text: 'Enter ARPT.'),
        _ReferenceStep(number: 5, text: 'Enter RWY.'),
        _ReferenceStep(
          number: 6,
          text: 'Select AIRPORT INFO and confirm AIRPORT DATA as needed.',
        ),
        _ReferenceStep(
          number: 7,
          text: 'Enter NOTAM, MEL and CDL data as appropriate.',
        ),
        _ReferenceStep(
          number: 8,
          text: 'Enter all remaining appropriate data.',
        ),
        _ReferenceStep(
          number: 9,
          text:
              'Use OPTIMUM RTG and OPTIMUM FLAP unless conditions dictate otherwise.',
        ),
        _ReferenceStep(number: 10, text: 'Do not enter TOW, ZFW or CG.'),
        _ReferenceStep(number: 11, text: 'Press CALC.'),
        SizedBox(height: 8),
        _ReferenceWarning(),
        _ReferenceStep(number: 12, text: 'Press DONE.'),
        SizedBox(height: 8),
        _CrosswindReferenceNote(),
        _ReferenceStep(
          number: 13,
          text: 'Verify the correct RWY / INTX position.',
        ),
        _ReferenceStep(number: 14, text: 'Note TOGW.'),
        _ReferenceStep(
          number: 15,
          text: 'Notify the Captain that the RTOW calculation is complete.',
        ),
        SizedBox(height: 10),
        Text(
          'Reference aid only — verify against the current approved company and aircraft procedure.',
          style: TextStyle(color: Color(0xFF667069), fontSize: 11),
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
          'MESSAGE INSTRUCTION',
          style: TextStyle(
            color: Color(0xFF8A5B13),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text('Ignore the following message:'),
        SizedBox(height: 3),
        Text(
          '“For limit weight calculation, maximum crosswind has not been checked for this runway condition”.',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _ProcedureNote extends StatelessWidget {
  const _ProcedureNote({
    required this.title,
    required this.text,
    this.warning = false,
  });

  final String title;
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final background = warning
        ? const Color(0xFFFFF1DA)
        : const Color(0xFFEAF3FA);
    final border = warning ? const Color(0xFFE3B96F) : const Color(0xFFB9D1E4);
    final foreground = warning
        ? const Color(0xFF8A5B13)
        : const Color(0xFF315F86);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 19,
            color: foreground,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
          'At this stage, refer to “Take-off Crosswind Guidelines – TALPA ARC” in FCTM Chapter 3, section “Crosswind Take-off”, or QRH OI “Runway Condition Matrix and Crosswind Limits”.',
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
  const _ActualValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          value.isEmpty ? 'Pending' : '$value kg',
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
