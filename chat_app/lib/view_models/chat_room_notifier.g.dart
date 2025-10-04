// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatRoomNotifier)
const chatRoomProvider = ChatRoomNotifierFamily._();

final class ChatRoomNotifierProvider
    extends $AsyncNotifierProvider<ChatRoomNotifier, List<MessageData>> {
  const ChatRoomNotifierProvider._({
    required ChatRoomNotifierFamily super.from,
    required ({String username, String roomCode}) super.argument,
  }) : super(
         retry: null,
         name: r'chatRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatRoomNotifierHash();

  @override
  String toString() {
    return r'chatRoomProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatRoomNotifier create() => ChatRoomNotifier();

  @override
  bool operator ==(Object other) {
    return other is ChatRoomNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatRoomNotifierHash() => r'09ae4003050c5303e3de22f83999ea118c82c15d';

final class ChatRoomNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatRoomNotifier,
          AsyncValue<List<MessageData>>,
          List<MessageData>,
          FutureOr<List<MessageData>>,
          ({String username, String roomCode})
        > {
  const ChatRoomNotifierFamily._()
    : super(
        retry: null,
        name: r'chatRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatRoomNotifierProvider call({
    required String username,
    required String roomCode,
  }) => ChatRoomNotifierProvider._(
    argument: (username: username, roomCode: roomCode),
    from: this,
  );

  @override
  String toString() => r'chatRoomProvider';
}

abstract class _$ChatRoomNotifier extends $AsyncNotifier<List<MessageData>> {
  late final _$args = ref.$arg as ({String username, String roomCode});
  String get username => _$args.username;
  String get roomCode => _$args.roomCode;

  FutureOr<List<MessageData>> build({
    required String username,
    required String roomCode,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(username: _$args.username, roomCode: _$args.roomCode);
    final ref =
        this.ref as $Ref<AsyncValue<List<MessageData>>, List<MessageData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MessageData>>, List<MessageData>>,
              AsyncValue<List<MessageData>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
