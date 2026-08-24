class BriefingFlight {
  const BriefingFlight({
    required this.flightNumber,
    required this.aircraft,
    required this.registration,
    required this.departure,
    required this.departureName,
    required this.departureTime,
    required this.arrival,
    required this.arrivalName,
    required this.arrivalTime,
    required this.blockTime,
    required this.reportTime,
    required this.gate,
  });

  final String flightNumber,
      aircraft,
      registration,
      departure,
      departureName,
      departureTime,
      arrival,
      arrivalName,
      arrivalTime,
      blockTime,
      reportTime,
      gate;
}
