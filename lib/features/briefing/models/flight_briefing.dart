import 'package:flutter/material.dart';

enum BriefingDocumentType {
  operationalFlightPlan,
  weather,
  notams,
  routeChart,
  significantWeather,
  tracks,
  terrain,
}

class BriefingDocument {
  const BriefingDocument({
    required this.type,
    required this.title,
    required this.fileCount,
    this.fileNames = const [],
    this.filePaths = const [],
  });
  final BriefingDocumentType type;
  final String title;
  final int fileCount;
  final List<String> fileNames;
  final List<String> filePaths;

  IconData get icon => switch (type) {
    BriefingDocumentType.operationalFlightPlan => Icons.description_outlined,
    BriefingDocumentType.weather => Icons.cloud_outlined,
    BriefingDocumentType.notams => Icons.campaign_outlined,
    BriefingDocumentType.routeChart => Icons.route_outlined,
    BriefingDocumentType.significantWeather => Icons.thunderstorm_outlined,
    BriefingDocumentType.tracks => Icons.public_outlined,
    BriefingDocumentType.terrain => Icons.terrain_outlined,
  };
}

class FlightBriefing {
  const FlightBriefing({
    required this.flightNumber,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    this.departureTimeUtc = '',
    this.arrivalTimeUtc = '',
    required this.aircraftType,
    required this.registration,
    required this.planType,
    required this.documents,
    this.callsign = '',
    this.planId = '',
    this.reportTime = '',
    this.scheduledDepartureUtc,
    this.flightDate,
    this.scheduledFlightTime = '',
    this.flightPlanTime = '',
    this.detailedRoute = '',
    this.captain = '',
    this.firstOfficer = '',
    this.reliefPilot = '',
    this.otherCrew = '',
    this.otherCrewRole = 'Other',
    this.pilotFlying = '',
    this.takeoffWeight = '',
    this.landingWeight = '',
    this.zeroFuelWeight = '',
    this.payload = '',
    this.blockFuel = '',
    this.taxiFuel = '',
    this.tripFuel = '',
    this.contingencyFuel = '',
    this.alternateFuel = '',
    this.finalReserveFuel = '',
    this.etpAdjustmentFuel = '',
    this.additionalFuel = '',
    this.unusableFuel = '',
    this.arrivalDelayFuel = '',
    this.extraFuel = '',
    this.discretionaryFuel = '',
    this.fuelTimes = const {},
    this.actualZeroFuelWeight = '',
    this.actualTakeoffWeight = '',
    this.actualLandingWeight = '',
    this.calculatedRtow = '',
    this.airbusZfwCg = '',
    this.airbusStabCg = '',
    this.maxPayloadPlan = false,
    this.finalZfwReceived = false,
    this.preliminaryThrustSetting = '',
    this.preliminaryFlapSetting = '',
    this.preliminaryPerformanceComplete = false,
    this.efbPerformanceEntered = false,
    this.finalLoadsheetReceived = false,
    this.actualTakeoffCg = '',
    this.finalThrustSetting = '',
    this.finalFlapSetting = '',
    this.finalPerformanceComplete = false,
    this.atisLetter = '',
    this.atisPrintedAndRetained = false,
    this.loadsheetInitialized = false,
    this.regulatedLandingWeight = '',
    this.regulatedWeightsSent = false,
    this.landingDispatchRequired = false,
    this.landingDispatchAnswered = false,
    this.flightDeckCount = 3,
    this.cabinCrewCount = 10,
    this.captainPayrollNumber = '',
    this.fsm = '',
    this.css = '',
    this.stand = '',
    this.melCdlReferences = '',
    this.defectSummary = '',
    this.operationalRestrictions = '',
  });
  final String flightNumber;
  final String route;
  final String departureTime;
  final String arrivalTime;
  final String departureTimeUtc;
  final String arrivalTimeUtc;
  final String aircraftType;
  final String registration;
  final String planType;
  final List<BriefingDocument> documents;
  final String callsign;
  final String planId;
  final String reportTime;
  final DateTime? scheduledDepartureUtc;
  final DateTime? flightDate;
  final String scheduledFlightTime;
  final String flightPlanTime;
  final String detailedRoute;
  final String captain;
  final String firstOfficer;
  final String reliefPilot;
  final String otherCrew;
  final String otherCrewRole;
  final String pilotFlying;
  final String takeoffWeight;
  final String landingWeight;
  final String zeroFuelWeight;
  final String payload;
  final String blockFuel;
  final String taxiFuel;
  final String tripFuel;
  final String contingencyFuel;
  final String alternateFuel;
  final String finalReserveFuel;
  final String etpAdjustmentFuel;
  final String additionalFuel;
  final String unusableFuel;
  final String arrivalDelayFuel;
  final String extraFuel;
  final String discretionaryFuel;
  final Map<String, String> fuelTimes;
  final String actualZeroFuelWeight;
  final String actualTakeoffWeight;
  final String actualLandingWeight;
  final String calculatedRtow;
  final String airbusZfwCg;
  final String airbusStabCg;
  final bool maxPayloadPlan;
  final bool finalZfwReceived;
  final String preliminaryThrustSetting;
  final String preliminaryFlapSetting;
  final bool preliminaryPerformanceComplete;
  final bool efbPerformanceEntered;
  final bool finalLoadsheetReceived;
  final String actualTakeoffCg;
  final String finalThrustSetting;
  final String finalFlapSetting;
  final bool finalPerformanceComplete;
  final String atisLetter;
  final bool atisPrintedAndRetained;
  final bool loadsheetInitialized;
  final String regulatedLandingWeight;
  final bool regulatedWeightsSent;
  final bool landingDispatchRequired;
  final bool landingDispatchAnswered;
  final int flightDeckCount;
  final int cabinCrewCount;
  final String captainPayrollNumber;
  final String fsm;
  final String css;
  final String stand;
  final String melCdlReferences;
  final String defectSummary;
  final String operationalRestrictions;

