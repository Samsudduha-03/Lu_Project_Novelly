import 'dart:io';

import 'package:flutter/material.dart';

import 'chat_model.dart';
import 'chat_screen.dart';
import 'chat_service.dart';

const _ink = Color(0xFF173B43);
const _gold = Color(0xFFC89543);
const _paper = Color(0xFFF4F0E7);
const _line = Color(0xFFDDD5C7);
const _muted = Color(0xFF777873);

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({this.service, super.key});

  final ChatService? service;

  @override
  Widget build(BuildContext context) {
    final chatService = service ?? ChatService.shared;
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        color: _ink,
                        fontFamily: 'Georgia',
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _line),
            Expanded(
              child: AnimatedBuilder(
                animation: chatService,
                builder: (context, _) {
                  final conversations = chatService.conversations;
                  if (conversations.isEmpty) {
                    return const _EmptyConversations();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: _line, indent: 72),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return _ConversationTile(
                        conversation: conversation,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChatScreen(
                              conversation: conversation,
                              service: chatService,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          _ProfileAvatar(
            imagePath: conversation.avatarPath,
            online: conversation.isOnline,
            radius: 27,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  conversation.lastMessagePreview ?? 'Start a conversation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatConversationTime(conversation.lastMessageAt),
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
              const SizedBox(height: 7),
              if (conversation.unreadCount > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 21),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: const BoxDecoration(
                    color: _ink,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    conversation.unreadCount > 99
                        ? '99+'
                        : '${conversation.unreadCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imagePath,
    required this.online,
    required this.radius,
  });

  final String? imagePath;
  final bool online;
  final double radius;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      CircleAvatar(
        radius: radius,
        backgroundColor: _ink,
        child: imagePath == null
            ? Icon(Icons.person, color: _gold, size: radius * 1.15)
            : ClipOval(
                child: Image.file(
                  File(imagePath!),
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.person,
                    color: _gold,
                    size: radius * 1.15,
                  ),
                ),
              ),
      ),
      if (online)
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: const Color(0xFF3D936A),
              shape: BoxShape.circle,
              border: Border.all(color: _paper, width: 2),
            ),
          ),
        ),
    ],
  );
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline, color: _gold, size: 48),
          const SizedBox(height: 14),
          const Text(
            'No conversations yet',
            style: TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Your messages with other readers and writers will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _ink.withValues(alpha: .7), height: 1.5),
          ),
        ],
      ),
    ),
  );
}

String _formatConversationTime(DateTime? time) {
  if (time == null) return '';
  final now = DateTime.now();
  if (time.year == now.year && time.month == now.month && time.day == now.day) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$hour:${time.minute.toString().padLeft(2, '0')} '
        '${time.hour < 12 ? 'AM' : 'PM'}';
  }
  if (now.difference(time).inDays < 2) return 'Yesterday';
  return '${time.day}/${time.month}/${time.year}';
}
