import 'package:novelly/chat/chat_model.dart';
import 'package:novelly/chat/chat_service.dart';

final sampleChatConversation = ChatConversation(
  conversationId: 'conversation-jane-austen',
  userId: 'jane-austen',
  userName: 'Jane Austen',
  isOnline: true,
  lastMessagePreview: 'Oh, that is a lovely choice!',
  lastMessageAt: DateTime.now().subtract(const Duration(minutes: 2)),
  unreadCount: 1,
);

final _now = DateTime.now();

final sampleChatMessages = [
  ChatMessage(
    messageId: 'jane-1',
    conversationId: sampleChatConversation.conversationId,
    senderId: sampleChatConversation.userId,
    type: ChatMessageType.text,
    text: 'Hello! I loved your review of Pride and Prejudice.',
    sentAt: _now.subtract(const Duration(minutes: 16)),
  ),
  ChatMessage(
    messageId: 'reader-1',
    conversationId: sampleChatConversation.conversationId,
    senderId: 'current-user',
    type: ChatMessageType.text,
    text: 'Thank you so much! It is one of my all-time favorites.',
    sentAt: _now.subtract(const Duration(minutes: 14)),
  ),
  ChatMessage(
    messageId: 'jane-2',
    conversationId: sampleChatConversation.conversationId,
    senderId: sampleChatConversation.userId,
    type: ChatMessageType.text,
    text: 'Have you read Persuasion? I think you would love it too.',
    sentAt: _now.subtract(const Duration(minutes: 10)),
  ),
  ChatMessage(
    messageId: 'reader-2',
    conversationId: sampleChatConversation.conversationId,
    senderId: 'current-user',
    type: ChatMessageType.text,
    text: 'Yes! Persuasion is absolutely wonderful.',
    sentAt: _now.subtract(const Duration(minutes: 8)),
  ),
  ChatMessage(
    messageId: 'jane-3',
    conversationId: sampleChatConversation.conversationId,
    senderId: sampleChatConversation.userId,
    type: ChatMessageType.text,
    text: 'Oh, that is a lovely choice!',
    sentAt: _now.subtract(const Duration(minutes: 2)),
  ),
];

ChatService createSampleChatService() => ChatService(
  conversations: [sampleChatConversation],
  messages: sampleChatMessages,
);
