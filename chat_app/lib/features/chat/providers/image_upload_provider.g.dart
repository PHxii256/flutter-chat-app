// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(uploadImages)
const uploadImagesProvider = UploadImagesFamily._();

final class UploadImagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ImageUploadResult>,
          ImageUploadResult,
          FutureOr<ImageUploadResult>
        >
    with
        $FutureModifier<ImageUploadResult>,
        $FutureProvider<ImageUploadResult> {
  const UploadImagesProvider._({
    required UploadImagesFamily super.from,
    required ({
      List<XFile> images,
      String roomCode,
      String? content,
      ReplyTo? replyTo,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'uploadImagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$uploadImagesHash();

  @override
  String toString() {
    return r'uploadImagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ImageUploadResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ImageUploadResult> create(Ref ref) {
    final argument =
        this.argument
            as ({
              List<XFile> images,
              String roomCode,
              String? content,
              ReplyTo? replyTo,
            });
    return uploadImages(
      ref,
      images: argument.images,
      roomCode: argument.roomCode,
      content: argument.content,
      replyTo: argument.replyTo,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UploadImagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadImagesHash() => r'c54098d8597229634097cb4888e54dfff5bf2243';

final class UploadImagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ImageUploadResult>,
          ({
            List<XFile> images,
            String roomCode,
            String? content,
            ReplyTo? replyTo,
          })
        > {
  const UploadImagesFamily._()
    : super(
        retry: null,
        name: r'uploadImagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UploadImagesProvider call({
    required List<XFile> images,
    required String roomCode,
    String? content,
    ReplyTo? replyTo,
  }) => UploadImagesProvider._(
    argument: (
      images: images,
      roomCode: roomCode,
      content: content,
      replyTo: replyTo,
    ),
    from: this,
  );

  @override
  String toString() => r'uploadImagesProvider';
}
