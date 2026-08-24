import 'package:flutter/material.dart';

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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.number,
    required this.module,
    required this.reviewed,
    required this.onReviewed,
  });
  final int number;
  final _NatModule module;
  final bool reviewed;
  final ValueChanged<bool> onReviewed;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xFFFBFAF6),
    margin: const EdgeInsets.only(bottom: 9),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: reviewed
            ? const Color(0xFF28634A)
            : const Color(0xFFDCEADD),
        foregroundColor: reviewed ? Colors.white : const Color(0xFF28634A),
        child: reviewed ? const Icon(Icons.check_rounded) : Text('$number'),
      ),
      title: Text(
        module.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(module.purpose),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        ...module.points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.arrow_right_rounded, size: 18),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(point, style: const TextStyle(height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Combined notes by source',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        ...module.sourceNotes.map(
          (note) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFE8),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.$1,
                  style: const TextStyle(
                    color: Color(0xFF28634A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(note.$2, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFE4EEE7),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            'Review question: ${module.question}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Source trail: ${module.source}',
            style: const TextStyle(color: Color(0xFF6C756F), fontSize: 11),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: reviewed,
          title: const Text('Reviewed against current controlled material'),
          onChanged: (value) => onReviewed(value ?? false),
        ),
      ],
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.reviewed, required this.total});
  final int reviewed, total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF173D31),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.public_rounded, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$reviewed of $total modules reviewed',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : reviewed / total,
            color: const Color(0xFFE2B878),
            backgroundColor: const Color(0xFF46675C),
          ),
        ),
      ],
    ),
  );
}

class _NatSafetyNotice extends StatelessWidget {
  const _NatSafetyNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE9D2),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Study aid only. NAT procedures, contingency values, offsets, frequencies and datalink requirements change. For a flight, use the current NAT manual, company OMC/OMB, OFP, NOTAMs, clearance and approved EFB procedures.',
      style: TextStyle(
        color: Color(0xFF6E451B),
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}

