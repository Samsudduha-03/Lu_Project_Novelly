import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/main_page/discover.dart';
import 'package:novelly/main_page/writer_profile.dart';
import 'package:novelly/publisher/publisher_dashboard.dart';

void main() {
  setUp(() {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'My Press',
      accountId: 'publisher-dashboard-test',
      isPublisher: true,
    );
  });

  testWidgets('publisher navigation opens the My Publishing dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    expect(find.text('My Publishing'), findsOneWidget);
    expect(find.text('My Book'), findsNothing);

    await tester.tap(find.text('My Publishing'));
    await tester.pumpAndSettle();

    expect(find.byType(PublisherDashboardScreen), findsOneWidget);
    expect(find.text('Published Books'), findsOneWidget);
    expect(find.text('Authors Worked With'), findsOneWidget);
  });

  testWidgets('writers keep the My Book navigation destination', (
    tester,
  ) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Writer',
      accountId: 'writer-dashboard-test',
      isWriter: true,
    );
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    expect(find.text('My Book'), findsOneWidget);
    expect(find.text('My Publishing'), findsNothing);
  });

  testWidgets('publishers can add, edit, and remove published books', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );

    await tester.tap(find.byTooltip('Add book'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Harbor Lights');
    await tester.enterText(find.byType(TextFormField).at(2), 'Nora Sen');
    await tester.enterText(find.byType(TextFormField).at(7), '2026');
    await tester.ensureVisible(find.text('Add Book'));
    await tester.tap(find.text('Add Book'));
    await tester.pumpAndSettle();

    expect(find.text('Harbor Lights'), findsOneWidget);
    expect(find.text('Nora Sen'), findsOneWidget);

    await tester.ensureVisible(find.text('Harbor Lights'));
    await tester.tap(find.text('Harbor Lights'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit book'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Harbor Lights II',
    );
    await tester.ensureVisible(find.text('Save Book'));
    await tester.tap(find.text('Save Book'));
    await tester.pumpAndSettle();

    expect(find.text('Harbor Lights II'), findsOneWidget);
    expect(find.text('Harbor Lights'), findsNothing);

    await tester.ensureVisible(find.text('Harbor Lights II'));
    await tester.tap(find.text('Harbor Lights II'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove book'));
    await tester.pumpAndSettle();
    expect(find.text('Your published books will appear here.'), findsOneWidget);
  });

  testWidgets('add-book form captures publication details for future storage', (
    tester,
  ) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Field Test Press',
      accountId: 'publisher-add-book-fields',
      isPublisher: true,
    );
    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );
    await tester.tap(find.byTooltip('Add book'));
    await tester.pumpAndSettle();

    expect(find.text('Add a New Book'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Genre'), findsOneWidget);
    expect(find.text('Page'), findsOneWidget);
    expect(find.text('Goodreads Link'), findsOneWidget);
    expect(find.text('ISBN Number'), findsOneWidget);
    expect(find.text('Publication'), findsOneWidget);
    expect(find.text('Add Image'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'River Archive');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'A story of memory.',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Mina Rahman');
    await tester.enterText(find.byType(TextFormField).at(3), '280');
    await tester.enterText(
      find.byType(TextFormField).at(4),
      'https://goodreads.com/book/show/123',
    );
    await tester.enterText(find.byType(TextFormField).at(5), '9781234567890');
    await tester.enterText(find.byType(TextFormField).at(6), 'Novelly Press');
    await tester.enterText(find.byType(TextFormField).at(7), '2025');
    final genreDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(genreDropdown);
    await tester.tap(genreDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fantasy').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add Book'));
    await tester.tap(find.text('Add Book'));
    await tester.pumpAndSettle();

    final book = PublisherWorkspaceStore.forAccount(
      'publisher-add-book-fields',
    ).books.single;
    expect(book.title, 'River Archive');
    expect(book.author, 'Mina Rahman');
    expect(book.genre, 'Fantasy');
    expect(book.description, 'A story of memory.');
    expect(book.pageCount, '280');
    expect(book.goodreadsLink, 'https://goodreads.com/book/show/123');
    expect(book.isbn, '9781234567890');
    expect(book.publication, 'Novelly Press');
    expect(book.year, '2025');
  });

  testWidgets('publishers can manage associated author profiles', (
    tester,
  ) async {
    const accountId = 'publisher-manage-authors';
    final workspace = PublisherWorkspaceStore.forAccount(accountId);
    workspace.books
      ..add(
        const PublisherBookRecord(
          id: 'author-search-book-1',
          title: 'A Harbor of Stars',
          author: 'Nora Sen',
          year: '2024',
        ),
      )
      ..add(
        const PublisherBookRecord(
          id: 'author-search-book-2',
          title: 'The Winter Orchard',
          author: 'Nora Sen',
          year: '2025',
        ),
      )
      ..add(
        const PublisherBookRecord(
          id: 'author-search-book-3',
          title: 'Riverglass',
          author: 'Mina Rahman',
          year: '2026',
        ),
      );
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'My Press',
      accountId: accountId,
      isPublisher: true,
    );

    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );

    await tester.ensureVisible(find.text('Add author'));
    await tester.tap(find.text('Add author'));
    await tester.pumpAndSettle();
    expect(find.text('Profile details'), findsNothing);
    await tester.enterText(find.byType(TextField).last, 'Nora');
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(Dialog), matching: find.text('Nora Sen')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Mina Rahman'),
      ),
      findsNothing,
    );
    await tester.tap(find.byTooltip('Add Nora Sen'));
    await tester.pumpAndSettle();

    expect(find.text('Nora Sen'), findsAtLeastNWidgets(1));
    expect(workspace.authors, hasLength(1));
    expect(workspace.authors.single.about, isEmpty);

    await tester.ensureVisible(find.text('Add author'));
    await tester.tap(find.text('Add author'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Already added'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Nora Sen').last);
    await tester.tap(find.text('Nora Sen').last);
    await tester.pumpAndSettle();
    expect(find.text('No profile details added yet.'), findsOneWidget);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Nora S.');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Award-winning novelist.',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nora S.'), findsOneWidget);
    expect(workspace.authors.single.name, 'Nora S.');
    expect(workspace.authors.single.about, 'Award-winning novelist.');
  });

  testWidgets('author search dialog fits a phone screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final workspace = PublisherWorkspaceStore.forAccount(
      'publisher-author-search-phone',
    );
    workspace.books.add(
      const PublisherBookRecord(
        id: 'phone-author-search-book',
        title: 'The Glass River',
        author: 'Lina Ahmed',
        year: '2026',
      ),
    );
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Phone Press',
      accountId: 'publisher-author-search-phone',
      isPublisher: true,
    );

    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );
    await tester.ensureVisible(find.text('Add author'));
    await tester.tap(find.text('Add author'));
    await tester.pumpAndSettle();

    expect(find.text('Search authors'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Lina Ahmed'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard books and authors appear in publisher profile', (
    tester,
  ) async {
    final workspace = PublisherWorkspaceStore.forAccount(
      'publisher-profile-catalog-sync',
    );
    workspace.books.add(
      const PublisherBookRecord(
        id: 'profile-book',
        title: 'The Moonlit Archive',
        author: 'Samira Noor',
        year: '2026',
      ),
    );
    workspace.authors.add(
      const PublisherAuthorRecord(
        id: 'profile-author',
        name: 'Samira Noor',
        about: 'A novelist.',
      ),
    );
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'My Press',
      accountId: 'publisher-profile-catalog-sync',
      isPublisher: true,
    );

    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1100));
    await tester.pumpAndSettle();

    expect(find.text('The Moonlit Archive'), findsOneWidget);
    expect(find.text('Samira Noor'), findsWidgets);
    expect(find.text('1 titles'), findsOneWidget);
  });

  testWidgets('dashboard matches the reference layout at tablet width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(768, 1152));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final workspace = PublisherWorkspaceStore.forAccount(
      'publisher-reference-layout',
    );
    workspace.books
      ..add(
        const PublisherBookRecord(
          id: 'book-one',
          title: 'The Salt Orchard',
          author: 'Amina Rahman',
          year: '2021',
        ),
      )
      ..add(
        const PublisherBookRecord(
          id: 'book-two',
          title: 'Letters from Sylhet',
          author: 'Tariq Hasan',
          year: '2019',
        ),
      )
      ..add(
        const PublisherBookRecord(
          id: 'book-three',
          title: 'River Cartographer',
          author: 'Amina Rahman',
          year: '2023',
        ),
      );
    workspace.authors
      ..add(
        const PublisherAuthorRecord(
          id: 'author-one',
          name: 'Amina Rahman',
          about: '',
        ),
      )
      ..add(
        const PublisherAuthorRecord(
          id: 'author-two',
          name: 'Tariq Hasan',
          about: '',
        ),
      );
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'My Press',
      accountId: 'publisher-reference-layout',
      isPublisher: true,
    );

    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Publishing'), findsNWidgets(2));
    expect(find.text('3 books'), findsOneWidget);
    expect(find.text('Authors Worked With'), findsOneWidget);
    expect(find.text('2 authors'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard book cards fit phone width without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final workspace = PublisherWorkspaceStore.forAccount(
      'publisher-phone-layout',
    );
    workspace.books
      ..add(
        const PublisherBookRecord(
          id: 'phone-book-1',
          title: 'The Salt Orchard',
          author: 'Amina Rahman',
          year: '2021',
        ),
      )
      ..add(
        const PublisherBookRecord(
          id: 'phone-book-2',
          title: 'Letters from Sylhet',
          author: 'Tariq Hasan',
          year: '2019',
        ),
      )
      ..add(
        const PublisherBookRecord(
          id: 'phone-book-3',
          title: 'River Cartographer',
          author: 'Amina Rahman',
          year: '2023',
        ),
      );
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'My Press',
      accountId: 'publisher-phone-layout',
      isPublisher: true,
    );

    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('The Salt Orchard'), findsOneWidget);
    expect(find.byTooltip('Manage The Salt Orchard'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-publishers cannot open the publisher dashboard', (
    tester,
  ) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Reader',
      accountId: 'reader-dashboard-test',
    );
    await tester.pumpWidget(
      const MaterialApp(home: PublisherDashboardScreen()),
    );

    expect(find.text('Publisher access required'), findsOneWidget);
    expect(find.byTooltip('Add book'), findsNothing);
  });

  test('publisher workspaces are isolated by account id', () {
    final firstPublisher = PublisherWorkspaceStore.forAccount(
      'publisher-owner-one',
    );
    final secondPublisher = PublisherWorkspaceStore.forAccount(
      'publisher-owner-two',
    );
    firstPublisher.books.add(
      const PublisherBookRecord(
        id: 'owned-book',
        title: 'Private collection',
        author: 'Publisher One',
        year: '2026',
      ),
    );

    expect(firstPublisher.books, hasLength(1));
    expect(secondPublisher.books, isEmpty);
  });
}
