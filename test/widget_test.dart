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

    expect(find.text('Good afternoon, Luke'), findsOneWidget);
    expect(find.text('BA275'), findsOneWidget);
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

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'luke@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Good afternoon, Luke'), findsOneWidget);
  });

  testWidgets('learning page filters and expands definitions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Knowledge centre'), findsOneWidget);
    expect(find.text('Reduced contingency fuel'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'RCF');
    await tester.pump();
    expect(find.text('Reduced contingency fuel'), findsOneWidget);
    expect(find.text('Boeing 787 fuel system'), findsNothing);

    await tester.tap(find.text('Reduced contingency fuel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('statistical contingency fuel'), findsOneWidget);
  });

  testWidgets('logbook page opens the compliant flight entry form', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Flight logbook'), findsOneWidget);
    expect(find.text('UK PART-FCL · FCL.050'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add flight'));
    await tester.pumpAndSettle();
    expect(find.text('Add flight entry'), findsOneWidget);
    expect(find.text('Aircraft type'), findsOneWidget);
    expect(find.text('Pilot-in-command name'), findsOneWidget);
  });

  testWidgets('completed roster flight creates a logbook draft', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    final completeButton = find.text('Flight complete · prepare log entry');
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    expect(find.text('Flight logbook'), findsOneWidget);
    expect(find.text('LHR → LAS'), findsOneWidget);
    expect(find.text('10:40'), findsWidgets);
  });
}
