import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trying_flutter/main.dart';
import 'package:trying_flutter/features/planning/planning_compliance_page.dart';
import 'package:trying_flutter/features/commute/commute_reminder_page.dart';

void main() {
  test('commute timing includes travel, arrival buffer and reminder lead', () {
    const settings = CommuteSettings(
      enabled: true,
      homeAddress: 'Home',
      workAddress: 'Work',
      mode: 'Driving',
      arrivalBufferMinutes: 60,
      reminderLeadMinutes: 30,
      fallbackTravelMinutes: 160,
    );
    final signOn = DateTime(2026, 9, 1, 10);

    expect(settings.leaveTime(signOn), DateTime(2026, 9, 1, 6, 20));
    expect(settings.reminderTime(signOn), DateTime(2026, 9, 1, 5, 50));
  });

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

  testWidgets('completed roster flight creates a logbook draft', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    final completeButton = find.text('Flight complete · prepare log entry');
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    expect(find.text('Flight logbook'), findsOneWidget);
    expect(find.text('LHR → LAS'), findsOneWidget);
    expect(find.text('10:40'), findsWidgets);
  });

  testWidgets('flight briefing includes office report workflow', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.byIcon(Icons.airplane_ticket_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Report & brief'), findsOneWidget);
    expect(find.text('Sign on to eCrew'), findsOneWidget);
    expect(find.text('Flight package'), findsOneWidget);
    expect(find.text('Aircraft defects & MEL'), findsOneWidget);
    expect(find.text('Cabin crew brief'), findsOneWidget);
  });

  testWidgets('787 preflight checklist follows procedure stages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.byIcon(Icons.airplane_ticket_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preflight'));
    await tester.pumpAndSettle();

    expect(find.text('787-9 preflight flow'), findsOneWidget);
    expect(
      find.text('Flight deck arrival & preliminary setup'),
      findsOneWidget,
    );
    await tester.fling(
      find.byType(ListView).last,
      const Offset(0, -4000),
      3000,
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Before Start boundary reached'),
      findsOneWidget,
    );
  });

  testWidgets('custom compliance date shows a colour-coded countdown', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: PlanningCompliancePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Class 1 medical');
    await tester.fling(
      find.byType(ListView).last,
      const Offset(0, -1200),
      2000,
    );
    await tester.pumpAndSettle();
    final addButton = find.widgetWithText(FilledButton, 'Add reminder');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Class 1 medical'), findsOneWidget);
    expect(find.textContaining('days remaining'), findsOneWidget);
    expect(find.text('VALID'), findsOneWidget);
  });
}
