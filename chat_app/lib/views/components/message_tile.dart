// ignore_for_file: avoid_print

import 'package:chat_app/models/message_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class MessageTile extends ConsumerStatefulWidget {
  final String roomCode;
  final String currentUsername;
  final MessageData message;
  final int index;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Function(MessageData message, String emoji)? onReactionRemove;

  const MessageTile({
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
    if (state is _MessageTileState) {
      state.highlight();
    }
  }

  @override
  ConsumerState<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends ConsumerState<MessageTile> {
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

  String? _getMessage() {
    if (widget.message.senderId == 'Server') {
      return widget.message.content;
    } else {
      return "${widget.message.username}: ${widget.message.content}";
    }
  }

  String _getMessageTime() {
    return DateFormat('h:mm a').format(widget.message.createdAt);
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
            // Only allow removing own reactions
            if (hasUserReacted && widget.onReactionRemove != null) {
              print('Calling onReactionRemove for $emoji');
              widget.onReactionRemove!(widget.message, emoji);
            } else {
              print(
                'Cannot remove reaction: hasUserReacted=$hasUserReacted, callback=${widget.onReactionRemove != null}',
              );
            }
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
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply indicator (if exists) - full width above everything
              if (widget.message.replyTo != null)
                Padding(
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
                          "Replying to: \"${widget.message.replyTo!.content}\"",
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
                ),
              // Main message row - timestamp and message content always aligned
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Time column - fixed width for consistent alignment
                  SizedBox(
                    width: 60,
                    child: Text(
                      _getMessageTime(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  // Message content
                  Expanded(
                    child: Text(
                      _getMessage() ?? 'anon',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
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
