import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novelly/chat/chat_list.dart';
import 'package:novelly/chat/chat_model.dart';
import 'package:novelly/chat/chat_screen.dart';
import 'package:novelly/chat/chat_service.dart';
import 'package:novelly/main_page/discover.dart';

import 'fixtures/chat_fixture.dart';

void main() {
  test('chat service sends text and image messages in memory', () {
    final service = createSampleChatService();
    final textMessage = service.sendTextMessage(
      conversationId: sampleChatConversation.conversationId,
      text: '  A new message  ',
    );
    final imageMessage = service.sendImageMessage(
      conversationId: sampleChatConversation.conversationId,
      imagePath: 'picked-image.jpg',
    );

    expect(textMessage.text, 'A new message');
    expect(textMessage.senderId, service.currentUserId);
    expect(imageMessage.type, ChatMessageType.image);
    expect(imageMessage.imagePath, 'picked-image.jpg');
    expect(service.conversations.single.lastMessagePreview, 'Photo');
    expect(service.conversations.single.unreadCount, 0);
  });

  testWidgets('Discover Chat tab opens an empty conversation list by default', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('No conversations yet'), findsOneWidget);
    expect(find.text('Jane Austen'), findsNothing);
    expect(find.text('Eleanor Hart'), findsNothing);
    expect(find.text('James Okafor'), findsNothing);
  });

  test('a fresh chat service is empty for database-backed use', () {
    expect(ChatService().conversations, isEmpty);
  });

  testWidgets('chat list opens conversation and supports sending text', (
    tester,
  ) async {
    final service = createSampleChatService();
    await tester.pumpWidget(
      MaterialApp(home: ChatListScreen(service: service)),
    );

    expect(find.text('Jane Austen'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text('Jane Austen'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(
      find.text('Hello! I loved your review of Pride and Prejudice.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'A lovely book.');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('A lovely book.'), findsOneWidget);
    expect(service.conversations.single.unreadCount, 0);
  });

  testWidgets('voice and video call controls show Coming soon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(
          conversation: sampleChatConversation,
          service: createSampleChatService(),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Voice call'));
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);

    await tester.tap(find.byTooltip('Video call'));
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
