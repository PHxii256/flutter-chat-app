// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/auth/providers/auth_view_model.dart';
import 'package:chat_app/features/chat/providers/chat_room_notifier.dart';
import 'package:chat_app/features/chat/providers/toast_provider.dart';
import 'package:chat_app/features/chat/widgets/input_toast.dart';
import 'package:chat_app/features/chat/widgets/reactions_viewer.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageOptionsMenu extends ConsumerStatefulWidget {
  final TextEditingController textController;
  final MessageData message;
  final ChatRoomNotifierProvider chatroomProvider;
  const MessageOptionsMenu({
    super.key,
    required this.chatroomProvider,
    required this.textController,
    required this.message,
  });

  @override
  ConsumerState<MessageOptionsMenu> createState() => _MessageOptionsMenuState();
}

class _MessageOptionsMenuState extends ConsumerState<MessageOptionsMenu> {
  void addReact(MessageData msg, String emoji) {
    ref.read(widget.chatroomProvider.notifier).reactToMessage(message: msg, emoji: emoji);
  }

  void reply(MessageData repliedToMsg) {
    if (!mounted) return;
    ref
        .read(widget.chatroomProvider.notifier)
        .sendMessage(
          content: widget.textController.text,
          replyTo: ReplyTo(
            content: repliedToMsg.content ?? repliedToMsg.type,
            messageId: repliedToMsg.id,
          ),
        );
  }

  void edit(MessageData repliedToMsg) {
    if (!mounted) return;
    ref
        .read(widget.chatroomProvider.notifier)
        .sendMessage(
          content: widget.textController.text,
          replyTo: ReplyTo(
            content: repliedToMsg.content ?? repliedToMsg.type,
            messageId: repliedToMsg.id,
          ),
        );
  }

  void delete(msg) {
    if (!mounted) return;
    ref.read(widget.chatroomProvider.notifier).deleteMessage(msgId: msg.id);
    if (mounted && context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnMessage(MessageData msg) {
      return msg.username == ref.read(authViewModelProvider.notifier).getCurrentUser()?.username;
    }

    final t = S.of(context);

    void showEmojiPicker(MessageData message) {
      final chatRoomNotifier = ref.read(widget.chatroomProvider.notifier);

      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 300,
            child: EmojiPicker(
              onBackspacePressed: () {
                Navigator.pop(context); // Close emoji picker
              },
              onEmojiSelected: (Category? category, Emoji emoji) {
                chatRoomNotifier.reactToMessage(message: message, emoji: emoji.emoji);
                Navigator.pop(context); // Close emoji picker
              },
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 26,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  columns: 8,
                  recentsLimit: 40,
                  noRecents: Text(
                    t.noRecents,
                    style: TextStyle(fontSize: 20, color: Colors.black26),
                    textAlign: TextAlign.center,
                  ),
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: CategoryViewConfig(
                  iconColorSelected: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                bottomActionBarConfig: BottomActionBarConfig(enabled: false),
                searchViewConfig: const SearchViewConfig(),
              ),
            ),
          );
        },
      );
    }

    void showReactions(MessageData message) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return ReactionsViewer(message: message);
        },
      );
    }

    return SizedBox(
      height: isOwnMessage(widget.message) ? 250 : 150,
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
                      Navigator.pop(context);
                      showEmojiPicker(widget.message);
                    },
                    child: Text(t.reactToMessage),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showReactions(widget.message);
                    },
                    child: Text(t.showReactions),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(toastProvider.notifier)
                    .setToast(
                      ReplyToast(
                        messageRepliedTo: widget.message,
                        sendReply: () => reply(widget.message),
                        replyToText: t.replyTo(widget.message.username),
                      ),
                    );
                Navigator.pop(context);
              },
              child: Text(t.replyToMessage),
            ),
            isOwnMessage(widget.message)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(toastProvider.notifier)
                              .setToast(
                                EditToast(
                                  sendEdit: () => edit(widget.message),
                                  editingText: t.editingMessage,
                                ),
                              );

                          widget.textController.text = widget.message.content ?? '';
                          Navigator.pop(context);
                        },
                        child: Text(t.editMessage),
                      ),
                      ElevatedButton(
                        onPressed: () => delete(widget.message),
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
