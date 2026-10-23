import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'chat_model.dart';

class ChatService extends ChangeNotifier {
  ChatService({
    Iterable<ChatConversation> conversations = const [],
    Iterable<ChatMessage> messages = const [],
    this.currentUserId = 'current-user',
  }) {
    for (final conversation in conversations) {
      if (_conversations.containsKey(conversation.conversationId)) {
        throw ArgumentError.value(
          conversation.conversationId,
          'conversations',
          'Conversation IDs must be unique.',
        );
      }
      _conversations[conversation.conversationId] = conversation;
      _messages[conversation.conversationId] = [];
    }

    for (final message in messages) {
      final conversationMessages = _messages[message.conversationId];
      if (conversationMessages == null) {
        throw ArgumentError.value(
          message.conversationId,
          'messages',
          'Every message must belong to a supplied conversation.',
        );
      }
      conversationMessages.add(message);
    }

    for (final conversationMessages in _messages.values) {
      conversationMessages.sort(
        (first, second) => first.sentAt.compareTo(second.sentAt),
      );
    }
  }

  factory ChatService.demo() {
    final now = DateTime.now();
    const janeConversationId = 'demo-jane-austen';
    const eleanorConversationId = 'demo-eleanor-hart';
    const jamesConversationId = 'demo-james-okafor';

    return ChatService(
      conversations: [
        ChatConversation(
          conversationId: janeConversationId,
          userId: 'jane-austen',
          userName: 'Jane Austen',
          isOnline: true,
          lastMessagePreview: 'Oh, that is a lovely choice!',
          lastMessageAt: now.subtract(const Duration(minutes: 2)),
          unreadCount: 2,
        ),
        ChatConversation(
          conversationId: eleanorConversationId,
          userId: 'eleanor-hart',
          userName: 'Eleanor Hart',
          isOnline: true,
          lastMessagePreview: 'I would love to hear what you think.',
          lastMessageAt: now.subtract(const Duration(minutes: 18)),
        ),
        ChatConversation(
          conversationId: jamesConversationId,
          userId: 'james-okafor',
          userName: 'James Okafor',
          lastMessagePreview: 'Thanks for the recommendation!',
          lastMessageAt: now.subtract(const Duration(days: 1, hours: 2)),
        ),
      ],
      messages: [
        ChatMessage(
          messageId: 'demo-jane-1',
          conversationId: janeConversationId,
          senderId: 'jane-austen',
          type: ChatMessageType.text,
          text: 'Hello! I loved your review of Pride and Prejudice.',
          sentAt: now.subtract(const Duration(minutes: 16)),
        ),
        ChatMessage(
          messageId: 'demo-jane-2',
          conversationId: janeConversationId,
          senderId: 'current-user',
          type: ChatMessageType.text,
          text: 'Thank you so much! It is one of my all-time favorites.',
          sentAt: now.subtract(const Duration(minutes: 14)),
        ),
        ChatMessage(
          messageId: 'demo-jane-3',
          conversationId: janeConversationId,
          senderId: 'jane-austen',
          type: ChatMessageType.text,
          text: 'Have you read Persuasion? I think you would love it too.',
          sentAt: now.subtract(const Duration(minutes: 10)),
        ),
        ChatMessage(
          messageId: 'demo-jane-4',
          conversationId: janeConversationId,
          senderId: 'current-user',
          type: ChatMessageType.text,
          text: 'Yes! Persuasion is absolutely wonderful.',
          sentAt: now.subtract(const Duration(minutes: 8)),
        ),
        ChatMessage(
          messageId: 'demo-jane-5',
          conversationId: janeConversationId,
          senderId: 'jane-austen',
          type: ChatMessageType.text,
          text: 'Oh, that is a lovely choice!',
          sentAt: now.subtract(const Duration(minutes: 2)),
        ),
        ChatMessage(
          messageId: 'demo-eleanor-1',
          conversationId: eleanorConversationId,
          senderId: 'current-user',
          type: ChatMessageType.text,
          text:
              'I just finished The Quiet Meridian. The ending stayed with me.',
          sentAt: now.subtract(const Duration(minutes: 24)),
        ),
        ChatMessage(
          messageId: 'demo-eleanor-2',
          conversationId: eleanorConversationId,
          senderId: 'eleanor-hart',
          type: ChatMessageType.text,
          text: 'I would love to hear what you think.',
          sentAt: now.subtract(const Duration(minutes: 18)),
        ),
        ChatMessage(
          messageId: 'demo-james-1',
          conversationId: jamesConversationId,
          senderId: 'james-okafor',
          type: ChatMessageType.text,
          text: 'Do you have any science fiction recommendations?',
          sentAt: now.subtract(const Duration(days: 1, hours: 3)),
        ),
        ChatMessage(
          messageId: 'demo-james-2',
          conversationId: jamesConversationId,
          senderId: 'current-user',
          type: ChatMessageType.text,
          text: 'Try The Left Hand of Darkness. It is a favorite of mine.',
          sentAt: now.subtract(const Duration(days: 1, hours: 2, minutes: 30)),
        ),
        ChatMessage(
          messageId: 'demo-james-3',
          conversationId: jamesConversationId,
          senderId: 'james-okafor',
          type: ChatMessageType.text,
          text: 'Thanks for the recommendation!',
          sentAt: now.subtract(const Duration(days: 1, hours: 2)),
        ),
      ],
    );
  }

