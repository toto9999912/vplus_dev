import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_dev/shared/enum/media_type.dart';

import '../../domain/entities/gallery_media.dart';

/// 處理不同類型媒體顯示的可重用元件
class MediaDisplayWidget extends StatelessWidget {
  final GalleryMedia media;

  const MediaDisplayWidget({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return switch (media.mediaType) {
      MediaType.image => _buildImageDisplay(),
      MediaType.video => _buildVideoDisplay(),
      MediaType.file => _buildFileDisplay(),
      MediaType.link => _buildLinkDisplay(),
    };
  }

  Widget _buildImageDisplay() {
    return SizedBox.expand(
      child: Image.network(media.image?.smallAddressUrl ?? '', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildErrorWidget()),
    );
  }

  Widget _buildVideoDisplay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          media.video?.thumbnailUrl ?? '',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
        Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill, size: 48, color: Colors.grey[300]))),
      ],
    );
  }

  Widget _buildFileDisplay() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(media.title)]),
    );
  }

  Widget _buildLinkDisplay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          media.link?.thumbnailUrl ?? '',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
        const Positioned(right: 6, top: 6, child: Icon(FontAwesomeIcons.link, color: Colors.white, size: 18)),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(color: Colors.grey[300], alignment: Alignment.center, child: const Icon(Icons.broken_image, size: 48, color: Colors.grey));
  }
}
