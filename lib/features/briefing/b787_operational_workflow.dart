import 'package:flutter/material.dart';

import 'b787_preflight_checklist.dart';

part 'workflow/flight_phase_checklist.dart';
part 'data/flight_phases.dart';

class B787OperationalWorkflow extends StatefulWidget {
  const B787OperationalWorkflow({super.key});

  @override
  State<B787OperationalWorkflow> createState() =>
      _B787OperationalWorkflowState();
}

class _B787OperationalWorkflowState extends State<B787OperationalWorkflow> {
  String _section = 'setup';

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'setup', label: Text('Aircraft setup')),
            ButtonSegment(value: 'phases', label: Text('Flight phases')),
          ],
          selected: {_section},
          onSelectionChanged: (value) {
            setState(() => _section = value.first);
          },
        ),
      ),
      Expanded(
        child: IndexedStack(
          index: _section == 'setup' ? 0 : 1,
          children: const [B787PreflightChecklist(), _FlightPhaseChecklist()],
        ),
      ),
    ],
  );
}
