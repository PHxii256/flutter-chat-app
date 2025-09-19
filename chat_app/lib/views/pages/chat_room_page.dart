// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/repositories/messages_repo.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/views/components/chat_screen_input.dart';
import 'package:chat_app/views/components/input_toast_component.dart';
import 'package:chat_app/views/components/message_options_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, this.username = "default user", this.roomCode = "general"});

  final String username;
  final String roomCode;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
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
        if (decodedMsg is Map<String, dynamic> && decodedMsg["serverMsg"] == null) {
          messages.add(MessageData.fromJson(decodedMsg, widget.roomCode));
        } else if (decodedMsg is Map<String, dynamic> && decodedMsg["serverMsg"] != null) {
          messages.add(
            MessageData(
              roomCode: widget.roomCode,
              id: decodedMsg["_id"],
              userId: 'Server',
              content: decodedMsg["serverMsg"].toString(),
              createdAt: DateTime.now(),
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
          messages.removeAt(idx);
          messages.insert(idx, msgData);
        });
      }
    } catch (e) {
      print("oopsie couldnt update message, $e");
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

  String getSender(int index) {
    final lastMessage = messages[index];

    if (lastMessage.userId == 'Server') {
      return lastMessage.content;
    } else {
      return "${lastMessage.username}: ${lastMessage.content}";
    }
  }

  String getMessageTime(int index) {
    return DateFormat(
      'h:mm a',
    ).format(messages[index].createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));
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
                      return ListTile(
                        leading: Text(getMessageTime(index)),
                        title: Text(getSender(index)),
                        onLongPress: () {
                          if (mounted && messages[index].userId != "Server") {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return MessageOptionsMenu(
                                  editMsg: (msg) {
                                    socketService.updateMessage(
                                      messageId: msg.id!,
                                      newContent: textController.text,
                                      roomCode: widget.roomCode,
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
