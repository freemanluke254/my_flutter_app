import 'package:flutter/material.dart';

import 'b787_preflight_checklist.dart';

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

class _FlightPhaseChecklist extends StatefulWidget {
  const _FlightPhaseChecklist();

  @override
  State<_FlightPhaseChecklist> createState() => _FlightPhaseChecklistState();
}

class _FlightPhaseChecklistState extends State<_FlightPhaseChecklist> {
  final Set<String> _done = {};
  final Set<int> _notApplicable = {};
  int _activePhase = 0;

  static const _phases = <_FlightPhase>[
    _FlightPhase(
      title: 'Before start',
      source: 'FCOM Normal Procedures · OMB Chapter 2',
      gate: 'Complete the current controlled Before Start checklist.',
      items: [
        _FlightCheck('doors', 'Doors and passenger/cargo status confirmed'),
        _FlightCheck(
          'loads',
          'Final loadsheet and take-off data cross-check complete',
        ),
        _FlightCheck(
          'clearance',
          'ATC clearance and FMC route agreement confirmed',
        ),
        _FlightCheck(
          'brief',
          'Threat-based departure brief and roles confirmed',
        ),
        _FlightCheck(
          'ground',
          'Ground team, pushback and start plan coordinated',
        ),
      ],
    ),
    _FlightPhase(
      title: 'Pushback, start & taxi',
      source: 'FCOM Normal Procedures · OMB Ground Operations',
      gate: 'Use the approved engine-start and taxi checklists.',
      items: [
        _FlightCheck(
          'push_clear',
          'Push/start clearance and ramp conditions confirmed',
        ),
        _FlightCheck(
          'start_monitor',
          'Engine start monitored; indications and messages assessed',
        ),
        _FlightCheck(
          'taxi_clearance',
          'Taxi clearance understood and route cross-checked',
        ),
        _FlightCheck(
          'taxi_threats',
          'Hotspots, restrictions, braking and low-visibility threats reviewed',
        ),
        _FlightCheck(
          'controls',
          'Required taxi checks completed without distraction',
        ),
      ],
    ),
    _FlightPhase(
      title: 'Before take-off & departure',
      source: 'FCOM Normal Procedures · OMB Departure Procedures',
      gate: 'Complete the approved Before Take-off checklist.',
      items: [
        _FlightCheck(
          'lineup',
          'Runway, intersection and remaining distance positively identified',
        ),
        _FlightCheck(
          'departure_change',
          'Late clearance, weather or runway changes reassessed',
        ),
        _FlightCheck(
          'cabin_ready',
          'Cabin secure status received and recorded',
        ),
        _FlightCheck(
          'takeoff_data_check',
          'Displayed take-off data matches the accepted calculation',
        ),
        _FlightCheck(
          'departure_monitor',
          'Initial routing, altitude and navigation mode awareness shared',
        ),
      ],
    ),
    _FlightPhase(
      title: 'Climb & cruise',
      source: 'FCOM Normal Procedures · OMB In-flight Procedures',
      gate:
          'Use the appropriate controlled climb/cruise checklist and non-normal procedure.',
      items: [
        _FlightCheck(
          'climb_transition',
          'Climb transition and altimeter requirements actioned',
        ),
        _FlightCheck(
          'fuel_first',
          'Fuel quantity, balance and OFP trend checked',
        ),
        _FlightCheck(
          'weather_route',
          'En-route weather, turbulence and route threats updated',
        ),
        _FlightCheck(
          'systems_cruise',
          'Aircraft status and deferred-defect implications monitored',
        ),
        _FlightCheck(
          'crew_coordination',
          'Cabin and relief-crew handovers include current threats',
        ),
      ],
    ),
    _FlightPhase(
      title: 'Oceanic / remote operations when applicable',
      source: 'OMB Long-range Navigation · current route manuals',
      gate:
          'Current NAT HLA/oceanic procedures and clearance remain controlling.',
      optional: true,
      items: [
        _FlightCheck(
          'oceanic_clearance',
          'Oceanic clearance independently checked against the flight plan',
        ),
        _FlightCheck(
          'entry_check',
          'Entry-point time, level, speed and navigation status verified',
        ),
        _FlightCheck(
          'comms',
          'Required communication and surveillance capability confirmed',
        ),
        _FlightCheck(
          'position_monitor',
          'Position, fuel and navigation performance monitored at required intervals',
        ),
        _FlightCheck(
          'contingency_review',
          'Applicable weather-deviation and contingency procedures reviewed',
        ),
      ],
    ),
    _FlightPhase(
      title: 'Descent & approach',
      source: 'FCOM Normal Procedures · OMB Arrival Procedures',
      gate: 'Complete the approved Descent and Approach checklists.',
      items: [
        _FlightCheck(
          'arrival_info',
          'Latest destination and alternate weather/NOTAMs reviewed',
        ),
        _FlightCheck(
          'landing_perf',
          'Landing performance completed with approved source and cross-checked',
        ),
        _FlightCheck(
          'arrival_route',
          'STAR, approach, constraints and missed approach verified',
        ),
        _FlightCheck(
          'arrival_tEM',
          'Arrival threats, mitigations and diversion decision points briefed',
        ),
        _FlightCheck(
          'cabin_descent',
          'Cabin crew advised of arrival conditions and expected landing time',
        ),
      ],
    ),
    _FlightPhase(
      title: 'Landing, taxi-in & shutdown',
      source: 'FCOM Normal Procedures · OMB Post-flight Procedures',
      gate: 'Complete the approved Landing and Shutdown checklists.',
      items: [
        _FlightCheck(
          'landing_change',
          'Runway condition or landing change reassessed before commitment',
        ),
        _FlightCheck(
          'vacate',
          'Runway vacated and ground route positively confirmed',
        ),
        _FlightCheck(
          'stand',
          'Stand, guidance and ground personnel status confirmed',
        ),
        _FlightCheck('shutdown', 'Shutdown flow and checklist completed'),
        _FlightCheck(
          'defects_recorded',
          'Technical and cabin defects entered and handed over',
        ),
      ],
    ),
    _FlightPhase(
      title: 'Post-flight & logbook',
      source: 'OMB Reporting Procedures · UK flight-time record requirements',
      gate: 'Check company reporting and occurrence-reporting requirements.',
      items: [
        _FlightCheck(
          'actual_times',
          'Actual off/on-block and take-off/landing times captured',
        ),
        _FlightCheck(
          'fuel_arrival',
          'Arrival fuel and uplift/usage records captured where required',
        ),
        _FlightCheck(
          'journey_log',
          'Sector, aircraft, capacity and duty details reviewed for logbook draft',
        ),
        _FlightCheck(
          'reports',
          'Safety, technical or operational reports identified and submitted',
        ),
        _FlightCheck(
          'handover',
          'Documents, EFB and aircraft handover completed',
        ),
      ],
    ),
  ];

