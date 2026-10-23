import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/cover/cover_artist_profile.dart';
import 'package:novelly/cover/cover_design.dart';
import 'package:novelly/cover/my_designs.dart';
import 'package:novelly/main_page/discover.dart';
import 'package:novelly/main_page/writer_profile.dart';

void main() {
  setUp(() {
    CoverArtistWorkspace.clearForTesting();
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Cover artist',
      accountId: 'cover-artist-test',
      isCoverArtist: true,
    );
    WriterProfileScreen.currentAvatarPath = null;
  });

  testWidgets('cover artists have a dedicated My Designs destination', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    expect(find.text('My Designs'), findsOneWidget);
    await tester.tap(find.text('My Designs').last);
    await tester.pumpAndSettle();

    expect(find.byType(MyDesignsScreen), findsOneWidget);
    expect(find.text('All Covers'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('No covers yet'), findsOneWidget);

    await tester.tap(find.text('Drafts'));
    await tester.pumpAndSettle();
    expect(find.text('No drafts yet'), findsOneWidget);
  });

  testWidgets('designs and profile display supplied cover data', (
    tester,
  ) async {
    const cover = CoverDesign(
      title: 'Test Cover',
      creator: 'Cover artist',
      color: Color(0xFF52756C),
    );
    const draft = CoverDesign(
      title: 'Test Draft',
      creator: 'Cover artist',
      color: Color(0xFF4C6C94),
      isDraft: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: MyDesignsScreen(covers: [cover], drafts: [draft]),
      ),
    );
    expect(find.text('Test Cover'), findsNWidgets(2));

    await tester.tap(find.text('Drafts'));
    await tester.pumpAndSettle();
    expect(find.text('Test Draft'), findsNWidgets(2));

    await tester.pumpWidget(
      const MaterialApp(
        home: CoverArtistProfileScreen(isCurrentUser: true, covers: [cover]),
      ),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Test Cover'), findsNWidgets(2));
  });

  testWidgets('cover upload form requires image and cover details', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MyDesignsScreen()));
    await tester.tap(find.byTooltip('Add cover'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Cover Page'), findsOneWidget);
    expect(find.text('Book name'), findsOneWidget);
    expect(find.text('Author name'), findsOneWidget);
    expect(find.text('Year made'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Book title');
    await tester.enterText(find.byType(TextFormField).at(1), 'Book author');
    await tester.enterText(find.byType(TextFormField).at(2), '2025');
    await tester.tap(find.widgetWithText(FilledButton, 'Add Cover'));
    await tester.pumpAndSettle();

    expect(find.text('Upload the cover page to continue.'), findsOneWidget);
    expect(find.text('Book title'), findsOneWidget);
  });

  testWidgets('cover upload form fits on a phone screen', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MyDesignsScreen()));
    await tester.tap(find.byTooltip('Add cover'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Cover Page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cover artist can edit profile description', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: CoverArtistProfileScreen(isCurrentUser: true)),
    );
    await tester.ensureVisible(find.text('Edit Profile'));
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile picture'), findsOneWidget);
    final editDialog = find.byType(Dialog);
    expect(
      find.descendant(of: editDialog, matching: find.text('About the Artist')),
      findsOneWidget,
    );
    for (final label in [
      'Design Specialization',
      'Art Style',
      'Services Offered',
      'Years of Experience',
      'Design Tools',
      'Work Availability',
      'Custom Design Requests',
      'Pricing & Packages',
      'Average Delivery Time',
      'Revision Policy',
    ]) {
      expect(
        find.descendant(of: editDialog, matching: find.text(label)),
        findsOneWidget,
        reason: 'Missing $label field',
      );
    }
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'I design story-led book covers.',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Fantasy, Sci-Fi');
    await tester.enterText(find.byType(TextFormField).at(9), '2000-5000 tk');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('I design story-led book covers.'), findsOneWidget);
    expect(find.text('Design Specialization'), findsNothing);
    await tester.tap(find.text('See more'));
    await tester.pumpAndSettle();
    expect(find.text('See less'), findsOneWidget);
    expect(find.text('Fantasy, Sci-Fi'), findsOneWidget);
    expect(find.text('2000-5000 tk'), findsOneWidget);
    expect(
      WriterProfileScreen.currentUser.designSpecialization,
      'Fantasy, Sci-Fi',
    );
    expect(WriterProfileScreen.currentUser.pricingPackages, '2000-5000 tk');
    expect(find.text('View Portfolio'), findsNothing);
    expect(find.byTooltip('Bookmark profile'), findsNothing);
  });

  testWidgets('cover artist profile uses account details and empty sections', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(CoverArtistProfileScreen), findsOneWidget);
    expect(find.text('Cover artist'), findsOneWidget);
    expect(find.text('Cover Artist'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('My Covers'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Publishers Worked With'), findsOneWidget);
    expect(find.text('No covers yet'), findsOneWidget);
    expect(find.text('No publishers yet'), findsOneWidget);

    await tester.tap(find.text('My Designs').last);
    await tester.pumpAndSettle();
    expect(find.byType(MyDesignsScreen), findsOneWidget);
  });

  testWidgets('cover artist can cancel or confirm logging out', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CoverArtistProfileScreen(isCurrentUser: true)),
    );

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(find.byType(CoverArtistProfileScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Discover covers section has no seeded cover data', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
    await tester.tap(find.text('Covers'));
    await tester.pumpAndSettle();

    expect(find.text('No cover artists yet'), findsOneWidget);
    expect(find.text('Sample cover'), findsNothing);
  });

  testWidgets('only cover artists can open the My Designs workspace', (
    tester,
  ) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Reader',
      isWriter: true,
    );
    await tester.pumpWidget(const MaterialApp(home: MyDesignsScreen()));

    expect(
      find.text('My Designs is only available to cover artists.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Add cover'), findsNothing);
    expect(find.text('All Covers'), findsNothing);
  });

  testWidgets('all users can browse real cover-artist profiles', (
    tester,
  ) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Reader',
      isWriter: true,
    );
    const artist = WriterProfile(
      name: 'A Cover Artist',
      about: 'Illustrated book jackets.',
      isCoverArtist: true,
    );
    const unrelatedWriter = WriterProfile(name: 'A Writer', isWriter: true);

    await tester.pumpWidget(
      const MaterialApp(
        home: DiscoverScreen(
          coverArtists: [artist, unrelatedWriter],
          initialTab: 2,
        ),
      ),
    );

    expect(find.text('A Cover Artist'), findsOneWidget);
    expect(find.text('A Writer'), findsNothing);
    await tester.tap(find.text('A Cover Artist'));
    await tester.pumpAndSettle();

    expect(find.byType(CoverArtistProfileScreen), findsOneWidget);
    expect(find.text('Illustrated book jackets.'), findsOneWidget);
    expect(find.byTooltip('Edit profile photo'), findsNothing);
    expect(find.byIcon(Icons.verified), findsNothing);
    expect(find.text('See more'), findsOneWidget);
    expect(find.text('My Book'), findsOneWidget);
  });

  testWidgets('public profile See all opens the public covers section', (
    tester,
  ) async {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Reader',
      isWriter: true,
    );
    const artist = WriterProfile(name: 'Public Artist', isCoverArtist: true);
    await tester.pumpWidget(
      const MaterialApp(home: CoverArtistProfileScreen(profile: artist)),
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all').first);
    await tester.pumpAndSettle();

    expect(find.byType(DiscoverScreen), findsOneWidget);
    expect(find.text('No cover artists yet'), findsOneWidget);
    expect(
      find.text('My Designs is only available to cover artists.'),
      findsNothing,
    );
  });

  testWidgets('cover artists can browse all three Discover sections', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Publishers'), findsOneWidget);
    expect(find.text('Covers'), findsOneWidget);
  });
}
