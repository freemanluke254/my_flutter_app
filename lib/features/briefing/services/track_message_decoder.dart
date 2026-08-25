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
    required this.informationGroups,
  });

  final String title;
  final String validity;
  final String flightLevels;
  final List<DecodedOceanicTrack> tracks;
  final List<String> remarks;
  final List<String> additionalInformation;
  final List<DecodedTrackInformationGroup> informationGroups;
}

class DecodedTrackInformation {
  const DecodedTrackInformation({required this.label, required this.value});

  final String label;
  final String value;
}

class DecodedTrackInformationGroup {
  const DecodedTrackInformationGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<DecodedTrackInformation> items;
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
    final informationGroups = _informationGroups(remarks, additional);
    return DecodedTrackMessage(
      title: title,
      validity: validity,
      flightLevels: levels,
      tracks: tracks,
      remarks: remarks,
      additionalInformation: additional,
      informationGroups: informationGroups,
    );
  }

  List<DecodedTrackInformationGroup> _informationGroups(
    List<String> remarks,
    List<String> additional,
  ) {
    final grouped = <String, List<DecodedTrackInformation>>{};
    void add(String group, String line) {
      final decoded = _decodeInformation(line);
      (grouped[group] ??= []).add(decoded);
    }

    for (final line in remarks) {
      add('Operational requirements and remarks', line);
    }
    var currentTrackSystem = false;
    for (final line in additional) {
      if (RegExp(
        r'\b(PACOTS|TDM|TRACK DEFINITION MESSAGE)\b',
        caseSensitive: false,
      ).hasMatch(line)) {
        currentTrackSystem = true;
      }
      if (RegExp(r'^[QABCE]\)').hasMatch(line)) {
        add('Associated NOTAM fields', line);
      } else if (currentTrackSystem ||
          RegExp(r'\b(PACOTS|TDM)\b', caseSensitive: false).hasMatch(line)) {
        add('PACOTS and additional track messages', line);
      } else if (RegExp(
        r'^[A-Z]{3}\d+\b|\b[A-Z]{4}\s*[-/]\s*[A-Z]{4}\b',
      ).hasMatch(line)) {
        add('Flight and package details', line);
      } else {
        add('Other source information', line);
      }
    }
    const order = <String>[
      'Operational requirements and remarks',
      'Flight and package details',
      'PACOTS and additional track messages',
      'Associated NOTAM fields',
      'Other source information',
    ];
    return [
      for (final title in order)
        if (grouped[title]?.isNotEmpty == true)
          DecodedTrackInformationGroup(title: title, items: grouped[title]!),
    ];
  }

  DecodedTrackInformation _decodeInformation(String line) {
    final upper = line.toUpperCase();
    const notamLabels = <String, String>{
      'Q)': 'Qualified NOTAM code',
      'A)': 'Affected FIR or location',
      'B)': 'Valid from',
      'C)': 'Valid until',
      'E)': 'Details',
    };
    for (final entry in notamLabels.entries) {
      if (upper.startsWith(entry.key)) {
        return DecodedTrackInformation(
          label: entry.value,
          value: line.substring(entry.key.length).trim(),
        );
      }
    }
    final labels = <(RegExp, String)>[
      (RegExp(r'\bTMI\b'), 'Track Message Identification'),
      (RegExp(r'\bRCL\b'), 'Oceanic clearance request'),
      (RegExp(r'\bPBCS\b'), 'Performance-based communication and surveillance'),
      (RegExp(r'\bSLOP\b'), 'Strategic lateral offset procedure'),
      (RegExp(r'\bSQUAWK\b'), 'Transponder setting'),
      (RegExp(r'\bADS-C\b|\bCPDLC\b'), 'Data-link requirement'),
      (RegExp(r'\bLOGON\b'), 'Data-link logon'),
      (RegExp(r'\bPACOTS\b'), 'Pacific organised track system'),
      (RegExp(r'\bTDM\b'), 'Track definition message'),
    ];
    for (final item in labels) {
      if (item.$1.hasMatch(upper)) {
        return DecodedTrackInformation(label: item.$2, value: line);
      }
    }
    return DecodedTrackInformation(label: 'Source information', value: line);
  }

  bool _looksLikeRoute(String value) =>
      RegExp(r'(\d{2}/\d{2}|\b[A-Z]{5}\b)').hasMatch(value);

  String _afterLabel(String line, String label) {
    final value = line.substring(label.length).trim();
    return value.isEmpty ? 'NIL' : value;
  }
}
