import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/main.dart';

void main() {
  testWidgets('home screen shows dashboard and task interaction', (
    tester,
  ) async {
    await tester.pumpWidget(const FocusApp());

    expect(find.text('Good morning, Luke.'), findsOneWidget);
    expect(find.text('Today’s tasks'), findsOneWidget);
    expect(find.text('1 of 3 done'), findsOneWidget);

    await tester.tap(find.text('Review project direction'));
    await tester.pump();
    expect(find.text('2 of 3 done'), findsOneWidget);
  });

  testWidgets('navigation changes pages', (tester) async {
    await tester.pumpWidget(const FocusApp());
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(
      find.text('This space is ready for your next idea.'),
      findsOneWidget,
    );
  });
}
