// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/views/components/input_toast.dart';
import 'package:flutter/material.dart';

class MessageOptionsMenu extends StatelessWidget {
  final Function(MessageData msg) deleteMessage;
  final Function(MessageData msg) editMsg;
  final Function(MessageData repliedToMsg) replyToMsg;
  final Function(InputToast toast) onShowToast;
  final Function() onCloseToast;
  final Function(MessageData message) onShowReactions;

  final Function(MessageData message) onShowEmojiPicker;
  final TextEditingController textController;
  final MessageData message;
  final String username;

  const MessageOptionsMenu({
    super.key,
    required this.username,
    required this.onShowToast,
    required this.onCloseToast,
    required this.textController,
    required this.deleteMessage,
    required this.message,
    required this.editMsg,
    required this.replyToMsg,
    required this.onShowEmojiPicker,
    required this.onShowReactions,
  });

  bool isOwnMessage(MessageData msg) => msg.username == username;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return SizedBox(
      height: isOwnMessage(message) ? 250 : 150,
      child: Center(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close options menu first
                      onShowEmojiPicker(message); // Call parent callback
                    },
                    child: Text(t.reactToMessage),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close options menu first
                      onShowReactions(message); // Call parent callback
                    },
                    child: Text(t.showReactions),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                onShowToast(
                  ReplyToast(
                    closeCallback: onCloseToast,
                    messageRepliedTo: message,
                    sendReply: () => replyToMsg(message),
                    replyToText: t.replyTo(message.username),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(t.replyToMessage),
            ),
            isOwnMessage(message)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          onShowToast(
                            EditToast(
                              closeCallback: onCloseToast,
                              sendEdit: () => editMsg(message),
                              editingText: t.editingMessage,
                            ),
                          );
                          textController.text = message.content ?? '';
                          Navigator.pop(context);
                        },
                        child: Text(t.editMessage),
                      ),
                      ElevatedButton(
                        onPressed: () => deleteMessage(message),
                        child: Text(t.deleteMessage, style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
