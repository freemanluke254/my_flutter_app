import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/briefing/services/aviation_weather_decoder.dart';

void main() {
  test('decodes core ICAO METAR groups without mixing in raw text', () {
    const raw = 'METAR EGLL 241350Z AUTO 10016KT 9999 SCT048 21/09 Q1018=';
    final decoded = const AviationWeatherDecoder().decodeDocument(raw);

    expect(decoded, contains('Station: EGLL'));
    expect(decoded, contains('Wind: 100° true at 16 kt'));
    expect(decoded, contains('Visibility: 10 km or more'));
    expect(decoded, contains('scattered (3–4 oktas) at 4800 ft AAL'));
    expect(decoded, contains('Temperature: 21°C · dew point: 09°C'));
    expect(decoded, contains('QNH: 1018 hPa'));
    expect(decoded, isNot(contains('RAW')));
    expect(decoded, isNot(contains('METAR EGLL')));
  });

  test('decodes TAF validity and change groups', () {
    const raw =
        'TAF EGLL 241054Z 2412/2518 08013KT 9999 SCT040 PROB30 TEMPO 2412/2418 09015G25KT=';
    final decoded = const AviationWeatherDecoder().decodeDocument(raw);

    expect(decoded, contains('Valid: day 24 12:00 to day 25 18:00 UTC'));
    expect(decoded, contains('30% probability'));
    expect(decoded, contains('TEMPORARILY'));
    expect(decoded, contains('gusting 25'));
  });

  test('labels package weather with its airport heading', () {
    const raw = '''
EGLL -LHR - LONDON HEATHROW
METAR 241350Z 10016KT 9999 SCT048 21/09 Q1018=
TAF 241054Z 2412/2518 08013KT 9999 SCT040=
KLAX -LAX - LOS ANGELES
METAR 241353Z 22004KT 8SM SCT140 21/20 A2994=
''';
    final decoded = const AviationWeatherDecoder().decodeDocument(raw);

    expect(decoded, contains('AIRPORT · EGLL · LHR - LONDON HEATHROW'));
    expect(decoded, contains('AIRPORT · KLAX · LAX - LOS ANGELES'));
  });
}
