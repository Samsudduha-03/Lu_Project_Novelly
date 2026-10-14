import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/main_page/book_detail.dart';

import 'fixtures/book_detail_fixture.dart';

void main() {
  testWidgets('renders book detail and expands its description', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: BookDetailScreen(book: sampleBookDetail)),
    );

    expect(find.text('1984'), findsOneWidget);
    expect(find.text('by George Orwell'), findsOneWidget);
    expect(find.textContaining('384 pages'), findsOneWidget);
    expect(find.text('Book Description'), findsOneWidget);
    expect(find.text('Goodreads Review'), findsOneWidget);
    expect(find.text('Reviews (312)'), findsOneWidget);

    await tester.tap(find.byTooltip('Read full description'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Show less'), findsOneWidget);
    expect(find.textContaining('unchecked power.'), findsOneWidget);
  });

  testWidgets('sorts reviews by rating', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: BookDetailScreen(book: sampleBookDetail)),
    );

    final mostRecent = find.text('Most Recent');
    await tester.ensureVisible(mostRecent);
    await tester.tap(mostRecent);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest Rated').last);
    await tester.pumpAndSettle();

    final priya = tester.getTopLeft(find.text('Priya Sharma'));
    final aarav = tester.getTopLeft(find.text('Aarav Mehta'));
    expect(priya.dy, lessThan(aarav.dy));
  });
}
