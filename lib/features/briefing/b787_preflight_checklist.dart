import 'package:flutter/material.dart';

part 'models/preflight_procedure.dart';
part 'data/preflight_stages.dart';
part 'widgets/preflight_checklist_widgets.dart';

class B787PreflightChecklist extends StatefulWidget {
  const B787PreflightChecklist({super.key});

  @override
  State<B787PreflightChecklist> createState() => _B787PreflightChecklistState();
}

class _B787PreflightChecklistState extends State<B787PreflightChecklist> {
  final Set<String> _completed = {};
  final _atis = TextEditingController();
  final _rtow = TextEditingController();
  final _rampFuel = TextEditingController();
  final _clearance = TextEditingController();
  String _role = 'First Officer';

  int get _total =>
      _preflightStages.fold(0, (total, stage) => total + stage.items.length);

  @override
  void dispose() {
    _atis.dispose();
    _rtow.dispose();
    _rampFuel.dispose();
    _clearance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '787-9 preflight flow',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Arrival at aircraft → Before Start boundary',
                  style: TextStyle(color: Color(0xFF6C756F)),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: _reset,
            tooltip: 'Reset checklist',
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      const SizedBox(height: 14),
      const _ManualNotice(),
      const SizedBox(height: 14),
      _ProgressCard(done: _completed.length, total: _total),
      const SizedBox(height: 14),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'Captain', label: Text('Captain')),
          ButtonSegment(value: 'First Officer', label: Text('First Officer')),
        ],
        selected: {_role},
        onSelectionChanged: (value) => setState(() => _role = value.first),
      ),
      const SizedBox(height: 14),
      ..._preflightStages.map(
        (stage) => _StageCard(
          stage: stage,
          completed: _completed,
          onChanged: _toggle,
          input: _inputFor(stage),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFECE1CD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.stop_circle_outlined, color: Color(0xFF79562E)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Before Start boundary reached. Continue only with the current controlled Before Start procedure and checklist.',
                style: TextStyle(
                  color: Color(0xFF654C31),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget? _inputFor(_ProcedureStage stage) {
    if (stage.reference == 'FCOM NP.21.7–9') {
      return _DataCapture(
        children: [
          TextField(
            controller: _atis,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'ATIS record',
              hintText:
                  'Designator, time, runway, wind, visibility, cloud, temperature, QNH…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _rtow,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Approved OPT RTOW result',
              suffixText: 'kg',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This app records the approved calculation; it does not calculate certified take-off performance.',
            style: TextStyle(color: Color(0xFF6C756F), fontSize: 11),
          ),
        ],
      );
    }
    if (stage.reference == 'FCOM NP.21.39–41') {
      return _DataCapture(
        children: [
          TextField(
            controller: _rampFuel,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Agreed ramp fuel',
              suffixText: 'kg',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
    if (stage.reference == 'FCOM NP.21.41–47') {
      return _DataCapture(
        children: [
          TextField(
            controller: _clearance,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Departure clearance / briefing notes',
              hintText: 'Runway, SID, initial level, squawk and threats…',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
    return null;
  }

  void _toggle(String id, bool value) =>
      setState(() => value ? _completed.add(id) : _completed.remove(id));

  void _reset() {
    setState(() {
      _completed.clear();
      _atis.clear();
      _rtow.clear();
      _rampFuel.clear();
      _clearance.clear();
    });
  }
}
