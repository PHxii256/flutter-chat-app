import 'package:chat_app/view_models/conversations_notifier.dart';
import 'package:chat_app/views/components/conversation_tile.dart';
import 'package:chat_app/views/components/enter_room.dart';
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
          itemBuilder: ((context, index) => ConversationTile(convoData: value[index])),
        ),
        AsyncLoading() => Center(
          child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
        ),
        AsyncError(error: final error) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Error loading conversation history :/, message: ${error.toString()}"),
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
