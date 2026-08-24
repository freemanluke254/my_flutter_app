import 'package:flutter/material.dart';
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

  testWidgets('calendar prompts for a roster before displaying a month', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const PilotApp());

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('No roster loaded'), findsOneWidget);
    expect(find.text('August 2026'), findsNothing);
    expect(find.text('Load roster'), findsOneWidget);
  });
}
