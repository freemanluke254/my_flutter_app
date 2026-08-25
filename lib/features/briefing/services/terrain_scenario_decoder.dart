class DecodedTerrainSegment {
  const DecodedTerrainSegment({
    required this.heading,
    required this.lines,
    required this.isCritical,
    this.emergencyDescentDiversion = '',
    this.engineOutDiversion = '',
    this.maximumTerrain = '',
    this.boundaryPoints = const [],
    this.engineRestriction = '',
    this.additionalInformation = const [],
  });

  final String heading;
  final List<String> lines;
  final bool isCritical;
  final String emergencyDescentDiversion;
  final String engineOutDiversion;
  final String maximumTerrain;
  final List<String> boundaryPoints;
  final String engineRestriction;
  final List<String> additionalInformation;
}

class DecodedTerrainScenario {
  const DecodedTerrainScenario({
    required this.title,
    required this.flight,
    required this.route,
    required this.scenarioRoute,
    required this.segments,
    required this.additionalInformation,
    required this.registrationAndType,
    required this.departure,
    required this.destination,
    required this.scheduledDeparture,
    required this.scheduledArrival,
    required this.flightTime,
    required this.variantAndRating,
    required this.forecastValidity,
  });

  final String title;
  final String flight;
  final String route;
  final String scenarioRoute;
  final List<DecodedTerrainSegment> segments;
  final List<String> additionalInformation;
  final String registrationAndType;
  final String departure;
  final String destination;
  final String scheduledDeparture;
  final String scheduledArrival;
  final String flightTime;
  final String variantAndRating;
  final String forecastValidity;
}

class TerrainScenarioDecoder {
  const TerrainScenarioDecoder();

  DecodedTerrainScenario decode(String source) {
    final lines = source
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    String find(RegExp expression, String fallback) =>
        lines.firstWhere(expression.hasMatch, orElse: () => fallback);
    final title = find(
      RegExp(r'CRITICAL TERRAIN', caseSensitive: false),
      'Terrain scenario',
    );
    final flight = find(
      RegExp(r'^[A-Z]{3}\d+\s*/?\d*\s+\d{1,2}[A-Z]{3}\d{2}'),
      'Flight details not identified',
    );
    final airportLines = lines
        .where((line) => RegExp(r'^[A-Z]{4}\s*/\s*[A-Z]{3,4}$').hasMatch(line))
        .toList();
    final combinedRoute = airportLines.firstOrNull?.split(RegExp(r'\s*/\s*'));
    final isCombinedRoute = combinedRoute?.last.length == 4;
    final departure = isCombinedRoute
        ? combinedRoute!.first
        : airportLines.firstOrNull ?? 'Departure not identified';
    final destination = isCombinedRoute
        ? combinedRoute!.last
        : airportLines.length > 1
        ? airportLines[1]
        : 'Destination not identified';
    final route = '$departure → $destination';
    final registrationAndType = find(
      RegExp(r'^[A-Z0-9]{5}\s+\d{3}(?:-\d+)?$'),
      'Aircraft not identified',
    );
    final departureIndex = lines.indexOf(departure);
    final times = departureIndex >= 0
        ? lines
              .skip(departureIndex + 2)
              .take(3)
              .where(
                (line) => RegExp(r'^(?:\d{4}|\d{2}\.\d{2})$').hasMatch(line),
              )
              .toList()
        : const <String>[];
    final variantAndRating = find(
      RegExp(r'^VRNT\s+', caseSensitive: false),
      'Variant/rating not identified',
    );
    final forecastValidity = find(
      RegExp(r'^FC\s+', caseSensitive: false),
      'Forecast validity not identified',
    );
    final scenarioRoute = find(
      RegExp(r'^VIA\s+', caseSensitive: false),
      'Scenario route not identified',
    );
    final headingPattern = RegExp(
      r'^(PRIOR TO|BETWEEN|AFTER)\s+',
      caseSensitive: false,
    );
    final starts = <int>[];
    for (var index = 0; index < lines.length; index++) {
      if (headingPattern.hasMatch(lines[index])) starts.add(index);
    }
    final segments = <DecodedTerrainSegment>[];
    final consumed = <int>{};
    for (var position = 0; position < starts.length; position++) {
      final start = starts[position];
      final end = position + 1 < starts.length
          ? starts[position + 1]
          : lines.length;
      final body = lines.sublist(start + 1, end);
      consumed.addAll([for (var index = start; index < end; index++) index]);
      final combined = '${lines[start]} ${body.join(' ')}';
      bool recognised(String line) => RegExp(
        r'^(TERRAIN\s+NOT\s+CRITICAL|EMER\s+DES|1ENG\s+OUT|\(M2-|MAX\s+TERRAIN|ENG\s+ANTI\s+ICE)',
        caseSensitive: false,
      ).hasMatch(line);
      segments.add(
        DecodedTerrainSegment(
          heading: lines[start],
          lines: body,
          isCritical: !RegExp(
            r'TERRAIN\s+NOT\s+CRITICAL',
            caseSensitive: false,
          ).hasMatch(combined),
          emergencyDescentDiversion: _captureAirport(
            body,
            RegExp(r'(EMERGENCY\s+DESCENT|EMER\s+DES)', caseSensitive: false),
          ),
          engineOutDiversion: _captureAirport(
            body,
            RegExp(
              r'(ONE\s+ENGINE|ENGINE\s+OUT|1ENG\s+OUT)',
              caseSensitive: false,
            ),
          ),
          maximumTerrain: _maximumTerrain(body),
          boundaryPoints: body
              .where((line) => RegExp(r'^\(M2-').hasMatch(line))
              .toList(),
          engineRestriction: _engineRestriction(body),
          additionalInformation: body
              .where((line) => !recognised(line))
              .toList(),
        ),
      );
    }
    final additional = <String>[];
    for (var index = 0; index < lines.length; index++) {
      if (!consumed.contains(index) &&
          ![
            title,
            flight,
            departure,
            destination,
            registrationAndType,
            ...times,
            variantAndRating,
            forecastValidity,
            scenarioRoute,
          ].contains(lines[index])) {
        additional.add(lines[index]);
      }
    }
    return DecodedTerrainScenario(
      title: title,
      flight: flight,
      route: route,
      scenarioRoute: scenarioRoute,
      segments: segments,
      additionalInformation: additional,
      registrationAndType: registrationAndType,
      departure: departure,
      destination: destination,
      scheduledDeparture: times.firstOrNull ?? 'Not identified',
      scheduledArrival: times.length > 1 ? times[1] : 'Not identified',
      flightTime: times.length > 2 ? times[2] : 'Not identified',
      variantAndRating: variantAndRating,
      forecastValidity: forecastValidity,
    );
  }

