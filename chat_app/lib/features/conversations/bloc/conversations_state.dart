import 'package:chat_app/features/conversations/data/models/conversations_data.dart';

sealed class ConversationsState {
  const ConversationsState();
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationsData> conversations;
  const ConversationsLoaded({required this.conversations});
}

class ConversationsError extends ConversationsState {
  final String message;
  const ConversationsError({required this.message});
}
