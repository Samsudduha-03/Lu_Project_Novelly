import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/main_page/book_detail.dart';
import 'package:novelly/main_page/discover.dart';
import 'package:novelly/main_page/writer_profile.dart';

import 'fixtures/writer_profile_fixture.dart';

void main() {
  setUp(() {
    WriterProfileScreen.currentUser = const WriterProfile(name: 'Your profile');
  });

  testWidgets('Discover profile opens and allows editing profile details', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Author Profile'), findsOneWidget);
    expect(find.text('Your profile'), findsOneWidget);
    expect(find.byTooltip('Edit stats'), findsNothing);

    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'New Name');
    await tester.enterText(fields.at(1), 'https://goodreads.example/new');
    await tester.enterText(fields.at(2), 'https://facebook.example/new');
    await tester.enterText(fields.at(3), 'https://instagram.example/new');
    await tester.enterText(fields.at(4), 'https://writer.example');
    await tester.enterText(fields.at(5), 'A short author biography.');
    await tester.enterText(fields.at(6), 'North Star Press, Elm House');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('New Name'), findsOneWidget);
    expect(find.text('A short author biography.'), findsOneWidget);
    expect(find.byTooltip('https://facebook.example/new'), findsOneWidget);
    expect(find.byTooltip('https://instagram.example/new'), findsOneWidget);
    expect(find.byTooltip('https://writer.example'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    final savedFields = find.byType(TextField);
    expect(
      tester.widget<TextField>(savedFields.at(0)).controller!.text,
      'New Name',
    );
    expect(
      tester.widget<TextField>(savedFields.at(5)).controller!.text,
      'A short author biography.',
    );
    expect(
      tester.widget<TextField>(savedFields.at(6)).controller!.text,
      'North Star Press, Elm House',
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('New Name'), findsOneWidget);
  });

  testWidgets('sample author profile data is visible and derived from books', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: WriterProfileScreen(profile: sampleWriterProfile)),
    );

    expect(find.text('George Orwell'), findsOneWidget);
    expect(find.text('Published books'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('312'), findsOneWidget);
    expect(find.text('8.4K'), findsOneWidget);
    expect(find.byTooltip('Edit stats'), findsNothing);
    expect(find.text('Writer'), findsOneWidget);
    expect(find.byTooltip('https://facebook.com/georgeorwell'), findsOneWidget);
    expect(
      find.byTooltip('https://instagram.com/georgeorwell'),
      findsOneWidget,
    );
    expect(find.byTooltip('https://george-orwell.example'), findsOneWidget);
  });

  testWidgets('book author name opens that writer profile', (tester) async {
    final book = BookDetail(
      title: 'Sample book',
      author: 'Eleanor Hart',
      rating: 4.5,
      genres: ['Fiction'],
      reviews: [
        BookReview(
          reviewerName: 'Reader',
          rating: 4,
          createdAt: DateTime(2026),
          body: 'A review.',
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(home: BookDetailScreen(book: book)));

    await tester.tap(find.text('by Eleanor Hart'));
    await tester.pumpAndSettle();

    expect(find.text('Author Profile'), findsOneWidget);
    expect(find.text('Eleanor Hart'), findsOneWidget);
    expect(find.text('Published books'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('0'), findsOneWidget);
  });
}
