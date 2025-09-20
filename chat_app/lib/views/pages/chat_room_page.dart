// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/repositories/messages_repo.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/views/components/chat_screen_input.dart';
import 'package:chat_app/views/components/input_toast.dart';
import 'package:chat_app/views/components/message_options_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, this.username = "default user", this.roomCode = "general"});

  final String username;
  final String roomCode;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final Map<String, GlobalKey> _messageKeys = {};
  final ScrollController scrollController = ScrollController();
  final SocketService socketService = SocketService();
  final TextEditingController textController = TextEditingController();
  final List<MessageData> messages = [];
  InputToast? currentToast;

  @override
  void initState() {
    super.initState();
    loadChatHistory();
    socketService.connectAndListen(roomCode: widget.roomCode, username: widget.username);
    socketService.onMessageReceived = addMessage;
    socketService.onMessageUpdated = updateMessage;
  }

  @override
  void dispose() {
    scrollController.dispose();
    socketService.onMessageReceived = null;
    socketService.dispose();
    super.dispose();
  }

  void loadChatHistory() async {
    try {
      List<MessageData> history = await fetchChatHistory(widget.roomCode);
      setState(() {
        //ASSUMPTION !!!!: SYSTEM MESSAGES COME FIRST
        final welcomeMsg = messages.lastOrNull;
        messages.clear();
        messages.addAll(history);
        if (welcomeMsg != null) messages.insert(history.length, welcomeMsg);
      });
      jumpToLastMessage(animated: false);
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void addMessage(dynamic msg) {
    if (!mounted) return;
    setState(() {
      try {
        dynamic decodedMsg = jsonDecode(msg);
        if (decodedMsg["serverMsg"] == null) {
          messages.add(MessageData.fromJson(decodedMsg, widget.roomCode));
        } else if (decodedMsg["serverMsg"] != null) {
          messages.add(
            MessageData(
              roomCode: widget.roomCode,
              id: "${DateTime.now().toIso8601String()}: ${decodedMsg["serverMsg"].toString()}",
              senderId: 'Server',
              content: decodedMsg["serverMsg"].toString(),
              createdAt: DateTime.now(),
              username: 'Server',
            ),
          );
        }
      } catch (e) {
        print('Error decoding message: $e');
      }
    });
    jumpToLastMessage();
  }

  void updateMessage(dynamic updatedMsg) {
    if (!mounted) return;
    try {
      dynamic decodedMsg = jsonDecode(updatedMsg);
      final msgToBeUpdated = messages.firstWhereOrNull((msg) => msg.id == decodedMsg["messageId"]);

      if (msgToBeUpdated != null) {
        final MessageData msgData = msgToBeUpdated.copyWith(
          content: decodedMsg["newContent"],
          updatedAt: DateTime.now(),
        );

        setState(() {
          final idx = messages.indexOf(msgToBeUpdated);
          messages[idx] = msgData;
        });
      }
    } catch (e) {
      print("oopsie couldnt update message, $e");
    }
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Chat Room #${widget.roomCode}')),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: Scrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      // Create or get existing key for this message
                      _messageKeys.putIfAbsent(message.id, () => GlobalKey());

                      return MessageTile(
                        key: _messageKeys[message.id],
                        message: message,
                        index: index,
                        onTap: () {
                          if (messages[index].replyTo == null) return;
                          final id = messages[index].replyTo!.messageId;
                          jumpToMessageById(id);
                        },
                        onLongPress: () {
                          if (mounted && messages[index].senderId != "Server") {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return MessageOptionsMenu(
                                  editMsg: (msg) {
                                    socketService.updateMessage(
                                      messageId: msg.id,
                                      newContent: textController.text,
                                      roomCode: widget.roomCode,
                                    );
                                  },
                                  replyToMsg: (repliedToMsg) {
                                    socketService.sendMessage(
                                      username: widget.username,
                                      roomCode: widget.roomCode,
                                      content: textController.text,
                                      replyTo: ReplyTo(
                                        content: repliedToMsg.content,
                                        messageId: repliedToMsg.id,
                                      ),
                                    );
                                  },
                                  deleteMessage: (msg) {
                                    setState(() => messages.remove(msg));
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
                                  message: messages[index],
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            ChatScreenInput(
              textController: textController,
              socketService: socketService,
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
