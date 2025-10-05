import 'package:chat_app/view_models/auth_view_model.dart';
import 'package:chat_app/view_models/conversations_notifier.dart';
import 'package:chat_app/views/components/enter_room.dart';
import 'package:chat_app/views/pages/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationList = ref.watch(conversationsProvider);

    if (conversationList.hasError) {
      print(conversationList.asError);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Your Coversations")),
      body: switch (conversationList) {
        AsyncValue(:final value?) => ListView.builder(
          itemCount: value.length,
          itemBuilder: ((context, index) => ChatroomTile(roomCode: value[index].roomCode)),
        ),
        AsyncLoading() => Center(
          child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
        ),
        AsyncError(error: final error, stackTrace: final stackTrace) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "error loading conversation history :/, error message: ${error.toString()}, stack trace: ${stackTrace.toString()}",
          ),
        ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
                child: EnterRoom(closeDialog: () => Navigator.of(context).pop()),
              ),
            ),
          ),
        ),
        child: Icon(Icons.chat),
      ),
    );
  }
}

class ChatroomTile extends ConsumerWidget {
  final String roomCode;
  const ChatroomTile({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      minTileHeight: 70,
      leading: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(255, 45, 29, 50),
        ),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(Icons.group_outlined, color: const Color.fromARGB(255, 141, 19, 131)),
        ),
      ),
      title: Text("Chatroom #$roomCode", style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoom(
              username: ref.read(authViewModelProvider.notifier).getCurrentUser()!.username,
              roomCode: roomCode,
            ),
          ),
        );
      },
      subtitle: Text("Welcome vro!"),
      trailing: SizedBox(
        width: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(TimeOfDay.now().format(context)),
              "1" == "1"
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SizedBox(
                          child: Text(
                            "12",
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
