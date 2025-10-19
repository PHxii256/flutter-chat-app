// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/services/image_upload_service.dart';
import 'package:chat_app/services/token_storage_service.dart';
import 'package:chat_app/utils/image_picker_helper.dart';
import 'package:chat_app/view_models/auth_view_model.dart';
import 'package:chat_app/view_models/chat_room_notifier.dart';
import 'package:chat_app/view_models/locale_notifier.dart';
import 'package:chat_app/views/components/chat_media_picker.dart';
import 'package:chat_app/views/components/input_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
                      ChatMediaPicker(
                        chatRoomProvider: widget.chatRoomProvider,
                        textController: widget.textController,
                        username: widget.username,
                        roomCode: widget.roomCode,
                        getToast: widget.getToast,
                        closeToast: widget.closeToast,
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
