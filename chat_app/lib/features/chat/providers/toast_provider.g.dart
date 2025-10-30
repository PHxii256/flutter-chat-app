// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ToastNotifier)
const toastProvider = ToastNotifierProvider._();

final class ToastNotifierProvider
    extends $NotifierProvider<ToastNotifier, InputToast?> {
  const ToastNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toastProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toastNotifierHash();

  @$internal
  @override
  ToastNotifier create() => ToastNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InputToast? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InputToast?>(value),
    );
  }
}

String _$toastNotifierHash() => r'39b73029aa26a5e7b05fbf11dcd3bee8c331c275';

abstract class _$ToastNotifier extends $Notifier<InputToast?> {
  InputToast? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<InputToast?, InputToast?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InputToast?, InputToast?>,
              InputToast?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
