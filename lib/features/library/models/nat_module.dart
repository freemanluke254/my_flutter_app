part of '../north_atlantic_review_page.dart';

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
