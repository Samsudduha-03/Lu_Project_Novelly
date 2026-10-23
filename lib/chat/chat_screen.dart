import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_model.dart';
import 'chat_service.dart';

const _ink = Color(0xFF173B43);
const _gold = Color(0xFFC89543);
const _paper = Color(0xFFF4F0E7);
const _line = Color(0xFFDDD5C7);

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.conversation,
    required this.service,
    super.key,
  });

  final ChatConversation conversation;
  final ChatService service;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.service.markAsRead(widget.conversation.conversationId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    widget.service.sendTextMessage(
      conversationId: widget.conversation.conversationId,
      text: text,
    );
    _messageController.clear();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      widget.service.sendImageMessage(
        conversationId: widget.conversation.conversationId,
        imagePath: image.path,
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not select image: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _paper,
    body: SafeArea(
      child: Column(
        children: [
          _ChatHeader(
            conversation: widget.conversation,
            onBack: () => Navigator.of(context).maybePop(),
            onCall: () => _showMessage('Coming soon'),
            onVideoCall: () => _showMessage('Coming soon'),
          ),
          const Divider(height: 1, color: _line),
          Expanded(
            child: AnimatedBuilder(
              animation: widget.service,
              builder: (context, _) {
                final messages = widget.service.messagesFor(
                  widget.conversation.conversationId,
                );
                if (messages.isEmpty) {
                  return _EmptyConversation(
                    userName: widget.conversation.userName,
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _MessageBubble(
                    message: messages[messages.length - index - 1],
                    outgoing:
                        messages[messages.length - index - 1].senderId ==
                        widget.service.currentUserId,
                  ),
                );
              },
            ),
          ),
          _MessageComposer(
            controller: _messageController,
            onAttach: _pickImage,
            onSend: _sendText,
          ),
        ],
      ),
    ),
  );
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.conversation,
    required this.onBack,
    required this.onCall,
    required this.onVideoCall,
  });

  final ChatConversation conversation;
  final VoidCallback onBack;
  final VoidCallback onCall;
  final VoidCallback onVideoCall;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(5, 5, 9, 10),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        _ProfileAvatar(
          imagePath: conversation.avatarPath,
          online: conversation.isOnline,
          radius: 23,
        ),
        const SizedBox(width: 10),
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
                  fontFamily: 'Georgia',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: conversation.isOnline
                          ? const Color(0xFF3D936A)
                          : const Color(0xFF9A9A94),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    conversation.isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(
                      color: Color(0xFF5E866E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Voice call',
          onPressed: onCall,
          color: _ink,
          icon: const Icon(Icons.call_outlined),
        ),
        IconButton(
          tooltip: 'Video call',
          onPressed: onVideoCall,
          color: _ink,
          icon: const Icon(Icons.videocam_outlined),
        ),
      ],
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.outgoing});

  final ChatMessage message;
  final bool outgoing;

  @override
  Widget build(BuildContext context) {
    final alignment = outgoing ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = outgoing ? _ink : const Color(0xFFEDE7DC);
    final foregroundColor = outgoing ? Colors.white : const Color(0xFF202B2D);

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * .76,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(outgoing ? 18 : 5),
                bottomRight: Radius.circular(outgoing ? 5 : 18),
              ),
              border: outgoing ? null : Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.type == ChatMessageType.image)
                  _SharedImage(path: message.imagePath!)
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.text!,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMessageTime(message.sentAt),
                      style: TextStyle(
                        color: outgoing
                            ? Colors.white.withValues(alpha: .72)
                            : const Color(0xFF777873),
                        fontSize: 10,
                      ),
                    ),
                    if (outgoing) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, size: 14, color: _gold),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharedImage extends StatelessWidget {
  const _SharedImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.file(
      File(path),
      width: 220,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox(
        width: 220,
        height: 120,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: _gold, size: 36),
        ),
      ),
    ),
  );
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onAttach,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFCF7),
      border: Border(top: BorderSide(color: _line.withValues(alpha: .8))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Attach image',
          onPressed: onAttach,
          color: _gold,
          icon: const Icon(Icons.image_outlined),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Write a message...',
              filled: true,
              fillColor: _paper,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: _gold, width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 43,
          height: 43,
          child: FilledButton(
            onPressed: onSend,
            style: FilledButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: _gold,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            child: const Icon(Icons.send_rounded, size: 19),
          ),
        ),
      ],
    ),
  );
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_outlined, color: _gold, size: 42),
          const SizedBox(height: 12),
          const Text(
            'Start the conversation',
            style: TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Send a message to $userName to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _ink.withValues(alpha: .7)),
          ),
        ],
      ),
    ),
  );
}

String _formatMessageTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  return '$hour:${time.minute.toString().padLeft(2, '0')} '
      '${time.hour < 12 ? 'AM' : 'PM'}';
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
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.person, color: _gold, size: radius * 1.15),
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
