// ignore_for_file: avoid_print

import 'package:chat_app/models/message_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

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

  /// Static method to trigger highlight on a MessageTile via GlobalKey
  static void highlightByKey(GlobalKey key) {
    final state = key.currentState;
    if (state is _MessageTileState) {
      state.highlight();
    }
  }

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
