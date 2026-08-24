import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/main.dart';

void main() {
  testWidgets('fresh app opens the start page', (tester) async {
    await tester.pumpWidget(const PilotApp());

    expect(find.text('Pilot App'), findsOneWidget);
    expect(find.text('Fresh start'), findsOneWidget);
    expect(find.text('Ready to build one page at a time.'), findsOneWidget);
  });
}
