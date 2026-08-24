part of '../b787_preflight_checklist.dart';

const _preflightStages = <_ProcedureStage>[
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
