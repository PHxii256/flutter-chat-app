import 'package:chat_app/models/conversations_data.dart';
import 'package:chat_app/view_models/auth_view_model.dart';
import 'package:chat_app/view_models/conversations_notifier.dart';
import 'package:chat_app/views/pages/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationTile extends ConsumerWidget {
  final ConversationsData convoData;
  const ConversationTile({super.key, required this.convoData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      minTileHeight: 70,
      leading: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(255, 45, 29, 50),
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.group_outlined, color: const Color.fromARGB(255, 141, 19, 131)),
          ),
        ),
      ),
      title: Text("Chatroom #${convoData.roomCode}", style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoom(
              username: ref.read(authViewModelProvider.notifier).getCurrentUser()!.username,
              roomCode: convoData.roomCode,
            ),
          ),
        );
      },
      subtitle: FutureBuilder<String>(
        future: ref
            .read(conversationsProvider.notifier)
            .getFormatedLastMessage(convoData.lastMessage),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ?? "",
            style: convoData.lastMessage == null ? TextStyle(fontStyle: FontStyle.italic) : null,
          );
        },
      ),
      trailing: SizedBox(
        width: 60,
        child: convoData.lastMessage != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(TimeOfDay.fromDateTime(convoData.lastMessage!.createdAt).format(context)),
                    SizedBox(
                      height: 30,
                      child: convoData.unreadCount > 0
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  convoData.unreadCount.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
