// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/chat/providers/chat_room_notifier.dart';
import 'package:chat_app/features/chat/widgets/message_tile.dart';
import 'package:chat_app/features/chat/widgets/chat_screen_input.dart';
import 'package:chat_app/features/chat/widgets/members_drawer.dart';
import 'package:chat_app/features/chat/widgets/message_options_menu.dart';
import 'package:chat_app/features/chat/widgets/message_tile_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void setupAutoScroll(ChatRoomNotifierProvider chatroomProvider) {
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
  }

  void showOptionsMenu(MessageData message, ChatRoomNotifierProvider chatroomProvider) {
    if (mounted && message.senderId != "Server") {
      showModalBottomSheet(
        context: context,
        builder: (modalContext) {
          return MessageOptionsMenu(
            chatroomProvider: chatroomProvider,
            textController: textController,
            message: message,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final chatroomProvider = chatRoomProvider(roomCode: widget.roomCode);
    final messages = ref.watch(chatroomProvider);
    // Set up callback for the notifier to trigger scrolling
    setupAutoScroll(chatroomProvider);

    return Scaffold(
      endDrawer: MembersDrawer(roomCode: widget.roomCode),
      appBar: AppBar(title: Text(t.chatRoomTitle(widget.roomCode))),
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
                    padding: EdgeInsets.zero,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final message = value[index];
                      // Create or get existing key for this message
                      _messageKeys.putIfAbsent(message.id, () => GlobalKey());
                      return MessageTileFactory(
                        currentUsername: widget.username,
                        roomCode: widget.roomCode,
                        key: _messageKeys[message.id],
                        jumpToMessage: (String messageId) => jumpToMessageById(messageId),
                        message: message,
                        index: index,
                        onLongPress: () => showOptionsMenu(message, chatroomProvider),
                      );
                    },
                  ),
                ),
                AsyncValue(error: != null) => Text(t.errorMessage(messages.error.toString())),
                AsyncValue() => Center(
                  child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
                ),
              },
            ),
          ),
          ChatScreenInput(
            chatRoomProvider: chatroomProvider,
            textController: textController,
            roomCode: widget.roomCode,
          ),
        ],
      ),
    );
  }
}
