import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/gallery_media.dart';

abstract class MediaRepository {
  /// 獲取相簿分類的圖片
  Future<List<GalleryMedia>> getTagSearchMedia(List<int> tagIds);

  Future<void> uploadGalleryMedia({
    required String uploadType,
    required int galleryTypeId,
    required File file,
    required String fileName,
    required List<int> tagsId,
    ProgressCallback? onSendProgress,
  });
}
