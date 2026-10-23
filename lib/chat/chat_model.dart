import 'package:flutter/foundation.dart';

@immutable
class ChatConversation {
  const ChatConversation({
    required this.conversationId,
    required this.userId,
    required this.userName,
    this.avatarPath,
    this.isOnline = false,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String conversationId;
  final String userId;
  final String userName;
  final String? avatarPath;
  final bool isOnline;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatConversation copyWith({
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) => ChatConversation(
    conversationId: conversationId,
    userId: userId,
    userName: userName,
    avatarPath: avatarPath,
    isOnline: isOnline,
    lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
  );
}

enum ChatMessageType { text, image }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.sentAt,
    this.text,
    this.imagePath,
  }) : assert(
         type == ChatMessageType.text ? text != null : imagePath != null,
       );

  final String messageId;
  final String conversationId;
  final String senderId;
  final ChatMessageType type;
  final String? text;
  final String? imagePath;
  final DateTime sentAt;
}
