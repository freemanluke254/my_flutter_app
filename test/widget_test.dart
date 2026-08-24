import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/app.dart';

void main() {
  testWidgets('create account opens and navigates to sign in', (tester) async {
    await tester.pumpWidget(const PilotApp());

    expect(find.text('Create your account'), findsOneWidget);

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('valid account creation opens the landing screen', (
    tester,
  ) async {
    await tester.pumpWidget(const PilotApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'Luke');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'luke@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome aboard, Luke'), findsOneWidget);
    expect(find.text('Today’s duty'), findsOneWidget);
    expect(find.text('BA275'), findsOneWidget);
    expect(find.text('Ready for your next flight'), findsOneWidget);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your complete roster, personal events and expiry dates.'),
      findsOneWidget,
    );
  });
}
