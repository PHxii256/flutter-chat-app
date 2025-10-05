// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/view_models/chat_room_notifier.dart';
import 'package:chat_app/view_models/locale_notifier.dart';
import 'package:chat_app/views/components/enter_room.dart';
import 'package:chat_app/views/components/input_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreenInput extends ConsumerStatefulWidget {
  final TextEditingController textController;
  final ChatRoomNotifierProvider chatRoomProvider;
  final String username;
  final String roomCode;
  final InputToast? Function() getToast;
  final Function() closeToast;
  const ChatScreenInput({
    super.key,
    required this.chatRoomProvider,
    required this.textController,
    required this.username,
    required this.roomCode,
    required this.getToast,
    required this.closeToast,
  });

  @override
  ConsumerState<ChatScreenInput> createState() => _ChatScreenInputState();
}

class _ChatScreenInputState extends ConsumerState<ChatScreenInput> {
  void sendMessage() {
    if (widget.textController.text.isNotEmpty && ref.read(widget.chatRoomProvider).hasValue) {
      final InputToast? toast = widget.getToast();
      if (toast != null) {
        toast.performAction();
        widget.closeToast();
      } else {
        ref
            .read(widget.chatRoomProvider.notifier)
            .sendMessage(username: widget.username, content: widget.textController.text);
      }

      FocusScope.of(context).unfocus();
      widget.textController.clear();
    }
  }

  void exitRoom() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EnterRoom()));
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
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
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
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
                        child: Directionality(
                          textDirection: ref.read(localeProvider.notifier).isArabic()
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: TextField(
                            controller: widget.textController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send_rounded),
                                onPressed: sendMessage,
                              ),
                              hintText: t.enterMessage,
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
