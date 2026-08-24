import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trying_flutter/main.dart';

void main() {
  testWidgets('create account validates empty fields', (tester) async {
    await tester.pumpWidget(const FocusApp());

    expect(find.text('Create your account'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Use at least 8 characters'), findsOneWidget);
  });

  testWidgets('valid account form opens dashboard', (tester) async {
    await tester.pumpWidget(const FocusApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'Luke Freeman');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'luke@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Luke.'), findsOneWidget);
  });

  testWidgets('sign in screen validates and opens dashboard', (tester) async {
    await tester.pumpWidget(const FocusApp());

    final signInLink = find.widgetWithText(TextButton, 'Sign in');
    await tester.ensureVisible(signInLink);
    await tester.tap(signInLink);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'luke@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Luke.'), findsOneWidget);
  });
}
