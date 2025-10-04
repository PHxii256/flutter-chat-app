// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_cache_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userCacheService)
const userCacheServiceProvider = UserCacheServiceProvider._();

final class UserCacheServiceProvider
    extends
        $FunctionalProvider<
          UserCacheService,
          UserCacheService,
          UserCacheService
        >
    with $Provider<UserCacheService> {
  const UserCacheServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userCacheServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userCacheServiceHash();

  @$internal
  @override
  $ProviderElement<UserCacheService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserCacheService create(Ref ref) {
    return userCacheService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserCacheService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserCacheService>(value),
    );
  }
}

String _$userCacheServiceHash() => r'4196c5739ec1637da6dd4a9cf603452c41efaf17';