  String _captureAirport(List<String> lines, RegExp label) {
    for (var index = 0; index < lines.length; index++) {
      if (!label.hasMatch(lines[index])) continue;
      final sameLine = RegExp(
        r'\b[A-Z]{4}\b',
      ).allMatches(lines[index]).toList();
      if (sameLine.isNotEmpty) return sameLine.last.group(0)!;
      if (index + 1 < lines.length) {
        final next = RegExp(r'\b[A-Z]{4}\b').firstMatch(lines[index + 1]);
        if (next != null) return next.group(0)!;
      }
    }
    return '';
  }

  String _maximumTerrain(List<String> lines) {
    final line = lines.firstWhere(
      (value) => RegExp(
        r'^(?:MAX\s+TERRAIN|MAXIMUM\s+TERRAIN\s+HEIGHT)',
        caseSensitive: false,
      ).hasMatch(value),
      orElse: () => '',
    );
    final match = RegExp(
      r'(?:MAX\s+TERRAIN|MAXIMUM\s+TERRAIN\s+HEIGHT)\s+(\d+)(?:\s+FT)?(?:\s+AT\s+(.+))?$',
      caseSensitive: false,
    ).firstMatch(line);
    return match == null
        ? line
        : '${match.group(1)} ft${match.group(2) == null ? '' : ' at ${match.group(2)}'}';
  }

  String _engineRestriction(List<String> lines) {
    final line = lines.firstWhere(
      (value) =>
          RegExp(r'^ENG\s+ANTI\s+ICE', caseSensitive: false).hasMatch(value),
      orElse: () => '',
    );
    if (line.isEmpty) return '';
    return line
        .replaceFirst(RegExp(r'^ENG\s+ANTI\s+ICE\s*', caseSensitive: false), '')
        .replaceFirst('/', ' · MEL restrictions: ');
  }
}
