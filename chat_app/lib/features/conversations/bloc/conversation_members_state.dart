import 'package:chat_app/features/chat/data/models/user_model.dart';

sealed class ConversationMembersState {
  const ConversationMembersState();
}

class ConversationMembersInitial extends ConversationMembersState {
  const ConversationMembersInitial();
}

class ConversationMembersLoading extends ConversationMembersState {
  const ConversationMembersLoading();
}

class ConversationMembersLoaded extends ConversationMembersState {
  final List<User> members;
  const ConversationMembersLoaded({required this.members});
}

class ConversationMembersError extends ConversationMembersState {
  final String message;
  const ConversationMembersError({required this.message});
}
