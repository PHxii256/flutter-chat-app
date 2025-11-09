import 'package:chat_app/features/chat/data/models/message_data.dart';
import 'package:flutter/material.dart';

/// Simple content widget for text messages - used with composition in MessageTile
class TextMessageContent extends StatelessWidget {
  final MessageData message;

  const TextMessageContent({super.key, required this.message});

  String _getMessage() {
    print("c: ${message.createdAt}, u: ${message.updatedAt}, e?: ${message.isEdited()}");
    if (message.senderId == 'Server') {
      return message.content ?? '';
    } else {
      return "${message.username}: ${message.content ?? ''}";
    }
  }

  Widget _getEditedText() {
    return message.isEdited()
        ? Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              "(edited)",
              style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(_getMessage(), style: Theme.of(context).textTheme.bodyLarge),
        _getEditedText(),
      ],
    );
  }
}
