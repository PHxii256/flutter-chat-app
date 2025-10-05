// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conversationsService)
const conversationsServiceProvider = ConversationsServiceProvider._();

final class ConversationsServiceProvider
    extends
        $FunctionalProvider<
          ConversationsService,
          ConversationsService,
          ConversationsService
        >
    with $Provider<ConversationsService> {
  const ConversationsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsServiceHash();

  @$internal
  @override
  $ProviderElement<ConversationsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationsService create(Ref ref) {
    return conversationsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationsService>(value),
    );
  }
}

String _$conversationsServiceHash() =>
    r'b10e640906e633387cffccfbd8665072d31f87ba';
