import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/chat/providers/toast_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

abstract class InputToast extends ConsumerWidget {
  final String message;
  final IconData icon;
  const InputToast({super.key, required this.message, required this.icon});

  void performAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 20,
      child: Row(
        spacing: 4,
        children: [
          Icon(icon, size: 20, fontWeight: FontWeight.bold, opticalSize: 1),
          Text(message, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Spacer(),
          GestureDetector(
            onTap: () {
              ref.read(toastProvider.notifier).setToast(null);
            },
            child: Icon(Symbols.close, size: 20, fontWeight: FontWeight.bold, opticalSize: 1),
          ),
        ],
      ),
    );
  }
}

class ReplyToast extends InputToast {
  final MessageData messageRepliedTo;
  final Function sendReply;

  const ReplyToast({
    super.key,
    required this.sendReply,
    required this.messageRepliedTo,
    required String replyToText,
  }) : super(message: replyToText, icon: Symbols.reply);

  @override
  void performAction() => sendReply();
}

class EditToast extends InputToast {
  final Function sendEdit;

  const EditToast({super.key, required this.sendEdit, required String editingText})
    : super(message: editingText, icon: Symbols.edit);

  @override
  void performAction() => sendEdit();
}
