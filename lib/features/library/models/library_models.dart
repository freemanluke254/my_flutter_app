part of '../operations_library_page.dart';

class _LibraryDocument {
  const _LibraryDocument(this.title, this.category, this.status, this.code);
  final String title, category, status, code;
}

class _LibraryEntry {
  const _LibraryEntry(
    this.title,
    this.category,
    this.summary,
    this.source,
    this.keywords, {
    this.timeSensitive = false,
    this.controlledOnly = false,
  });
  final String title, category, summary, source;
  final List<String> keywords;
  final bool timeSensitive, controlledOnly;

  String get searchText =>
      '$title $category $summary $source ${keywords.join(' ')}'.toLowerCase();

  List<String> get sourceCoverage => switch (category) {
    'Aircraft' => const ['FCOM', 'OMB', 'OMA policy'],
    'Flight operations' => const ['OMA', 'OMB', 'FCOM where applicable'],
    'Navigation' => const [
      'OMC Navigation',
      'NAT Manual/revisions',
      'FCOM/OMB',
      'ICAO where applicable',
    ],
    'ATC' => const ['ICAO Doc 4444', 'OMC regional', 'OMA/OMB company'],
    'Contingencies' => const [
      'Current operational notice',
      'OMA/OMB',
      'FCOM/QRH/ECL',
      'ICAO/regional',
    ],
    'Airports' => const [
      'OMC Area/Aerodrome',
      'OMC Navigation',
      'OMA/OMB',
      'Current chart/NOTAM',
    ],
    'Training' => const ['OMD', 'OMA qualification policy', 'OMB/FCOM content'],
    _ => const [],
  };

  List<(String, List<String>)> get briefingSections => switch (category) {
    'Airports' => [
      (
        'Briefing objective',
        [
          'Build a current operational picture of the aerodrome rather than relying on remembered experience.',
          'Identify the airport-specific threats that affect this aircraft, crew, weather and planned runway.',
        ],
      ),
      (
        'Information to gather',
        [
          'Current charts, NOTAMs, ATIS/METAR/TAF, runway condition, declared distances and applicable company notices.',
          'Parking/stand information, ground-movement restrictions, hotspots, low-visibility arrangements and local communication requirements.',
          'Departure, arrival, approach and missed-approach procedures plus relevant terrain, noise and airspace constraints.',
        ],
      ),
      (
        'Operational review flow',
        [
          'Confirm document currency and identify the expected runway configuration.',
          'Review ground movement from stand to runway or runway to stand, including hotspots and stop-bar threats.',
          'Compare the expected SID/STAR/approach with charts, FMC coding, weather and NOTAM restrictions.',
          'Complete approved take-off or landing performance using the actual runway condition and declared distances.',
          'Brief threats, mitigations, rejected-take-off or missed-approach considerations and any diversion trigger.',
        ],
      ),
      (
        'Before operating',
        [
          'Recheck late runway, weather, NOTAM, stand or clearance changes.',
          'Use the current chart and ATC clearance when they differ from historic aerodrome notes.',
        ],
      ),
    ],
    'Aircraft' => [
      (
        'What to understand',
        [
          summary,
          'Identify the normal system state, crew indications, automatic functions, controls and operational limitations relevant to the subject.',
        ],
      ),
      (
        'Review sequence',
        [
          'Start with the FCOM system description to understand architecture and normal logic.',
          'Add FCOM normal or supplementary procedures that show how the crew operates and monitors the system.',
          'Apply OMB company techniques, limitations and cross-check requirements.',
          'Review related EICAS messages and locate the controlling QRH/ECL non-normal procedure without memorising unapproved steps.',
        ],
      ),
      (
        'Operational application',
        [
          'Connect system status to MEL/CDL restrictions, dispatch decisions and performance consequences.',
          'Brief expected indications, monitoring responsibilities and the cues that require a checklist or engineering involvement.',
        ],
      ),
    ],
    'Flight operations' => [
      (
        'Policy and purpose',
        [
          summary,
          'Separate regulatory/company policy, aircraft technique and flight-specific data before making a decision.',
        ],
      ),
      (
        'Preparation',
        [
          'Identify eligibility, limitations, required approvals and the data source that controls the calculation or decision.',
          'Review the OFP, weather, NOTAMs, aircraft status, MEL/CDL and applicable alternates or diversion options.',
        ],
      ),
      (
        'Operating flow',
        [
          'Calculate or retrieve the result using the approved company system.',
          'Independently cross-check inputs, units, assumptions and resulting operational margin.',
          'Monitor actual progress against the plan and define the point at which a re-plan or commander decision is required.',
          'Record, communicate and report the result in the company-prescribed manner.',
        ],
      ),
    ],
    'Navigation' => [
      (
        'Operational picture',
        [
          summary,
          'Establish the airspace requirement, aircraft capability, approval, database status and contingency path.',
        ],
      ),
      (
        'Procedure flow',
        [
          'Validate the planned route and procedure against current charts, airspace information and company authorisation.',
          'Confirm required navigation, communication and surveillance equipment is serviceable and correctly represented in the flight plan.',
          'Load and independently verify route, waypoint, altitude and performance data using approved source material.',
          'Monitor navigation performance, cross-track position, system agreement and ATC clearance compliance.',
          'Use the current regional/company contingency procedure if capability or communication is degraded.',
        ],
      ),
    ],
    'ATC' => [
      (
        'Procedure briefing',
        [
          summary,
          'Identify the applicable global rule, regional variation and company procedure for the airspace being flown.',
          'Record and cross-check clearances; resolve ambiguity before acting.',
          'Monitor compliance with route, level, speed and communication requirements.',
          'For failure or contingency, use current published procedures and phraseology rather than recalled values.',
        ],
      ),
    ],
    'Contingencies' => [
      (
        'Situation briefing',
        [
          summary,
          'Confirm that any operational notice remains active and determine the flight-specific exposure.',
        ],
      ),
      (
        'Decision workflow',
        [
          'Maintain aircraft control and use the current QRH/ECL or published contingency procedure.',
          'Identify available communication, navigation, fuel, diversion and airspace options.',
          'Coordinate with ATC, dispatch, cabin and other agencies as the current procedure requires.',
          'Reassess the plan whenever weather, clearance, system capability or regional status changes.',
          'Complete required technical, safety and operational reporting after the event.',
        ],
      ),
    ],
    'Training' => [
      (
        'Study briefing',
        [
          summary,
          'Identify the applicable syllabus, entry requirements, checking standard, validity period and record-keeping requirement.',
          'Use the type-specific FCOM/OMB content for technical preparation and OMD for the training/checking framework.',
          'Track completion, expiry and revalidation requirements in the compliance section.',
        ],
      ),
    ],
    _ => [
      ('Overview', [summary]),
    ],
  };
}
