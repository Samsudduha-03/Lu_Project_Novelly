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
import 'package:novelly/main_page/writer_profile.dart';
import 'package:novelly/publisher/publisher_profile.dart';

import 'fixtures/discover_fixture.dart';

void main() {
  testWidgets('Discover has no bundled sample books by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    expect(find.text('No books found'), findsOneWidget);
    expect(find.text('The Quiet Meridian'), findsNothing);
    expect(WriterProfileScreen.currentUser.isPublisher, isFalse);
  });

  testWidgets('Discover can search books and switch layouts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DiscoverScreen(books: sampleDiscoverBooks)),
    );

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
    await tester.pumpWidget(
      const MaterialApp(home: DiscoverScreen(books: sampleDiscoverBooks)),
    );

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
    await tester.pumpWidget(
      const MaterialApp(home: DiscoverScreen(books: sampleDiscoverBooks)),
    );
    await tester.tap(find.byTooltip('Switch to grid view'));
    await tester.pumpAndSettle();
    final bookTitle = find.text('Salt & Silence');
    await tester.ensureVisible(bookTitle);
    await tester.tap(bookTitle);
    await tester.pumpAndSettle();

    expect(find.text('Salt & Silence'), findsOneWidget);
    expect(find.text('by Eleanor Hart'), findsOneWidget);
  });

  testWidgets('valid login opens Novelly', (WidgetTester tester) async {
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

    expect(find.text('Novelly'), findsOneWidget);
  });

  testWidgets('valid registration opens Novelly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Reader Name');
    await tester.enterText(fields.at(1), '@reader1@example.com');
    await tester.tap(find.text('Select your role'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Writer').last);
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

    expect(find.text('Novelly'), findsOneWidget);
    expect(find.text('No books found'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Reader Name'), findsOneWidget);
    expect(find.text('Writer'), findsOneWidget);
    expect(WriterProfileScreen.currentUser.isPublisher, isFalse);
  });

  testWidgets('role selector expands and password suggestion stays a hint', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    await tester.tap(find.text('Select your role'));
    await tester.pumpAndSettle();
    expect(find.text('Writer'), findsOneWidget);
    expect(find.text('Publisher'), findsOneWidget);
    expect(find.text('Cover Artist'), findsOneWidget);
    await tester.tap(find.text('Writer').last);
    await tester.pumpAndSettle();

    final passwordField = find.byType(TextFormField).at(2);
    await tester.ensureVisible(passwordField);
    final passwordWidget = tester.widget<TextFormField>(passwordField);
    final passwordInputDecoration = tester.widget<InputDecorator>(
      find.descendant(of: passwordField, matching: find.byType(InputDecorator)),
    );
    expect(passwordInputDecoration.decoration.hintText, isNotEmpty);
    await tester.tap(passwordField);
    await tester.pump();
    expect(passwordWidget.controller?.text, isEmpty);
    expect(find.byTooltip('Suggest another password'), findsNothing);
  });

  testWidgets(
    'registration as writer and publisher opens empty listings and the profile',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Dual Role Press');
      await tester.enterText(fields.at(1), 'dualrole@example.com');
      await tester.tap(find.text('Select your role'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Writer and Publisher').last);
      await tester.tap(find.text('Writer and Publisher').last);
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      final registerButton = find.widgetWithText(FilledButton, 'Register');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(WriterProfileScreen.currentUser.isWriter, isTrue);
      expect(WriterProfileScreen.currentUser.isPublisher, isTrue);
      expect(find.text('My Publishing'), findsOneWidget);
      expect(find.text('My Book'), findsNothing);
      expect(find.text('No books found'), findsOneWidget);
      expect(PublisherProfileScreen.currentUser?.name, 'Dual Role Press');

      await tester.tap(find.text('Publishers'));
      await tester.pumpAndSettle();
      expect(find.text('No publishers yet'), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Dual Role Press'), findsOneWidget);
      expect(find.text('Edit Profile'), findsWidgets);
    },
  );

  testWidgets('registration as publisher opens publisher profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Publisher Only Press');
    await tester.enterText(fields.at(1), 'publisheronly@example.com');
    await tester.tap(find.text('Select your role'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Publisher').last);
    await tester.tap(find.text('Publisher').last);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');

    final registerButton = find.widgetWithText(FilledButton, 'Register');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(WriterProfileScreen.currentUser.isWriter, isFalse);
    expect(WriterProfileScreen.currentUser.isPublisher, isTrue);
    expect(PublisherProfileScreen.currentUser?.name, 'Publisher Only Press');
    expect(find.text('My Publishing'), findsOneWidget);
    expect(find.text('My Book'), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Publisher Only Press'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('About the Author'), findsNothing);

    await tester.drag(find.byType(ListView).first, const Offset(0, -950));
    await tester.pumpAndSettle();
    expect(find.text('Writer worked with'), findsOneWidget);
    expect(find.text('The Silent Ink'), findsNothing);
  });
}
