import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:flutter/material.dart';

/// Simple content widget for text messages - used with composition in MessageTile
class TextMessageContent extends StatelessWidget {
  final MessageData message;

  const TextMessageContent({super.key, required this.message});

  String _getMessage() {
    if (message.senderId == 'Server') {
      return message.content ?? '';
    } else {
      return "${message.username}: ${message.content ?? ''}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_getMessage(), style: Theme.of(context).textTheme.bodyLarge);
  }
}
