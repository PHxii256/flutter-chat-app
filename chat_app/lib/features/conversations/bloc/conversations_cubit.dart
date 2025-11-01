import 'package:chat_app/features/conversations/models/conversations_data.dart';
import 'package:chat_app/features/conversations/models/message_preview_data.dart';
import 'package:chat_app/features/chat/models/user_model.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:chat_app/features/conversations/repositories/conversations_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

// States
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

// Cubit
class ConversationsCubit extends Cubit<ConversationsState> {
  final AuthRepository _authRepository;
  final ConversationsRepository _conversationsRepository;

  ConversationsCubit({
    required AuthRepository authRepository,
    required ConversationsRepository conversationsRepository,
  }) : _authRepository = authRepository,
       _conversationsRepository = conversationsRepository,
       super(const ConversationsInitial());

  Future<void> loadConversations() async {
    emit(const ConversationsLoading());

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        final list = await _conversationsRepository.getChatrooms(user.id);
        print(list);
        emit(ConversationsLoaded(conversations: list));
      } else {
        print("user is null");
        emit(const ConversationsLoaded(conversations: []));
      }
    } catch (e) {
      emit(ConversationsError(message: e.toString()));
    }
  }

  Future<User?> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  Future<List<User>> getConversationMembers(String roomCode) async {
    final currentState = state;
    if (currentState is! ConversationsLoaded) return [];

    final convo = currentState.conversations.firstWhereOrNull((c) => c.roomCode == roomCode);
    if (convo == null) return Future.error(Exception("couldn't get members"));
    return convo.memberList;
  }

  /// Refresh the conversations list
  Future<void> refresh() async {
    await loadConversations();
  }

  Future<String> getFormattedLastMessage(MessagePreviewData? lastMessage) async {
    if (lastMessage != null) {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        if (currentUser.id == lastMessage.senderId) return "you sent: ${lastMessage.content}";
      }
      return "${lastMessage.username}: ${lastMessage.content}";
    }
    return "No Messages Yet, Say Hi!";
  }
}
