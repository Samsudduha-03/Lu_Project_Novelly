import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/main_page/discover.dart';
import 'package:novelly/main_page/writer_profile.dart';

import 'fixtures/publisher_directory_fixture.dart';

void main() {
  setUp(() {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Writer',
      isWriter: true,
    );
  });

  testWidgets('writers can browse the read-only publisher directory', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DiscoverScreen(publishers: samplePublishers)),
    );

    await tester.tap(find.text('Publishers'));
    await tester.pumpAndSettle();

    expect(find.text('Prothoma'), findsOneWidget);
    expect(find.text('Bangla Bazar'), findsOneWidget);
    expect(find.text('222'), findsOneWidget);
    expect(find.text('Add Picture'), findsNothing);
    expect(find.byTooltip('Edit publisher'), findsNothing);
    expect(find.byTooltip('Switch to grid view'), findsNothing);
  });

  testWidgets(
    'publisher-only accounts can browse and open other publisher profiles read-only',
    (tester) async {
      WriterProfileScreen.currentUser = const WriterProfile(
        name: 'My Press',
        isPublisher: true,
      );

      await tester.pumpWidget(
        const MaterialApp(home: DiscoverScreen(publishers: samplePublishers)),
      );

      expect(find.text('Books'), findsOneWidget);
      expect(find.text('Publishers'), findsOneWidget);
      expect(find.text('Covers'), findsOneWidget);
      await tester.tap(find.text('Publishers'));
      await tester.pumpAndSettle();

      expect(find.text('Prothoma'), findsOneWidget);
      await tester.tap(find.text('Prothoma'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).last, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Publisher Profile'), findsNothing);
      expect(find.text('Writer worked with'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.text('Edit Profile'), findsNothing);
    },
  );

  testWidgets('publisher account can edit its own profile', (tester) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'My Press',
      isPublisher: true,
    );

    await tester.pumpWidget(
      const MaterialApp(home: DiscoverScreen(publishers: samplePublishers)),
    );
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('My Press'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('Discover shows no publishers when no data is passed', (
    tester,
  ) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'My Press',
      isPublisher: true,
    );

    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
    await tester.tap(find.text('Publishers'));
    await tester.pumpAndSettle();

    expect(find.text('No publishers yet'), findsOneWidget);
    expect(find.text('Prothoma'), findsNothing);
  });

  testWidgets(
    'writer and publisher accounts can browse but not edit listings',
    (tester) async {
      WriterProfileScreen.currentUser = const WriterProfile(
        name: 'Writer and Publisher',
        isWriter: true,
        isPublisher: true,
      );
      await tester.pumpWidget(
        const MaterialApp(home: DiscoverScreen(publishers: samplePublishers)),
      );
      await tester.tap(find.text('Publishers'));
      await tester.pumpAndSettle();

      expect(find.text('Prothoma'), findsOneWidget);
      expect(find.text('Add Publisher'), findsNothing);
      expect(find.byTooltip('Edit publisher'), findsNothing);
    },
  );
}
