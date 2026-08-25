import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/features/briefing/services/ofp_parser.dart';
import 'package:trying_flutter/features/briefing/services/ofp_time_resolver.dart';

void main() {
  test('decodes VS300 OFP front-page configuration values', () {
    const source = '''
OPERATIONAL FLIGHT PLAN VS300 PG 1/11
VIR300 22JUN26 EGLL-VIDP STD LOCAL EGLL/LHR 1910 P01.00 STA VIDP/DEL 0340+ P05.30 SCH 8.30 REGN GVZIG
TYPE 787-9
ETD 1910/22 PLAN ID 0023
APPL RULE:NON ETOPS
MAX PAYLOAD PLAN
EGLL DET1J DET L6 DVR L9 KONAN UL607 KOK DCT LIRSU DCT LALMI DCT ABTAL DCT
RIDAR DCT GOMIG DCT VATET DCT MOPUG DCT NERDI DCT ASNEL DCT UDROS UM859 KARDE
UN644 ROLIN DCT FOQUS DCT DISKA M737 VERCA M747 BAGVA DCT ERLEV M11 RODAR A909
LEMOD N644 DI A466 ELKUX ELKUX7N VIDP
EGLL/0370/UDROS/0390
CAPT PLN ZFW ACT ZFW
NBR PF/PNF 161500
FO PLN TOW ACT TOW
RLF1 212700
RLF2 PLN LWT ACT LWT
PAX SOB 171000
TRIP 41700 07.44 ACT TIME T/O
CONT%5 2100 00.28
FNL RES 2200 00.30
EXTRA 0 00.00
TAXI/APU 500 00.23
RAMP 51700 TD FUEL 9500
''';

    final result = const OfpParser().parseText(source);

    expect(result.callsign, 'VIR300');
    expect(result.flightDate, DateTime(2026, 6, 22));
    expect(result.scheduledFlightTime, '8.30');
    expect(result.flightPlanTime, '07.44');
    expect(result.registration, 'GVZIG');
    expect(result.aircraftType, '787-9');
    expect(result.detailedRoute, startsWith('EGLL DET1J DET'));
    expect(result.detailedRoute, endsWith('ELKUX7N VIDP'));
    expect(result.zeroFuelWeight, '161500');
    expect(result.takeoffWeight, '212700');
    expect(result.landingWeight, '171000');
    expect(result.blockFuel, '51700');
    expect(result.tripFuel, '41700');
    expect(result.fuelTimes['trip'], '07:44');
    expect(result.fuelTimes['cont'], '00:28');
    expect(result.fuelTimes['taxiApu'], '00:23');
    expect(result.maxPayloadPlan, isTrue);
  });

  test('decodes split CONT20MIN and the complete OFP fuel table', () {
    const source = '''
OPERATIONAL FLIGHT PLAN VS23 PG 1/9
VIR23X 24AUG26 EGLL-KLAX
TRIP 51500 10.24
CONT20MI
N
1400 00.20
ALTN 2000 00.24
FNL RES 2000 00.30
ETP ADJ 0
ADDNL 0
UNUSABLE 0
ARR DLY 200 00.02
EXTRA 0 00.00
DISC 0 00.00
TAXI/APU 600 00.28
RAMP 57700
INCREASE/DECREASE FUEL BURN BY 253kg PER 1000kg CHANGE IN T.O.W.
''';

    final result = const OfpParser().parseText(source);

    expect(result.contingencyFuel, '1400');
    expect(result.fuelTimes['cont'], '00:20');
    expect(result.alternateFuel, '2000');
    expect(result.arrivalDelayFuel, '200');
    expect(result.discretionaryFuel, '0');
    expect(result.fuelBurnCorrectionFactor, '253');
  });

  test('uses the OFP date and local STD for the UTC countdown time', () {
    final times = const OfpTimeResolver().resolve(
      OfpFlightDetails(
        flightNumber: 'VS300',
        departure: 'EGLL',
        arrival: 'VIDP',
        departureTime: '1910',
        arrivalTime: '0340+',
        aircraftType: '787-9',
        registration: 'GVZIG',
        operation: 'NON ETOPS',
        callsign: 'VIR300',
        planId: '0023',
        flightDate: DateTime(2026, 6, 22),
      ),
    );

    expect(times.departureUtc, DateTime.utc(2026, 6, 22, 18, 10));
    expect(times.departureLabel, '18:10');
    expect(times.arrivalLabel, '22:10');
  });
}
