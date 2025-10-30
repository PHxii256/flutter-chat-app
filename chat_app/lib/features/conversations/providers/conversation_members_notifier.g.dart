// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_members_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationMembers)
const conversationMembersProvider = ConversationMembersFamily._();

final class ConversationMembersProvider
    extends $AsyncNotifierProvider<ConversationMembers, List<User>> {
  const ConversationMembersProvider._({
    required ConversationMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationMembersHash();

  @override
  String toString() {
    return r'conversationMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConversationMembers create() => ConversationMembers();

  @override
  bool operator ==(Object other) {
    return other is ConversationMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationMembersHash() =>
    r'261d04809bd69d99295d2bca4dfc0c207c81273c';

final class ConversationMembersFamily extends $Family
    with
        $ClassFamilyOverride<
          ConversationMembers,
          AsyncValue<List<User>>,
          List<User>,
          FutureOr<List<User>>,
          String
        > {
  const ConversationMembersFamily._()
    : super(
        retry: null,
        name: r'conversationMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversationMembersProvider call(String roomCode) =>
      ConversationMembersProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'conversationMembersProvider';
}

abstract class _$ConversationMembers extends $AsyncNotifier<List<User>> {
  late final _$args = ref.$arg as String;
  String get roomCode => _$args;

  FutureOr<List<User>> build(String roomCode);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<User>>, List<User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<User>>, List<User>>,
              AsyncValue<List<User>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
