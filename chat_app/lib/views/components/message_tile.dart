// ignore_for_file: avoid_print

import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/views/components/base_message_tile.dart';
import 'package:chat_app/views/components/text_message_tile.dart';
import 'package:chat_app/views/components/image_message_tile.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String roomCode;
  final String currentUsername;
  final MessageData message;
  final int index;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Function(MessageData message, String emoji)? onReactionRemove;

  const MessageTile({
    super.key,
    required this.roomCode,
    required this.currentUsername,
    required this.message,
    required this.index,
    required this.onLongPress,
    required this.onTap,
    this.onReactionRemove,
  });

  /// Static method to trigger highlight on a MessageTile via GlobalKey
  static void highlightByKey(GlobalKey key) {
    BaseMessageTile.highlightByKey(key);
  }

  @override
  Widget build(BuildContext context) {
    // Factory pattern - return appropriate tile type based on message type
    if (message.type == 'image' && message is ImageMessageData) {
      return ImageMessageTile(
        roomCode: roomCode,
        currentUsername: currentUsername,
        message: message,
        index: index,
        onLongPress: onLongPress,
        onTap: onTap,
        onReactionRemove: onReactionRemove,
      );
    } else {
      return TextMessageTile(
        roomCode: roomCode,
        currentUsername: currentUsername,
        message: message,
        index: index,
        onLongPress: onLongPress,
        onTap: onTap,
        onReactionRemove: onReactionRemove,
      );
    }
  }
}
