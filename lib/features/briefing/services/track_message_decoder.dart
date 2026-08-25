class DecodedOceanicTrack {
  const DecodedOceanicTrack({
    required this.designator,
    required this.route,
    this.eastLevels = '',
    this.westLevels = '',
    this.europeanRoute = '',
    this.northAmericanRoute = '',
  });

  final String designator;
  final String route;
  final String eastLevels;
  final String westLevels;
  final String europeanRoute;
  final String northAmericanRoute;
}

class DecodedTrackMessage {
  const DecodedTrackMessage({
    required this.title,
    required this.validity,
    required this.flightLevels,
    required this.tracks,
    required this.remarks,
    required this.additionalInformation,
  });

  final String title;
  final String validity;
  final String flightLevels;
  final List<DecodedOceanicTrack> tracks;
  final List<String> remarks;
  final List<String> additionalInformation;
}

class TrackMessageDecoder {
  const TrackMessageDecoder();

  DecodedTrackMessage decode(String source) {
    final lines = source
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final title = lines.firstWhere(
      (line) => RegExp(r'\bTRACKS?\b', caseSensitive: false).hasMatch(line),
      orElse: () => 'Oceanic track message',
    );
    final validity = lines.firstWhere(
      (line) => RegExp(r'\bTO\b').hasMatch(line) && line.contains('Z'),
      orElse: () => 'Validity not identified',
    );
    final levels =
        RegExp(
          r'FLS?\s+(.+?)(?:\s+INCLUSIVE)?$',
          caseSensitive: false,
        ).firstMatch(title)?.group(1) ??
        '';
    final tracks = <DecodedOceanicTrack>[];
    final consumed = <int>{};
    for (var index = 0; index < lines.length; index++) {
      final match = RegExp(r'^([A-Z])\s+(.+)$').firstMatch(lines[index]);
      if (match == null || !_looksLikeRoute(match.group(2)!)) continue;
      consumed.add(index);
      var east = '';
      var west = '';
      var eur = '';
      var nar = '';
      var cursor = index + 1;
      while (cursor < lines.length && cursor <= index + 6) {
        final line = lines[cursor];
        if (RegExp(r'^[A-Z]\s+.+').hasMatch(line) &&
            _looksLikeRoute(line.substring(2))) {
          break;
        }
        if (line.startsWith('EAST LVLS')) {
          east = _afterLabel(line, 'EAST LVLS');
        }
        if (line.startsWith('WEST LVLS')) {
          west = _afterLabel(line, 'WEST LVLS');
        }
        if (line.startsWith('EUR RTS WEST')) {
          eur = _afterLabel(line, 'EUR RTS WEST');
        }
        if (line.startsWith('NAR')) {
          nar = _afterLabel(line, 'NAR');
        }
        if (line.startsWith('EAST LVLS') ||
            line.startsWith('WEST LVLS') ||
            line.startsWith('EUR RTS WEST') ||
            line.startsWith('NAR')) {
          consumed.add(cursor);
        }
        cursor++;
      }
      tracks.add(
        DecodedOceanicTrack(
          designator: match.group(1)!,
          route: match.group(2)!,
          eastLevels: east,
          westLevels: west,
          europeanRoute: eur,
          northAmericanRoute: nar,
        ),
      );
    }
    final remarks = lines
        .where(
          (line) => RegExp(
            r'\b(TMI|PBCS|SLOP|CPDLC|ADS-C|SQUAWK|LOGON|RCL)\b',
            caseSensitive: false,
          ).hasMatch(line),
        )
        .toList();
    final additional = <String>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (consumed.contains(index) ||
          line == title ||
          line == validity ||
          remarks.contains(line)) {
        continue;
      }
      additional.add(line);
    }
    return DecodedTrackMessage(
      title: title,
      validity: validity,
      flightLevels: levels,
      tracks: tracks,
      remarks: remarks,
      additionalInformation: additional,
    );
  }

  bool _looksLikeRoute(String value) =>
      RegExp(r'(\d{2}/\d{2}|\b[A-Z]{5}\b)').hasMatch(value);

  String _afterLabel(String line, String label) {
    final value = line.substring(label.length).trim();
    return value.isEmpty ? 'NIL' : value;
  }
}
