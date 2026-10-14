// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/Splash,login,register/login.dart';
import 'package:novelly/Splash,login,register/register.dart';
import 'package:novelly/main_page/discover.dart';

void main() {
  testWidgets('Discover can search books and switch layouts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    expect(find.text('The Quiet Meridian'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch to grid view'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Switch to list view'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Okafor');
    await tester.pumpAndSettle();
    expect(find.text('Before the Clock Stops'), findsOneWidget);
    expect(find.text('The Quiet Meridian'), findsNothing);
  });

  testWidgets('tapping a book in list view opens its detail page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    await tester.tap(find.text('The Quiet Meridian'));
    await tester.pumpAndSettle();
    expect(find.text('by Eleanor Hart'), findsOneWidget);
    expect(find.text('Literary Fiction'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Switch to grid view'), findsOneWidget);
  });

  testWidgets('tapping a book in grid view opens its detail page', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
    await tester.tap(find.byTooltip('Switch to grid view'));
    await tester.pumpAndSettle();
    final bookTitle = find.text('Salt & Silence');
    await tester.ensureVisible(bookTitle);
    await tester.tap(bookTitle);
    await tester.pumpAndSettle();

    expect(find.text('Salt & Silence'), findsOneWidget);
    expect(find.text('by Eleanor Hart'), findsOneWidget);
  });

  testWidgets('valid login opens Discover', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final fields = find.byType(TextFormField);
    final loginButton = find.widgetWithText(FilledButton, 'Login');
    await tester.enterText(fields.at(0), '1reader@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Email must start with a letter'), findsOneWidget);
    expect(find.text('The Quiet Meridian'), findsNothing);

    await tester.enterText(fields.at(0), 'reader1+test@example.com');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('The Quiet Meridian'), findsOneWidget);
  });

  testWidgets('valid registration opens Discover', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Reader Name');
    await tester.enterText(fields.at(1), '@reader1@example.com');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Writer').last);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');

    final registerButton = find.widgetWithText(FilledButton, 'Register');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Email must start with a letter'), findsOneWidget);
    expect(find.text('The Quiet Meridian'), findsNothing);

    await tester.enterText(fields.at(1), 'reader1+test@example.com');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('The Quiet Meridian'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Reader Name'), findsOneWidget);
    expect(find.text('Writer'), findsOneWidget);
  });
}