  static final ChatService shared = ChatService();

  String currentUserId;
  final Map<String, ChatConversation> _conversations = {};
  final Map<String, List<ChatMessage>> _messages = {};
  int _messageSequence = 0;

  List<ChatConversation> get conversations {
    final result = _conversations.values.toList()
      ..sort((first, second) {
        final firstTime = first.lastMessageAt;
        final secondTime = second.lastMessageAt;
        if (firstTime == null) return secondTime == null ? 0 : 1;
        if (secondTime == null) return -1;
        return secondTime.compareTo(firstTime);
      });
    return List.unmodifiable(result);
  }

  List<ChatMessage> messagesFor(String conversationId) {
    final messages = _messages[conversationId];
    if (messages == null) {
      throw ArgumentError.value(
        conversationId,
        'conversationId',
        'Conversation was not found.',
      );
    }
    return List.unmodifiable(messages);
  }

  ChatConversation getOrCreateConversation({
    required String currentUserId,
    required String userId,
    required String userName,
    String? avatarPath,
  }) {
    final senderId = currentUserId.trim();
    final recipientId = userId.trim();
    if (senderId.isEmpty) {
      throw ArgumentError.value(
        currentUserId,
        'currentUserId',
        'Current user ID cannot be empty.',
      );
    }
    if (recipientId.isEmpty) {
      throw ArgumentError.value(
        userId,
        'userId',
        'Recipient user ID cannot be empty.',
      );
    }
    if (senderId == recipientId) {
      throw ArgumentError.value(
        userId,
        'userId',
        'Cannot start a conversation with the current user.',
      );
    }

    this.currentUserId = senderId;
    final participantIds = [senderId, recipientId]..sort();
    final encodedPair = base64Url
        .encode(utf8.encode(participantIds.join('\u0000')))
        .replaceAll('=', '');
    final conversationId = 'direct-$encodedPair';
    final existing = _conversations[conversationId];
    if (existing != null) return existing;

    final conversation = ChatConversation(
      conversationId: conversationId,
      userId: recipientId,
      userName: userName,
      avatarPath: avatarPath,
    );
    _conversations[conversationId] = conversation;
    _messages[conversationId] = [];
    notifyListeners();
    return conversation;
  }

  void markAsRead(String conversationId) {
    final conversation = _conversationFor(conversationId);
    if (conversation.unreadCount == 0) return;
    _conversations[conversationId] = conversation.copyWith(unreadCount: 0);
    notifyListeners();
  }

  ChatMessage sendTextMessage({
    required String conversationId,
    required String text,
  }) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Message text cannot be empty.');
    }
    return _addMessage(
      conversationId: conversationId,
      type: ChatMessageType.text,
      text: trimmedText,
    );
  }

  ChatMessage sendImageMessage({
    required String conversationId,
    required String imagePath,
  }) {
    if (imagePath.trim().isEmpty) {
      throw ArgumentError.value(
        imagePath,
        'imagePath',
        'Image path cannot be empty.',
      );
    }
    return _addMessage(
      conversationId: conversationId,
      type: ChatMessageType.image,
      imagePath: imagePath,
    );
  }

  ChatConversation _conversationFor(String conversationId) {
    final conversation = _conversations[conversationId];
    if (conversation == null) {
      throw ArgumentError.value(
        conversationId,
        'conversationId',
        'Conversation was not found.',
      );
    }
    return conversation;
  }

  ChatMessage _addMessage({
    required String conversationId,
    required ChatMessageType type,
    String? text,
    String? imagePath,
  }) {
    final conversation = _conversationFor(conversationId);
    final sentAt = DateTime.now();
    final message = ChatMessage(
      messageId:
          'message-${sentAt.microsecondsSinceEpoch}-${_messageSequence++}',
      conversationId: conversationId,
      senderId: currentUserId,
      type: type,
      text: text,
      imagePath: imagePath,
      sentAt: sentAt,
    );

    _messages[conversationId]!.add(message);
    _conversations[conversationId] = conversation.copyWith(
      lastMessagePreview: type == ChatMessageType.image ? 'Photo' : text,
      lastMessageAt: sentAt,
      unreadCount: 0,
    );
    notifyListeners();
    return message;
  }
}
