import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/briefing/services/terrain_scenario_decoder.dart';

void main() {
  test('decodes critical and non-critical terrain segments', () {
    const source = '''
CRITICAL TERRAIN SCENARIO
VIR358 /1 24AUG26
EGLL / VABB
VIA AZB/TURKMEN/AFGHAN
PRIOR TO M2-1 TERRAIN NOT CRITICAL
BETWEEN M2-1 AND M2-2
EMERGENCY DESCENT DIVERSION LTCG
ONE ENGINE OUT DIVERSION LTCG
(M2-1) N4058.5 E04033.4 - EKTES/015
(M2-2) N4053.9 E04234.1 - DELEL/076
MAXIMUM TERRAIN HEIGHT 12897 FT
ENG ANTI ICE ON/NO MEL RESTRICTIONS
AFTER M2-5 TERRAIN NOT CRITICAL
''';

    final result = const TerrainScenarioDecoder().decode(source);

    expect(result.flight, 'VIR358 /1 24AUG26');
    expect(result.route, 'EGLL → VABB');
    expect(result.segments, hasLength(3));
    expect(result.segments.first.isCritical, isFalse);
    expect(result.segments[1].isCritical, isTrue);
    expect(result.segments[1].emergencyDescentDiversion, 'LTCG');
    expect(result.segments[1].engineOutDiversion, 'LTCG');
    expect(result.segments[1].maximumTerrain, contains('12897'));
    expect(result.segments[1].entryPoint, contains('M2-1'));
    expect(result.segments[1].exitPoint, contains('M2-2'));
    expect(result.segments[1].engineAntiIce, 'ON');
    expect(result.segments[1].melRestriction, 'NO MEL RESTRICTIONS');
    expect(result.segments.last.isCritical, isFalse);
  });
}