  int get _total => _phases.fold(0, (sum, phase) => sum + phase.items.length);

  bool _phaseComplete(int index) =>
      _notApplicable.contains(index) ||
      _phases[index].items.every((item) => _done.contains(item.id));

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '787-9 flight workflow',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text('${_done.length}/$_total'),
          IconButton(
            tooltip: 'Reset workflow',
            onPressed: () => setState(() {
              _done.clear();
              _notApplicable.clear();
              _activePhase = 0;
            }),
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const _WorkflowWarning(),
      const SizedBox(height: 12),
      SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _phases.length,
          separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (context, index) => ChoiceChip(
            selected: index == _activePhase,
            avatar: Icon(
              _phaseComplete(index)
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 17,
            ),
            label: Text('${index + 1}. ${_phases[index].shortTitle}'),
            onSelected: (_) => setState(() => _activePhase = index),
          ),
        ),
      ),
      const SizedBox(height: 10),
      _phaseCard(context),
    ],
  );

  Widget _phaseCard(BuildContext context) {
    final phase = _phases[_activePhase];
    final complete = _phaseComplete(_activePhase);
    final checked = phase.items.where((item) => _done.contains(item.id)).length;
    return Card(
      elevation: 0,
      color: const Color(0xFFFBFAF6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PHASE ${_activePhase + 1} OF ${_phases.length}',
              style: const TextStyle(
                color: Color(0xFF28634A),
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              phase.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              '${phase.source} · $checked/${phase.items.length}',
              style: const TextStyle(color: Color(0xFF6C756F), fontSize: 12),
            ),
            const Divider(height: 24),
            ...phase.items.map(
              (item) => CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _done.contains(item.id),
                title: Text(item.label),
                onChanged: _notApplicable.contains(_activePhase)
                    ? null
                    : (value) => setState(
                        () => value == true
                            ? _done.add(item.id)
                            : _done.remove(item.id),
                      ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4, bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9D2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                phase.gate,
                style: const TextStyle(
                  color: Color(0xFF6E451B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (phase.optional)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _notApplicable.contains(_activePhase),
                title: const Text('Not applicable to this sector'),
                onChanged: (value) => setState(() {
                  value == true
                      ? _notApplicable.add(_activePhase)
                      : _notApplicable.remove(_activePhase);
                }),
              ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _activePhase == 0
                      ? null
                      : () => setState(() => _activePhase--),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: complete && _activePhase < _phases.length - 1
                      ? () => setState(() => _activePhase++)
                      : null,
                  icon: Icon(
                    _activePhase == _phases.length - 1
                        ? Icons.flag_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    _activePhase == _phases.length - 1
                        ? 'Workflow complete'
                        : 'Complete & continue',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowWarning extends StatelessWidget {
  const _WorkflowWarning();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Workflow summary derived from the supplied FCOM and Operations Manual Part B. It is a preparation and progress aid, not an approved checklist. Current controlled manuals, EFB checklists and crew procedures always take precedence.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}

class _FlightPhase {
  const _FlightPhase({
    required this.title,
    required this.source,
    required this.gate,
    required this.items,
    this.optional = false,
  });
  final String title, source, gate;
  final List<_FlightCheck> items;
  final bool optional;

  String get shortTitle => title.split(' & ').first;
}

class _FlightCheck {
  const _FlightCheck(this.id, this.label);
  final String id, label;
}
