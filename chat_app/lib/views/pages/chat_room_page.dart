// ignore_for_file: avoid_print
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/view_models/chat_room_notifier.dart';
import 'package:chat_app/views/components/chat_screen_input.dart';
import 'package:chat_app/views/components/input_toast.dart';
import 'package:chat_app/views/components/message_options_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatRoom extends ConsumerStatefulWidget {
  const ChatRoom({super.key, this.username = "default user", this.roomCode = "general"});

  final String username;
  final String roomCode;

  @override
  ConsumerState<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends ConsumerState<ChatRoom> {
  final Map<String, GlobalKey> _messageKeys = {};
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  InputToast? currentToast;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void jumpToMessageById(String messageId) {
    final key = _messageKeys[messageId];
    if (key?.currentContext != null) {
      // Use Scrollable.ensureVisible for precise scrolling
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Trigger highlight on the specific MessageTile
      final messageTileState = key.currentState as _MessageTileState?;
      messageTileState?.highlight();
    }
  }

  void jumpToLastMessage({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final current = scrollController.offset;
        // Only animate if not already at the bottom
        if ((maxScroll - current).abs() > 10) {
          if (animated) {
            scrollController.animateTo(
              maxScroll,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          } else {
            scrollController.jumpTo(maxScroll);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatroomProvider = chatRoomProvider(roomCode: widget.roomCode, username: widget.username);
    final messages = ref.watch(chatroomProvider);

    // Set up callback for the notifier to trigger scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(chatroomProvider.notifier);
      notifier.onMessagesChanged = () {
        jumpToLastMessage(animated: true);
      };
      notifier.onHistoryLoaded = () {
        jumpToLastMessage(animated: false);
      };
    });

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true, // This is default, but being explicit
        appBar: AppBar(title: Text('Chat Room #${widget.roomCode}')),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: switch (messages) {
                  AsyncValue(:final value?) => Scrollbar(
                    controller: scrollController,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero, // Remove default padding
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final message = value[index];
                        // Create or get existing key for this message
                        _messageKeys.putIfAbsent(message.id, () => GlobalKey());

                        return MessageTile(
                          key: _messageKeys[message.id],
                          message: message,
                          index: index,
                          onTap: () {
                            if (value[index].replyTo == null) return;
                            final id = value[index].replyTo!.messageId;
                            jumpToMessageById(id);
                          },
                          onLongPress: () {
                            if (mounted && value[index].senderId != "Server") {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return MessageOptionsMenu(
                                    editMsg: (msg) {
                                      ref
                                          .read(chatroomProvider.notifier)
                                          .updateMessage(
                                            messageId: msg.id,
                                            newContent: textController.text,
                                          );
                                    },
                                    replyToMsg: (repliedToMsg) {
                                      ref
                                          .read(chatroomProvider.notifier)
                                          .sendMessage(
                                            username: widget.username,
                                            content: textController.text,
                                            replyTo: ReplyTo(
                                              content: repliedToMsg.content,
                                              messageId: repliedToMsg.id,
                                            ),
                                          );
                                    },
                                    deleteMessage: (msg) {
                                      print("msg content to be deleted: ${msg.content}");
                                      ref
                                          .read(chatroomProvider.notifier)
                                          .deleteMessage(msgId: msg.id, roomCode: widget.roomCode);
                                      Navigator.pop(context);
                                    },
                                    username: widget.username,
                                    onShowToast: (InputToast toast) {
                                      setState(() => currentToast = toast);
                                    },
                                    onCloseToast: () {
                                      setState(() => currentToast = null);
                                    },
                                    textController: textController,
                                    message: value[index],
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  // If "error" is non-null, it means that the operation failed.
                  AsyncValue(error: != null) => Text('Error: ${messages.error}'),
                  // If we're neither in data state nor in error state, then we're in loading state.
                  AsyncValue() => Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                },
              ),
            ),
            ChatScreenInput(
              chatRoomProvider: chatroomProvider,
              textController: textController,
              username: widget.username,
              roomCode: widget.roomCode,
              getToast: () => currentToast,
              closeToast: () => currentToast = null,
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final MessageData message;
  final int index;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const MessageTile({
    super.key,
    required this.message,
    required this.index,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  int _highlightOpacity = 0;

  void highlight() {
    if (!mounted) return;
    setState(() {
      _highlightOpacity = 30;
    });

    Future.delayed(Duration(milliseconds: 750), () {
      if (mounted) {
        setState(() {
          _highlightOpacity = 0;
        });
      }
    });
  }

  String? _getSender() {
    if (widget.message.senderId == 'Server') {
      return widget.message.content;
    } else {
      return "${widget.message.username}: ${widget.message.content}";
    }
  }

  String _getMessageTime() {
    return DateFormat('h:mm a').format(widget.message.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(_highlightOpacity)),
      child: ListTile(
        leading: Text(_getMessageTime()),
        title: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.message.replyTo != null
                ? Positioned(
                    bottom: 21,
                    left: 4,
                    child: Row(
                      children: [
                        Transform.flip(
                          flipX: true,
                          child: Icon(Symbols.reply_rounded, size: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Repling to: \"${widget.message.replyTo!.content}\"",
                          style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Text(_getSender() ?? 'anon'),
          ],
        ),
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
      ),
    );
  }
}
