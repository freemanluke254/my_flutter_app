part of '../b787_operational_workflow.dart';

const _flightPhases = <_FlightPhase>[
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
      _FlightCheck('brief', 'Threat-based departure brief and roles confirmed'),
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
      _FlightCheck('cabin_ready', 'Cabin secure status received and recorded'),
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
