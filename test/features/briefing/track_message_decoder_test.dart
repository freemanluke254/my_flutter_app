import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/briefing/services/track_message_decoder.dart';

void main() {
  test('decodes NAT routes, levels and operational remarks', () {
    const source = '''
NAT-1/3 TRACKS FLS 340/400 INCLUSIVE
AUG 24/1130Z TO AUG 24/1900Z
A GOMUP 62/20 64/30 64/40 63/50 LIBOR
EAST LVLS NIL
WEST LVLS 350 360 380 390 400
EUR RTS WEST NIL
NAR N485A N491A
TMI IS 236
PBCS TRACKS C D E
SLOP SHOULD BE USED
PACOTS TRACK MESSAGE
TDM TRK 1
Q) RJJJ/QARLC/IV/NBO/E/055/660/3500N14000E999
A) RJJJ
B) 2608241200
C) 2608242000
E) TRACK 1 AVAILABLE
''';

    final result = const TrackMessageDecoder().decode(source);

    expect(result.validity, 'AUG 24/1130Z TO AUG 24/1900Z');
    expect(result.flightLevels, '340/400');
    expect(result.tracks, hasLength(1));
    expect(result.tracks.single.designator, 'A');
    expect(result.tracks.single.route, contains('64/40'));
    expect(result.tracks.single.eastLevels, 'NIL');
    expect(result.tracks.single.westLevels, '350 360 380 390 400');
    expect(result.remarks, contains('TMI IS 236'));
    expect(result.remarks, contains('PBCS TRACKS C D E'));
    final operational = result.informationGroups.firstWhere(
      (group) => group.title == 'Operational requirements and remarks',
    );
    expect(
      operational.items.map((item) => item.label),
      contains('Performance-based communication and surveillance'),
    );
    final pacots = result.informationGroups.firstWhere(
      (group) => group.title == 'TDM tracks',
    );
    expect(
      pacots.items.map((item) => item.label),
      contains('Track definition'),
    );
    final notam = result.informationGroups.firstWhere(
      (group) => group.title == 'PACOTS message details',
    );
    expect(
      notam.items.map((item) => item.label),
      containsAll([
        'Qualified NOTAM code',
        'Affected FIR',
        'Valid from',
        'Valid until',
      ]),
    );
  });
}
