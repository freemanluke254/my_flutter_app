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
    final informationLines = <String>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (!consumed.contains(index) && line != title && line != validity) {
        informationLines.add(line);
      }
    }
    final informationGroups = _informationGroups(informationLines);
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

  List<DecodedTrackInformationGroup> _informationGroups(List<String> lines) {
    final grouped = <String, List<DecodedTrackInformation>>{};
    var currentGroup = 'Other source information';
    void add(String group, String label, String value) {
      currentGroup = group;
      (grouped[group] ??= []).add(
        DecodedTrackInformation(label: label, value: value),
      );
    }

    void append(String value) {
      final items = grouped[currentGroup];
      if (items == null || items.isEmpty) {
        add('Other source information', 'Additional information', value);
        return;
      }
      final previous = items.removeLast();
      items.add(
        DecodedTrackInformation(
          label: previous.label,
          value: '${previous.value} $value',
        ),
      );
    }

    var inRemarks = false;
    for (var line in lines) {
      line = line.trim();
      if (line == r'$B' ||
          line == 'B' ||
          RegExp(r'^PAGE\s+\d+$').hasMatch(line)) {
        continue;
      }
      if (line == 'REMARKS.') {
        inRemarks = true;
        continue;
      }
      if (line.startsWith('END OF PART THREE')) inRemarks = false;
      if (inRemarks ||
          RegExp(r'^\d+\.\s').hasMatch(line) ||
          RegExp(
            r'\b(TMI|RCL|PBCS|SLOP|SQUAWK|ADS[ -]C|CPDLC|LOGON|GNSS)\b',
          ).hasMatch(line)) {
        final numbered = RegExp(r'^(\d+)\.\s*(.*)$').firstMatch(line);
        if (numbered != null) {
          add(
            'Operational requirements and remarks',
            _operationalLabel(numbered.group(2)!, number: numbered.group(1)),
            numbered.group(2)!,
          );
        } else {
          add(
            'Operational requirements and remarks',
            _operationalLabel(line),
            line.replaceAll(RegExp(r'-$'), ''),
          );
        }
      } else if (RegExp(
        r'^(?:END OF )?PART\s+',
        caseSensitive: false,
      ).hasMatch(line)) {
        add('Message structure', 'Message part', line.replaceAll(')', ''));
      } else if (RegExp(r'^\([QA]\d{4}/\d{2}\s+NOTAMN').hasMatch(line)) {
        add(
          'PACOTS message details',
          'NOTAM identifier',
          line.replaceFirst('(', ''),
        );
      } else if (line.contains('PACOTS TRACK MESSAGE')) {
        add('PACOTS message details', 'Message type', line);
      } else if (line.startsWith('Q)')) {
        add(
          'PACOTS message details',
          'Qualified NOTAM code',
          line.substring(2),
        );
      } else if (line.startsWith('A)')) {
        final fields = RegExp(
          r'^A\)(\S+)\s+B\)(\d{10})\s+C\)(\d{10})',
        ).firstMatch(line);
        if (fields == null) {
          add(
            'PACOTS message details',
            'Affected FIR',
            line.substring(2).trim(),
          );
        } else {
          add('PACOTS message details', 'Affected FIR', fields.group(1)!);
          add(
            'PACOTS message details',
            'Valid from',
            _compactDate(fields.group(2)!),
          );
          add(
            'PACOTS message details',
            'Valid until',
            _compactDate(fields.group(3)!),
          );
        }
      } else if (line.startsWith('B)')) {
        add(
          'PACOTS message details',
          'Valid from',
          _compactDate(line.substring(2).trim()),
        );
      } else if (line.startsWith('C)')) {
        add(
          'PACOTS message details',
          'Valid until',
          _compactDate(line.substring(2).trim()),
        );
      } else if (line.startsWith('E)') && !line.contains('TDM TRK')) {
        add('PACOTS message details', 'Track requirement', line.substring(2));
      } else if (RegExp(
        r'^TRACK\s+\d+\.?$',
        caseSensitive: false,
      ).hasMatch(line)) {
        add('PACOTS routes', 'Track', line.replaceAll('.', ''));
      } else if (RegExp(
        r'^(FLEX|JAPAN|NAR|PHNL|RCTP/VHHH) ROUTE\s*:',
        caseSensitive: false,
      ).hasMatch(line)) {
        final separator = line.indexOf(':');
        add(
          'PACOTS routes',
          _routeLabel(line.substring(0, separator)),
          line.substring(separator + 1).trim(),
        );
      } else if (line.startsWith('RMK :')) {
        add('PACOTS routes', 'Track remarks', line.substring(5).trim());
      } else if (line.startsWith('ATM CENTER TEL:')) {
        add('PACOTS routes', 'ATM centre contact', line.substring(15).trim());
      } else if (line.contains('TDM TRK')) {
        line = line.replaceFirst(RegExp(r'^E\)\(?'), '');
        add('TDM tracks', 'Track definition', line);
      } else if (line.startsWith('RTS/')) {
        add('TDM tracks', 'Published routing', line.substring(4));
      } else if (line.startsWith('RMK/')) {
        add('TDM tracks', 'Track remarks', line.substring(4));
      } else if (RegExp(
        r'^[A-Z]{3}\d+\b|\b[A-Z]{4}\s*[-/]\s*[A-Z]{4}\b',
      ).hasMatch(line)) {
        add('Flight and package details', 'Flight', line);
      } else if (RegExp(r'^(NAT-|INCLUSIVE$)').hasMatch(line)) {
        add('Message structure', 'Track message part', line);
      } else {
        append(line.replaceAll(RegExp(r'[)-]+$'), ''));
      }
    }
    const order = <String>[
      'Flight and package details',
      'Message structure',
      'Operational requirements and remarks',
      'PACOTS message details',
      'PACOTS routes',
      'TDM tracks',
      'Other source information',
    ];
    return [
      for (final title in order)
        if (grouped[title]?.isNotEmpty == true)
          DecodedTrackInformationGroup(title: title, items: grouped[title]!),
    ];
  }

  String _routeLabel(String source) => switch (source.trim().toUpperCase()) {
    'FLEX ROUTE' => 'Flexible route',
    'JAPAN ROUTE' => 'Japan route',
    'NAR ROUTE' => 'North American route',
    'PHNL ROUTE' => 'Honolulu route',
    'RCTP/VHHH ROUTE' => 'Taipei / Hong Kong route',
    _ => source.trim(),
  };

  String _operationalLabel(String value, {String? number}) {
    final upper = value.toUpperCase();
    final label = switch (upper) {
      _ when upper.contains('TMI') => 'Track message identification',
      _ when upper.contains('RCL') => 'Oceanic clearance request',
      _ when upper.contains('PBCS') =>
        'Performance-based communication and surveillance',
      _ when upper.contains('SLOP') => 'Strategic lateral offset procedure',
      _ when upper.contains('SQUAWK') => 'Transponder setting',
      _
          when upper.contains('ADS C') ||
              upper.contains('ADS-C') ||
              upper.contains('CPDLC') =>
        'Data-link requirement',
      _ when upper.contains('LOGON') => 'Data-link logon',
      _ when upper.contains('GNSS') => 'GNSS interference reporting',
      _ => 'Operational remark',
    };
    return number == null ? label : '$label · $number';
  }

  String _compactDate(String value) {
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return value;
    return '20${value.substring(0, 2)}-${value.substring(2, 4)}-${value.substring(4, 6)} '
        '${value.substring(6, 8)}:${value.substring(8, 10)} UTC';
  }

  bool _looksLikeRoute(String value) =>
      RegExp(r'(\d{2}/\d{2}|\b[A-Z]{5}\b)').hasMatch(value);

  String _afterLabel(String line, String label) {
    final value = line.substring(label.length).trim();
    return value.isEmpty ? 'NIL' : value;
  }
}
