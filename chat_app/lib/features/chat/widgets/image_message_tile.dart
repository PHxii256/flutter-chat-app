import 'package:chat_app/features/chat/models/message_data.dart';
import 'package:flutter/material.dart';

class ImageMessageContent extends StatelessWidget {
  final ImageMessageData message;

  const ImageMessageContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return _buildImageGrid(context);
  }

  Widget _buildImageGrid(BuildContext context) {
    final images = message.imageData;

    if (images.isEmpty) {
      return ErrorImageWidget(context: context, message: 'No images available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${message.username}:", style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 8),
        if (message.content != null && message.content!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(message.content!, style: Theme.of(context).textTheme.bodyMedium),
          ),
        // Images grid
        Builder(
          builder: (context) {
            switch (images.length) {
              case 1:
                return SingleImageLayout(image: images.first);
              case 2:
                return TwoImageLayout(images: images);
              case 3:
                return ThreeImageLayout(images: images);
              default:
                return MultiImageLayout(images: images);
            }
          },
        ),
      ],
    );
  }
}

class CustomNetworkImage extends StatelessWidget {
  final ImageData image;
  const CustomNetworkImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.url.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 32,
              ),
              SizedBox(height: 4),
              Text(
                'No image URL',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Replace localhost with Android emulator host IP
    String imageUrl = image.url.replaceFirst('localhost', '10.0.2.2');

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print(error);
        return Container(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 32),
                SizedBox(height: 4),
                Text(
                  'Failed to load',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SingleImageLayout extends StatelessWidget {
  final ImageData image;
  const SingleImageLayout({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250, maxHeight: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomNetworkImage(image: image),
      ),
    );
  }
}

class TwoImageLayout extends StatelessWidget {
  final List<ImageData> images;
  const TwoImageLayout({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: AspectRatio(aspectRatio: 1, child: CustomNetworkImage(image: images[0])),
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: AspectRatio(aspectRatio: 1, child: CustomNetworkImage(image: images[1])),
            ),
          ),
        ],
      ),
    );
  }
}

class ThreeImageLayout extends StatelessWidget {
  final List<ImageData> images;
  const ThreeImageLayout({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: AspectRatio(aspectRatio: 2, child: CustomNetworkImage(image: images[0])),
          ),
          SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                  child: AspectRatio(aspectRatio: 1, child: CustomNetworkImage(image: images[1])),
                ),
              ),
              SizedBox(width: 2),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                  child: AspectRatio(aspectRatio: 1, child: CustomNetworkImage(image: images[2])),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MultiImageLayout extends StatelessWidget {
  final List<ImageData> images;
  const MultiImageLayout({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: Column(
        children: [
          // First image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: AspectRatio(aspectRatio: 2, child: CustomNetworkImage(image: images[0])),
          ),
          SizedBox(height: 2),
          // Second row with up to 2 images
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                  child: AspectRatio(aspectRatio: 1, child: CustomNetworkImage(image: images[1])),
                ),
              ),
              SizedBox(width: 2),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: images.length > 2
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomNetworkImage(image: images[2]),
                              if (images.length > 3)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${images.length - 3}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Container(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ErrorImageWidget extends StatelessWidget {
  final String message;
  const ErrorImageWidget({super.key, required this.context, required this.message});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
          SizedBox(width: 8),
          Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
        ],
      ),
    );
  }
}
