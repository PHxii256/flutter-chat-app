import 'package:chat_app/models/conversations_data.dart';
import 'package:chat_app/repositories/auth_repository.dart';
import 'package:chat_app/repositories/conversations_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'conversations_notifier.g.dart';

@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  Future<List<ConversationsData>> build() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user != null) {
      return await ref.read(conversationsRepositoryProvider).getChatrooms(user.id);
    }
    return [];
  }
}
