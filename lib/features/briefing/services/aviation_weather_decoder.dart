class AviationWeatherDecoder {
  const AviationWeatherDecoder();

  String decodeDocument(String raw) {
    final headings = RegExp(
      r'^([A-Z]{4})\s*-\s*([^\n]+)$',
      multiLine: true,
    ).allMatches(raw).toList();
    if (headings.isNotEmpty) {
      final sections = <String>[];
      for (var index = 0; index < headings.length; index++) {
        final end = index + 1 < headings.length
            ? headings[index + 1].start
            : raw.length;
        final decoded = _decodeMessages(
          raw.substring(headings[index].end, end),
        );
        if (decoded.isEmpty) continue;
        sections.add(
          'AIRPORT · ${headings[index].group(1)} · ${headings[index].group(2)!.trim()}\n\n$decoded',
        );
      }
      if (sections.isNotEmpty) {
        return sections.join('\n\n══════════════════════════════════\n\n');
      }
    }
    final decoded = _decodeMessages(raw);
    return decoded.isEmpty ? raw : decoded;
  }

  String _decodeMessages(String raw) {
    final messages = RegExp(
      r'\b(METAR|SPECI|TAF)\s+([^=]+)=',
      dotAll: true,
    ).allMatches(raw).toList();
    if (messages.isEmpty) return '';
    return messages
        .map((match) {
          final type = match.group(1)!;
          final body = match.group(2)!.replaceAll(RegExp(r'\s+'), ' ').trim();
          return '${type == 'TAF' ? 'FORECAST' : 'OBSERVATION'} · $type\n${_decodeTokens(body)}';
        })
        .join('\n\n──────────────────────────────────\n\n');
  }

  String _decodeTokens(String message) {
    final output = <String>[];
    final unparsed = <String>[];
    for (final token in message.split(' ')) {
      final decoded = _token(token);
      if (decoded == null) {
        unparsed.add(token);
      } else {
        output.add(decoded);
      }
    }
    if (unparsed.isNotEmpty) output.add('Other groups: ${unparsed.join(' ')}');
    return output.join('\n');
  }

  String? _token(String token) {
    if (RegExp(r'^[A-Z]{4}$').hasMatch(token)) return 'Station: $token';
    final issued = RegExp(r'^(\d{2})(\d{2})(\d{2})Z$').firstMatch(token);
    if (issued != null) {
      return 'Issued: day ${issued.group(1)} at ${issued.group(2)}:${issued.group(3)} UTC';
    }
    final validity = RegExp(
      r'^(\d{2})(\d{2})/(\d{2})(\d{2})$',
    ).firstMatch(token);
    if (validity != null) {
      return 'Valid: day ${validity.group(1)} ${validity.group(2)}:00 to day ${validity.group(3)} ${validity.group(4)}:00 UTC';
    }
    final from = RegExp(r'^FM(\d{2})(\d{2})(\d{2})$').firstMatch(token);
    if (from != null) {
      return 'FROM day ${from.group(1)} at ${from.group(2)}:${from.group(3)} UTC';
    }
    final wind = RegExp(
      r'^(\d{3}|VRB)(\d{2,3})(?:G(\d{2,3}))?(KT|MPS)$',
    ).firstMatch(token);
    if (wind != null) {
      final direction = wind.group(1) == 'VRB'
          ? 'variable'
          : '${wind.group(1)}° true';
      return 'Wind: $direction at ${wind.group(2)} ${wind.group(4) == 'KT' ? 'kt' : 'm/s'}${wind.group(3) == null ? '' : ', gusting ${wind.group(3)}'}';
    }
    final varying = RegExp(r'^(\d{3})V(\d{3})$').firstMatch(token);
    if (varying != null) {
      return 'Wind varying: ${varying.group(1)}° to ${varying.group(2)}°';
    }
    if (token == '9999') return 'Visibility: 10 km or more';
    if (token == 'CAVOK') {
      return 'CAVOK: visibility 10 km or more, no significant weather and no significant cloud below the applicable level';
    }
    final metricVisibility = RegExp(r'^\d{4}$').hasMatch(token);
    if (metricVisibility) return 'Visibility: ${int.parse(token)} m';
    final usVisibility = RegExp(r'^(P|M)?(\d+(?:/\d+)?)SM$').firstMatch(token);
    if (usVisibility != null) {
      return 'Visibility: ${usVisibility.group(1) == 'P'
          ? 'more than '
          : usVisibility.group(1) == 'M'
          ? 'less than '
          : ''}${usVisibility.group(2)} statute miles';
    }
    final cloud = RegExp(
      r'^(FEW|SCT|BKN|OVC|VV)(\d{3}|///)(CB|TCU)?$',
    ).firstMatch(token);
    if (cloud != null) {
      const amounts = {
        'FEW': 'few (1–2 oktas)',
        'SCT': 'scattered (3–4 oktas)',
        'BKN': 'broken (5–7 oktas)',
        'OVC': 'overcast (8 oktas)',
        'VV': 'vertical visibility',
      };
      final height = cloud.group(2) == '///'
          ? 'unknown height'
          : '${int.parse(cloud.group(2)!) * 100} ft AAL';
      return 'Cloud: ${amounts[cloud.group(1)]} at $height${cloud.group(3) == null ? '' : ' · ${cloud.group(3) == 'CB' ? 'cumulonimbus' : 'towering cumulus'}'}';
    }
    if (const {'NSC', 'NCD', 'SKC', 'CLR'}.contains(token)) {
      return 'Cloud: $token';
    }
    final temperature = RegExp(r'^(M?\d{2})/(M?\d{2}|//)$').firstMatch(token);
    if (temperature != null) {
      String value(String input) => input.replaceFirst('M', '-');
      return 'Temperature: ${value(temperature.group(1)!)}°C · dew point: ${temperature.group(2) == '//' ? 'not reported' : '${value(temperature.group(2)!)}°C'}';
    }
    final qnh = RegExp(r'^Q(\d{4})$').firstMatch(token);
    if (qnh != null) return 'QNH: ${qnh.group(1)} hPa';
    final altimeter = RegExp(r'^A(\d{4})$').firstMatch(token);
    if (altimeter != null) {
      return 'Altimeter: ${altimeter.group(1)!.substring(0, 2)}.${altimeter.group(1)!.substring(2)} inHg';
    }
    if (token == 'AUTO') return 'Automated observation';
    if (token == 'NOSIG') return 'No significant change expected';
    if (token == 'NSW') return 'No significant weather';
    if (token == 'TEMPO') return 'TEMPORARILY';
    if (token == 'BECMG') return 'BECOMING';
    if (token == 'PROB30') return '30% probability';
    if (token == 'PROB40') return '40% probability';
    final weather = _weather(token);
    return weather == null ? null : 'Weather: $weather';
  }

  String? _weather(String token) {
    var value = token;
    final words = <String>[];
    if (value.startsWith('+')) {
      words.add('heavy');
      value = value.substring(1);
    }
    if (value.startsWith('-')) {
      words.add('light');
      value = value.substring(1);
    }
    const codes = <String, String>{
      'VC': 'in the vicinity',
      'MI': 'shallow',
      'PR': 'partial',
      'BC': 'patches',
      'DR': 'low drifting',
      'BL': 'blowing',
      'SH': 'showers',
      'TS': 'thunderstorm',
      'FZ': 'freezing',
      'DZ': 'drizzle',
      'RA': 'rain',
      'SN': 'snow',
      'SG': 'snow grains',
      'IC': 'ice crystals',
      'PL': 'ice pellets',
      'GR': 'hail',
      'GS': 'small hail or snow pellets',
      'UP': 'unidentified precipitation',
      'BR': 'mist',
      'FG': 'fog',
      'FU': 'smoke',
      'VA': 'volcanic ash',
      'DU': 'widespread dust',
      'SA': 'sand',
      'HZ': 'haze',
      'PO': 'dust or sand whirls',
      'SQ': 'squalls',
      'FC': 'funnel cloud',
      'SS': 'sandstorm',
      'DS': 'duststorm',
    };
    while (value.length >= 2) {
      final code = value.substring(0, 2);
      final word = codes[code];
      if (word == null) return null;
      words.add(word);
      value = value.substring(2);
    }
    return value.isEmpty && words.isNotEmpty ? words.join(' ') : null;
  }
}
