import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AirportReference {
  const AirportReference({
    required this.icao,
    required this.iata,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.firCode,
  });
  final String icao;
  final String iata;
  final String name;
  final double latitude;
  final double longitude;
  final String firCode;
}

class FreeAviationReferenceService {
  const FreeAviationReferenceService();

  static const _airportsUrl =
      'https://davidmegginson.github.io/ourairports-data/airports.csv';
  static const _vatSpyUrl =
      'https://raw.githubusercontent.com/vatsimnetwork/vatspy-data-project/master/VATSpy.dat';
  static Future<Map<String, AirportReference>>? _records;

  Future<AirportReference?> airport(String icao) async {
    final records = await (_records ??= _load());
    return records[icao.trim().toUpperCase()];
  }

  Future<List<AirportReference>> airports(Iterable<String> codes) async {
    final records = await (_records ??= _load());
    return codes
        .map((code) => records[code.trim().toUpperCase()])
        .whereType<AirportReference>()
        .toList();
  }

  static Future<Map<String, AirportReference>> _load() async {
    try {
      final values = await Future.wait([
        _cachedDownload(_airportsUrl, 'pilot_airports.csv'),
        _cachedDownload(_vatSpyUrl, 'pilot_vatspy.dat'),
      ]);
      final firByAirport = _parseVatSpy(values[1]);
      return _parseAirports(values[0], firByAirport);
    } on Object {
      _records = null;
      return const {};
    }
  }

  static Future<String> _cachedDownload(String url, String fileName) async {
    final cacheDirectory = Directory(
      '${Directory.systemTemp.path}/pilot_reference_data',
    );
    await cacheDirectory.create(recursive: true);
    final file = File('${cacheDirectory.path}/$fileName');
    if (await file.exists()) {
      final modified = await file.lastModified();
      if (DateTime.now().difference(modified) < const Duration(days: 7)) {
        return file.readAsString();
      }
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'PilotApp/1.0');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Reference download returned ${response.statusCode}');
      }
      final text = await utf8.decoder.bind(response).join();
      await file.writeAsString(text, flush: true);
      return text;
    } finally {
      client.close(force: true);
    }
  }

  static Map<String, String> _parseVatSpy(String text) {
    final result = <String, String>{};
    var inAirports = false;
    for (final rawLine in const LineSplitter().convert(text)) {
      final line = rawLine.trim();
      if (line == '[Airports]') {
        inAirports = true;
        continue;
      }
      if (inAirports && line.startsWith('[')) break;
      if (!inAirports || line.isEmpty || line.startsWith(';')) continue;
      final fields = line.split('|');
      if (fields.length < 6) continue;
      final airport = fields[0].trim().toUpperCase();
      final fir = fields[5].trim().toUpperCase();
      if (airport.length == 4 && fir.isNotEmpty) result[airport] = fir;
    }
    return result;
  }

  static Map<String, AirportReference> _parseAirports(
    String text,
    Map<String, String> firByAirport,
  ) {
    final lines = const LineSplitter().convert(text);
    if (lines.isEmpty) return const {};
    final headers = _csvRow(lines.first);
    final index = <String, int>{
      for (var position = 0; position < headers.length; position++)
        headers[position]: position,
    };
    String field(List<String> row, String name) {
      final position = index[name];
      return position == null || position >= row.length ? '' : row[position];
    }

    final result = <String, AirportReference>{};
    for (final line in lines.skip(1)) {
      final row = _csvRow(line);
      final icao = field(row, 'icao_code').trim().toUpperCase();
      if (icao.length != 4) continue;
      result[icao] = AirportReference(
        icao: icao,
        iata: field(row, 'iata_code').trim().toUpperCase(),
        name: field(row, 'name').trim(),
        latitude: double.tryParse(field(row, 'latitude_deg')) ?? 0,
        longitude: double.tryParse(field(row, 'longitude_deg')) ?? 0,
        firCode: firByAirport[icao] ?? '',
      );
    }
    return result;
  }

  static List<String> _csvRow(String line) {
    final fields = <String>[];
    final value = StringBuffer();
    var quoted = false;
    for (var index = 0; index < line.length; index++) {
      final character = line[index];
      if (character == '"') {
        if (quoted && index + 1 < line.length && line[index + 1] == '"') {
          value.write('"');
          index++;
        } else {
          quoted = !quoted;
        }
      } else if (character == ',' && !quoted) {
        fields.add(value.toString());
        value.clear();
      } else {
        value.write(character);
      }
    }
    fields.add(value.toString());
    return fields;
  }
}
