// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationsNotifier)
const conversationsProvider = ConversationsNotifierProvider._();

final class ConversationsNotifierProvider
    extends
        $AsyncNotifierProvider<ConversationsNotifier, List<ConversationsData>> {
  const ConversationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsNotifierHash();

  @$internal
  @override
  ConversationsNotifier create() => ConversationsNotifier();
}

String _$conversationsNotifierHash() =>
    r'0f507596b7882afe8d17fcc9a3d512c4db385cbd';

abstract class _$ConversationsNotifier
    extends $AsyncNotifier<List<ConversationsData>> {
  FutureOr<List<ConversationsData>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ConversationsData>>,
              List<ConversationsData>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ConversationsData>>,
                List<ConversationsData>
              >,
              AsyncValue<List<ConversationsData>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
