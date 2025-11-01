import 'package:chat_app/features/conversations/models/conversations_data.dart';
import 'package:chat_app/features/auth/bloc/auth_cubit.dart';
import 'package:chat_app/features/conversations/bloc/conversations_cubit.dart';
import 'package:chat_app/features/chat/pages/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationTile extends StatelessWidget {
  final ConversationsData convoData;
  const ConversationTile({super.key, required this.convoData});

  @override
  Widget build(BuildContext context) {
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
        final username = context.read<AuthCubit>().getCurrentUser()?.username;
        if (username != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatRoom(username: username, roomCode: convoData.roomCode),
            ),
          );
        }
      },
      subtitle: FutureBuilder<String>(
        future: context.read<ConversationsCubit>().getFormattedLastMessage(convoData.lastMessage),
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
