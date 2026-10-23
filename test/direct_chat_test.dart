import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/chat/chat_screen.dart';
import 'package:novelly/chat/chat_service.dart';
import 'package:novelly/cover/cover_artist_profile.dart';
import 'package:novelly/main_page/discover.dart';
import 'package:novelly/main_page/writer_profile.dart';
import 'package:novelly/publisher/publisher._directory.dart';
import 'package:novelly/publisher/publisher_profile.dart';

void main() {
  setUp(() {
    WriterProfileScreen.currentUser = const WriterProfile(
      name: 'Reader',
      accountId: 'reader-id',
      isWriter: true,
    );
  });

  test('direct conversation IDs are stable and reused for the same pair', () {
    final service = ChatService();
    final first = service.getOrCreateConversation(
      currentUserId: 'reader-id',
      userId: 'writer-id',
      userName: 'Writer',
    );
    final repeated = service.getOrCreateConversation(
      currentUserId: 'reader-id',
      userId: 'writer-id',
      userName: 'Writer',
    );

    expect(repeated.conversationId, first.conversationId);
    expect(service.conversations, hasLength(1));
    expect(first.userId, 'writer-id');
  });

  testWidgets('writer message button opens a direct conversation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: WriterProfileScreen(
          profile: WriterProfile(name: 'Writer One', accountId: 'writer-one'),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Message'));
    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Writer One'), findsOneWidget);
    expect(find.text('Send a message to Writer One to begin.'), findsOneWidget);
  });

  testWidgets('publisher message button opens a direct conversation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: PublisherProfileScreen(
          profile: PublisherProfile(
            name: 'Publisher One',
            accountId: 'publisher-one',
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Message'));
    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(
      find.text('Send a message to Publisher One to begin.'),
      findsOneWidget,
    );
  });

  testWidgets('publisher directory keeps the publisher account ID', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: DiscoverScreen(
          publishers: [
            PublisherEntry(
              name: 'Directory Press',
              rating: 4.5,
              bookCount: 10,
              accountId: 'directory-press-id',
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Publishers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Directory Press'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Message'));
    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(
      ChatService.shared.conversations.any(
        (conversation) => conversation.userId == 'directory-press-id',
      ),
      isTrue,
    );
  });

  testWidgets('cover artist message button opens a direct conversation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: CoverArtistProfileScreen(
          profile: WriterProfile(
            name: 'Artist One',
            accountId: 'artist-one',
            isCoverArtist: true,
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Message'));
    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Send a message to Artist One to begin.'), findsOneWidget);
  });
}
