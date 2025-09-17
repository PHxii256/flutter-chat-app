// ignore_for_file: avoid_print

import 'package:chat_app/views/pages/info_page.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/views/components/input_toast_component.dart';
import 'package:flutter/material.dart';

class ChatScreenInput extends StatefulWidget {
  final TextEditingController textController;
  final SocketService socketService;
  final String username;
  final String roomCode;
  final InputToast? Function() getToast;
  final Function() closeToast;
  const ChatScreenInput({
    super.key,
    required this.textController,
    required this.socketService,
    required this.username,
    required this.roomCode,
    required this.getToast,
    required this.closeToast,
  });

  @override
  State<ChatScreenInput> createState() => _ChatScreenInputState();
}

class _ChatScreenInputState extends State<ChatScreenInput> {
  void sendMessage() {
    if (widget.textController.text.isNotEmpty && widget.socketService.socket != null) {
      final InputToast? toast = widget.getToast();

      if (toast != null) {
        toast.performAction();
        widget.closeToast();
      } else {
        widget.socketService.sendMessage(
          username: widget.username,
          roomCode: widget.roomCode,
          content: widget.textController.text,
        );
      }

      widget.textController.clear();
    }
  }

  void exitRoom() {
    if (!mounted) return;
    widget.socketService.dispose();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserInfoPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        alignment: AlignmentGeometry.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              width: 2.0,
              color: widget.getToast() != null ? Colors.black12 : Colors.transparent,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 8,
              children: [
                widget.getToast() ?? Container(),
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
                        controller: widget.textController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send_rounded),
                            onPressed: sendMessage,
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
                        onSubmitted: (_) => sendMessage(),
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
    );
  }
}
