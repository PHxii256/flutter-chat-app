import 'package:chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:chat_app/features/conversations/bloc/conversations_cubit.dart';
import 'package:chat_app/features/conversations/bloc/conversations_state.dart';
import 'package:chat_app/features/conversations/data/repositories/conversations_repo.dart';
import 'package:chat_app/features/conversations/data/services/conversations_service.dart';
import 'package:chat_app/features/conversations/presentation/widgets/conversation_tile.dart';
import 'package:chat_app/features/auth/presentation/widgets/enter_room.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConversationsDiSetup(
      child: Scaffold(
        appBar: AppBar(title: Text("Your Conversations")),
        body: BlocBuilder<ConversationsCubit, ConversationsState>(
          builder: (context, state) {
            if (state is ConversationsError) {
              print(state.message);
            }

            return switch (state) {
              ConversationsLoaded(:final conversations) => ListView.builder(
                itemCount: conversations.length,
                itemBuilder: ((context, index) =>
                    ConversationTile(convoData: conversations[index])),
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
      ),
    );
  }
}

class ConversationsDiSetup extends StatelessWidget {
  final Widget child;
  const ConversationsDiSetup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ConversationsService>(
          create: (context) => ConversationsService(context.read<Dio>()),
        ),
        RepositoryProvider<ConversationsRepository>(
          create: (context) => ConversationsRepository(context.read<ConversationsService>()),
        ),
      ],
      child: BlocProvider(
        create: (context) {
          final cubit = ConversationsCubit(
            authRepository: context.read<AuthRepository>(),
            conversationsRepository: context.read<ConversationsRepository>(),
          );
          cubit.loadConversations();
          return cubit;
        },
        child: child,
      ),
    );
  }
}
