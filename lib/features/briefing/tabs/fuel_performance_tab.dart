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
        Text(
          'Fuel & performance',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
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
          _RtowField(
            controller: _controllers['rtow']!,
            onChanged: (value) => _update('rtow', value),
          ),
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
      _ => flight,
    });
  }

  String _flightKey(FlightBriefing? flight) =>
      '${flight?.callsign}|${flight?.flightDate?.toIso8601String()}|${flight?.route}';
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
