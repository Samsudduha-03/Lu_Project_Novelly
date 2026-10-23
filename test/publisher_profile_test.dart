import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/Splash,login,register/login.dart';
import 'package:novelly/main_page/writer_profile.dart';
import 'package:novelly/publisher/publisher_profile.dart';

void main() {
  setUp(() {
    PublisherProfileScreen.currentUser = null;
  });

  testWidgets('publisher details expand and collapse inline', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(
          profile: PublisherProfile(
            name: 'Sample Press',
            description: 'Independent publisher of thoughtful fiction.',
            genresPublished: 'Fiction, poetry',
            bookFairParticipation: 'Yes',
            publishingModel: 'Traditional',
          ),
        ),
      ),
    );

    expect(find.text('Description'), findsOneWidget);
    expect(
      find.text('Independent publisher of thoughtful fiction.'),
      findsOneWidget,
    );
    expect(find.text('Genres Published'), findsNothing);

    await tester.tap(find.text('See more →'));
    await tester.pumpAndSettle();

    const detailLabels = [
      'Genres Published',
      'Book Fair Participation',
      'Publishing Model',
      'Print-on-Demand',
      'Manuscript Submission Guidelines',
      'Manuscript Feedback Time',
      'Average Book Publishing Time',
      'In-house Editorial Team',
      'ISBN Support',
      'Author Royalty Percentage or Terms',
      'Royalty Model',
      'Sales Reports for Authors',
      'Complimentary Copies',
      'Contract Duration',
    ];
    for (final label in detailLabels) {
      expect(find.text(label), findsOneWidget, reason: 'Missing $label row');
    }
    expect(find.text('Traditional'), findsOneWidget);
    expect(find.text('Not specified'), findsAtLeastNWidgets(10));
    expect(find.text('See less ↑'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See less ↑'));
    await tester.pumpAndSettle();

    expect(find.text('Genres Published'), findsNothing);
    expect(find.text('See more →'), findsOneWidget);
  });

  testWidgets('writers worked with use small circular profile badges', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(
          profile: PublisherProfile(
            name: 'Sample Press',
            writersWorkedWith: ['Amina Rahman', 'David Lee'],
          ),
        ),
      ),
    );

    expect(find.text('Writer worked with'), findsOneWidget);
    expect(find.text('Amina Rahman'), findsOneWidget);
    expect(find.text('David Lee'), findsOneWidget);
    final avatars = tester.widgetList<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatars, hasLength(2));
    expect(avatars.every((avatar) => avatar.radius == 14), isTrue);
  });

  testWidgets('Edit Profile saves values shown by the Description section', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(
          isCurrentUser: true,
          profile: PublisherProfile(name: 'Sample Press'),
        ),
      ),
    );

    await tester.tap(find.text('Edit Profile').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == 'Description',
      ),
      'We publish new voices in fiction.',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Genres Published',
      ),
      'Fiction, mystery',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('We publish new voices in fiction.'), findsOneWidget);
    expect(find.text('Publishes: Fiction, mystery'), findsOneWidget);

    await tester.tap(find.text('See more →'));
    await tester.pumpAndSettle();
    expect(find.text('Fiction, mystery'), findsOneWidget);
  });

  testWidgets('Edit Profile field prompts disappear when values are set', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(
          isCurrentUser: true,
          profile: PublisherProfile(
            name: 'Sample Press',
            publishingModel: 'Traditional',
            printOnDemand: 'Yes',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit Profile').first);
    await tester.pumpAndSettle();

    final publishingModel = tester.widget<DropdownButtonFormField<String>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.hintText == null &&
            widget.initialValue == 'Traditional',
      ),
    );
    expect(publishingModel.decoration.labelText, isNull);
    expect(find.text('Publishing Model'), findsOneWidget);
    expect(find.text('Traditional'), findsOneWidget);
    expect(find.text('Print-on-Demand'), findsOneWidget);

    final publisherName = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Publisher name',
      ),
    );
    expect(publisherName.decoration?.labelText, isNull);
    expect(publisherName.decoration?.hintText, 'Publisher name');
    expect(publisherName.controller?.text, 'Sample Press');
  });

  testWidgets('publisher profile remains usable at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(
          profile: PublisherProfile(
            name: 'Small Screen Press',
            description: 'A short publisher introduction.',
          ),
        ),
      ),
    );

    await tester.tap(find.text('See more →'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('publisher books display in three columns on phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(
          profile: PublisherProfile(
            name: 'Three Column Press',
            books: [
              PublisherBook(title: 'Book One', year: '2024'),
              PublisherBook(title: 'Book Two', year: '2023'),
              PublisherBook(title: 'Book Three', year: '2022'),
            ],
          ),
        ),
      ),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      3,
    );
    expect(find.text('Book One'), findsOneWidget);
    expect(find.text('Book Two'), findsOneWidget);
    expect(find.text('Book Three'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('publisher profile has no seeded writers or books by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(isCurrentUser: true, profile: null),
      ),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(find.text('The Silent Ink'), findsNothing);
    expect(find.text('Whispers of the Valley'), findsNothing);
    expect(find.text('Beyond the Horizon'), findsNothing);
    expect(find.text('Fragments of Time'), findsNothing);
    expect(find.text('Amina Rahman'), findsNothing);
  });

  testWidgets('publisher profile supports logout', (tester) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Sample Press',
      accountId: 'publisher-profile-logout',
      isPublisher: true,
    );
    PublisherProfileScreen.currentUser = PublisherProfile(name: 'Sample Press');

    await tester.pumpWidget(
      const MaterialApp(home: PublisherProfileScreen(isCurrentUser: true)),
    );

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(WriterProfileScreen.currentUser.isPublisher, isFalse);
    expect(PublisherProfileScreen.currentUser, isNull);
  });
}
