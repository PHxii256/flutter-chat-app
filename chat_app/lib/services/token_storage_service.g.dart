// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureStorage)
const secureStorageProvider = SecureStorageProvider._();

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  const SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'273dc403a965c1f24962aaf4d40776611a26f8b8';

@ProviderFor(tokenStorageService)
const tokenStorageServiceProvider = TokenStorageServiceProvider._();

final class TokenStorageServiceProvider
    extends
        $FunctionalProvider<
          TokenStorageService,
          TokenStorageService,
          TokenStorageService
        >
    with $Provider<TokenStorageService> {
  const TokenStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStorageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStorageServiceHash();

  @$internal
  @override
  $ProviderElement<TokenStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TokenStorageService create(Ref ref) {
    return tokenStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStorageService>(value),
    );
  }
}

String _$tokenStorageServiceHash() =>
    r'f986848aae53ba12deddadfb0ca6a2db566f5d95';
