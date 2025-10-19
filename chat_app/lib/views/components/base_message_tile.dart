// ignore_for_file: avoid_print

import 'package:chat_app/generated/l10n.dart';
import 'package:chat_app/models/message_data.dart';
import 'package:chat_app/view_models/chat_room_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

abstract class BaseMessageTile extends ConsumerStatefulWidget {
  final String roomCode;
  final String currentUsername;
  final MessageData message;
  final int index;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Function(MessageData message, String emoji)? onReactionRemove;

  const BaseMessageTile({
    super.key,
    required this.roomCode,
    required this.currentUsername,
    required this.message,
    required this.index,
    required this.onLongPress,
    required this.onTap,
    this.onReactionRemove,
  });

  /// Static method to trigger highlight on a MessageTile via GlobalKey
  static void highlightByKey(GlobalKey key) {
    final state = key.currentState;
    if (state is BaseMessageTileState) {
      state.highlight();
    }
  }
}

abstract class BaseMessageTileState<T extends BaseMessageTile> extends ConsumerState<T> {
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
            print('Reaction tapped: $emoji, hasUserReacted: $hasUserReacted');
            ref
                .read(
                  chatRoomProvider(
                    roomCode: widget.roomCode,
                    username: widget.currentUsername,
                  ).notifier,
                )
                .reactToMessage(
                  message: widget.message,
                  senderUsername: widget.currentUsername,
                  emoji: emoji,
                );
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

  /// Abstract method to be implemented by specific tile types
  Widget buildMessageContent();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(_highlightOpacity)),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply indicator (if exists)
              _buildReplyIndicator(),
              // Main message content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time column - fixed width for consistent alignment
                  Padding(
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
                  ),
                  // Message content (delegated to specific implementations)
                  Expanded(child: buildMessageContent()),
                ],
              ),
              // Reactions row (if any)
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
