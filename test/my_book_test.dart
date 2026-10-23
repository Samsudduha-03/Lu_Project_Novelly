import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/main_page/my_book.dart';
import 'package:novelly/main_page/writer_profile.dart';

void main() {
  setUp(() {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Test Writer',
      accountId: 'test-writer',
      isWriter: true,
    );
  });

  testWidgets('My Book starts without sample titles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MyBookScreen()));

    expect(
      find.text('No books yet. Add a book to get started.'),
      findsOneWidget,
    );
    expect(find.text('1984'), findsNothing);
    expect(find.text('Animal Farm'), findsNothing);
  });

  testWidgets('adding a book and tapping it shows its saved details', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: MyBookScreen()));
    await tester.tap(find.text('Add Book'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'The Last Lantern');
    await tester.enterText(fields.at(1), 'A story about finding a way home.');
    await tester.enterText(fields.at(2), '240');
    await tester.enterText(fields.at(3), 'https://goodreads.example/book');
    await tester.enterText(fields.at(4), '978-1-2345-6789-0');
    await tester.enterText(fields.at(5), 'North Star Press');

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fantasy').last);
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(FilledButton, 'Add Book');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('The Last Lantern'), findsOneWidget);
    await tester.tap(find.text('The Last Lantern'));
    await tester.pumpAndSettle();

    expect(find.text('by Test Writer'), findsOneWidget);
    expect(find.text('Fantasy'), findsOneWidget);
    expect(find.textContaining('240 pages'), findsOneWidget);
    expect(find.text('A story about finding a way home.'), findsOneWidget);
    expect(find.text('North Star Press'), findsOneWidget);
    expect(find.text('978-1-2345-6789-0'), findsOneWidget);
    expect(find.text('https://goodreads.example/book'), findsOneWidget);

    expect(WriterProfileScreen.currentUser.publishedBookCount, 1);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Published books'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
