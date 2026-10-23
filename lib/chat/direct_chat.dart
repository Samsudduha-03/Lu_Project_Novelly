import 'package:flutter/material.dart';

import '../main_page/writer_profile.dart';
import 'chat_screen.dart';
import 'chat_service.dart';

void openDirectChat(
  BuildContext context, {
  required String userId,
  required String userName,
  String? avatarPath,
  ChatService? service,
}) {
  final currentUser = WriterProfileScreen.currentUser;
  final chatService = service ?? ChatService.shared;
  final conversation = chatService.getOrCreateConversation(
    currentUserId: _chatIdentity(
      accountId: currentUser.accountId,
      displayName: currentUser.name,
    ),
    userId: _chatIdentity(accountId: userId, displayName: userName),
    userName: userName,
    avatarPath: avatarPath,
  );

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          ChatScreen(conversation: conversation, service: chatService),
    ),
  );
}

String _chatIdentity({required String accountId, required String displayName}) {
  final stableId = accountId.trim();
  if (stableId.isNotEmpty) return stableId;
  return 'local:${displayName.trim().toLowerCase()}';
}
