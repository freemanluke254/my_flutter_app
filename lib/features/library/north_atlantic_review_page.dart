import 'package:flutter/material.dart';

part 'models/nat_module.dart';
part 'widgets/north_atlantic_widgets.dart';

class NorthAtlanticReviewPage extends StatefulWidget {
  const NorthAtlanticReviewPage({super.key});

  @override
  State<NorthAtlanticReviewPage> createState() =>
      _NorthAtlanticReviewPageState();
}

class _NorthAtlanticReviewPageState extends State<NorthAtlanticReviewPage> {
  final Set<int> _reviewed = {};

  static const _modules = <_NatModule>[
    _NatModule(
      'Airspace, approval & capability',
      'Understand what makes NAT HLA different and establish that the aircraft, crew and flight are eligible.',
      [
        'Identify the portions of the route that use NAT HLA or other special airspace.',
        'Confirm the operational approval and required navigation, communication and surveillance capability.',
        'Relate serviceability, MEL restrictions and flight-plan capability codes to the planned route.',
        'Identify the applicable navigation-performance and datalink monitoring requirements.',
      ],
      'NAT Operations Manual — operational approval/equipment sections · OMC Navigation Appendix 1–2 · OMB limitations',
      'What defect or capability change would make you reassess the planned oceanic route?',
    ),
    _NatModule(
      'Pre-flight route & fuel planning',
      'Build a shared mental model of the oceanic portion before accepting the aircraft and plan.',
      [
        'Review the OFP route, organised-track information when applicable, levels, speeds and boundary points.',
        'Review forecast winds, significant weather, turbulence, alternates and diversion options.',
        'Check fuel planning, ETOPS considerations and critical or decision points using approved sources.',
        'Confirm waypoint coordinates and route data using the company-prescribed independent cross-check method.',
        'Brief threats such as weather, congestion, equipment status and route amendments.',
      ],
      'NAT Operations Manual — flight planning · OMC Navigation Ch 2–3 · OMA 8 · OMB Ch 5',
      'Which parts of the oceanic route must be independently checked, and against what source?',
    ),
    _NatModule(
      'Oceanic clearance',
      'Understand the clearance lifecycle and prevent a difference between the cleared route and the FMC/OFP.',
      [
        'Know when and through which available system the clearance should be requested.',
        'Record the clearance using the operator-approved method without relying on memory.',
        'Both pilots compare route, level and speed elements with the request, OFP and FMC.',
        'Resolve any difference or ambiguity with ATC before oceanic entry.',
        'Re-brief and re-check the route when a revised clearance is received.',
      ],
      'NAT Operations Manual — oceanic clearances · OMC Navigation Ch 3 · company datalink procedures',
      'If the clearance differs from the request, what must be changed and independently verified?',
    ),
    _NatModule(
      'Before oceanic entry',
      'Use a deliberate entry gate so navigation, communication, clearance and fuel status agree.',
      [
        'Confirm the aircraft is following the cleared route and the next oceanic waypoints are correctly sequenced.',
        'Verify navigation-system status and the required navigation performance indication.',
        'Confirm communication and surveillance logons or checks required for the route.',
        'Compare actual fuel and timing with the OFP and review developing threats.',
        'Complete the current company oceanic-entry procedure at the prescribed time or position.',
      ],
      'NAT Operations Manual — entry procedures · OMC Navigation Ch 3 · FCOM SP.20 NAT HLA procedure',
      'What independent evidence tells both pilots the aircraft will enter on the cleared route?',
    ),
    _NatModule(
      'Communications & surveillance',
      'Know which system is primary, which systems are backups and how communication status is monitored.',
      [
        'Identify the applicable voice, CPDLC, ADS-C and SELCAL arrangements for the route and FIR.',
        'Monitor logon/connection status and respond to messages using standard crew cross-check discipline.',
        'Maintain the required listening watch and know when a frequency or agency change is expected.',
        'Recognise a degraded or failed communication path early and transition to the prescribed alternative.',
      ],
      'NAT Operations Manual — communications/surveillance · OMC Navigation Ch 6 · ICAO Doc 4444',
      'What are the primary and backup communication paths for today’s route?',
    ),
    _NatModule(
      'In-flight navigation monitoring',
      'Continuously detect route, waypoint, timing or navigation-performance errors before they develop.',
      [
        'Use the operator-prescribed waypoint, track and distance checks rather than passive FMC observation.',
        'Monitor cross-track position, navigation performance, system disagreement and unexpected mode changes.',
        'Compare waypoint passage times and fuel against the OFP at the required intervals.',
        'Include route, clearance, communications, weather and fuel status in any crew handover.',
        'Report and manage suspected navigation error using current company and ATC procedures.',
      ],
      'NAT Operations Manual — navigation procedures · OMC Navigation Ch 3 · FCOM flight-management chapters',
      'Which cues would alert you to a developing gross navigation error?',
    ),
    _NatModule(
      'Strategic lateral offset',
      'Understand why the offset procedure exists and how it interacts with weather and contingency manoeuvres.',
      [
        'Review the current eligibility, direction and permitted offset options before use.',
        'Apply the procedure only using current published and operator guidance.',
        'Maintain crew awareness of the selected offset and confirm it remains appropriate.',
        'Distinguish a strategic offset from a weather deviation or contingency procedure.',
      ],
      'Current NAT Operations Manual — strategic lateral offset procedure',
      'How would both pilots confirm that an offset is intentional rather than a navigation error?',
    ),
    _NatModule(
      'Weather deviation & turbulence',
      'Prepare for deviations early and know when normal ATC coordination changes into contingency action.',
      [
        'Use weather radar, forecasts and reports to identify the need for action early.',
        'Request and verify a revised clearance whenever communication and time permit.',
        'If a clearance cannot be obtained, use the current published contingency procedure—not remembered values.',
        'Coordinate flight-path, communications, cabin and fuel implications between both pilots.',
        'Re-establish the cleared route only in accordance with ATC and published procedures.',
      ],
      'NAT Operations Manual — weather deviation/contingencies · ICAO Doc 4444 · OMB abnormal procedures',
      'At what point would today’s weather plan require a new clearance, extra fuel review or diversion decision?',
    ),
    _NatModule(
      'Communication or navigation degradation',
      'Recognise the failure, stabilise the operation and use the current regional contingency path.',
      [
        'Identify exactly which capability is lost and which independent systems remain available.',
        'Attempt the prescribed alternative communication or navigation method.',
        'Inform ATC and other aircraft as required using current published phraseology and channels.',
        'Protect the cleared flight path while consulting the controlled failure/contingency procedure.',
        'Reassess airspace eligibility, fuel, diversion options and downstream operational impact.',
      ],
      'NAT Operations Manual — communications/navigation failures · ICAO Doc 4444 · QRH/ECL',
      'Which remaining capability would you use to verify position after a navigation-system disagreement?',
    ),
    _NatModule(
      'Oceanic exit & post-flight review',
      'Transition cleanly back to domestic airspace and capture anything that requires follow-up.',
      [
        'Anticipate the next agency, clearance, frequency and domestic airspace requirements.',
        'Confirm route and altitude constraints beyond the oceanic boundary.',
        'Review destination weather, NOTAMs, landing performance and fuel state.',
        'Record navigation, communication or surveillance anomalies in the technical log and reports as required.',
        'Capture useful operational lessons without replacing formal safety reporting.',
      ],
      'NAT Operations Manual — exit/reporting · OMC Navigation · OMA occurrence reporting',
      'What event during the crossing would require a technical-log entry or safety report?',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('North Atlantic review')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'NAT HLA study path',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        const Text(
          'From flight planning to oceanic exit',
          style: TextStyle(color: Color(0xFF6C756F)),
        ),
        const SizedBox(height: 14),
        _Progress(reviewed: _reviewed.length, total: _modules.length),
        const SizedBox(height: 12),
        const _NatSafetyNotice(),
        const SizedBox(height: 10),
        const _SourceCoverage(),
        const SizedBox(height: 12),
        ..._modules.indexed.map(
          (record) => _ModuleCard(
            number: record.$1 + 1,
            module: record.$2,
            reviewed: _reviewed.contains(record.$1),
            onReviewed: (value) => setState(() {
              value ? _reviewed.add(record.$1) : _reviewed.remove(record.$1);
            }),
          ),
        ),
      ],
    ),
  );
}
