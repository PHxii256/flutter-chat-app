import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

abstract class InputToast extends StatelessWidget {
  final VoidCallback closeCallback;
  final String message;
  final IconData icon;
  const InputToast({
    super.key,
    required this.closeCallback,
    required this.message,
    required this.icon,
  });

  void performAction();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        spacing: 4,
        children: [
          Icon(icon, size: 20, fontWeight: FontWeight.bold, opticalSize: 1),
          Text(message, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

class ReplyToast extends InputToast {
  final String? replyToUsername;
  const ReplyToast({super.key, required super.closeCallback, required this.replyToUsername})
    : super(message: "Reply To $replyToUsername", icon: Symbols.reply);

  @override
  void performAction() {}
}

class EditToast extends InputToast {
  const EditToast({super.key, required super.closeCallback})
    : super(message: "Editing Message", icon: Symbols.edit);

  @override
  void performAction() {}
}
