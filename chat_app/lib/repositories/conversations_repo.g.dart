// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_repo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conversationsRepository)
const conversationsRepositoryProvider = ConversationsRepositoryProvider._();

final class ConversationsRepositoryProvider
    extends
        $FunctionalProvider<
          ConversationsRepository,
          ConversationsRepository,
          ConversationsRepository
        >
    with $Provider<ConversationsRepository> {
  const ConversationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConversationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationsRepository create(Ref ref) {
    return conversationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationsRepository>(value),
    );
  }
}

String _$conversationsRepositoryHash() =>
    r'05f5c26e3b095486babeb6f02c3b1b81c3de4d73';
