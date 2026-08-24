import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/app.dart';

void main() {
  testWidgets('app temporarily opens directly on the landing screen', (
    tester,
  ) async {
    await tester.pumpWidget(const PilotApp());

    expect(find.text('Welcome aboard, Luke'), findsOneWidget);
    expect(find.text('Today’s duty'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
  });
}
