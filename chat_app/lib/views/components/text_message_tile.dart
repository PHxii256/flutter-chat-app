import 'package:chat_app/views/components/base_message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextMessageTile extends BaseMessageTile {
  const TextMessageTile({
    super.key,
    required super.roomCode,
    required super.currentUsername,
    required super.message,
    required super.index,
    required super.onLongPress,
    required super.onTap,
    super.onReactionRemove,
  });

  @override
  ConsumerState<TextMessageTile> createState() => _TextMessageTileState();
}

class _TextMessageTileState extends BaseMessageTileState<TextMessageTile> {
  String? _getMessage() {
    if (widget.message.senderId == 'Server') {
      return widget.message.content;
    } else {
      return "${widget.message.username}: ${widget.message.content}";
    }
  }

  @override
  Widget buildMessageContent() {
    return Text(_getMessage() ?? 'anon', style: Theme.of(context).textTheme.bodyLarge);
  }
}
