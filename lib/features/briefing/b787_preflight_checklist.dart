import 'package:flutter/material.dart';

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

  static const _stages = <_ProcedureStage>[
    _ProcedureStage(
      title: 'Flight deck arrival & preliminary setup',
      reference: 'FCOM NP.21.1–6',
      items: [
        _ProcedureItem(
          'security',
          'Flight deck security and loose articles checked',
          'Both',
        ),
        _ProcedureItem(
          'controlled_preflight',
          'Planning complete; operational preflight started in a controlled environment with interruptions managed',
          'Both',
          source: 'OMB 2.2.2.1',
        ),
        _ProcedureItem(
          'crew_roles',
          'PF, PM, APIC and any additional-crew support roles agreed; operating-seat cross-check tasks protected',
          'Captain',
          source: 'OMB 2.2.4',
        ),
        _ProcedureItem(
          'efb_setup',
          'Portable EFB mounted, powered and flight applications configured',
          'Both',
        ),
        _ProcedureItem(
          'ehandshake_start',
          'eHandshake session started with flight and aircraft details',
          'Both',
        ),
        _ProcedureItem(
          'installed_efb',
          'Installed EFB status, data currency, messages and faults reviewed',
          'Both',
        ),
        _ProcedureItem(
          'tech_log',
          'Open, deferred, closed and cabin defects reviewed with technical notices and servicing data',
          'Captain',
          source: 'OMB 2.3.13',
        ),
        _ProcedureItem(
          'status',
          'Aircraft status, expected EICAS messages and dispatch quantities checked',
          'F/O',
        ),
        _ProcedureItem(
          'emergency_equipment',
          'Flight deck emergency equipment and required stowage checked',
          'F/O',
        ),
        _ProcedureItem(
          'door_test',
          'Flight deck door access system test completed',
          'F/O',
        ),
      ],
    ),
    _ProcedureStage(
      title: 'ATIS, RTOW & initial loadsheet',
      reference: 'FCOM NP.21.7–9',
      items: [
        _ProcedureItem(
          'route_identity',
          'Origin, destination and flight number entered and cross-checked',
          'Both',
        ),
        _ProcedureItem(
          'actual_aircraft_status',
          'Planning defects checked against the actual aircraft technical status on arrival',
          'Both',
          source: 'OMB 2.2.2.2',
        ),
        _ProcedureItem(
          'atis_obtained',
          'Current ATIS obtained and recorded below',
          'F/O',
        ),
        _ProcedureItem(
          'rtow_calculated',
          'RTOW calculated using the approved OPT source',
          'Both',
        ),
        _ProcedureItem(
          'rtow_crosscheck',
          'Aircraft, runway/intersection, weather, NOTAM and MEL/CDL inputs independently checked',
          'Both',
        ),
        _ProcedureItem(
          'declared_distances',
          'Runway and intersection declared distances verified against current ATIS and NOTAM information',
          'Both',
          source: 'OMB 2.3.11',
        ),
        _ProcedureItem(
          'raim_review',
          'OFP RAIM remarks reviewed where an RNAV or RNP operation is planned',
          'Both',
          source: 'OMB 2.2.2.4',
        ),
        _ProcedureItem(
          'loadsheet_init',
          'Initial loadsheet data checked and sent',
          'Both',
        ),
        _ProcedureItem(
          'fuel_change',
          'Any predicted fuel change communicated through the approved company channel',
          'Captain',
        ),
      ],
    ),
    _ProcedureStage(
      title: 'Role-specific cockpit preflight',
      reference: 'FCOM NP.21.9–23',
      items: [
        _ProcedureItem(
          'fo_scan',
          'First Officer panel scan and configuration completed',
          'F/O',
        ),
        _ProcedureItem(
          'capt_scan',
          'Captain panel scan and configuration completed',
          'Captain',
        ),
        _ProcedureItem(
          'oxygen_instruments',
          'Oxygen, flight instruments, displays and alert status checked',
          'Both',
        ),
        _ProcedureItem(
          'ground_restrictions',
          'Local ground-power, PCA and APU restrictions reviewed and applied',
          'Both',
          source: 'OMB 2.3.2',
        ),
        _ProcedureItem(
          'manned_lights',
          'Navigation-light requirement while the aircraft is manned confirmed',
          'Both',
          source: 'OMB 2.3.5',
        ),
        _ProcedureItem(
          'controls_position',
          'Flight controls, gear, brakes, flap and fuel control positions verified',
          'Both',
        ),
        _ProcedureItem(
          'preflight_checklist',
          'Preflight checklist called, completed and announced',
          'Both',
        ),
      ],
    ),
    _ProcedureStage(
      title: 'FMC & EFB preflight — pre-final ZFW',
      reference: 'FCOM NP.21.23–30',
      items: [
        _ProcedureItem(
          'fmc_identity',
          '787-9 model, engine fit, navigation database and performance factors verified',
          'PF/PM',
        ),
        _ProcedureItem(
          'position',
          'Time, aircraft position and IRS alignment checked',
          'PF/PM',
        ),
        _ProcedureItem(
          'route_uplink',
          'Correct route uplink received and matched to flight number, aircraft, STD and plan',
          'PF/PM',
        ),
        _ProcedureItem(
          'route_check',
          'Route, SID, STAR, approach, transitions and discontinuities reviewed',
          'PF/PM',
        ),
        _ProcedureItem(
          'rnav_procedure_check',
          'Published procedure and FMC track, distance, altitude and constraint data compared; required RNP and navigation serviceability confirmed',
          'PF/PM',
          source: 'OMB 2.2.2.4',
        ),
        _ProcedureItem(
          'distance_rnp',
          'Planned distance, RNP, reserves, cruise altitude and cost index checked',
          'PF/PM',
        ),
        _ProcedureItem(
          'winds',
          'Climb, cruise and descent winds loaded and checked for reasonableness',
          'PF/PM',
        ),
        _ProcedureItem(
          'drag_fuel_flow',
          'DRAG/FF entries checked against the OFP performance decrement and applicable MEL correction',
          'PF/PM',
          source: 'OMB 2.3.12',
        ),
        _ProcedureItem(
          'efb_initialise',
          'Installed EFB flight initialised; charts, databases and messages checked',
          'Both',
        ),
        _ProcedureItem(
          'fmc_checked',
          'PF declares FMC complete; PM independently declares it checked',
          'PF/PM',
        ),
      ],
    ),
    _ProcedureStage(
      title: 'Exterior inspection',
      reference: 'FCOM NP.21.31–38',
      items: [
        _ProcedureItem(
          'door_synoptic',
          'Door synoptic checked before leaving the flight deck and compared with actual door status',
          'Inspector',
          source: 'OMB 2.3.9',
        ),
        _ProcedureItem(
          'general_external',
          'Structures, surfaces, probes, ports, vents, lights and access panels inspected',
          'Inspector',
        ),
        _ProcedureItem(
          'landing_gear',
          'Wheels, tyres, brakes, gear, pins and wheel wells inspected',
          'Inspector',
        ),
        _ProcedureItem(
          'engines',
          'Both engines, inlets, fan areas, exhausts, reversers and panels inspected',
          'Inspector',
        ),
        _ProcedureItem(
          'wings_tail',
          'Wings, controls, fuel vents/nozzles, tail and static discharge wicks inspected',
          'Inspector',
        ),
        _ProcedureItem(
          'walkaround_complete',
          'Exterior inspection complete; discrepancies raised with engineering',
          'Inspector',
        ),
      ],
    ),
    _ProcedureStage(
      title: 'Final ZFW, fuel & preliminary performance',
      reference: 'FCOM NP.21.39–41',
      items: [
        _ProcedureItem(
          'final_zfw',
          'Final ZFW received; revised ramp fuel independently determined and agreed',
          'Both',
        ),
        _ProcedureItem(
          'finalise_loadsheet',
          'Finalise Loadsheet message completed, checked and sent',
          'Both',
        ),
        _ProcedureItem(
          'fuel_sent',
          'Agreed ramp fuel sent to refueller using eHandshake where applicable',
          'Captain',
        ),
        _ProcedureItem(
          'estimated_tow',
          'Estimated TOW independently calculated, agreed and checked against RTOW',
          'Both',
        ),
        _ProcedureItem(
          'prelim_perf',
          'Preliminary take-off performance independently calculated and compared',
          'Both',
        ),
        _ProcedureItem(
          'prelim_perf_basis',
          'Preliminary performance basis checked using final ZFW, ramp fuel and the operator-prescribed CG assumption',
          'Both',
          source: 'OMB 2.3.11',
        ),
        _ProcedureItem(
          'installed_efb_prep',
          'Installed EFB take-off page prepared with runway, NOTAM, MEL/CDL, rating and flap',
          'Both',
        ),
      ],
    ),
    _ProcedureStage(
      title: 'Joint departure preparation',
      reference: 'FCOM NP.21.41–47',
      items: [
        _ProcedureItem(
          'independent_tEM_review',
          'Both pilots independently reviewed weather, NOTAMs, airfield information and the FMC route before briefing',
          'Both',
          source: 'OMB 2.2.3',
        ),
        _ProcedureItem(
          'threat_brief',
          'Concise threat-based briefing completed with mitigations, role clarity and an understanding check',
          'PF leads',
          source: 'OMB 2.2.3',
        ),
        _ProcedureItem(
          'takeoff_brief',
          'Taxi, departure, take-off and applicable emergency-turn briefing completed',
          'PF leads',
        ),
        _ProcedureItem(
          'departure_clearance',
          'PDC/ATC clearance obtained, recorded and cross-checked against FMC',
          'Both',
        ),
        _ProcedureItem(
          'fuel_complete',
          'Refuelling complete; uplift data and receipt checked',
          'Captain',
        ),
        _ProcedureItem(
          'ehandshake_complete',
          'eHandshake workflow completed where enhanced mode is used',
          'Both',
        ),
        _ProcedureItem(
          'flight_acceptance',
          'Aircraft accepted only after engineering release; electronic log synchronisation confirmed',
          'Both',
          source: 'OMB 2.3.13',
        ),
        _ProcedureItem(
          'final_loadsheet',
          'Final loadsheet independently checked for gross errors, weights/index, passenger count, LMCs and required signatures',
          'Both',
          source: 'OMB 2.3.11.3',
        ),
        _ProcedureItem(
          'final_performance',
          'Final take-off performance calculated, cross-checked and transferred to FMC',
          'Both',
        ),
        _ProcedureItem(
          'takeoff_data',
          'Flap, thrust, runway, speeds, heights and climb setting verified',
          'Both',
        ),
        _ProcedureItem(
          'final_setup',
          'FMC preflight complete; displays, MCP, trim and fuel sufficiency confirmed',
          'Both',
        ),
      ],
    ),
  ];

  int get _total =>
      _stages.fold(0, (total, stage) => total + stage.items.length);

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
      ..._stages.map(
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

class _ProcedureStage {
  const _ProcedureStage({
    required this.title,
    required this.reference,
    required this.items,
  });
  final String title, reference;
  final List<_ProcedureItem> items;
}

class _ProcedureItem {
  const _ProcedureItem(this.id, this.label, this.owner, {this.source = 'FCOM'});
  final String id, label, owner, source;
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stage,
    required this.completed,
    required this.onChanged,
    required this.input,
  });
  final _ProcedureStage stage;
  final Set<String> completed;
  final void Function(String, bool) onChanged;
  final Widget? input;
  @override
  Widget build(BuildContext context) {
    final done = stage.items
        .where((item) => completed.contains(item.id))
        .length;
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
        leading: CircleAvatar(
          backgroundColor: done == stage.items.length
              ? const Color(0xFF28634A)
              : const Color(0xFFE9E7DE),
          foregroundColor: done == stage.items.length
              ? Colors.white
              : const Color(0xFF17211B),
          child: done == stage.items.length
              ? const Icon(Icons.check_rounded)
              : Text('$done'),
        ),
        title: Text(
          stage.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${stage.reference} · $done/${stage.items.length}'),
        children: [
          ...stage.items.map(
            (item) => CheckboxListTile(
              dense: true,
              value: completed.contains(item.id),
              onChanged: (value) => onChanged(item.id, value ?? false),
              title: Text(
                item.label,
                style: TextStyle(
                  decoration: completed.contains(item.id)
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(
                '${item.owner} · ${item.source}',
                style: const TextStyle(fontSize: 11),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          ?input,
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 15,
                  color: Color(0xFF6C756F),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Verify in ${stage.reference} and current company SOP',
                    style: const TextStyle(
                      color: Color(0xFF6C756F),
                      fontSize: 11,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 17),
                  label: const Text('Video later'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCapture extends StatelessWidget {
  const _DataCapture({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFF1EFE8),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(children: children),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});
  final int done, total;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: total == 0 ? 0 : done / total,
                backgroundColor: const Color(0xFF46675C),
                color: const Color(0xFFE2B878),
                strokeWidth: 6,
              ),
              Text(
                '$done',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PREFLIGHT PROGRESS',
                style: TextStyle(
                  color: Color(0xFFBFD8C8),
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$done of $total checks complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ManualNotice extends StatelessWidget {
  const _ManualNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Study and workflow aid cross-referenced to the attached FCOM and B787-9 Operations Manual Part B, Rev 20 (2 Apr 2026). FCOM and OMB prompts are labelled separately. This is not an approved electronic checklist: verify current revisions and use the AFM, FCOM, QRH, EFB, MEL and company procedures in their prescribed hierarchy.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}
