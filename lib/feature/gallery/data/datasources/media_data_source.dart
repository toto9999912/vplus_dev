import 'dart:io';

import 'package:dio/dio.dart';

import '../dtos/gallery_media_dto.dart';

abstract class MediaDataSource {
  Future<List<GalleryMediaDto>> getTagSearchMedia(List<int> tagIds);

  Future<void> uploadGalleryMedia({
    required String uploadType,
    required int galleryTypeId,
    required File file,
    required String fileName,
    required List<int> tagsId,
    ProgressCallback? onSendProgress,
  });
}
