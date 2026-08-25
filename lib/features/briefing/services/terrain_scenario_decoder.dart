class DecodedTerrainSegment {
  const DecodedTerrainSegment({
    required this.heading,
    required this.lines,
    required this.isCritical,
    this.emergencyDescentDiversion = '',
    this.engineOutDiversion = '',
    this.maximumTerrain = '',
  });

  final String heading;
  final List<String> lines;
  final bool isCritical;
  final String emergencyDescentDiversion;
  final String engineOutDiversion;
  final String maximumTerrain;
}

class DecodedTerrainScenario {
  const DecodedTerrainScenario({
    required this.title,
    required this.flight,
    required this.route,
    required this.scenarioRoute,
    required this.segments,
    required this.additionalInformation,
  });

  final String title;
  final String flight;
  final String route;
  final String scenarioRoute;
  final List<DecodedTerrainSegment> segments;
  final List<String> additionalInformation;
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
    final route = find(
      RegExp(r'\b[A-Z]{4}\s*/\s*[A-Z]{4}\b'),
      'Route not identified',
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
            RegExp(r'EMERGENCY\s+DESCENT', caseSensitive: false),
          ),
          engineOutDiversion: _captureAirport(
            body,
            RegExp(r'(ONE\s+ENGINE|ENGINE\s+OUT)', caseSensitive: false),
          ),
          maximumTerrain: body.firstWhere(
            (line) => RegExp(
              r'(MAX(?:IMUM)?\s+TERRAIN|TERRAIN\s+HEIGHT)',
              caseSensitive: false,
            ).hasMatch(line),
            orElse: () => '',
          ),
        ),
      );
    }
    final additional = <String>[];
    for (var index = 0; index < lines.length; index++) {
      if (!consumed.contains(index) &&
          ![title, flight, route, scenarioRoute].contains(lines[index])) {
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
}
