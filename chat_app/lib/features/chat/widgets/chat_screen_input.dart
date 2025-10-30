// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/chat/providers/chat_room_notifier.dart';
import 'package:chat_app/features/localization/providers/locale_notifier.dart';
import 'package:chat_app/features/chat/providers/toast_provider.dart';
import 'package:chat_app/features/chat/widgets/chat_media_picker.dart';
import 'package:chat_app/features/chat/widgets/input_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreenInput extends ConsumerStatefulWidget {
  final TextEditingController textController;
  final ChatRoomNotifierProvider chatRoomProvider;
  final String roomCode;
  const ChatScreenInput({
    super.key,
    required this.chatRoomProvider,
    required this.textController,
    required this.roomCode,
  });

  @override
  ConsumerState<ChatScreenInput> createState() => _ChatScreenInputState();
}

class _ChatScreenInputState extends ConsumerState<ChatScreenInput> {
  void sendMessage() {
    if (widget.textController.text.isNotEmpty && ref.read(widget.chatRoomProvider).hasValue) {
      final InputToast? toast = ref.read(toastProvider.notifier).getToast();
      if (toast != null) {
        toast.performAction();
        ref.read(toastProvider.notifier).setToast(null);
      } else {
        ref.read(widget.chatRoomProvider.notifier).sendMessage(content: widget.textController.text);
      }

      FocusScope.of(context).unfocus();
      widget.textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final currentToast = ref.watch(toastProvider);

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        alignment: AlignmentGeometry.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              width: 2.0,
              color: currentToast != null ? Colors.black12 : Colors.transparent,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 8,
              children: [
                currentToast ?? Container(),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      ChatMediaPicker(
                        chatRoomProvider: widget.chatRoomProvider,
                        textController: widget.textController,
                        roomCode: widget.roomCode,
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
