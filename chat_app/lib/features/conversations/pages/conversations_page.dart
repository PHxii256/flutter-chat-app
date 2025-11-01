import 'package:chat_app/features/conversations/bloc/conversations_cubit.dart';
import 'package:chat_app/features/conversations/widgets/conversation_tile.dart';
import 'package:chat_app/features/auth/presentation/widgets/enter_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    // Load conversations when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationsCubit>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Conversations")),
      body: BlocBuilder<ConversationsCubit, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsError) {
            print(state.message);
          }

          return switch (state) {
            ConversationsLoaded(:final conversations) => ListView.builder(
              itemCount: conversations.length,
              itemBuilder: ((context, index) => ConversationTile(convoData: conversations[index])),
            ),
            ConversationsLoading() => Center(
              child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
            ),
            ConversationsError(:final message) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Error loading conversation history :/, message: $message"),
            ),
            ConversationsInitial() => Center(
              child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
            ),
          };
        },
      ),
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