class _SourceCoverage extends StatelessWidget {
  const _SourceCoverage();

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
    collapsedBackgroundColor: const Color(0xFFE4EEE7),
    backgroundColor: const Color(0xFFE4EEE7),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    collapsedShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(13),
    ),
    title: const Text(
      'Sources combined in this guide',
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: const Text('Tap to view coverage and precedence'),
    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
    children: const [
      _CoverageRow(
        source: 'NAT Operations and Airspace Manual',
        role: 'Regional operating framework and procedures',
      ),
      _CoverageRow(
        source: 'OMC Navigation + NAT HLA revisions',
        role: 'Company route, equipment and operating application',
      ),
      _CoverageRow(
        source: 'B787 FCOM',
        role: 'Aircraft-specific FMC, navigation and communication operation',
      ),
      _CoverageRow(
        source: 'OMA and B787 OMB',
        role:
            'Company policy, fuel, ETOPS, briefing and type-specific procedures',
      ),
      _CoverageRow(
        source: 'ICAO Doc 4444',
        role: 'ATC framework, clearances and applicable contingency context',
      ),
      SizedBox(height: 8),
      Text(
        'Apply the current company manual hierarchy and the latest operational instruction. A newer revision or flight-specific instruction can supersede this study summary.',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _CoverageRow extends StatelessWidget {
  const _CoverageRow({required this.source, required this.role});
  final String source, role;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.check_circle_outline_rounded, size: 18),
    title: Text(source, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(role),
  );
}

class _NatModule {
  const _NatModule(
    this.title,
    this.purpose,
    this.points,
    this.source,
    this.question,
  );
  final String title, purpose, source, question;
  final List<String> points;

  List<(String, String)> get sourceNotes => switch (title) {
    'Airspace, approval & capability' => const [
      (
        'NAT MANUAL',
        'Defines the regional airspace concept and the navigation, communication, surveillance and monitoring framework expected for the intended operation.',
      ),
      (
        'OMC NAVIGATION / NAT REVISION',
        'Translates regional requirements into company equipment, flight-plan coding and route-eligibility checks; the revision supplement must be checked for changes.',
      ),
      (
        'B787 FCOM',
        'Provides the aircraft-specific status indications and operation of the FMC, RNP monitoring, ADS-C, CPDLC, HF and related systems.',
      ),
      (
        'OMA / OMB',
        'Adds company approval, crew responsibility, MEL assessment and type-specific operational limitations.',
      ),
    ],
    'Pre-flight route & fuel planning' => const [
      (
        'NAT MANUAL',
        'Sets the regional planning context for routes, tracks, boundary points, levels, speeds, weather and alternates.',
      ),
      (
        'OMC NAVIGATION',
        'Adds company planning, independent route verification, airspace and navigation-database controls.',
      ),
      (
        'OMB CHAPTER 5 / OMA CHAPTER 8',
        'Provides the company OFP, fuel, ETOPS and in-flight replanning framework that must be applied to the NAT route.',
      ),
      (
        'B787 FCOM',
        'Provides the aircraft-specific FMC route, winds and performance-data loading and cross-check method.',
      ),
    ],
    'Oceanic clearance' => const [
      (
        'NAT MANUAL',
        'Explains the regional clearance process, clearance content, amendments and the need to resolve differences before entry.',
      ),
      (
        'OMC NAVIGATION / NAT REVISION',
        'Adds the company method for requesting, recording, reading back and independently checking the clearance, including current datalink changes.',
      ),
      (
        'B787 FCOM',
        'Covers aircraft-specific datalink handling and the FMC changes required to make the cleared route the active, verified route.',
      ),
      (
        'ICAO DOC 4444',
        'Provides the broader ATC clearance framework; the regional NAT and company procedures provide the more specific application.',
      ),
    ],
    'Before oceanic entry' => const [
      (
        'NAT MANUAL',
        'Identifies the entry-risk controls: cleared route, navigation accuracy, communications/surveillance and crew monitoring.',
      ),
      (
        'OMC NAVIGATION',
        'Defines the company entry workflow and independent checks, including how revised clearances and system degradations are handled.',
      ),
      (
        'B787 FCOM SP.20',
        'Provides the 787-specific NAT HLA procedure and the relevant FMC/navigation indications used by the crew.',
      ),
      (
        'OMB / OFP',
        'Adds the threat brief, actual-versus-planned fuel review and flight-specific route/timing information.',
      ),
    ],
    'Communications & surveillance' => const [
      (
        'NAT MANUAL',
        'Describes the regional voice, datalink and surveillance environment and the expected use of primary and backup paths.',
      ),
      (
        'OMC NAVIGATION',
        'Adds company procedures for logon, monitoring, HF/SELCAL use, message handling and degraded communications.',
      ),
      (
        'B787 FCOM',
        'Explains operation and status indications for CPDLC, ADS-C, SATCOM/HF and flight-deck communication functions.',
      ),
      (
        'ICAO DOC 4444',
        'Supplies the ATC communication and clearance context, including the basis for failure handling.',
      ),
    ],
    'In-flight navigation monitoring' => const [
      (
        'NAT MANUAL',
        'Focuses on preventing and detecting gross navigation errors through active route, position and system-performance monitoring.',
      ),
      (
        'OMC NAVIGATION',
        'Defines company waypoint, track, distance, timing and cross-track checks plus the required response to suspected error.',
      ),
      (
        'B787 FCOM',
        'Provides the FMC pages, navigation-performance indications and system comparisons used to perform those checks on the 787.',
      ),
      (
        'OMB / OFP',
        'Adds fuel-progress monitoring, crew handover expectations and operational reporting requirements.',
      ),
    ],
    'Strategic lateral offset' => const [
      (
        'NAT MANUAL',
        'Is the controlling source for the current purpose, eligibility and permitted application of the strategic offset procedure.',
      ),
      (
        'OMC NAVIGATION',
        'Adds company technique, crew cross-check and any operational restrictions or reporting expectations.',
      ),
      (
        'B787 FCOM',
        'Provides the aircraft-specific method for creating and monitoring an intentional lateral offset in the FMC.',
      ),
      (
        'IMPORTANT DISTINCTION',
        'A strategic offset is not the same as a weather deviation or contingency manoeuvre; use the correct current procedure for the situation.',
      ),
    ],
    'Weather deviation & turbulence' => const [
      (
        'NAT MANUAL',
        'Provides the regional weather-deviation and contingency framework when normal clearance coordination is unavailable.',
      ),
      (
        'ICAO DOC 4444',
        'Provides the associated international ATC contingency basis and communication context.',
      ),
      (
        'OMC NAVIGATION / OMA',
        'Adds company decision-making, communication, fuel and reporting requirements.',
      ),
      (
        'B787 FCOM / OMB',
        'Adds aircraft weather-radar use, turbulence procedures, FMC route modification and type-specific limitations.',
      ),
    ],
    'Communication or navigation degradation' => const [
      (
        'NAT MANUAL',
        'Defines regional expectations and contingency routes for loss or degradation of required capability.',
      ),
      (
        'OMC NAVIGATION',
        'Adds company failure recognition, backup-system use, ATC coordination and airspace-eligibility reassessment.',
      ),
      (
        'B787 FCOM / QRH / ECL',
        'Provide aircraft-specific indications, system operation and the controlled non-normal response.',
      ),
      (
        'ICAO DOC 4444 / OMA',
        'Add ATC contingency context plus company diversion, reporting and commander decision requirements.',
      ),
    ],
    'Oceanic exit & post-flight review' => const [
      (
        'NAT MANUAL',
        'Covers transition from the oceanic system and follow-up for regional navigation or communication events.',
      ),
      (
        'OMC NAVIGATION',
        'Adds company exit checks, domestic-airspace transition and navigation-performance reporting.',
      ),
      (
        'B787 FCOM / OMB',
        'Provide aircraft setup for descent/arrival and the technical-log treatment of system anomalies.',
      ),
      (
        'OMA',
        'Defines company occurrence, safety and operational reporting responsibilities after the flight.',
      ),
    ],
    _ => const [],
  };
}
