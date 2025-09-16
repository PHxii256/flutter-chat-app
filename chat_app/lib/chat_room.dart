// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, this.username = "default user", this.roomCode = "general"});

  final String username;
  final String roomCode;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final ScrollController _scrollController = ScrollController();
  final SocketService socketService = SocketService();
  final TextEditingController _controller = TextEditingController();

  final List<MessageData> _messages = [];

  // State variable to track reply toast
  MessageData? _replyingTo;

  @override
  void initState() {
    super.initState();
    loadChatHistory();
    socketService.connectAndListen(roomCode: widget.roomCode, username: widget.username);
    socketService.onMessage = _updateMessages;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    socketService.onMessage = null;
    socketService.dispose();
    super.dispose();
  }

  void loadChatHistory() async {
    try {
      List<MessageData> history = await fetchChatHistory(widget.roomCode);
      setState(() {
        //ASSUMPTION !!!!: SYSTEM MESSAGES COME FIRST
        print("deleting old messages (${_messages.length}): $_messages");
        final welcomeMsg = _messages.lastOrNull;
        _messages.clear();
        _messages.addAll(history);
        if (welcomeMsg != null) _messages.insert(history.length, welcomeMsg);
      });
      jumpToLastMessage(animated: false); // Use jumpTo for initial load
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<List<MessageData>> fetchChatHistory(String roomCode) async {
    try {
      final res = await http.get(Uri.parse("${getSocketUrl()}room/chat-history/$roomCode"));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as List<dynamic>;
        List<MessageData> messages = [];
        for (var msg in json) {
          messages.add(MessageData.fromJson(msg, roomCode));
        }
        return messages;
      } else {
        print('${res.body}: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }

  void _updateMessages(dynamic msg) {
    if (!mounted) return;
    setState(() {
      try {
        dynamic decodedMsg = jsonDecode(msg);
        if (decodedMsg is Map<String, dynamic> && decodedMsg["serverMsg"] == null) {
          _messages.add(MessageData.fromJson(decodedMsg, widget.roomCode));
        } else if (decodedMsg is Map<String, dynamic> && decodedMsg["serverMsg"] != null) {
          _messages.add(
            MessageData(
              roomCode: widget.roomCode,
              id: decodedMsg["_id"],
              userId: 'Server',
              content: decodedMsg["serverMsg"].toString(),
              createdAt: DateTime.now(),
            ),
          );
        } else {
          print('Received message of unexpected type: \\${msg.runtimeType}');
        }
      } catch (e) {
        print('Error decoding message: $e');
      }
    });
    jumpToLastMessage();
  }

  void jumpToLastMessage({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        // Only animate if not already at the bottom
        if ((maxScroll - current).abs() > 10) {
          if (animated) {
            _scrollController.animateTo(
              maxScroll,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          } else {
            _scrollController.jumpTo(maxScroll);
          }
        }
      }
    });
  }

  void exitRoom() {
    if (!mounted) return;
    socketService.dispose();
    Navigator.of(context).pop();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && socketService.socket != null) {
      setState(() {
        _replyingTo = null;
      });

      socketService.sendMessage(
        username: widget.username,
        roomCode: widget.roomCode,
        content: _controller.text,
      );
      _controller.clear();
    }
  }

  String getSender(int index) {
    final lastMessage = _messages[index];

    if (lastMessage.userId == 'Server') {
      return lastMessage.content;
    } else {
      return "${lastMessage.username}: ${lastMessage.content}";
    }
  }

  @override
  Widget build(BuildContext context) {
    void showReplyToast(MessageData message) {
      setState(() {
        _replyingTo = message;
      });
    }

    final DateTime defaultTime = DateTime.fromMillisecondsSinceEpoch(6767676767);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Chat Room #${widget.roomCode}')),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onLongPress: () {
                          if (mounted && _messages[index].username == widget.username) {
                            print("long press detected on message: \\${_messages[index]}");
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: ListView(
                                      padding: EdgeInsets.all(16),
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            showReplyToast(_messages[index]);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Reply To Message'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _messages.removeAt(index);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Delete Message',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        leading: Text(
                          DateFormat('h:mm a').format(_messages[index].createdAt ?? defaultTime),
                        ),
                        title: Text(getSender(index)),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                alignment: AlignmentGeometry.bottomCenter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                      width: 2.0,
                      color: _replyingTo != null ? Colors.black12 : Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8,
                      children: [
                        if (_replyingTo != null)
                          ReplyToast(
                            closeCallback: () {
                              setState(() {
                                _replyingTo = null;
                              });
                            },
                          ),
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: exitRoom,
                              style: ButtonStyle(
                                side: WidgetStateProperty.all(
                                  BorderSide(color: Colors.black12, width: 2.0),
                                ),
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                                visualDensity: VisualDensity.compact,
                                minimumSize: WidgetStateProperty.all(Size(58, 58)),
                              ),
                              icon: Icon(Icons.account_circle_outlined, size: 30),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.send_rounded),
                                    onPressed: _sendMessage,
                                  ),
                                  hintText: "Enter message",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.black12, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.black12, width: 2.0),
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                                textInputAction: TextInputAction.send,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReplyToast extends StatelessWidget implements MessageInputToast {
  final VoidCallback closeCallback;
  const ReplyToast({super.key, required this.closeCallback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        spacing: 4,
        children: [
          Icon(Symbols.reply, size: 20, fontWeight: FontWeight.bold, opticalSize: 1),
          Text("Reply to phxii", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Spacer(),
          GestureDetector(
            onTap: closeCallback,
            child: Icon(Symbols.close, size: 20, fontWeight: FontWeight.bold, opticalSize: 1),
          ),
        ],
      ),
    );
  }
}

abstract class MessageInputToast {}
