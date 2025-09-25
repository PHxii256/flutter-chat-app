// ignore_for_file: avoid_print
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/view_models/chat_room_notifier.dart';
import 'package:chat_app/views/components/chat_screen_input.dart';
import 'package:chat_app/views/components/input_toast.dart';
import 'package:chat_app/views/components/message_options_menu.dart';
import 'package:chat_app/views/components/message_tile.dart';
import 'package:chat_app/views/components/reactions_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
  void initState() {
    super.initState();
    // Refresh data when switching to this user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCurrentUserData();
    });
  }

  @override
  void didUpdateWidget(ChatRoom oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If username or roomCode changed, refresh the data
    if (oldWidget.username != widget.username || oldWidget.roomCode != widget.roomCode) {
      _refreshCurrentUserData();
    }
  }

  void _refreshCurrentUserData() {
    final chatroomProvider = chatRoomProvider(roomCode: widget.roomCode, username: widget.username);
    // Invalidate the provider to force rebuild and get fresh data
    ref.invalidate(chatroomProvider);

    // Also try to refresh from server if the provider is already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          ref.read(chatroomProvider.notifier).refreshFromServer();
        } catch (e) {
          print('Error refreshing from server: $e');
        }
      }
    });
  }

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

      MessageTile.highlightByKey(key);
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

    void addReact(MessageData msg, String emoji) {
      ref
          .read(chatroomProvider.notifier)
          .reactToMessage(message: msg, senderUsername: widget.username, emoji: emoji);
    }

    void removeReact(MessageData msg, String emoji) {
      ref
          .read(chatroomProvider.notifier)
          .reactToMessage(message: msg, senderUsername: widget.username, emoji: emoji);
    }

    void reply(MessageData repliedToMsg) {
      ref
          .read(chatroomProvider.notifier)
          .sendMessage(
            username: widget.username,
            content: textController.text,
            replyTo: ReplyTo(content: repliedToMsg.content, messageId: repliedToMsg.id),
          );
    }

    void edit(MessageData repliedToMsg) {
      ref
          .read(chatroomProvider.notifier)
          .sendMessage(
            username: widget.username,
            content: textController.text,
            replyTo: ReplyTo(content: repliedToMsg.content, messageId: repliedToMsg.id),
          );
    }

    void delete(msg) {
      ref.read(chatroomProvider.notifier).deleteMessage(msgId: msg.id, roomCode: widget.roomCode);
      Navigator.pop(context);
    }

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
                addReact(message, emoji.emoji);
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
                  noRecents: const Text(
                    'No Recents',
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

    return MaterialApp(
      home: Scaffold(
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
                          currentUsername: widget.username,
                          roomCode: widget.roomCode,
                          key: _messageKeys[message.id],
                          message: message,
                          index: index,
                          onReactionRemove: removeReact,
                          onTap: () {
                            if (value[index].replyTo == null) return;
                            final id = value[index].replyTo!.messageId;
                            jumpToMessageById(id);
                          },
                          onLongPress: () {
                            if (mounted && value[index].senderId != "Server") {
                              showModalBottomSheet(
                                context: context,
                                builder: (modalContext) {
                                  return MessageOptionsMenu(
                                    editMsg: edit,
                                    replyToMsg: reply,
                                    deleteMessage: delete,
                                    username: widget.username,
                                    onShowToast: (InputToast toast) {
                                      setState(() => currentToast = toast);
                                    },
                                    onCloseToast: () {
                                      setState(() => currentToast = null);
                                    },
                                    textController: textController,
                                    message: value[index],
                                    onShowEmojiPicker: showEmojiPicker,
                                    onShowReactions: showReactions,
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
