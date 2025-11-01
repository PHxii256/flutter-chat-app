// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/chat/bloc/chat_room_cubit.dart';
import 'package:chat_app/features/localization/bloc/locale_cubit.dart';
import 'package:chat_app/features/chat/bloc/toast_cubit.dart';
import 'package:chat_app/features/chat/widgets/chat_media_picker.dart';
import 'package:chat_app/features/chat/widgets/input_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreenInput extends StatefulWidget {
  final TextEditingController textController;
  final String roomCode;
  const ChatScreenInput({super.key, required this.textController, required this.roomCode});

  @override
  State<ChatScreenInput> createState() => _ChatScreenInputState();
}

class _ChatScreenInputState extends State<ChatScreenInput> {
  void sendMessage() {
    if (widget.textController.text.isNotEmpty) {
      final chatRoomState = context.read<ChatRoomCubit>().state;
      if (chatRoomState is ChatRoomLoaded) {
        final InputToast? toast = context.read<ToastCubit>().getToast();
        if (toast != null) {
          toast.performAction();
          context.read<ToastCubit>().setToast(null);
        } else {
          context.read<ChatRoomCubit>().sendMessage(content: widget.textController.text);
        }

        FocusScope.of(context).unfocus();
        widget.textController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);

    return BlocBuilder<ToastCubit, InputToast?>(
      builder: (context, currentToast) {
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
                            textController: widget.textController,
                            roomCode: widget.roomCode,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: BlocBuilder<LocaleCubit, Locale>(
                              builder: (context, locale) {
                                return Directionality(
                                  textDirection: context.read<LocaleCubit>().isArabic()
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
                                );
                              },
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
      },
    );
  }
}
