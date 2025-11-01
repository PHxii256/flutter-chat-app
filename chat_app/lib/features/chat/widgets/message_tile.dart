// ignore_for_file: avoid_print
import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:chat_app/features/chat/bloc/chat_room_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class MessageTile extends StatefulWidget {
  final String roomCode;
  final String currentUsername;
  final MessageData message;
  final int index;
  final VoidCallback onLongPress;
  final Function(String messageId) jumpToMessage;
  final Widget content;

  const MessageTile({
    super.key,
    required this.roomCode,
    required this.currentUsername,
    required this.message,
    required this.index,
    required this.onLongPress,
    required this.jumpToMessage,
    required this.content,
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

  void jumpToRepliedToMessage(MessageData msg) {
    if (msg.replyTo == null) return;
    final id = msg.replyTo!.messageId;
    widget.jumpToMessage(id);
  }

  String _getMessageTime() {
    return DateFormat('h:mm a').format(widget.message.createdAt);
  }

  String _clampText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildReactions() {
    if (widget.message.reactions.isEmpty) {
      return Container();
    }

    // Group reactions by emoji
    Map<String, List<MessageReact>> reactionGroups = {};
    for (var reaction in widget.message.reactions) {
      reactionGroups.putIfAbsent(reaction.emoji, () => []).add(reaction);
    }

    return Wrap(
      spacing: 4,
      children: reactionGroups.entries.map((entry) {
        final emoji = entry.key;
        final reactions = entry.value;
        final count = reactions.length;
        final hasUserReacted = reactions.any((r) => r.senderUsername == widget.currentUsername);

        return InkWell(
          onTap: () {
            if (!mounted) return;
            print('Reaction tapped: $emoji, hasUserReacted: $hasUserReacted');
            context.read<ChatRoomCubit>().reactToMessage(message: widget.message, emoji: emoji);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: hasUserReacted
                  ? Theme.of(context).primaryColor.withAlpha(50)
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: hasUserReacted
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: TextStyle(fontSize: 13)),
                SizedBox(width: 2),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: hasUserReacted
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: hasUserReacted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageTime() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: SizedBox(
        width: 60,
        child: Text(
          _getMessageTime(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyIndicator() {
    if (widget.message.replyTo == null) return Container();
    final t = S.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 60, bottom: 4), // Align with message content
      child: Row(
        children: [
          Transform.flip(
            flipX: true,
            child: Icon(
              Symbols.reply_rounded,
              size: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              weight: 600,
            ),
          ),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              t.replyingTo(_clampText(widget.message.replyTo!.content, 12)),
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Check if reactions exist
    if (widget.message.reactions.isNotEmpty) {
      print('Message ${widget.message.id} has ${widget.message.reactions.length} reactions');
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(_highlightOpacity)),
      child: InkWell(
        onTap: () => jumpToRepliedToMessage(widget.message),
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReplyIndicator(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageTime(),
                  Expanded(child: widget.content),
                ],
              ),
              if (widget.message.reactions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 60, top: 4), // Align with message content
                  child: _buildReactions(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