  FlightBriefing copyWith({
    String? flightNumber,
    String? route,
    String? departureTime,
    String? arrivalTime,
    String? departureTimeUtc,
    String? arrivalTimeUtc,
    String? aircraftType,
    String? registration,
    String? planType,
    List<BriefingDocument>? documents,
    String? callsign,
    String? planId,
    String? reportTime,
    DateTime? scheduledDepartureUtc,
    DateTime? flightDate,
    String? scheduledFlightTime,
    String? flightPlanTime,
    String? detailedRoute,
    String? captain,
    String? firstOfficer,
    String? reliefPilot,
    String? otherCrew,
    String? otherCrewRole,
    String? pilotFlying,
    String? takeoffWeight,
    String? landingWeight,
    String? zeroFuelWeight,
    String? payload,
    String? blockFuel,
    String? taxiFuel,
    String? tripFuel,
    String? contingencyFuel,
    String? alternateFuel,
    String? finalReserveFuel,
    String? etpAdjustmentFuel,
    String? additionalFuel,
    String? unusableFuel,
    String? arrivalDelayFuel,
    String? extraFuel,
    String? discretionaryFuel,
    Map<String, String>? fuelTimes,
    String? actualZeroFuelWeight,
    String? actualTakeoffWeight,
    String? actualLandingWeight,
    String? calculatedRtow,
    String? airbusZfwCg,
    String? airbusStabCg,
    bool? maxPayloadPlan,
    bool? finalZfwReceived,
    String? preliminaryThrustSetting,
    String? preliminaryFlapSetting,
    bool? preliminaryPerformanceComplete,
    bool? efbPerformanceEntered,
    bool? finalLoadsheetReceived,
    String? actualTakeoffCg,
    String? finalThrustSetting,
    String? finalFlapSetting,
    bool? finalPerformanceComplete,
    String? atisLetter,
    bool? atisPrintedAndRetained,
    bool? loadsheetInitialized,
    String? regulatedLandingWeight,
    bool? regulatedWeightsSent,
    bool? landingDispatchRequired,
    bool? landingDispatchAnswered,
    int? flightDeckCount,
    int? cabinCrewCount,
    String? captainPayrollNumber,
    String? fsm,
    String? css,
    String? stand,
    String? melCdlReferences,
    String? defectSummary,
    String? operationalRestrictions,
  }) => FlightBriefing(
    flightNumber: flightNumber ?? this.flightNumber,
    route: route ?? this.route,
    departureTime: departureTime ?? this.departureTime,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    departureTimeUtc: departureTimeUtc ?? this.departureTimeUtc,
    arrivalTimeUtc: arrivalTimeUtc ?? this.arrivalTimeUtc,
    aircraftType: aircraftType ?? this.aircraftType,
    registration: registration ?? this.registration,
    planType: planType ?? this.planType,
    documents: documents ?? this.documents,
    callsign: callsign ?? this.callsign,
    planId: planId ?? this.planId,
    reportTime: reportTime ?? this.reportTime,
    scheduledDepartureUtc: scheduledDepartureUtc ?? this.scheduledDepartureUtc,
    flightDate: flightDate ?? this.flightDate,
    scheduledFlightTime: scheduledFlightTime ?? this.scheduledFlightTime,
    flightPlanTime: flightPlanTime ?? this.flightPlanTime,
    detailedRoute: detailedRoute ?? this.detailedRoute,
    captain: captain ?? this.captain,
    firstOfficer: firstOfficer ?? this.firstOfficer,
    reliefPilot: reliefPilot ?? this.reliefPilot,
    otherCrew: otherCrew ?? this.otherCrew,
    otherCrewRole: otherCrewRole ?? this.otherCrewRole,
    pilotFlying: pilotFlying ?? this.pilotFlying,
    takeoffWeight: takeoffWeight ?? this.takeoffWeight,
    landingWeight: landingWeight ?? this.landingWeight,
    zeroFuelWeight: zeroFuelWeight ?? this.zeroFuelWeight,
    payload: payload ?? this.payload,
    blockFuel: blockFuel ?? this.blockFuel,
    taxiFuel: taxiFuel ?? this.taxiFuel,
    tripFuel: tripFuel ?? this.tripFuel,
    contingencyFuel: contingencyFuel ?? this.contingencyFuel,
    alternateFuel: alternateFuel ?? this.alternateFuel,
    finalReserveFuel: finalReserveFuel ?? this.finalReserveFuel,
    etpAdjustmentFuel: etpAdjustmentFuel ?? this.etpAdjustmentFuel,
    additionalFuel: additionalFuel ?? this.additionalFuel,
    unusableFuel: unusableFuel ?? this.unusableFuel,
    arrivalDelayFuel: arrivalDelayFuel ?? this.arrivalDelayFuel,
    extraFuel: extraFuel ?? this.extraFuel,
    discretionaryFuel: discretionaryFuel ?? this.discretionaryFuel,
    fuelTimes: fuelTimes ?? this.fuelTimes,
    actualZeroFuelWeight: actualZeroFuelWeight ?? this.actualZeroFuelWeight,
    actualTakeoffWeight: actualTakeoffWeight ?? this.actualTakeoffWeight,
    actualLandingWeight: actualLandingWeight ?? this.actualLandingWeight,
    calculatedRtow: calculatedRtow ?? this.calculatedRtow,
    airbusZfwCg: airbusZfwCg ?? this.airbusZfwCg,
    airbusStabCg: airbusStabCg ?? this.airbusStabCg,
    maxPayloadPlan: maxPayloadPlan ?? this.maxPayloadPlan,
    finalZfwReceived: finalZfwReceived ?? this.finalZfwReceived,
    preliminaryThrustSetting:
        preliminaryThrustSetting ?? this.preliminaryThrustSetting,
    preliminaryFlapSetting:
        preliminaryFlapSetting ?? this.preliminaryFlapSetting,
    preliminaryPerformanceComplete:
        preliminaryPerformanceComplete ?? this.preliminaryPerformanceComplete,
    efbPerformanceEntered: efbPerformanceEntered ?? this.efbPerformanceEntered,
    finalLoadsheetReceived:
        finalLoadsheetReceived ?? this.finalLoadsheetReceived,
    actualTakeoffCg: actualTakeoffCg ?? this.actualTakeoffCg,
    finalThrustSetting: finalThrustSetting ?? this.finalThrustSetting,
    finalFlapSetting: finalFlapSetting ?? this.finalFlapSetting,
    finalPerformanceComplete:
        finalPerformanceComplete ?? this.finalPerformanceComplete,
    atisLetter: atisLetter ?? this.atisLetter,
    atisPrintedAndRetained:
        atisPrintedAndRetained ?? this.atisPrintedAndRetained,
    loadsheetInitialized: loadsheetInitialized ?? this.loadsheetInitialized,
    regulatedLandingWeight:
        regulatedLandingWeight ?? this.regulatedLandingWeight,
    regulatedWeightsSent: regulatedWeightsSent ?? this.regulatedWeightsSent,
    landingDispatchRequired:
        landingDispatchRequired ?? this.landingDispatchRequired,
    landingDispatchAnswered:
        landingDispatchAnswered ?? this.landingDispatchAnswered,
    flightDeckCount: flightDeckCount ?? this.flightDeckCount,
    cabinCrewCount: cabinCrewCount ?? this.cabinCrewCount,
    captainPayrollNumber: captainPayrollNumber ?? this.captainPayrollNumber,
    fsm: fsm ?? this.fsm,
    css: css ?? this.css,
    stand: stand ?? this.stand,
    melCdlReferences: melCdlReferences ?? this.melCdlReferences,
    defectSummary: defectSummary ?? this.defectSummary,
    operationalRestrictions:
        operationalRestrictions ?? this.operationalRestrictions,
  );
}
