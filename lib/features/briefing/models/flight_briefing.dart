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
    required this.aircraftType,
    required this.registration,
    required this.planType,
    required this.documents,
  });
  final String flightNumber;
  final String route;
  final String departureTime;
  final String arrivalTime;
  final String aircraftType;
  final String registration;
  final String planType;
  final List<BriefingDocument> documents;
}
