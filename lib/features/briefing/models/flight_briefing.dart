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
  });
  final BriefingDocumentType type;
  final String title;
  final int fileCount;

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
    this.finalReserveFuel = '',
    this.extraFuel = '',
    this.flightDeckCount = 3,
    this.cabinCrewCount = 10,
    this.fsm = '',
    this.css = '',
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
  final String finalReserveFuel;
  final String extraFuel;
  final int flightDeckCount;
  final int cabinCrewCount;
  final String fsm;
  final String css;

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
    String? finalReserveFuel,
    String? extraFuel,
    int? flightDeckCount,
    int? cabinCrewCount,
    String? fsm,
    String? css,
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
    finalReserveFuel: finalReserveFuel ?? this.finalReserveFuel,
    extraFuel: extraFuel ?? this.extraFuel,
    flightDeckCount: flightDeckCount ?? this.flightDeckCount,
    cabinCrewCount: cabinCrewCount ?? this.cabinCrewCount,
    fsm: fsm ?? this.fsm,
    css: css ?? this.css,
  );
}
