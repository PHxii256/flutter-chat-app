// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/chat/data/models/message_data.dart';
import 'package:chat_app/features/chat/bloc/chat_room_cubit.dart';
import 'package:chat_app/features/chat/bloc/toast_cubit.dart';
import 'package:chat_app/features/auth/bloc/auth_cubit.dart';
import 'package:chat_app/features/chat/presentation/widgets/input_toast.dart';
import 'package:chat_app/features/chat/presentation/widgets/reactions_viewer.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageOptionsMenu extends StatefulWidget {
  final TextEditingController textController;
  final MessageData message;
  const MessageOptionsMenu({super.key, required this.textController, required this.message});

  @override
  State<MessageOptionsMenu> createState() => _MessageOptionsMenuState();
}

class _MessageOptionsMenuState extends State<MessageOptionsMenu> {
  void addReact(MessageData msg, String emoji) {
    context.read<ChatRoomCubit>().reactToMessage(message: msg, emoji: emoji);
  }

  void reply(MessageData repliedToMsg, ChatRoomCubit chatRoomCubit) {
    chatRoomCubit.sendMessage(
      content: widget.textController.text,
      replyTo: ReplyTo(
        content: repliedToMsg.content ?? repliedToMsg.type,
        messageId: repliedToMsg.id,
      ),
    );
  }

  void edit(MessageData messageToBeEdited, ChatRoomCubit chatRoomCubit) {
    chatRoomCubit.updateMessage(
      messageId: messageToBeEdited.id,
      newContent: widget.textController.text,
    );
  }

  void delete(msg, ChatRoomCubit chatRoomCubit) {
    chatRoomCubit.deleteMessage(msgId: msg.id);
    if (mounted && context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomCubit = context.read<ChatRoomCubit>();
    final toastCubit = context.read<ToastCubit>();
    final authCubit = context.read<AuthCubit>();

    bool isOwnMessage(MessageData msg) {
      return msg.username == authCubit.getCurrentUser()?.username;
    }

    final t = S.of(context);

    void showEmojiPicker(MessageData message) {
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
                chatRoomCubit.reactToMessage(message: message, emoji: emoji.emoji);
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
                toastCubit.setToast(
                  ReplyToast(
                    messageRepliedTo: widget.message,
                    sendReply: () => reply(widget.message, chatRoomCubit),
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
                          toastCubit.setToast(
                            EditToast(
                              sendEdit: () => edit(widget.message, chatRoomCubit),
                              editingText: t.editingMessage,
                            ),
                          );

                          widget.textController.text = widget.message.content ?? '';
                          Navigator.pop(context);
                        },
                        child: Text(t.editMessage),
                      ),
                      ElevatedButton(
                        onPressed: () => delete(widget.message, chatRoomCubit),
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
