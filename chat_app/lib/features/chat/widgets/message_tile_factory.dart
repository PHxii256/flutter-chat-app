// ignore_for_file: avoid_print
import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/chat/widgets/message_tile.dart';
import 'package:chat_app/features/chat/widgets/text_message_tile.dart';
import 'package:chat_app/features/chat/widgets/image_message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageTileFactory extends ConsumerWidget {
  final String roomCode;
  final String currentUsername;
  final MessageData message;
  final int index;
  final VoidCallback onLongPress;
  final Function(String messageId) jumpToMessage;

  const MessageTileFactory({
    super.key,
    required this.roomCode,
    required this.currentUsername,
    required this.message,
    required this.index,
    required this.onLongPress,
    required this.jumpToMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Factory pattern with composition - determine content widget based on message type
    Widget content;
    if (message.type == 'image' && message is ImageMessageData) {
      content = ImageMessageContent(message: message as ImageMessageData);
    } else {
      content = TextMessageContent(message: message);
    }

    // Return MessageTile with composed content
    return MessageTile(
      roomCode: roomCode,
      currentUsername: currentUsername,
      message: message,
      index: index,
      onLongPress: onLongPress,
      jumpToMessage: jumpToMessage,
      content: content,
    );
  }
}
